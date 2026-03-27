#!/usr/bin/env python3
import argparse
import json
import os
import signal
import sys
import threading
from pathlib import Path

LOCK_FILE = Path("/tmp/stt.lock")
CHUNK_SECONDS = 5
OVERLAP_SECONDS = 1


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=Path, required=True)
    return parser.parse_args()


def main():
    if LOCK_FILE.exists():
        pid = LOCK_FILE.read_text().strip()
        if Path(f"/proc/{pid}").exists():
            print("STT already running", file=sys.stderr)
            sys.exit(1)
    LOCK_FILE.write_text(str(os.getpid()))

    try:
        args = parse_args()
        config = json.loads(args.config.read_text())

        import numpy as np
        import sounddevice as sd
        from faster_whisper import WhisperModel

        model_name = config.get("whisper_model", "base")
        device = config.get("device", "pipewire")
        sample_rate = 16000
        chunk_samples = CHUNK_SECONDS * sample_rate
        overlap_samples = OVERLAP_SECONDS * sample_rate

        all_chunks = []
        window_chunks = []
        lock = threading.Lock()
        recording = True
        last_printed = ""

        cache = Path.home() / ".cache/huggingface/hub"
        model_cached = (
            any(model_name in str(p) for p in cache.glob("**/config.json"))
            if cache.exists()
            else False
        )
        if not model_cached:
            print(f"Downloading model '{model_name}'...", file=sys.stderr)
        model = WhisperModel(model_name, device="cpu", compute_type="int8")
        if not model_cached:
            print("Download complete.", file=sys.stderr)

        def stop(*_):
            nonlocal recording
            recording = False

        signal.signal(signal.SIGTERM, stop)
        signal.signal(signal.SIGINT, stop)

        def callback(indata, frames, time, status):
            with lock:
                all_chunks.append(indata.copy())
                window_chunks.append(indata.copy())

        def transcribe_loop():
            nonlocal last_printed
            collected = 0
            while recording:
                with lock:
                    total = sum(c.shape[0] for c in window_chunks)
                if total < chunk_samples:
                    threading.Event().wait(0.5)
                    continue
                with lock:
                    audio_window = np.concatenate(window_chunks).flatten()
                    kept_samples = min(overlap_samples, len(audio_window))
                    kept = audio_window[-kept_samples:]
                    window_chunks.clear()
                    window_chunks.append(kept.reshape(-1, 1))
                segments, _ = model.transcribe(
                    audio_window, language=config.get("language")
                )
                text = " ".join(s.text.strip() for s in segments).strip()
                if text and text != last_printed:
                    print(f"\r\033[K[live] {text}", end="", file=sys.stderr, flush=True)
                    last_printed = text

        t = threading.Thread(target=transcribe_loop, daemon=True)
        t.start()

        print("Recording... (Ctrl+C or SIGTERM to stop)\n", file=sys.stderr)
        with sd.InputStream(
            samplerate=sample_rate,
            channels=1,
            dtype="float32",
            device=device,
            callback=callback,
        ):
            signal.pause()

        print("", file=sys.stderr)

        with lock:
            final_audio = (
                np.concatenate(all_chunks).flatten() if all_chunks else np.array([])
            )

        if final_audio.size > 0:
            segments, _ = model.transcribe(final_audio, language=config.get("language"))
            print(" ".join(s.text.strip() for s in segments))

    finally:
        LOCK_FILE.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
