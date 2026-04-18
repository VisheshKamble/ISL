from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import base64
import asyncio
import os
import time
import logging
from collections import deque
import urllib.request
import urllib.parse
from ultralytics import YOLO

# ─────────────────────────────────────────────
# LOGGING SETUP
# ─────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  [%(levelname)s]  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("vani")

# ─────────────────────────────────────────────
# FASTAPI CONFIG
# ─────────────────────────────────────────────
app = FastAPI(title="VANI ISL Backend", version="2.2.0")


def _parse_csv_env(name: str) -> list[str]:
    raw = os.getenv(name, "")
    return [item.strip() for item in raw.split(",") if item.strip()]


cors_origins = _parse_csv_env("VANI_CORS_ORIGINS")
cors_origin_regex = os.getenv(
    "VANI_CORS_ORIGIN_REGEX",
    r"^(https?://(localhost|127\.0\.0\.1)(:\d+)?|https://.*\.up\.railway\.app)$",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_origin_regex=None if cors_origins else cors_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─────────────────────────────────────────────
# MODEL MANAGEMENT (YOLOv11 + G-DRIVE)
# ─────────────────────────────────────────────
os.makedirs("model", exist_ok=True)
MODEL_PATH = os.path.join("model", "isl_best.pt")
FILE_ID = "1TcCNyM1MtbixlN3wZgFttOlvuJutTPqB"
MIN_MODEL_BYTES = 10_000_000


def _download_model_urllib(file_id: str, destination: str) -> None:
    """
    Robust urllib fallback for large Google Drive files.
    Handles the virus-scan confirmation page Drive shows for large files.
    """
    import http.cookiejar

    cookie_jar = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie_jar))
    opener.addheaders = [("User-Agent", "Mozilla/5.0")]

    session_url = f"https://drive.google.com/uc?export=download&id={file_id}"
    log.info(f"📥 Fetching Drive page: {session_url}")

    with opener.open(session_url) as response:
        content_type = response.headers.get("Content-Type", "")
        initial_data = response.read(1024 * 64)  # Read first 64 KB to inspect

    # If Drive returned HTML, it's the virus-scan / confirm page
    if "text/html" in content_type:
        html = initial_data.decode("utf-8", errors="ignore")
        log.info("🔍 Got HTML confirm page, extracting token...")

        # Try to find confirm= token in the page source
        confirm_token = None
        for line in html.splitlines():
            if "confirm=" in line:
                start = line.find("confirm=") + len("confirm=")
                end = line.find("&", start)
                token = line[start:] if end == -1 else line[start:end]
                token = token.strip().strip('"').strip("'").strip(">").strip("/")
                if token and len(token) < 20:
                    confirm_token = token
                    break

        if confirm_token:
            download_url = (
                f"https://drive.google.com/uc?export=download"
                f"&id={file_id}&confirm={confirm_token}"
            )
            log.info(f"✅ Found confirm token: {confirm_token}")
        else:
            # Modern Drive endpoint — accepts confirm=t directly
            download_url = (
                f"https://drive.usercontent.google.com/download"
                f"?id={file_id}&export=download&confirm=t"
            )
            log.info("⚠️ No token found, using usercontent endpoint with confirm=t")
    else:
        # Drive served the binary directly (no confirm page needed)
        log.info("📦 Drive served file directly, writing to disk...")
        with open(destination, "wb") as f:
            f.write(initial_data)
            while True:
                chunk = response.read(1024 * 1024)
                if not chunk:
                    break
                f.write(chunk)
        return

    # Download the actual model file
    log.info(f"📥 Downloading from: {download_url}")
    with opener.open(download_url) as response, open(destination, "wb") as f:
        downloaded = 0
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            f.write(chunk)
            downloaded += len(chunk)
            if downloaded % (10 * 1024 * 1024) < 1024 * 1024:
                log.info(f"  ... {downloaded // (1024 * 1024)} MB downloaded")
    log.info(f"✅ urllib download complete ({downloaded // (1024 * 1024)} MB)")


def _download_model_from_drive(file_id: str, destination: str) -> None:
    """Try gdown first (no fuzzy= for compatibility), fall back to urllib."""
    # Primary: gdown — omit fuzzy= so it works on all gdown versions
    try:
        import gdown
        url = f"https://drive.google.com/uc?id={file_id}"
        log.info("📥 Trying gdown...")
        gdown.download(url, destination, quiet=False)
        return
    except Exception as e:
        log.warning(f"gdown failed, switching to urllib fallback: {e}")

    # Fallback: robust urllib with confirm-token handling
    _download_model_urllib(file_id, destination)


def _is_model_file_valid(path: str) -> bool:
    return os.path.exists(path) and os.path.getsize(path) >= MIN_MODEL_BYTES


