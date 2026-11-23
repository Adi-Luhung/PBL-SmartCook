import os
import re
import json
import shutil
import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

SEED = 42

# Kamus normalisasi (Lexicon) dibaca otomatis dari file eksternal
KAMUS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'kamus_normalisasi.json')
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

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(base_dir)
    models_dir = os.path.join(project_dir, 'backend_ml', 'models')
    os.makedirs(models_dir, exist_ok=True)
    
    # Gunakan dataset recount yang sudah tervalidasi
    csv_path = os.path.join(base_dir, 'resep_nutrisi_recount.csv')
    print(f"[1/2] Memuat dataset recount dari {csv_path}...")
    df_raw = pd.read_csv(csv_path, encoding='utf-8-sig')
    
    KATEGORI_VALID = {'ayam', 'sapi', 'ikan', 'udang', 'telur', 'tahu', 'tempe', 'kambing'}
    mask_valid = df_raw['Category'].isin(KATEGORI_VALID) & ~df_raw['Title'].astype(str).str.match(r'^\d+\)') & df_raw['URL'].notna()
    df = df_raw[mask_valid].copy()
    
    for c in ['Total Steps', 'kalori_kkal', 'protein_g', 'lemak_g', 'karbohidrat_g', 'berat_g', 'cakupan_bahan']:
        if c in df.columns:
            df[c] = pd.to_numeric(df[c], errors='coerce')
            
    df = df.dropna(subset=['Title', 'Steps', 'Ingredients Normalized', 'Total Steps', 'kalori_kkal', 'berat_g', 'cakupan_bahan'])
    df = df.drop_duplicates('URL')
    
    # Filter gizi andal
    reliable = (df['kalori_kkal'] > 0) & (df['berat_g'] >= 100) & (df['cakupan_bahan'] >= 0.8) & (df['cakupan_bahan'] <= 1.0)
    df = df[reliable].copy().reset_index(drop=True)
    
    doc_col = 'Ingredients Normalized'
    df['doc'] = df['Title'].astype(str) + " , " + df[doc_col].fillna('').astype(str)
    
    print(f"Dataset recount bersih: {len(df):,} resep siap dilatih untuk klasifikasi kategori.")
    
    # ── Klasifikasi Kategori Resep (Auto-tagging) ─────────────────────────────
    print("[2/2] Melatih Model Klasifikasi Kategori Resep (Logistic Regression)...")
    analyzer = SmartCookAnalyzer(2)
    vec_kategori = TfidfVectorizer(analyzer=analyzer, min_df=2, sublinear_tf=True)
    X_kat = vec_kategori.fit_transform(df['doc'])
    y_kat = df['Category']
    
    model_lr = LogisticRegression(max_iter=1000, C=5.0, random_state=SEED)
    model_lr.fit(X_kat, y_kat)
    
    # Hapus model usang yang tidak dipakai lagi
    obsolete_files = [
        'matrix_recom.joblib', 'model_diet_dt.joblib', 'model_diet_lr.joblib',
        'recipes_meta.joblib', 'scaler_diet.joblib', 'vec_recom.joblib'
    ]
    for obs in obsolete_files:
        p = os.path.join(models_dir, obs)
        if os.path.exists(p):
            os.remove(p)
            print(f"Model usang dihapus: {obs}")
            
    joblib.dump(vec_kategori, os.path.join(models_dir, 'vec_kategori.joblib'))
    joblib.dump(model_lr, os.path.join(models_dir, 'model_kategori_lr.joblib'))
    print("Model klasifikasi tersimpan: vec_kategori.joblib, model_kategori_lr.joblib")
    
    shutil.copy(KAMUS_PATH, os.path.join(models_dir, 'kamus_normalisasi.json'))
    print("Kamus tersalin: kamus_normalisasi.json")
    
    print("\n[SUKSES] Pelatihan & ekspor model backend selesai!")

if __name__ == '__main__':
    main()
