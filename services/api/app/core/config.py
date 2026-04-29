from pydantic_settings import BaseSettings
from pydantic import field_validator
from typing import List, Optional

class Settings(BaseSettings):

    PROJECT_NAME: str = "Sinapsek Fin"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "your-default-secret-key-for-dev" # Se cargará automáticamente del entorno (inyectado por GCP)
    GEMINI_API_KEY: Optional[str] = None


    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days

    DATABASE_URL: str = "postgresql://user:password@localhost:5432/sinapsek"

    CORS_ORIGINS: List[str] = ["*"]

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, value):
        if isinstance(value, str):
            if value.strip() == "":
                return []
            if value.lstrip().startswith("["):
                return value
            return [origin.strip() for origin in value.split(",") if origin.strip()]
        return value

    class Config:
        case_sensitive = True


settings = Settings()
