import os
import unittest
from fastapi.testclient import TestClient
from sqlalchemy import text

from ClassicFastAPI import app, engine


def is_mysql_available() -> bool:
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception:
        return False


class ClassicFastAPITest(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_root_endpoint(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertIn("message", body)
        self.assertIn("Classic Models", body["message"])
        self.assertEqual(body.get("database"), "MySQL")

    @unittest.skipUnless(is_mysql_available(), "MySQL database not accessible at DATABASE_URL")
    def test_health_reports_database_connected(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertEqual(body["status"], "ok")
        self.assertIn("connected", body["database"])
        self.assertIn("customer_count", body)
        self.assertGreaterEqual(body["customer_count"], 0)

    @unittest.skipUnless(is_mysql_available(), "MySQL database not accessible at DATABASE_URL")
    def test_get_customers_returns_list_with_expected_fields(self):
        response = self.client.get("/customers")
        self.assertEqual(response.status_code, 200)
        customers = response.json()
        self.assertIsInstance(customers, list)
        if len(customers) > 0:
            first = customers[0]
            expected_fields = {"id", "customername", "contactFirstName", "contactLastName", "city", "state", "country"}
            self.assertTrue(expected_fields.issubset(set(first.keys())))

    @unittest.skipUnless(is_mysql_available(), "MySQL database not accessible at DATABASE_URL")
    def test_get_customer_by_id_success(self):
        list_response = self.client.get("/customers")
        self.assertEqual(list_response.status_code, 200)
        customers = list_response.json()
        if customers:
            customer_id = customers[0]["id"]
            response = self.client.get(f"/customers/{customer_id}")
            self.assertEqual(response.status_code, 200)
            customer = response.json()
            self.assertEqual(customer["id"], customer_id)

    @unittest.skipUnless(is_mysql_available(), "MySQL database not accessible at DATABASE_URL")
    def test_get_customer_by_id_not_found(self):
        response = self.client.get("/customers/9999999")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json()["detail"], "Customer not found")

    @unittest.skipUnless(is_mysql_available(), "MySQL database not accessible at DATABASE_URL")
    def test_update_customer_not_found(self):
        response = self.client.put("/customers/9999999", json={"customername": "Nonexistent"})
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json()["detail"], "Customer not found")

    @unittest.skipUnless(is_mysql_available(), "MySQL database not accessible at DATABASE_URL")
    def test_update_customer_success(self):
        list_response = self.client.get("/customers")
        self.assertEqual(list_response.status_code, 200)
        customers = list_response.json()
        if customers:
            target = customers[0]
            customer_id = target["id"]
            original_city = target["city"]

            # Update city
            new_city = "Testville"
            update_response = self.client.put(
                f"/customers/{customer_id}",
                json={"city": new_city},
            )
            self.assertEqual(update_response.status_code, 200)
            self.assertEqual(update_response.json()["city"], new_city)

            # Restore original city
            restore_response = self.client.put(
                f"/customers/{customer_id}",
                json={"city": original_city},
            )
            self.assertEqual(restore_response.status_code, 200)
            self.assertEqual(restore_response.json()["city"], original_city)


if __name__ == "__main__":
    unittest.main()
