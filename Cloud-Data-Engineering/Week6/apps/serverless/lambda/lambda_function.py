import json
import os
import logging
import pymysql
import pymysql.cursors

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# --------------------------------------------------------------------------- #
# DB connection (re-used across warm Lambda invocations)                      #
# --------------------------------------------------------------------------- #
_connection = None


def _get_connection():
    global _connection
    if _connection and _connection.open:
        return _connection
    _connection = pymysql.connect(
        host=os.environ["DB_HOST"],
        port=int(os.environ.get("DB_PORT", 3306)),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ.get("DB_NAME", "classicmodels"),
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=5,
        autocommit=True,
    )
    return _connection


def _query(sql, params=None):
    conn = _get_connection()
    with conn.cursor() as cur:
        cur.execute(sql, params or ())
        return cur.fetchall()


def _read_s3_object(bucket, key):
    import boto3

    response = boto3.client("s3").get_object(Bucket=bucket, Key=key)
    body = response["Body"].read()
    return body.decode("utf-8")


# --------------------------------------------------------------------------- #
# Route handlers                                                               #
# --------------------------------------------------------------------------- #

def get_customers(path_params, query_params):
    customer_id = path_params.get("id")
    if customer_id:
        rows = _query(
            "SELECT * FROM customers WHERE customerNumber = %s",
            (customer_id,),
        )
        return rows[0] if rows else None
    limit = int(query_params.get("limit", 50))
    return _query("SELECT * FROM customers LIMIT %s", (limit,))


def get_products(path_params, query_params):
    product_code = path_params.get("id")
    if product_code:
        rows = _query(
            "SELECT p.*, pl.textDescription AS productLineDescription "
            "FROM products p JOIN productlines pl USING (productLine) "
            "WHERE p.productCode = %s",
            (product_code,),
        )
        return rows[0] if rows else None
    limit = int(query_params.get("limit", 50))
    return _query(
        "SELECT p.*, pl.textDescription AS productLineDescription "
        "FROM products p JOIN productlines pl USING (productLine) "
        "LIMIT %s",
        (limit,),
    )


def get_orders(path_params, query_params):
    order_id = path_params.get("id")
    if order_id:
        order = _query(
            "SELECT o.*, c.customerName "
            "FROM orders o JOIN customers c USING (customerNumber) "
            "WHERE o.orderNumber = %s",
            (order_id,),
        )
        if not order:
            return None
        details = _query(
            "SELECT od.*, p.productName "
            "FROM orderdetails od JOIN products p USING (productCode) "
            "WHERE od.orderNumber = %s",
            (order_id,),
        )
        result = dict(order[0])
        result["orderDetails"] = details
        return result
    limit = int(query_params.get("limit", 50))
    return _query(
        "SELECT o.*, c.customerName "
        "FROM orders o JOIN customers c USING (customerNumber) "
        "ORDER BY o.orderDate DESC LIMIT %s",
        (limit,),
    )


def get_employees(path_params, query_params):
    emp_id = path_params.get("id")
    if emp_id:
        rows = _query(
            "SELECT e.*, o.city AS officeCity, o.country AS officeCountry "
            "FROM employees e JOIN offices o USING (officeCode) "
            "WHERE e.employeeNumber = %s",
            (emp_id,),
        )
        return rows[0] if rows else None
    return _query(
        "SELECT e.*, o.city AS officeCity, o.country AS officeCountry "
        "FROM employees e JOIN offices o USING (officeCode)"
    )


def get_summary(_path_params, _query_params):
    counts = _query(
        "SELECT "
        "(SELECT COUNT(*) FROM customers)  AS totalCustomers, "
        "(SELECT COUNT(*) FROM products)   AS totalProducts, "
        "(SELECT COUNT(*) FROM orders)     AS totalOrders, "
        "(SELECT COUNT(*) FROM employees)  AS totalEmployees"
    )
    return counts[0] if counts else {}


def get_object_preview(path_params, query_params):
    bucket = os.environ["RAW_BUCKET"]
    key = path_params.get("key")
    limit = int(query_params.get("limit", 5))
    content = _read_s3_object(bucket, key)
    return {
        "bucket": bucket,
        "key": key,
        "preview": content.splitlines()[:limit],
    }


# --------------------------------------------------------------------------- #
# Router                                                                       #
# --------------------------------------------------------------------------- #

ROUTES = {
    ("GET", "/customers"):       (get_customers, {}),
    ("GET", "/customers/{id}"):  (get_customers, {}),
    ("GET", "/products"):        (get_products,  {}),
    ("GET", "/products/{id}"):   (get_products,  {}),
    ("GET", "/orders"):          (get_orders,    {}),
    ("GET", "/orders/{id}"):     (get_orders,    {}),
    ("GET", "/employees"):       (get_employees, {}),
    ("GET", "/employees/{id}"):  (get_employees, {}),
    ("GET", "/summary"):         (get_summary,   {}),
    ("GET", "/objects/{key}"):   (get_object_preview, {}),
}


def _match_route(method, raw_path):
    """Return (handler, path_params) or (None, None)."""
    segments = raw_path.strip("/").split("/")
    for (route_method, route_pattern), (handler, _) in ROUTES.items():
        if route_method != method:
            continue
        pattern_segments = route_pattern.strip("/").split("/")
        if len(segments) != len(pattern_segments):
            continue
        params = {}
        match = True
        for pat, seg in zip(pattern_segments, segments):
            if pat.startswith("{") and pat.endswith("}"):
                params[pat[1:-1]] = seg
            elif pat != seg:
                match = False
                break
        if match:
            return handler, params
    return None, None


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS",
        },
        "body": json.dumps(body, default=str),
    }


# --------------------------------------------------------------------------- #
# Entry point                                                                  #
# --------------------------------------------------------------------------- #

def lambda_handler(event, context):
    logger.info("Event: %s", json.dumps(event))

    method = event.get("httpMethod") or event.get("requestContext", {}).get(
        "http", {}
    ).get("method", "GET")
    path = event.get("path") or event.get("rawPath", "/")
    query_params = event.get("queryStringParameters") or {}

    # CORS pre-flight
    if method == "OPTIONS":
        return _response(200, {})

    handler, path_params = _match_route(method, path)
    if handler is None:
        return _response(404, {"error": f"Route not found: {method} {path}"})

    try:
        data = handler(path_params, query_params)
        if data is None:
            return _response(404, {"error": "Record not found"})
        return _response(200, {"data": data})
    except pymysql.MySQLError as exc:
        logger.error("DB error: %s", exc)
        return _response(500, {"error": "Database error"})
    except Exception as exc:
        logger.error("Unexpected error: %s", exc)
        return _response(500, {"error": "Internal server error"})
