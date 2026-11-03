import logging
import os
import re
from pathlib import Path
from typing import Any
import pandas as pd
import requests
import streamlit as st
import yaml

DEFAULT_CONFIG_PATH = Path(__file__).resolve().parent / "config.yaml"
LOGO_PATH = Path(__file__).resolve().parent / "logo.png"


def load_config(config_path: str | Path | None = None) -> dict[str, Any]:
    """Load YAML configuration and resolve ${VAR:-default} placeholders."""
    path = Path(config_path) if config_path else DEFAULT_CONFIG_PATH
    if not path.exists():
        return {}

    with open(path, encoding="utf-8") as f:
        content = f.read()

    def _resolve(match: re.Match[str]) -> str:
        expr = match.group(1)
        if ":-" in expr:
            var_name, default = expr.split(":-", 1)
        else:
            var_name, default = expr, ""
        return os.environ.get(var_name, default)

    resolved = re.sub(r"\$\{([^}]+)\}", _resolve, content)
    return yaml.safe_load(resolved) or {}


CONFIG = load_config()

# Setup logger with a simplified configuration
def setup_logger():
    logger = logging.getLogger("CustomerApp")
    if not logger.handlers:
        handler = logging.StreamHandler()
        handler.setFormatter(logging.Formatter('%(asctime)s - %(message)s'))
        logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger

logger = setup_logger()

# FastAPI base URL from config (with env var override support)
BASE_URL = os.getenv(
    "API_BASE_URL",
    CONFIG.get("api", {}).get("base_url", "http://127.0.0.1:8000"),
)

# Helper function for making GET requests
def make_get_request(endpoint: str):
    try:
        logger.info(f"Making GET request to: {endpoint}")
        response = requests.get(endpoint, timeout=10)
        response.raise_for_status()  # Raise error for bad status codes
        return response.json()
    except requests.exceptions.ConnectionError:
        logger.error(f"Failed to connect to FastAPI backend at {BASE_URL}")
        st.error(f"Cannot connect to FastAPI backend at `{BASE_URL}`. Make sure the FastAPI server is running (`uvicorn ClassicFastAPI:app --reload`).")
        return None
    except requests.exceptions.HTTPError as e:
        logger.error(f"HTTP error: {e}")
        error_detail = ""
        try:
            error_detail = response.json().get("detail", "")
        except Exception:
            error_detail = response.text

        if any(msg in error_detail for msg in ("Can't connect to MySQL server", "2003", "2002", "Access denied for user")):
            st.error(
                "❌ **MySQL Database Connection Failed**\n\n"
                f"{error_detail}\n\n"
                "**To resolve:**\n"
                "1. Make sure MySQL is running on your machine (e.g. `brew services start mysql` or start your local MySQL server).\n"
                "2. Verify connection credentials in `config.yaml` or set `DATABASE_URL`."
            )
        else:
            st.error(f"Server Error ({response.status_code}): {error_detail}")
        return None
    except requests.exceptions.RequestException as e:
        logger.error(f"Request failed: {e}")
        st.error(f"Request failed: {e}")
        return None

