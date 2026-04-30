from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.v1.api import api_router
from .core.config import settings
from .core.db.session import engine
from sqlalchemy import text


def parse_cors_origins(value: str) -> list[str]:
    if not value.strip():
        return []
    return [origin.strip() for origin in value.split(",") if origin.strip()]


app = FastAPI(title=settings.PROJECT_NAME)

# Set all CORS enabled origins
if settings.CORS_ORIGINS:
    cors_origins = parse_cors_origins(settings.CORS_ORIGINS)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/")
async def root():
    return {"message": "Sinapsek Fin API is running"}


@app.get("/health")
async def health():
    return {"status": "healthy"}
