from fastapi import FastAPI

app = FastAPI(title="Sinapsek Fin API")

@app.get("/")
async def root():
    return {"message": "Sinapsek Fin API is running"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
