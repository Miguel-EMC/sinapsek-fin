import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from .api.v1.api import api_router
from .core.config import settings
from .core.db.session import engine
from sqlalchemy import text

logger = logging.getLogger(__name__)


def parse_cors_origins(value: str) -> list[str]:
    if not value.strip():
        return []
    return [origin.strip() for origin in value.split(",") if origin.strip()]


app = FastAPI(title=settings.PROJECT_NAME)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"{request.method} {request.url.path}")
    response = await call_next(request)
    logger.info(f"{request.method} {request.url.path} - {response.status_code}")
    return response


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )

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


@app.get("/health/ready")
async def readiness():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return {"status": "ready", "database": "connected"}
    except Exception as e:
        return {"status": "not_ready", "database": "disconnected", "error": str(e)}
