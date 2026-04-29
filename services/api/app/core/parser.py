import io
import pandas as pd
from pypdf import PdfReader
import google.generativeai as genai
from typing import List, Dict, Any
from .config import settings


class StatementParser:
    def __init__(self):
        # Configure Gemini
        genai.configure(
            api_key=settings.SECRET_KEY
        )  # We should use a dedicated GEMINI_API_KEY later
        self.model = genai.GenerativeModel("gemini-1.5-flash")

    async def parse_pdf(self, file_content: bytes) -> str:
        reader = PdfReader(io.BytesIO(file_content))
        text = ""
        for page in reader.pages:
            text += page.extract_text() + "\n"
        return text

    async def parse_excel(self, file_content: bytes) -> str:
        df = pd.read_excel(io.BytesIO(file_content))
        return df.to_string()

    async def extract_transactions_with_ai(self, text: str) -> List[Dict[str, Any]]:
        prompt = f"""
        Extract financial transactions from the following text. 
        For each transaction, find the date, description, and amount.
        If it's an expense, the amount should be positive. If it's an income, specify it.
        Return the result ONLY as a valid JSON list of objects with keys: "date" (YYYY-MM-DD), "description", "amount".
        
        Text:
        {text[:10000]} # Limit text to avoid token issues
        """

        response = self.model.generate_content(prompt)
        # Here we should add parsing logic for the JSON response
        # This is a simplified version
        try:
            # Note: In a real scenario, we'd use a more robust JSON extractor
            import json
            import re

            json_match = re.search(r"\[.*\]", response.text, re.DOTALL)
            if json_match:
                return json.loads(json_match.group(0))
            return []
        except Exception:
            return []


parser = StatementParser()
