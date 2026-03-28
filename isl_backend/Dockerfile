# Slim Debian base — ~130MB vs ~900MB for bullseye full
FROM python:3.10-slim-bullseye

# libgl1 + libglib2.0 needed by opencv-python-headless
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies before copying code (layer cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD uvicorn app:app --host 0.0.0.0 --port ${PORT:-8000}
```

**`requirements.txt`** — headless opencv, pin versions to avoid resolution thrash:
```
fastapi==0.111.0
uvicorn[standard]==0.30.1
ultralytics==8.2.18
opencv-python-headless==4.9.0.80
numpy==1.26.4
python-multipart==0.0.9