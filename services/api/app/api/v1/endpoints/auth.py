from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ....core import security
from ....models.user import User
from ....schemas.user import UserCreate, Token
from ....api import deps

router = APIRouter()


@router.post("/register", response_model=Token)
def register(obj_in: UserCreate, db: Session = Depends(deps.get_db)):
    user = db.query(User).filter(User.email == obj_in.email).first()
    if user:
        raise HTTPException(status_code=400, detail="El usuario ya existe")

    new_user = User(
        email=obj_in.email,
        hashed_password=security.get_password_hash(obj_in.password),
        full_name=obj_in.full_name,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    access_token = security.create_access_token(subject=new_user.id)
    return {"access_token": access_token, "token_type": "bearer"}


@router.post("/login", response_model=Token)
def login(obj_in: UserCreate, db: Session = Depends(deps.get_db)):
    user = db.query(User).filter(User.email == obj_in.email).first()
    if not user or not security.verify_password(obj_in.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Email o contraseña incorrectos")

    access_token = security.create_access_token(subject=user.id)
    return {"access_token": access_token, "token_type": "bearer"}
