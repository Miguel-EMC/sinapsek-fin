import uuid
from sqlalchemy import Column, Float, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..core.db.base_class import Base


class FinancialProfile(Base):
    __tablename__ = "financial_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        unique=True,
        nullable=False,
        index=True,
    )

    income = Column(Float, nullable=False, default=0.0)
    debts = Column(
        JSONB, nullable=False, default=list
    )  # List of dicts: {name, amount, rate, etc}
    goals = Column(
        JSONB, nullable=False, default=list
    )  # List of dicts: {name, target_amount, date}
    habits = Column(
        JSONB, nullable=False, default=list
    )  # List of specific financial habits or tags

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="financial_profile")
