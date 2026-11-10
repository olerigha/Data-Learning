---
course: CDE
week: 4
source: "[[Cloud-Data-Engineering/Week4/README|Week 4 README]], [[SQL-Reference.pdf]]"
status: new
tags: [generated]
---
# SQL from Python
**In one line:** Connect Python to a database with SQLAlchemy and run SQL safely using parameters, not pasted-in strings.

**In plain words:** Pipelines and apps talk to databases from Python. SQLAlchemy creates an "engine" (a connection manager) from a connection URL. When a query needs a value from the user, pass it as a **parameter**, never by gluing it into the SQL text. That blocks SQL injection and handles quoting for you. Keep passwords in environment variables or a config file, not in code.

**Terms**
| Term | Means |
|---|---|
| SQLAlchemy | Python library for database connections (and an ORM) |
| Engine | object that manages connections to one database |
| Connection pooling | reuse open connections instead of opening new ones |
| Parameterized query | SQL with placeholders, values passed separately |
| SQL injection | an attack where user input is executed as SQL |
| ORM | Object-Relational Mapper: tables as Python classes |

**Key points**
```python
engine = create_engine(os.environ["DB_URL"])
with engine.begin() as conn:
    conn.execute(text("SELECT * FROM customers WHERE country = :c"), {"c": "USA"})
```
In words: connect using a URL from the environment, then run a query with `:c` filled in safely. `begin()` wraps it in a transaction.
- `pandas.read_sql(query, engine)` pulls results straight into a DataFrame.
- Submission asks for a rollback demonstration from Python.
- The SQL Reference also shows plain `pymysql` connections, and connecting from R.

**Memorize vs. look up:** Memorize "parameters, never string-pasting" and "secrets in env vars".

Related: [[ACID Transactions]], [[Pipeline Orchestration with Prefect]], [[Three-Tier Data Apps]]

*The code shape is a general example; the course materials name SQLAlchemy, pymysql and parameterized execution.*
