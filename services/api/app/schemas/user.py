from pydantic import BaseModel, EmailStr, UUID4
from typing import Optional


class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = True
    full_name: Optional[str] = None


class UserCreate(UserBase):
    email: EmailStr
    password: str


class User(UserBase):
    id: UUID4

    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str
