from fastapi import APIRouter
from .endpoints import auth, profile, transactions

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(profile.router, prefix="/profile", tags=["profile"])
api_router.include_router(
    transactions.router, prefix="/transactions", tags=["transactions"]
)
