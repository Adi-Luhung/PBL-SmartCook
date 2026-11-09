import os
import sys
import re
import joblib
import numpy as np
import pandas as pd
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sklearn.metrics.pairwise import cosine_similarity

# ── Dependency Analyzer untuk Model TF-IDF ──────────────────────────────────
NORMALISASI = {
    'cabe': 'cabai', 'telor': 'telur', 'saos': 'saus', 'asem': 'asam',
    'bombay': 'bombai', 'trasi': 'terasi', 'baput': 'bawang putih',
    'bamer': 'bawang merah', 'daun jeruk purut': 'daun jeruk',
    'royko': 'penyedap', 'masako': 'penyedap', 'micin': 'penyedap'
}

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

# ── Load Model ML ───────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, 'models')

print("Memuat seluruh model Machine Learning...")
model_diet_dt = joblib.load(os.path.join(MODELS_DIR, 'model_diet_dt.joblib'))
model_kategori_lr = joblib.load(os.path.join(MODELS_DIR, 'model_kategori_lr.joblib'))
vec_kategori = joblib.load(os.path.join(MODELS_DIR, 'vec_kategori.joblib'))
vec_recom = joblib.load(os.path.join(MODELS_DIR, 'vec_recom.joblib'))
matrix_recom = joblib.load(os.path.join(MODELS_DIR, 'matrix_recom.joblib'))
recipes_meta = joblib.load(os.path.join(MODELS_DIR, 'recipes_meta.joblib'))
print(f"Model berhasil dimuat! Resep tersedia: {len(recipes_meta):,}")

# ── Inisialisasi FastAPI ────────────────────────────────────────────────────
app = FastAPI(
    title="SmartCook Machine Learning API",
    description="REST API Microservice Machine Learning untuk PBL SmartCook (Diet Personal, Kategori, Rekomendasi TF-IDF)",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Schemas ─────────────────────────────────────────────────────────────────
class DietPredictionRequest(BaseModel):
    bmi: float
    tdee: float
    skor_bmi_tdee: Optional[float] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = "Pria"

class CategoryPredictionRequest(BaseModel):
    title: str
    ingredients: str

class RecommendationRequest(BaseModel):
    ingredients: List[str]
    limit: Optional[int] = 10

# ── Endpoints ───────────────────────────────────────────────────────────────
@app.get("/")
def root():
    return {
        "app": "SmartCook Machine Learning Service",
        "status": "online",
        "models_loaded": {
            "modul_1_recommender": "TF-IDF + Cosine Similarity (5,739 recipes)",
            "modul_2_category_classifier": "Logistic Regression + N-Gram TF-IDF",
            "modul_3_diet_classifier": "Decision Tree Classifier (BMI x TDEE)"
        }
    }

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict-diet")
def predict_diet(req: DietPredictionRequest):
    """
    Modul 3 ML: Memprediksi kategori diet personal pengguna menggunakan
    model Decision Tree hasil training dengan fitur BMI, TDEE, dan Skor BMI x TDEE.
    """
    bmi = req.bmi
    tdee = req.tdee
    skor = req.skor_bmi_tdee if req.skor_bmi_tdee is not None else round(bmi * tdee, 2)
    
    # Input fitur ke Decision Tree model
    X = pd.DataFrame([{'BMI': bmi, 'TDEE': tdee, 'Skor_BMI_TDEE': skor}])
    predicted_diet = str(model_diet_dt.predict(X)[0])
    
    # Alokasi rasio kalori per porsi makan
    rasio_dict = {
        'Diet Ketat (Defisit Besar)': 0.25,
        'Diet Ringan (Defisit Ringan)': 0.30,
        'Maintenance (Seimbang)': 0.35,
        'Bulking (Surplus)': 0.45
    }
    ratio = rasio_dict.get(predicted_diet, 0.35)
    meal_calorie_budget = round(tdee * ratio)
    
    return {
        "status": "success",
        "bmi": bmi,
        "tdee": tdee,
        "skor_bmi_tdee": skor,
        "diet_category": predicted_diet,
        "meal_calorie_budget": meal_calorie_budget,
        "meal_ratio": ratio,
        "ml_model": "DecisionTreeClassifier(max_depth=5)"
    }

@app.post("/predict-category")
def predict_category(req: CategoryPredictionRequest):
    """
    Modul 2 ML: Auto-tagging kategori protein utama masakan dari judul dan daftar bahan
    menggunakan model Logistic Regression + N-Gram TF-IDF.
    """
    text_combined = f"{req.title} , {req.ingredients}"
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

@app.post("/recommend")
def recommend_recipes(req: RecommendationRequest):
    """
    Modul 1 ML: Rekomendasi resep berbasis TF-IDF Cosine Similarity.
    """
    query_str = ", ".join(req.ingredients)
    query_vec = vec_recom.transform([query_str])
    sims = cosine_similarity(query_vec, matrix_recom).flatten()
    
    top_indices = np.argsort(-sims)[:req.limit]
    results = []
    
    for idx in top_indices:
        score = float(sims[idx])
        if score <= 0.0:
            continue
        rec = dict(recipes_meta[idx])
        rec['similarity_score'] = round(score, 4)
        rec['match_percent'] = int(round(score * 100))
        results.append(rec)
        
    return {
        "status": "success",
        "count": len(results),
        "recipes": results,
        "ml_model": "TF-IDF + Cosine Similarity"
    }

if __name__ == '__main__':
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
