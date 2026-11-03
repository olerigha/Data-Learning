import os
import requests
import streamlit as st
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

API_BASE_URL = os.environ.get("API_BASE_URL", "").rstrip("/")

# --------------------------------------------------------------------------- #
# Helpers                                                                      #
# --------------------------------------------------------------------------- #

def fetch(path: str, params: dict = None):
    """Call the API Gateway and return the data list / dict, or None on error."""
    url = f"{API_BASE_URL}{path}"
    try:
        resp = requests.get(url, params=params, timeout=10)
        resp.raise_for_status()
        payload = resp.json()
        return payload.get("data")
    except requests.exceptions.ConnectionError:
        st.error(f"Cannot reach API at {url}. Check API_BASE_URL in .env")
        return None
    except requests.exceptions.HTTPError as exc:
        st.error(f"API error {exc.response.status_code}: {exc.response.text}")
        return None
    except Exception as exc:
        st.error(f"Unexpected error: {exc}")
        return None


def show_table(data, title: str):
    if data is None:
        return
    if isinstance(data, dict):
        data = [data]
    if not data:
        st.info(f"No {title.lower()} found.")
        return
    df = pd.DataFrame(data)
    st.dataframe(df, width="stretch")
    return df


# --------------------------------------------------------------------------- #
# Page config                                                                  #
# --------------------------------------------------------------------------- #

st.set_page_config(
    page_title="ClassicModels Dashboard",
    page_icon="🚗",
    layout="wide",
)

st.title("🚗 ClassicModels – RDS Explorer")

if not API_BASE_URL:
    st.warning(
        "**API_BASE_URL is not set.**  "
        "Create a `.env` file with `API_BASE_URL=https://<api-id>.execute-api.<region>.amazonaws.com/prod`"
    )
    st.stop()

# --------------------------------------------------------------------------- #
# Sidebar                                                                      #
# --------------------------------------------------------------------------- #

st.sidebar.title("Navigation")
page = st.sidebar.radio(
    "Select a view",
    ["Summary", "Customers", "Products", "Orders", "Employees"],
)

limit = st.sidebar.slider("Row limit", min_value=10, max_value=200, value=50, step=10)

# --------------------------------------------------------------------------- #
# Summary page                                                                 #
# --------------------------------------------------------------------------- #

if page == "Summary":
    st.header("Database Summary")
    data = fetch("/summary")
    if data:
        col1, col2, col3, col4 = st.columns(4)
        col1.metric("Customers",  data.get("totalCustomers", "-"))
        col2.metric("Products",   data.get("totalProducts",  "-"))
        col3.metric("Orders",     data.get("totalOrders",    "-"))
        col4.metric("Employees",  data.get("totalEmployees", "-"))

# --------------------------------------------------------------------------- #
# Customers page                                                               #
# --------------------------------------------------------------------------- #

elif page == "Customers":
    st.header("Customers")

    search_id = st.text_input("Look up customer by ID (leave blank for all)")

    if search_id.strip():
        data = fetch(f"/customers/{search_id.strip()}")
        show_table(data, "customer")
    else:
        data = fetch("/customers", params={"limit": limit})
        df = show_table(data, "customers")

        if df is not None and not df.empty:
            st.subheader("Credit Limit by Country")
            country_credit = (
                df.groupby("country")["creditLimit"]
                .sum()
                .sort_values(ascending=False)
                .reset_index()
            )
            st.bar_chart(country_credit.set_index("country"))

# --------------------------------------------------------------------------- #
# Products page                                                                #
# --------------------------------------------------------------------------- #

elif page == "Products":
    st.header("Products")

    search_code = st.text_input("Look up product by code (e.g. S10_1678)")

    if search_code.strip():
        data = fetch(f"/products/{search_code.strip()}")
        show_table(data, "product")
    else:
        data = fetch("/products", params={"limit": limit})
        df = show_table(data, "products")

        if df is not None and not df.empty:
            st.subheader("Quantity In Stock by Product Line")
            line_stock = (
                df.groupby("productLine")["quantityInStock"]
                .sum()
                .sort_values(ascending=False)
                .reset_index()
            )
            st.bar_chart(line_stock.set_index("productLine"))

# --------------------------------------------------------------------------- #
# Orders page                                                                  #
# --------------------------------------------------------------------------- #

elif page == "Orders":
    st.header("Orders")

    search_order = st.text_input("Look up order by number (leave blank for all)")

    if search_order.strip():
        data = fetch(f"/orders/{search_order.strip()}")
        if data:
            st.subheader("Order Details")
            details = data.pop("orderDetails", [])
            show_table([data], "order")
            st.subheader("Line Items")
            show_table(details, "order details")
    else:
        data = fetch("/orders", params={"limit": limit})
        df = show_table(data, "orders")

        if df is not None and not df.empty and "orderDate" in df.columns:
            st.subheader("Orders Over Time")
            df["orderDate"] = pd.to_datetime(df["orderDate"])
            orders_by_month = (
                df.resample("ME", on="orderDate")
                .size()
                .reset_index(name="count")
            )
            st.line_chart(orders_by_month.set_index("orderDate"))

# --------------------------------------------------------------------------- #
# Employees page                                                               #
# --------------------------------------------------------------------------- #

elif page == "Employees":
    st.header("Employees")

    search_emp = st.text_input("Look up employee by ID")

    if search_emp.strip():
        data = fetch(f"/employees/{search_emp.strip()}")
        show_table(data, "employee")
    else:
        data = fetch("/employees")
        df = show_table(data, "employees")

        if df is not None and not df.empty:
            st.subheader("Employees by Office City")
            city_counts = (
                df["officeCity"].value_counts().reset_index()
            )
            city_counts.columns = ["city", "count"]
            st.bar_chart(city_counts.set_index("city"))
