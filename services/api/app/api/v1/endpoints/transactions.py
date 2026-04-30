from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Any
from app.api import deps
from app.models.user import User
from app.models.transaction import Transaction
from app.core.parser import parser
from app.schemas.transaction import Transaction as TransactionSchema
from datetime import datetime

router = APIRouter()


@router.get("/", response_model=List[TransactionSchema])
def read_transactions(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    Retrieve transactions.
    """
    transactions = (
        db.query(Transaction)
        .filter(Transaction.user_id == current_user.id)
        .offset(skip)
        .limit(limit)
        .all()
    )
    return transactions


@router.post("/upload", response_model=List[TransactionSchema])
async def upload_statement(
    *,
    db: Session = Depends(deps.get_db),
    file: UploadFile = File(...),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Upload a bank statement and extract transactions using AI.
    """
    content = await file.read()
    filename = file.filename

    if filename.endswith(".pdf"):
        text = await parser.parse_pdf(content)
    elif filename.endswith((".xls", ".xlsx")):
        text = await parser.parse_excel(content)
    else:
        raise HTTPException(status_code=400, detail="Unsupported file format")

    extracted_data = await parser.extract_transactions_with_ai(text)

    transactions = []
    for item in extracted_data:
        try:
            # Basic validation of extracted data
            db_obj = Transaction(
                user_id=current_user.id,
                date=datetime.strptime(item["date"], "%Y-%m-%d").date(),
                description=item["description"],
                amount=float(item["amount"]),
                source_file=filename,
                raw_data=str(item),
            )
            db.add(db_obj)
            transactions.append(db_obj)
        except Exception:
            continue

    db.commit()
    # Refresh objects
    for t in transactions:
        db.refresh(t)

    return transactions