def initialize_model():
    """Downloads model if missing/corrupt and loads into memory."""
    # 1. Clean up old/failed downloads (HTML error pages are usually < 1 MB)
    if os.path.exists(MODEL_PATH) and os.path.getsize(MODEL_PATH) < MIN_MODEL_BYTES:
        log.info("🗑️ Deleting corrupted model file (size too small)...")
        os.remove(MODEL_PATH)

    # 2. Download from Google Drive if not present
    if not os.path.exists(MODEL_PATH):
        try:
            log.info(f"📥 Downloading model ID: {FILE_ID}")
            _download_model_from_drive(FILE_ID, MODEL_PATH)

            if not _is_model_file_valid(MODEL_PATH):
                raise RuntimeError(
                    f"Downloaded file appears invalid "
                    f"(size={os.path.getsize(MODEL_PATH)} bytes)."
                )
            log.info("✅ Download complete!")
        except Exception as e:
            log.error(f"❌ Download failed: {e}")
            return None

    # 3. Load YOLO model
    try:
        loaded_model = YOLO(MODEL_PATH)
        loaded_model.to("cpu")
        loaded_model.fuse()
        log.info(f"✅ YOLO Model loaded successfully from {MODEL_PATH}")
        return loaded_model
    except Exception as e:
        log.error(f"❌ Model failed to load: {e}")
        return None


# Global model instance
model = initialize_model()

# ─────────────────────────────────────────────
# INFERENCE LOGIC
# ─────────────────────────────────────────────
CONF_THRESHOLD = 0.30
MAX_DET = 1
FRAME_SKIP_MS = 80  # Max ~12 FPS for CPU stability


class PredictionSmoother:
    def __init__(self, window: int = 5):
        self._buf = deque(maxlen=window)

    def push(self, label: str, conf: float):
        self._buf.append((label, conf))
        labels = [l for l, _ in self._buf]
        dominant = max(set(labels), key=labels.count)
        avg_conf = sum(c for l, c in self._buf if l == dominant) / labels.count(dominant)
        return dominant, round(avg_conf, 2)

    def reset(self):
        self._buf.clear()


# ─────────────────────────────────────────────
# WEBSOCKET ENDPOINT
# ─────────────────────────────────────────────
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    log.info(f"🔌 WebSocket Connected: {websocket.client}")

    if model is None:
        await websocket.send_json({"type": "error", "message": "Model not available on server"})
        await websocket.close()
        return

    smoother = PredictionSmoother()
    last_infer_time = 0.0
    frame_count = 0

    try:
        while True:
            # Receive data (Base64 string)
            try:
                raw_data = await asyncio.wait_for(websocket.receive_text(), timeout=20.0)
            except asyncio.TimeoutError:
                await websocket.send_json({"type": "ping"})
                continue

            # Protocol commands
            if raw_data == "__PING__":
                await websocket.send_json({"type": "pong"})
                continue
            if raw_data == "__STOP__":
                smoother.reset()
                continue

            # Frame throttling
            current_time = time.monotonic() * 1000
            if (current_time - last_infer_time) < FRAME_SKIP_MS:
                continue

            try:
                # Decode Base64 → OpenCV image
                header, encoded = raw_data.split(",", 1) if "," in raw_data else (None, raw_data)
                img_bytes = base64.b64decode(encoded)
                np_img = np.frombuffer(img_bytes, dtype=np.uint8)
                frame = cv2.imdecode(np_img, cv2.IMREAD_COLOR)

                if frame is None:
                    continue

                # Run inference in thread pool to keep event loop responsive
                loop = asyncio.get_running_loop()
                results = await loop.run_in_executor(
                    None,
                    lambda: model.predict(
                        frame,
                        device="cpu",
                        verbose=False,
                        conf=CONF_THRESHOLD,
                        max_det=MAX_DET,
                    )[0],
                )

                last_infer_time = time.monotonic() * 1000
                frame_count += 1

                # Process results
                if len(results.boxes) > 0:
                    box = results.boxes[0]
                    cls_id = int(box.cls[0])
                    raw_label = model.names[cls_id]
                    raw_conf = float(box.conf[0])
                    label, conf = smoother.push(raw_label, raw_conf)
                else:
                    label, conf = smoother.push("No Sign", 0.0)

                await websocket.send_json({
                    "type": "prediction",
                    "label": label,
                    "confidence": conf,
                    "frame": frame_count,
                })

            except Exception as e:
                log.debug(f"Frame processing error: {e}")
                continue

    except WebSocketDisconnect:
        log.info(f"🔌 WebSocket Disconnected: {websocket.client}")
    finally:
        smoother.reset()


# ─────────────────────────────────────────────
# SYSTEM ENDPOINTS
# ─────────────────────────────────────────────
@app.get("/health")
def health_check():
    return {
        "status": "online",
        "model_loaded": model is not None,
        "engine": "YOLOv11-CPU",
    }


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("app:app", host="0.0.0.0", port=port, log_level="info")