FROM python:3.10-slim

WORKDIR /app

# Salin dependencies dan install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Salin seluruh file kode dan folder models
COPY . .

# Hugging Face Spaces secara default mendengarkan port 7860
EXPOSE 7860

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
