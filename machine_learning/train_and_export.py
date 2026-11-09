import os
import re
import joblib
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

SEED = 42
np.random.seed(SEED)

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

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(base_dir)
    models_dir = os.path.join(project_dir, 'backend_ml', 'models')
    os.makedirs(models_dir, exist_ok=True)
    
    csv_path = os.path.join(base_dir, 'resep_nutrisi.csv')
    print(f"[1/4] Memuat dataset dari {csv_path}...")
    df_raw = pd.read_csv(csv_path, sep=';', encoding='utf-8-sig', on_bad_lines='skip')
    
    # Kolom teks bahan
    doc_col = 'Ingredients Normalized' if 'Ingredients Normalized' in df_raw.columns else 'Ingredients Cleaned'
    
    KATEGORI_VALID = {'ayam', 'sapi', 'ikan', 'udang', 'telur', 'tahu', 'tempe', 'kambing'}
    mask_valid = df_raw['Category'].isin(KATEGORI_VALID) & ~df_raw['Title'].astype(str).str.match(r'^\d+\)')
    df = df_raw[mask_valid].copy().reset_index(drop=True)
    df['id'] = df.index
    df['doc'] = df[doc_col].fillna('').astype(str)
    
    # Normalisasi nutrisi jika nilainya x10
    for col in ['kalori_kkal', 'protein_g', 'lemak_g', 'karbohidrat_g']:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')
            if df[col].mean() > 1000:
                df[col] = (df[col] / 10.0).round(1)
                
    print(f"Dataset bersih: {len(df):,} resep siap dimodelkan.")
    
    # ── MODUL 2: Klasifikasi Kategori Resep (Auto-tagging) ───────────────────
    print("[2/4] Melatih Modul 2 (Klasifikasi Kategori Resep)...")
    analyzer = SmartCookAnalyzer(2)
    vec_kategori = TfidfVectorizer(analyzer=analyzer, min_df=2, sublinear_tf=True)
    X_kat = vec_kategori.fit_transform(df['doc'])
    y_kat = df['Category']
    
    model_lr = LogisticRegression(max_iter=1000, C=5.0, random_state=SEED)
    model_lr.fit(X_kat, y_kat)
    
    joblib.dump(vec_kategori, os.path.join(models_dir, 'vec_kategori.joblib'))
    joblib.dump(model_lr, os.path.join(models_dir, 'model_kategori_lr.joblib'))
    print("Modul 2 tersimpan: vec_kategori.joblib, model_kategori_lr.joblib")
    
    # ── MODUL 3: Diet Personal BMI x TDEE (Decision Tree) ───────────────────
    print("[3/4] Melatih Modul 3 (Decision Tree Diet Personal BMI x TDEE)...")
    def hitung_bmi(b, t): return round(b / ((t / 100.0) ** 2), 2)
    def hitung_bmr(jk, b, t, u):
        return (10 * b + 6.25 * t - 5 * u + 5) if jk == 'L' else (10 * b + 6.25 * t - 5 * u - 161)
    
    FAKTOR_AKTIVITAS = {'sedentary': 1.2, 'ringan': 1.375, 'sedang': 1.55, 'aktif': 1.725, 'sangat_aktif': 1.9}
    def rule_diet(bmi):
        if bmi >= 30.0: return 'Diet Ketat (Defisit Besar)'
        elif bmi >= 25.0: return 'Diet Ringan (Defisit Ringan)'
        elif bmi >= 18.5: return 'Maintenance (Seimbang)'
        else: return 'Bulking (Surplus)'
        
    N_SINTETIS = 3000
    syn_jk = np.random.choice(['L', 'P'], size=N_SINTETIS)
    syn_u = np.random.randint(15, 65, size=N_SINTETIS)
    syn_t = np.random.normal(165, 10, size=N_SINTETIS).clip(140, 200).round(1)
    syn_b = np.random.normal(68, 18, size=N_SINTETIS).clip(35, 150).round(1)
    syn_akt = np.random.choice(list(FAKTOR_AKTIVITAS.keys()), size=N_SINTETIS)
    
    syn_bmi = np.array([hitung_bmi(b, t) for b, t in zip(syn_b, syn_t)])
    syn_bmr = np.array([hitung_bmr(jk, b, t, u) for jk, b, t, u in zip(syn_jk, syn_b, syn_t, syn_u)])
    syn_tdee = np.array([round(bmr * FAKTOR_AKTIVITAS[a]) for bmr, a in zip(syn_bmr, syn_akt)])
    syn_skor = np.array([round(bmi * tdee, 2) for bmi, tdee in zip(syn_bmi, syn_tdee)])
    syn_label = np.array([rule_diet(bmi) for bmi in syn_bmi])
    
    X_diet = pd.DataFrame({'BMI': syn_bmi, 'TDEE': syn_tdee, 'Skor_BMI_TDEE': syn_skor})
    y_diet = syn_label
    
    dt_diet = DecisionTreeClassifier(max_depth=5, random_state=SEED)
    dt_diet.fit(X_diet, y_diet)
    
    scaler_diet = StandardScaler()
    X_diet_scaled = scaler_diet.fit_transform(X_diet)
    lr_diet = LogisticRegression(max_iter=1000, random_state=SEED)
    lr_diet.fit(X_diet_scaled, y_diet)
    
    joblib.dump(dt_diet, os.path.join(models_dir, 'model_diet_dt.joblib'))
    joblib.dump(lr_diet, os.path.join(models_dir, 'model_diet_lr.joblib'))
    joblib.dump(scaler_diet, os.path.join(models_dir, 'scaler_diet.joblib'))
    print("Modul 3 tersimpan: model_diet_dt.joblib, model_diet_lr.joblib, scaler_diet.joblib")
    
    # ── MODUL 1: Rekomendasi TF-IDF Cosine Similarity ───────────────────────
    print("[4/4] Menyimpan artefak Modul 1 (TF-IDF Content Recommender)...")
    vec_recom = TfidfVectorizer(analyzer=analyzer, min_df=1, sublinear_tf=True, norm='l2')
    matrix_recom = vec_recom.fit_transform(df['doc'])
    
    cols = ['id', 'Title', 'Category', 'kalori_kkal', 'protein_g', 'lemak_g', 'karbohidrat_g', 'Steps', 'URL']
    available_cols = [c for c in cols if c in df.columns]
    recipes_meta = df[available_cols].to_dict(orient='records')
    
    joblib.dump(vec_recom, os.path.join(models_dir, 'vec_recom.joblib'))
    joblib.dump(matrix_recom, os.path.join(models_dir, 'matrix_recom.joblib'))
    joblib.dump(recipes_meta, os.path.join(models_dir, 'recipes_meta.joblib'))
    print("Modul 1 tersimpan: vec_recom.joblib, matrix_recom.joblib, recipes_meta.joblib")
    
    print("\n[SUKSES LENGKAP] Semua 3 Modul Model ML telah berhasil dilatih dan diekspor ke backend_ml/models/!")

if __name__ == '__main__':
    main()
