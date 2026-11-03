## Command : uvicorn TestFastAPI:app --reload

from fastapi import FastAPI
from pydantic import BaseModel

# Initialize FastAPI app
app = FastAPI()

# Define a Pydantic model for the data response (optional, but good practice)
class University(BaseModel):
    UniversityId: int
    UniversityName: str

# Route for the home page
@app.get("/")
async def home():
    return "<h1>Data Engineering Platforms</h1><p>We are data engineering experts !!!</p>"

# Route to return data as JSON
@app.get("/data", response_model=University)
async def data():
    return University(UniversityId=1001, UniversityName="Univ. of Chicago")
