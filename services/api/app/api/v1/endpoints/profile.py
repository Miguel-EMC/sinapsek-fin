from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Any
from ....core.db.session import SessionLocal
from ....api import deps
from ....models.user import User
from ....models.profile import FinancialProfile
from ....schemas.profile import FinancialProfile as FinancialProfileSchema, FinancialProfileCreate, FinancialProfileUpdate

router = APIRouter()

@router.get("/", response_model=FinancialProfileSchema)
def read_profile(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Get current user's financial profile.
    """
    profile = db.query(FinancialProfile).filter(FinancialProfile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Financial profile not found")
    return profile

@router.post("/", response_model=FinancialProfileSchema)
def create_profile(
    *,
    db: Session = Depends(deps.get_db),
    profile_in: FinancialProfileCreate,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Create new financial profile.
    """
    profile = db.query(FinancialProfile).filter(FinancialProfile.user_id == current_user.id).first()
    if profile:
        raise HTTPException(status_code=400, detail="Financial profile already exists")
    
    db_obj = FinancialProfile(
        **profile_in.dict(),
        user_id=current_user.id
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    
    # TODO: Trigger IA plan generation hook (LangGraph) here
    
    return db_obj

@router.put("/", response_model=FinancialProfileSchema)
def update_profile(
    *,
    db: Session = Depends(deps.get_db),
    profile_in: FinancialProfileUpdate,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Update financial profile.
    """
    profile = db.query(FinancialProfile).filter(FinancialProfile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Financial profile not found")
    
    update_data = profile_in.dict(exclude_unset=True)
    for field in update_data:
        setattr(profile, field, update_data[field])
    
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile
