from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import cv2
import numpy as np
import base64
import asyncio
import os
import time
import logging
from collections import deque
from urllib.request import urlopen
from typing import Any
import gdown
from ultralytics import YOLO
from twilio.rest import Client

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

TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID", "")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "")
TWILIO_FROM_NUMBER = os.getenv("TWILIO_FROM_NUMBER", "")


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
# Direct ID from your link
FILE_ID = "1TcCNyM1MtbixlN3wZgFttOlvuJutTPqB"
MIN_MODEL_BYTES = 10_000_000


def _download_model(url: str, destination: str) -> None:
    with urlopen(url) as response, open(destination, "wb") as target:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            target.write(chunk)


def _download_model_from_drive(file_id: str, destination: str) -> None:
    url = f"https://drive.google.com/uc?id={file_id}"

    # Primary path: gdown handles Drive confirmation pages and redirects.
    try:
        gdown.download(url, destination, quiet=False, fuzzy=True)
        return
    except Exception as e:
        log.warning(f"gdown download failed, trying urllib fallback: {e}")

    # Fallback path for environments where gdown has transient issues.
    _download_model(url, destination)


def _is_model_file_valid(path: str) -> bool:
    return os.path.exists(path) and os.path.getsize(path) >= MIN_MODEL_BYTES

def initialize_model():
    """Downloads model if missing/corrupt and loads into memory."""
    # 1. Clean up old/failed downloads (HTML error pages are usually < 1MB)
    if os.path.exists(MODEL_PATH) and os.path.getsize(MODEL_PATH) < MIN_MODEL_BYTES:
        log.info("🗑️ Deleting corrupted model file (size too small)...")
        os.remove(MODEL_PATH)

    # 2. Download from Google Drive
    if not os.path.exists(MODEL_PATH):
        try:
            log.info(f"📥 Downloading model ID: {FILE_ID}")
            _download_model_from_drive(FILE_ID, MODEL_PATH)

            if not _is_model_file_valid(MODEL_PATH):
                raise RuntimeError(
                    f"Downloaded file appears invalid (size={os.path.getsize(MODEL_PATH)} bytes)."
                )

            log.info("✅ Download complete!")
        except Exception as e:
            log.error(f"❌ Download failed: {e}")
            return None

    # 3. Load YOLO model
    try:
        # Note: 'ultralytics>=8.3.0' is required for YOLOv11 (C3k2 layer)
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


class SOSContact(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    phone: str = Field(min_length=5, max_length=24)


class SOSLocation(BaseModel):
    latitude: float | None = None
    longitude: float | None = None
    display: str | None = None
    maps_link: str | None = None


class SOSDispatchRequest(BaseModel):
    type: str = Field(min_length=1, max_length=40)
    message: str = Field(min_length=5, max_length=4000)
    contacts: list[SOSContact]
    location: SOSLocation | None = None
    platform: str | None = None
    sent_at: str | None = None


def _normalize_phone(phone: str) -> str:
    digits = "".join(ch for ch in phone if ch.isdigit())
    if digits.startswith("00"):
        digits = digits[2:]
    if digits.startswith("0") and len(digits) == 11:
        digits = digits[1:]
    if len(digits) == 10:
        digits = "91" + digits
    if not digits.startswith("+"):
        digits = "+" + digits
    return digits


def _twilio_client_or_raise(account_sid: str, auth_token: str, from_number: str) -> Client:
    if not account_sid or not auth_token or not from_number:
        raise HTTPException(
            status_code=503,
            detail="Twilio is not configured on the server.",
        )
    return Client(account_sid, auth_token)

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

            # Handling Protocol Commands
            if raw_data == "__PING__":
                await websocket.send_json({"type": "pong"})
                continue
            if raw_data == "__STOP__":
                smoother.reset()
                continue

            # Frame Throttling
            current_time = time.monotonic() * 1000
            if (current_time - last_infer_time) < FRAME_SKIP_MS:
                continue

            try:
                # Decode Base64 to OpenCV Image
                header, encoded = raw_data.split(",", 1) if "," in raw_data else (None, raw_data)
                img_bytes = base64.b64decode(encoded)
                np_img = np.frombuffer(img_bytes, dtype=np.uint8)
                frame = cv2.imdecode(np_img, cv2.IMREAD_COLOR)

                if frame is None:
                    continue

                # Run Inference in thread pool to keep loop responsive
                loop = asyncio.get_running_loop()
                results = await loop.run_in_executor(None, lambda: model.predict(
                    frame, 
                    device="cpu", 
                    verbose=False, 
                    conf=CONF_THRESHOLD, 
                    max_det=MAX_DET
                )[0])

                last_infer_time = time.monotonic() * 1000
                frame_count += 1

                # Process Results
                if len(results.boxes) > 0:
                    box = results.boxes[0]
                    cls_id = int(box.cls[0])
                    raw_label = model.names[cls_id]
                    raw_conf = float(box.conf[0])
                    label, conf = smoother.push(raw_label, raw_conf)
                else:
                    label, conf = smoother.push("No Sign", 0.0)

                # Send Response
                await websocket.send_json({
                    "type": "prediction",
                    "label": label,
                    "confidence": conf,
                    "frame": frame_count
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
        "engine": "YOLOv11-CPU"
    }


@app.post("/sos/send")
def send_sos(payload: SOSDispatchRequest, request: Request) -> dict[str, Any]:
    account_sid = TWILIO_ACCOUNT_SID or request.headers.get("x-twilio-account-sid", "")
    auth_token = TWILIO_AUTH_TOKEN or request.headers.get("x-twilio-auth-token", "")
    from_number = TWILIO_FROM_NUMBER or request.headers.get("x-twilio-from-number", "")
    client = _twilio_client_or_raise(account_sid, auth_token, from_number)

    contacts = payload.contacts[:5]
    if not contacts:
        raise HTTPException(status_code=400, detail="No contacts provided.")

    sent_count = 0
    errors: list[str] = []

    for c in contacts:
        try:
            to_number = _normalize_phone(c.phone)
            msg = client.messages.create(
                body=payload.message,
                from_=from_number,
                to=to_number,
            )
            sent_count += 1
            log.info("SOS SMS sent to %s (%s) sid=%s", c.name, to_number, msg.sid)
        except Exception as e:
            err = f"{c.name}: {e}"
            errors.append(err)
            log.error("SOS SMS failed for %s: %s", c.name, e)

    success = sent_count > 0
    return {
        "success": success,
        "sent_count": sent_count,
        "total_contacts": len(contacts),
        "errors": errors,
        "message": (
            f"Alert sent to {sent_count} contact(s)."
            if success
            else "Failed to send alert via Twilio."
        ),
    }

if __name__ == "__main__":
    import uvicorn
    # Railway sets the PORT environment variable automatically
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("app:app", host="0.0.0.0", port=port, log_level="info")