#!/usr/bin/env python3
import json
import subprocess
import psutil
import time
import sys

def get_nvidia_gpus():
    try:
        output = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=index,name,utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw,power.limit", 
             "--format=csv,noheader,nounits"],
            stderr=subprocess.DEVNULL
        ).decode()
        
        gpus = []
        for line in output.strip().split('\n'):
            if not line.strip():
                continue
            parts = [p.strip() for p in line.split(',')]
            if len(parts) >= 4:
                def safe_float(val, default=0):
                    try:
                        return float(val) if val not in ['N/A', '', 'null', '[N/A]'] else default
                    except:
                        return default
                
                gpus.append({
                    "index": safe_float(parts[0], 0),
                    "name": parts[1] if len(parts) > 1 else "NVIDIA GPU",
                    "vendor": "nvidia",
                    "utilization": safe_float(parts[2] if len(parts) > 2 else 0),
                    "temperature": safe_float(parts[3] if len(parts) > 3 else 0),
                    "memory_used": safe_float(parts[4] if len(parts) > 4 else 0),
                    "memory_total": safe_float(parts[5] if len(parts) > 5 else 1, 1),
                    "power_draw": safe_float(parts[6] if len(parts) > 6 else 0),
                    "power_limit": safe_float(parts[7] if len(parts) > 7 else 0),
                })
        return gpus
    except:
        return []

def get_intel_gpus():
    try:
        lspci_output = subprocess.check_output(["lspci"], stderr=subprocess.DEVNULL).decode()
        if not any(x in lspci_output.lower() for x in ["intel", "vga", "3d"]):
            return []
        
        utilization = 0
        try:
            output = subprocess.check_output(
                ["intel_gpu_top", "-J", "-s", "100"],
                stderr=subprocess.DEVNULL, timeout=2
            ).decode()
            data = json.loads(output.split('\n')[0])
            engines = data.get('engines', {})
            if engines:
                utilization = sum(e.get('busy', 0) for e in engines.values()) / len(engines)
        except:
            pass
        
        return [{
            "index": 1,
            "name": "Intel GPU",
            "vendor": "intel",
            "utilization": utilization,
            "temperature": 0,
            "memory_used": 0,
            "memory_total": 1,
            "power_draw": 0,
            "power_limit": 0,
        }]
    except:
        return []

def get_stats():
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

    gpus = []
    gpus.extend(get_nvidia_gpus())
    gpus.extend(get_intel_gpus())

    return {
        "cpu_percent": psutil.cpu_percent(interval=0.5),
        "cpu_freq_ghz": cpu_freq.current / 1000 if cpu_freq else 0,
        "cpu_temp": cpu_temp,
        "mem_total": mem.total,
        "mem_available": mem.available,
        "swap_total": swap.total,
        "swap_free": swap.free,
        "gpus": gpus,
    }

if __name__ == "__main__":
    # Flush output immediately
    sys.stdout.reconfigure(line_buffering=True)
    
    while True:
        try:
            stats = get_stats()
            print(json.dumps(stats), flush=True)
            time.sleep(1)
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(json.dumps({"error": str(e)}), file=sys.stderr, flush=True)
            time.sleep(1)
