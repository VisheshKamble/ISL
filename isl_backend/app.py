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
import gdown
from ultralytics import YOLO

# ─────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  [%(levelname)s]  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("vani")

# ─────────────────────────────────────────────
# APP & CORS
# ─────────────────────────────────────────────
app = FastAPI(title="VANI ISL Backend", version="2.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─────────────────────────────────────────────
# MODEL LOAD (GOOGLE DRIVE)
# ─────────────────────────────────────────────
os.makedirs("model", exist_ok=True)
MODEL_PATH = os.path.join("model", "isl_best.pt")

# 🔥 FIXED: The exact ID and the DIRECT download URL format
FILE_ID = "1TcCNyM1MtbixlN3wZgFttOlvuJutTPqB"

def download_model():
    # If file is tiny (< 1MB), it's just HTML/error text. Delete it to retry.
    if os.path.exists(MODEL_PATH) and os.path.getsize(MODEL_PATH) < 1000000:
        log.info("🗑️ Detected corrupted model file, deleting to redownload...")
        os.remove(MODEL_PATH)

    if not os.path.exists(MODEL_PATH):
        try:
            log.info("📥 Downloading model from Google Drive...")
            # Use the 'uc' (user content) URL for direct downloading
            url = f"https://drive.google.com/uc?id={FILE_ID}"
            gdown.download(url, MODEL_PATH, quiet=False)
            log.info("✅ Download complete!")
        except Exception as e:
            log.error(f"❌ Failed to download model: {e}")
            raise
    return True

# Run download and load model
download_model()

if not os.path.exists(MODEL_PATH) or os.path.getsize(MODEL_PATH) < 1000000:
    raise ValueError("❌ Model file is still corrupted or too small. Check Drive permissions!")

try:
    model = YOLO(MODEL_PATH)
    model.to("cpu")
    model.fuse() 
    log.info(f"✅ Model loaded successfully from {MODEL_PATH}")
except Exception as e:
    log.error(f"❌ Model failed to load: {e}")
    raise

# ─────────────────────────────────────────────
# INFERENCE CONFIG
# ─────────────────────────────────────────────
CONF_THRESHOLD = 0.30
MAX_DET = 1
SMOOTH_WINDOW = 5
FRAME_SKIP_MS = 80 

class PredictionSmoother:
    def __init__(self, window: int = SMOOTH_WINDOW):
        self._window = window
        self._buf = deque(maxlen=window)

    def push(self, label: str, conf: float):
        self._buf.append((label, conf))
        if len(self._buf) < self._window:
            return label, conf

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
    log.info(f"🔌 Connected {websocket.client}")

    smoother = PredictionSmoother()
    last_infer = 0.0
    frame_count = 0

    try:
        while True:
            try:
                raw = await asyncio.wait_for(websocket.receive_text(), timeout=15.0)
            except asyncio.TimeoutError:
                await websocket.send_json({"type": "ping"})
                continue

            if raw == "__STOP__":
                smoother.reset()
                await websocket.send_json({"type": "stopped"})
                continue

            if raw == "__PING__":
                await websocket.send_json({"type": "pong"})
                continue

            now_ms = time.monotonic() * 1000
            if (now_ms - last_infer) < FRAME_SKIP_MS:
                continue

            try:
                b64 = raw.split(",")[-1]
                img_bytes = base64.b64decode(b64)
                np_img = np.frombuffer(img_bytes, dtype=np.uint8)
                frame = cv2.imdecode(np_img, cv2.IMREAD_COLOR)

                if frame is None: continue

                loop = asyncio.get_event_loop()
                results = await loop.run_in_executor(
                    None,
                    lambda: model.predict(
                        frame, device="cpu", verbose=False, 
                        conf=CONF_THRESHOLD, max_det=MAX_DET
                    )[0],
                )

                last_infer = time.monotonic() * 1000
                frame_count += 1

                if len(results.boxes) > 0:
                    box = results.boxes[0]
                    label, conf = smoother.push(model.names[int(box.cls[0])], float(box.conf[0]))
                else:
                    label, conf = smoother.push("No Sign", 0.0)

                await websocket.send_json({
                    "type": "prediction",
                    "label": label,
                    "confidence": conf,
                    "frame": frame_count,
                })

            except Exception as e:
                log.warning(f"Frame error: {e}")

    except WebSocketDisconnect:
        log.info("Disconnected")
    finally:
        smoother.reset()

@app.get("/health")
def health():
    return {"status": "ok", "model": MODEL_PATH}

if __name__ == "__main__":
    import uvicorn
    # Use Railway's dynamic port
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)