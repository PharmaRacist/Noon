#!/usr/bin/env python3
import asyncio

# --- 1. PROMPT BYPASS: Fix "Are you sure this is the right device?" ---
# This monkeypatch forces the library to skip the terminal confirmation.
import builtins
import json
import os
import socket
import sys
import threading
from pathlib import Path

builtins.input = lambda _: "y"

try:
    import pyquickshare.receive as _mod_recv

    # Apply to the specific module as well to ensure it catches internal calls
    _mod_recv.input = lambda _: "y"
except Exception:
    pass

# --- 2. Port Capture for mDNS ---
try:
    import pyquickshare.mdns.receive as _mdns_receive
except ImportError:
    _mdns_receive = None

_recv_port: int = 0


async def _capture_port(*args, **kwargs):
    global _recv_port
    for a in args:
        if isinstance(a, int) and a > 0:
            _recv_port = a
            return
    if "port" in kwargs and isinstance(kwargs["port"], int):
        _recv_port = kwargs["port"]


if _mdns_receive:
    _mdns_receive.temporarily_open_port = _capture_port

from pyquickshare import discover_services, receive, send_to


def _local_ip() -> str:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return socket.gethostbyname(socket.gethostname())


def emit(event: str, **kwargs) -> None:
    """Standardized output. Note: Added 'discoveryStarted' check logic."""
    print(json.dumps({"event": event, **kwargs}), flush=True)


class Bridge:
    def __init__(self):
        self._recv_task = None
        self._discovered = {}
        self._output_dir = str(Path.home() / "Downloads" / "QuickShare")

    async def start_receiving(self, output_dir: str = None):
        global _recv_port
        if self._recv_task and not self._recv_task.done():
            emit("error", message="Receiver already active")
            return

        if output_dir:
            self._output_dir = output_dir

        os.makedirs(self._output_dir, exist_ok=True)
        os.chdir(self._output_dir)

        _recv_port = 0
        self._recv_task = asyncio.create_task(self._recv_loop())

        for _ in range(15):
            if _recv_port > 0:
                break
            await asyncio.sleep(0.1)

        ip = _local_ip()
        name = socket.gethostname()
        emit(
            "receiving",
            endpointName=name,
            ip=ip,
            port=_recv_port,
            qrData=f"nearby://{ip}:{_recv_port}?name={name}" if _recv_port else "",
        )

    async def _recv_loop(self):
        try:
            # FIX: endpoint_id MUST be 4 bytes ASCII for your version.
            eid = socket.gethostname()[:4].upper().ljust(4, "X")

            async for request in receive(endpoint_id=eid):
                emit(
                    "transferRequest",
                    sender=getattr(request, "sender_name", "Unknown Device"),
                    files=[
                        getattr(f, "name", "file")
                        for f in getattr(request, "files", [])
                    ],
                )

                # target_dir bypasses the hidden endpoint check in some versions.
                try:
                    results = await request.accept(target_dir=self._output_dir)
                    emit(
                        "transferComplete",
                        files=[str(f) for f in (results or [])],
                        outputDir=self._output_dir,
                    )
                except TypeError:
                    await request.accept()
                    emit(
                        "transferComplete",
                        files=["received_file"],
                        outputDir=self._output_dir,
                    )

        except asyncio.CancelledError:
            pass
        except Exception as e:
            emit("error", message=str(e))

    async def discover(self):
        self._discovered = {}
        count = 0
        # Check: QML doesn't know 'discoveryStarted', so we skip emitting it or change it
        # emit("discoveryStarted")
        try:
            iterator = await discover_services()
            try:
                while count < 15:
                    device = await asyncio.wait_for(iterator.__anext__(), timeout=5.0)
                    self._discovered[count] = device

                    name = getattr(device, "endpoint_name", None) or (
                        device.service_info.name.split(".")[0]
                        if hasattr(device, "service_info")
                        else f"Device {count}"
                    )

                    emit("deviceFound", index=count, name=name)
                    count += 1
            except (StopAsyncIteration, asyncio.TimeoutError):
                pass
        except Exception as e:
            emit("error", message=f"Discovery Error: {str(e)}")
        finally:
            emit("discoverDone", total=count)

    async def send_file(self, device_index: int, path: str):
        device = self._discovered.get(device_index)
        if not device:
            emit("error", message="Device index missing")
            return
        try:
            # FIX: singular 'file' keyword as required by your API version.
            await send_to(device, file=str(Path(path).absolute()))
            emit("sendComplete", fileName=Path(path).name)
        except Exception as e:
            emit("error", message=str(e))


_bridge = Bridge()


async def dispatch(data: dict):
    cmd = data.get("cmd")
    if cmd == "startReceiving":
        await _bridge.start_receiving(data.get("outputDir"))
    elif cmd == "stopReceiving":
        if _bridge._recv_task:
            _bridge._recv_task.cancel()
        emit("stopped")
    elif cmd == "discoverDevices":
        await _bridge.discover()
    elif cmd == "sendFile":
        await _bridge.send_file(data.get("deviceIndex"), data.get("path"))


async def main():
    emit("ready")
    loop = asyncio.get_running_loop()

    def _read_stdin():
        for line in sys.stdin:
            line = line.strip()
            if line:
                try:
                    asyncio.run_coroutine_threadsafe(dispatch(json.loads(line)), loop)
                except:
                    pass

    threading.Thread(target=_read_stdin, daemon=True).start()
    await asyncio.Event().wait()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(0)
