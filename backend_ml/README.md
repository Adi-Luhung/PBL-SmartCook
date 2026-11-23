# SmartCook Machine Learning Service (Backend Microservice)

Backend REST API ini melayani inferensi model Machine Learning yang telah dilatih dari dataset recount (`resep_nutrisi_recount.csv`) untuk aplikasi mobile **SmartCook**.

- **Modul Rekomendasi Resep** dihitung langsung di database Supabase / PostgreSQL menggunakan SQL RPC function `match_recipes` berbasis TF-IDF + Cosine Similarity bahan utuh.
- **Modul Diet Personal** dihitung langsung secara lokal di aplikasi Flutter (`lib/core/utils/nutrition.dart`) menggunakan aturan deterministik medis & gizi (WHO BMI Cut-offs & Mifflin-St Jeor BMR).
- **Backend Microservice ini HANYA fokus melayani inferensi Klasifikasi Kategori Resep (Auto-Tagging Protein)**.

---

## Modul Machine Learning yang Dimuat:

### Auto-Tagging Kategori Resep
- **Algoritma:** Logistic Regression ($C=5.0$) + Custom N-Gram TF-IDF Analyzer
- **Endpoint:** `POST /predict-category`
- **Fungsi:** Mengklasifikasikan jenis bahan utama / protein resep (*ayam, sapi, ikan, udang, telur, tahu, tempe, kambing*) saat pengguna mengunggah resep baru.

---

## Cara Menjalankan Backend:

### Cara 1: Double-Click File Batch (Windows)
Jalankan file `run_server.bat` di folder `backend_ml/`.

### Cara 2: Terminal / PowerShell
```bash
cd backend_ml
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Dokumentasi interaktif (Swagger UI) otomatis tersedia di:  
👉 **http://127.0.0.1:8000/docs**

---

## Endpoint API:
- `GET /` — Informasi status & arsitektur layanan
- `GET /health` — Pemeriksaan status aktif (*health check*)
- `POST /predict-category` — Inferensi auto-tagging kategori resep
