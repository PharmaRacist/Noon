#!/usr/bin/env python3
import json
import subprocess

import psutil

cpu_freq = psutil.cpu_freq()
temps = psutil.sensors_temperatures()
cpu_temp = 0

if "coretemp" in temps:
    cpu_temp = sum(t.current for t in temps["coretemp"]) / len(temps["coretemp"])
elif "k10temp" in temps:
    cpu_temp = temps["k10temp"][0].current
elif "cpu_thermal" in temps:
    cpu_temp = temps["cpu_thermal"][0].current

mem = psutil.virtual_memory()
swap = psutil.swap_memory()

result = {
    "cpu_percent": psutil.cpu_percent(interval=0.5),
    "cpu_freq_ghz": cpu_freq.current / 1000 if cpu_freq else 0,
    "cpu_temp": cpu_temp,
    "mem_total": mem.total,
    "mem_available": mem.available,
    "swap_total": swap.total,
    "swap_free": swap.free,
    "gpus": [],
}

try:
    gpu_output = subprocess.check_output(
        ["gpustat", "--json"], stderr=subprocess.DEVNULL
    ).decode()
    gpu_data = json.loads(gpu_output)
    for gpu in gpu_data.get("gpus", []):
        result["gpus"].append(
            {
                "index": gpu.get("index", 0),
                "name": gpu.get("name", "Unknown"),
                "utilization": gpu.get("utilization.gpu", 0),
                "temperature": gpu.get("temperature.gpu", 0),
                "memory_used": gpu.get("memory.used", 0),
                "memory_total": gpu.get("memory.total", 1),
                "power_draw": gpu.get("power.draw", 0),
                "power_limit": gpu.get("enforced.power.limit", 0),
            }
        )
except:
    pass

print(json.dumps(result))
