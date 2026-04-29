from pydantic import BaseModel, UUID4
from typing import Optional
from datetime import date, datetime


class TransactionBase(BaseModel):
    date: date
    description: str
    amount: float
    category: Optional[str] = None
    subcategory: Optional[str] = None
    source_file: Optional[str] = None
    raw_data: Optional[str] = None


class TransactionCreate(TransactionBase):
    pass


class Transaction(TransactionBase):
    id: UUID4
    user_id: UUID4
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
