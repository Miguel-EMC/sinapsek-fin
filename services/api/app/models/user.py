import uuid
from sqlalchemy import Column
from sqlalchemy.dialects.postgresql import UUID
from ..core.db.base_class import Base


from sqlalchemy.orm import relationship


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    # ... rest of columns
    financial_profile = relationship(
        "FinancialProfile", back_populates="user", uselist=False
    )
