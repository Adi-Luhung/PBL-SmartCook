import os
import sys
import re
import json
import joblib
import numpy as np
from typing import Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ── Dependency Analyzer untuk Model TF-IDF ──────────────────────────────────
KAMUS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'models', 'kamus_normalisasi.json')
with open(KAMUS_PATH, 'r', encoding='utf-8') as f:
    NORMALISASI = json.load(f)

STOPWORDS_DAPUR = set(
    'secukupnya secukup sdm sdt gr gram kg ml buah siung biji iris tipis halus sedikit untuk dan atau yang '
    'dengan suka jika sesuai selera potong ukuran sedang besar kecil sebutir lembar ruas butir bungkus bks '
    'sachet ekor batang dipotong diiris dihaluskan dicincang dimemarkan dikupas dicuci disuwir direbus digeprek'.split()
)

def bersihkan_frasa(frasa):
    frasa = re.sub(r'[^a-z\s]', ' ', str(frasa).lower())
    tokens = [NORMALISASI.get(t, t) for t in frasa.split() if t not in STOPWORDS_DAPUR and len(t) > 1]
    return " ".join(tokens)

class SmartCookAnalyzer:
    def __init__(self, maks_ngram=2):
        self.maks_ngram = maks_ngram
    def __call__(self, doc):
        terms = []
        for frasa in str(doc).split(','):
            b = bersihkan_frasa(frasa)
            tokens = b.split()
            terms += tokens
            if self.maks_ngram >= 2:
                terms += [a + ' ' + b for a, b in zip(tokens, tokens[1:])]
        return terms

# Daftarkan analyzer ke __main__ agar joblib deserializer menemukannya
sys.modules['__main__'].SmartCookAnalyzer = SmartCookAnalyzer

# Load Model ML
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, 'models')

print("Memuat model klasifikasi kategori SmartCook...")
model_kategori_lr = joblib.load(os.path.join(MODELS_DIR, 'model_kategori_lr.joblib'))
vec_kategori = joblib.load(os.path.join(MODELS_DIR, 'vec_kategori.joblib'))
print("Model klasifikasi kategori berhasil dimuat!")

# ── Inisialisasi FastAPI ────────────────────────────────────────────────────
app = FastAPI(
    title="SmartCook Machine Learning API",
    description="REST API Microservice untuk Klasifikasi Kategori Resep (Auto-Tagging Protein)",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Schemas ─────────────────────────────────────────────────────────────────
class CategoryPredictionRequest(BaseModel):
    title: str
    ingredients: str

# ── Endpoints ───────────────────────────────────────────────────────────────
@app.get("/")
def root():
    return {
        "app": "SmartCook Machine Learning Service",
        "version": "2.0.0",
        "status": "online",
        "architecture": "Pilihan A (Hanya Klasifikasi Kategori Resep)",
        "endpoints": {
            "health": "GET /health",
            "predict_category": "POST /predict-category"
        }
    }

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict-category")
def predict_category(req: CategoryPredictionRequest):
    """
    Auto-tagging kategori protein utama masakan dari judul dan daftar bahan
    menggunakan model Logistic Regression + N-Gram TF-IDF.
    """
    if not req.title.strip() and not req.ingredients.strip():
        raise HTTPException(status_code=400, detail="Judul dan bahan tidak boleh kosong.")

    # Normalisasi teks masukan
    title_clean = bersihkan_frasa(req.title)
    ingredients_clean = ", ".join([bersihkan_frasa(item) for item in req.ingredients.split(',') if bersihkan_frasa(item)])
    text_combined = f"{title_clean} , {ingredients_clean}"

    vec = vec_kategori.transform([text_combined])
    pred_category = str(model_kategori_lr.predict(vec)[0])
    
    probs = model_kategori_lr.predict_proba(vec)[0]
    confidence = float(np.max(probs))
    
    return {
        "status": "success",
        "predicted_category": pred_category,
        "confidence": round(confidence * 100, 2),
        "ml_model": "LogisticRegression(C=5.0)"
    }

if __name__ == '__main__':
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
