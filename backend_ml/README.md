# SmartCook Machine Learning Service (Backend Microservice)

Backend REST API ini melayani inferensi model Machine Learning yang telah dilatih dari dataset resep (`resep_nutrisi.csv`) untuk aplikasi mobile **SmartCook**.

---

## 3 Modul Machine Learning yang Dimuat:

1. **Modul 1: TF-IDF Content-Based Recommender**
   - **Algoritma:** TF-IDF Vectorizer + Cosine Similarity
   - **Endpoint:** `POST /recommend`
   - **Fungsi:** Menghitung skor kemiripan resep berdasarkan bahan yang diinputkan pengguna.

2. **Modul 2: Auto-Tagging Kategori Resep**
   - **Algoritma:** Logistic Regression ($C=5.0$) + Custom N-Gram TF-IDF Analyzer
   - **Endpoint:** `POST /predict-category`
   - **Fungsi:** Mengklasifikasikan jenis protein resep (*ayam, sapi, ikan, udang, telur, tahu, tempe, kambing*).

3. **Modul 3: Filter Diet Personal (BMI × TDEE)**
   - **Algoritma:** Decision Tree Classifier (`max_depth=5`)
   - **Endpoint:** `POST /predict-diet`
   - **Fungsi:** Memprediksi kategori diet (*Diet Ketat, Diet Ringan, Maintenance, Bulking*) dan alokasi batas kalori per porsi makan.

---

## Cara Menjalankan Backend:

### Cara 1: Double-Click File Batch (Windows)
Cukup jalankan file `run_server.bat` di folder `backend_ml/`.

### Cara 2: Terminal / PowerShell
```bash
cd backend_ml
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Dokumentasi interaktif (Swagger UI) otomatis tersedia di:  
👉 **http://127.0.0.1:8000/docs**

---

## Integrasi di Flutter:
- Service client ada di [`lib/core/services/ml_service.dart`](file:///D:/Kuliah/Semester%205/PBL/PBL-SmartCook/lib/core/services/ml_service.dart).
- Jika server Python aktif, badge di tab Profil akan menampilkan label **API LIVE** (Cloud).
- Jika server offline, Flutter otomatis beralih (*fallback*) ke **EMBEDDED** rules tanpa membuat aplikasi error.
