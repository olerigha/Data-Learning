import os
import re
from pathlib import Path
from typing import Any, List, Optional
import yaml
from fastapi import Depends, FastAPI, HTTPException
from pydantic import BaseModel, ConfigDict
from sqlalchemy import Column, Integer, String, create_engine, func
from sqlalchemy.orm import Session, declarative_base, sessionmaker

DEFAULT_CONFIG_PATH = Path(__file__).resolve().parent / "config.yaml"


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

# Build MySQL database connection URL from config
db_cfg = CONFIG.get("database", {})
dialect = db_cfg.get("dialect", "mysql")
driver = db_cfg.get("driver", "mysqlconnector")
user = db_cfg.get("user", "root")
password = db_cfg.get("password", "")
host = db_cfg.get("host", "localhost")
port = db_cfg.get("port", 3306)
dbname = db_cfg.get("database", "classicmodels")
charset = db_cfg.get("charset", "utf8")
pool_recycle = db_cfg.get("pool_recycle", 3600)

if password:
    default_db_url = f"{dialect}+{driver}://{user}:{password}@{host}:{port}/{dbname}"
else:
    default_db_url = f"{dialect}+{driver}://{user}@{host}:{port}/{dbname}"
DATABASE_URL = os.getenv("DATABASE_URL", default_db_url)

api_cfg = CONFIG.get("api", {})

# Initialize FastAPI app
app = FastAPI(
    title=api_cfg.get("title", "Classic Models API"),
    description="FastAPI service exposing Classic Models customer data from MySQL database",
    version=api_cfg.get("version", "1.0.0"),
)

engine = create_engine(
    DATABASE_URL,
    connect_args={"charset": charset} if "mysql" in DATABASE_URL else {},
    pool_recycle=pool_recycle,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Define SQLAlchemy model for "Customer" table in MySQL classicmodels database
class Customer(Base):
    __tablename__ = "customers"
    id = Column("customerNumber", Integer, primary_key=True, index=True)
    customername = Column("customerName", String(50), nullable=False)
    contactFirstName = Column("contactFirstName", String(50), nullable=False)
    contactLastName = Column("contactLastName", String(50), nullable=False)
    city = Column("city", String(50), nullable=False)
    state = Column("state", String(50), nullable=True)
    country = Column("country", String(50), nullable=False)


# Pydantic model for serializing customer data
class CustomerOut(BaseModel):
    id: int
    customername: str
    contactFirstName: str
    contactLastName: str
    city: str
    state: Optional[str] = None
    country: str

    model_config = ConfigDict(from_attributes=True)


# Pydantic model for updating customer data
class CustomerUpdate(BaseModel):
    customername: Optional[str] = None
    contactFirstName: Optional[str] = None
    contactLastName: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


# Dependency to get a database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
async def root():
    return {
        "message": "Classic Models API is running",
        "database": "MySQL",
        "documentation": "/docs",
        "endpoints": [
            "/health",
            "/customers",
            "/customers/{customer_id} (GET, PUT)",
        ],
    }


@app.get("/health")
async def health(db: Session = Depends(get_db)):
    try:
        count = db.query(func.count(Customer.id)).scalar()
        return {
            "status": "ok",
            "database": "connected (MySQL)",
            "customer_count": count,
        }
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Database connection error: {exc}")


# Endpoint to get all customers from MySQL
@app.get("/customers", response_model=List[CustomerOut])
async def get_customers(db: Session = Depends(get_db)):
    try:
        customers = db.query(Customer).all()
        return customers
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Database query error: {exc}")


# Endpoint to get a single customer by ID from MySQL
@app.get("/customers/{customer_id}", response_model=CustomerOut)
async def get_customer(customer_id: int, db: Session = Depends(get_db)):
    try:
        customer = db.query(Customer).filter(Customer.id == customer_id).first()
        if customer is None:
            raise HTTPException(status_code=404, detail="Customer not found")
        return customer
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Database query error: {exc}")


# Endpoint to update customer details by ID in MySQL
@app.put("/customers/{customer_id}", response_model=CustomerOut)
async def update_customer(customer_id: int, payload: CustomerUpdate, db: Session = Depends(get_db)):
    try:
        customer = db.query(Customer).filter(Customer.id == customer_id).first()
        if customer is None:
            raise HTTPException(status_code=404, detail="Customer not found")

        if payload.customername is not None:
            customer.customername = payload.customername
        if payload.contactFirstName is not None:
            customer.contactFirstName = payload.contactFirstName
        if payload.contactLastName is not None:
            customer.contactLastName = payload.contactLastName
        if payload.city is not None:
            customer.city = payload.city
        if payload.state is not None:
            customer.state = payload.state
        if payload.country is not None:
            customer.country = payload.country

        db.commit()
        db.refresh(customer)
        return customer
    except HTTPException:
        raise
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Database update error: {exc}")
