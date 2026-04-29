from pydantic import BaseModel, UUID4
from typing import List, Optional, Dict, Any
from datetime import datetime


class FinancialProfileBase(BaseModel):
    income: float = 0.0
    debts: List[Dict[str, Any]] = []
    goals: List[Dict[str, Any]] = []
    habits: List[str] = []


class FinancialProfileCreate(FinancialProfileBase):
    pass


class FinancialProfileUpdate(FinancialProfileBase):
    income: Optional[float] = None


class FinancialProfile(FinancialProfileBase):
    id: UUID4
    user_id: UUID4
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