# Helper function for making PUT requests (customer updates)
def make_put_request(endpoint: str, data: dict):
    try:
        logger.info(f"Making PUT request to: {endpoint} with data: {data}")
        response = requests.put(endpoint, json=data, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.ConnectionError:
        logger.error(f"Failed to connect to FastAPI backend at {BASE_URL}")
        st.error(f"Cannot connect to FastAPI backend at `{BASE_URL}`. Make sure the FastAPI server is running.")
        return None
    except requests.exceptions.HTTPError as e:
        logger.error(f"HTTP error on update: {e}")
        error_detail = ""
        try:
            error_detail = response.json().get("detail", "")
        except Exception:
            error_detail = response.text
        st.error(f"Failed to update customer ({response.status_code}): {error_detail}")
        return None
    except requests.exceptions.RequestException as e:
        logger.error(f"Update request failed: {e}")
        st.error(f"Request failed: {e}")
        return None

# Function to display customer details
def display_customer_details(customer):
    """
    Reusable function to display customer details in Streamlit.
    """
    st.write(f"**ID:** {customer['id']}")
    st.write(f"**Name:** {customer['customername']}")
    st.write(f"**Contact:** {customer['contactFirstName']} {customer['contactLastName']}")
    st.write(f"**City:** {customer['city']}")
    st.write(f"**State:** {customer.get('state') or 'N/A'}")
    st.write(f"**Country:** {customer['country']}")
    st.write("---")

# Reusable customer editing form
def render_edit_form(customer: dict, form_key_prefix: str = "edit"):
    st.markdown("### ✏️ Edit Customer Information")
    with st.form(f"{form_key_prefix}_customer_form"):
        st.caption(f"Editing Customer Number: **{customer['id']}**")
        new_name = st.text_input("Customer Name", value=customer.get("customername", ""))
        col_fn, col_ln = st.columns(2)
        with col_fn:
            new_fn = st.text_input("Contact First Name", value=customer.get("contactFirstName", ""))
        with col_ln:
            new_ln = st.text_input("Contact Last Name", value=customer.get("contactLastName", ""))
        col_city, col_state, col_country = st.columns(3)
        with col_city:
            new_city = st.text_input("City", value=customer.get("city", ""))
        with col_state:
            new_state = st.text_input("State (optional)", value=customer.get("state") or "")
        with col_country:
            new_country = st.text_input("Country", value=customer.get("country", ""))

        update_submitted = st.form_submit_button("Update Customer", type="primary")

        if update_submitted:
            payload = {
                "customername": new_name.strip(),
                "contactFirstName": new_fn.strip(),
                "contactLastName": new_ln.strip(),
                "city": new_city.strip(),
                "state": new_state.strip() if new_state.strip() else None,
                "country": new_country.strip(),
            }
            updated = make_put_request(f"{BASE_URL}/customers/{customer['id']}", payload)
            if updated:
                st.success(f"Customer **{customer['id']}** successfully updated in MySQL via FastAPI!")
                st.write("**Updated Record:**")
                display_customer_details(updated)

# Streamlit app
def main():
    app_cfg = CONFIG.get("app", {})
    st.set_page_config(
        page_title=app_cfg.get("page_title", "Classic Models Customer App"),
        layout=app_cfg.get("layout", "wide"),
    )

    # Sidebar: Logo & Navigation
    if LOGO_PATH.exists():
        st.sidebar.image(str(LOGO_PATH), width="stretch")

    st.sidebar.header("Navigation")
    option = st.sidebar.selectbox(
        "Select an action",
        ["Get All Customers", "Get Customer by ID", "Edit Customer", "API Health Status"],
    )

    # Main page header with logo branding
    header_col1, header_col2 = st.columns([1, 6])
    with header_col1:
        if LOGO_PATH.exists():
            st.image(str(LOGO_PATH), width=90)
    with header_col2:
        st.title(app_cfg.get("title", "Classic Models Customer Data Application"))
        st.caption("Streamlit application consuming REST API endpoints from FastAPI backed by MySQL")

    st.markdown("---")

    if option == "API Health Status":
        st.subheader("FastAPI Backend Health Status")
        health_data = make_get_request(f"{BASE_URL}/health")
        if health_data:
            st.success("FastAPI backend is online and connected to MySQL!")
            st.json(health_data)
        else:
            st.error(f"Unable to reach FastAPI backend at `{BASE_URL}`.")

    # Option to get all customers
    elif option == "Get All Customers":
        st.subheader("📋 List of Customers")
        customers = make_get_request(f"{BASE_URL}/customers")

        if customers:
            st.info(f"Retrieved {len(customers)} customers from MySQL via FastAPI.")
            view_mode = st.radio("Display Mode", ["Table View", "Detailed Cards"], horizontal=True)
            if view_mode == "Table View":
                df = pd.DataFrame(customers)
                st.dataframe(df, width="stretch")
            else:
                for customer in customers:
                    display_customer_details(customer)
        elif customers == []:
            st.warning("Connected to database, but the customers table is currently empty.")

    # Option to get a specific customer by ID
    elif option == "Get Customer by ID":
        st.subheader("🔍 Look Up Customer by ID")
        customer_id = st.text_input("Enter Customer ID (e.g. 103, 112, 114)", "")

        if customer_id:
            if customer_id.strip().isdigit():
                customer = make_get_request(f"{BASE_URL}/customers/{customer_id.strip()}")
                if customer:
                    st.success(f"Customer {customer_id} found!")
                    display_customer_details(customer)
                    # Offer inline editing expander
                    with st.expander("✏️ Quick Edit this Customer"):
                        render_edit_form(customer, form_key_prefix="lookup")
                else:
                    st.error(f"Customer with ID {customer_id} not found in database.")
            else:
                st.warning("Please enter a valid numeric customer ID.")

    # Option to edit a customer
    elif option == "Edit Customer":
        st.subheader("✏️ Edit Customer Record")
        st.write("Enter a Customer ID to retrieve and edit their details in MySQL through the FastAPI service.")
        edit_id = st.text_input("Customer ID to Edit (e.g. 103, 112, 114)", "", key="edit_target_id")

        if edit_id:
            if edit_id.strip().isdigit():
                customer = make_get_request(f"{BASE_URL}/customers/{edit_id.strip()}")
                if customer:
                    render_edit_form(customer, form_key_prefix="dedicated")
                else:
                    st.error(f"Customer with ID {edit_id} not found.")
            else:
                st.warning("Please enter a valid numeric customer ID.")


# Run the Streamlit app
if __name__ == "__main__":
    main()
