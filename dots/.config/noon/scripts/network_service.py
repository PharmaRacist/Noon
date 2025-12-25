#!/usr/bin/env python3
import json
import subprocess
import time
import sys
import psutil
import threading

class NetworkMonitor:
    def __init__(self):
        self.last_io = None
        self.last_time = 0
    
    def format_speed(self, bps):
        if bps < 1024:
            return f"{bps:.0f} B/s"
        elif bps < 1024 * 1024:
            return f"{bps / 1024:.1f} KB/s"
        elif bps < 1024 * 1024 * 1024:
            return f"{bps / (1024 * 1024):.1f} MB/s"
        return f"{bps / (1024 * 1024 * 1024):.2f} GB/s"
    
    def get_active_interface(self):
        try:
            stats = psutil.net_if_stats()
            for iface, stat in stats.items():
                if stat.isup and not iface.startswith('lo'):
                    return iface
        except:
            pass
        return None
    
    def get_network_speed(self):
        try:
            iface = self.get_active_interface()
            if not iface:
                return 0, 0
            
            io_all = psutil.net_io_counters(pernic=True)
            if iface not in io_all:
                return 0, 0
            
            io = io_all[iface]
            now = time.time()
            download, upload = 0, 0
            
            if self.last_io and self.last_time > 0:
                dt = now - self.last_time
                if dt > 0:
                    download = max(0, (io.bytes_recv - self.last_io.bytes_recv) / dt)
                    upload = max(0, (io.bytes_sent - self.last_io.bytes_sent) / dt)
            
            self.last_io = io
            self.last_time = now
            return download, upload
        except:
            return 0, 0
    
    def run_nmcli(self, args):
        try:
            return subprocess.check_output(
                ["nmcli"] + args,
                stderr=subprocess.DEVNULL,
                timeout=2
            ).decode().strip()
        except:
            return ""
    
    def get_saved_networks(self):
        """Get list of saved/known network SSIDs"""
        try:
            output = self.run_nmcli(["-t", "-f", "NAME,TYPE", "connection", "show"])
            saved = set()
            for line in output.split('\n'):
                if not line:
                    continue
                parts = line.split(':')
                if len(parts) >= 2 and '802-11-wireless' in parts[1]:
                    saved.add(parts[0])
            return saved
        except:
            return set()
    
    def get_wifi_icon(self, strength, enabled, status, ethernet):
        if ethernet:
            return "lan"
        if not enabled:
            return "signal_wifi_off"
        if status == "connecting":
            return "signal_wifi_statusbar_not_connected"
        if status != "connected":
            return "wifi_find"
        
        icons = ["signal_wifi_0_bar", "network_wifi_1_bar", "network_wifi_2_bar", 
                 "network_wifi_3_bar", "network_wifi", "signal_wifi_4_bar"]
        idx = min(5, max(0, strength // 17))
        return icons[idx]
    
    def get_status(self):
        try:
            iface = self.get_active_interface() or ""
            ethernet = any(x in iface for x in ['eth', 'enp', 'eno'])
            wifi = any(x in iface for x in ['wlan', 'wlp'])
            
            wifi_enabled = self.run_nmcli(["radio", "wifi"]) == "enabled"
            
            wifi_status = "disconnected"
            if wifi:
                status_out = self.run_nmcli(["-t", "-f", "TYPE,STATE", "d", "status"])
                for line in status_out.split('\n'):
                    if "wifi" in line:
                        if "connected" in line:
                            wifi_status = "connected"
                        elif "connecting" in line:
                            wifi_status = "connecting"
                        break
            
            signal = 0
            if wifi:
                sig_out = self.run_nmcli(["-f", "IN-USE,SIGNAL", "device", "wifi"])
                for line in sig_out.split('\n'):
                    if line.strip().startswith('*'):
                        parts = line.split()
                        if len(parts) >= 2:
                            try:
                                signal = int(parts[1])
                            except:
                                pass
                        break
            
            network_name = ""
            name_out = self.run_nmcli(["-t", "-f", "NAME", "c", "show", "--active"])
            if name_out:
                network_name = name_out.split('\n')[0]
            
            download, upload = self.get_network_speed()
            
            # Get saved networks once per update
            saved_networks = self.get_saved_networks()
            
            networks = []
            if wifi_enabled:
                nets_out = self.run_nmcli(["-g", "ACTIVE,SIGNAL,SSID,SECURITY", "d", "w"])
                seen = set()
                for line in nets_out.split('\n'):
                    if not line:
                        continue
                    parts = line.replace('\\:', '|||').split(':')
                    if len(parts) >= 3:
                        ssid = parts[2].replace('|||', ':')
                        if ssid and ssid not in seen:
                            seen.add(ssid)
                            try:
                                strength = int(parts[1]) if parts[1] else 0
                            except:
                                strength = 0
                            
                            has_security = len(parts) > 3 and parts[3]
                            is_saved = ssid in saved_networks
                            
                            networks.append({
                                "active": parts[0] == "yes",
                                "strength": strength,
                                "strength_text": f"{strength}%",
                                "ssid": ssid,
                                "security": parts[3] if len(parts) > 3 else "",
                                "security_text": "Secured" if has_security else "Open",
                                "saved": is_saved
                            })
            
            return {
                "wifi_enabled": wifi_enabled,
                "ethernet": ethernet,
                "wifi": wifi,
                "wifi_status": wifi_status,
                "network_name": network_name,
                "signal_strength": signal,
                "signal_strength_text": f"{signal}%",
                "material_icon": self.get_wifi_icon(signal, wifi_enabled, wifi_status, ethernet),
                "wifi_networks": networks,
                "download_speed": download,
                "upload_speed": upload,
                "download_speed_text": self.format_speed(download),
                "upload_speed_text": self.format_speed(upload)
            }
        except Exception as e:
            return {
                "wifi_enabled": False,
                "ethernet": False,
                "wifi": False,
                "wifi_status": "unknown",
                "network_name": "",
                "signal_strength": 0,
                "signal_strength_text": "0%",
                "material_icon": "signal_wifi_bad",
                "wifi_networks": [],
                "download_speed": 0,
                "upload_speed": 0,
                "download_speed_text": "0 B/s",
                "upload_speed_text": "0 B/s",
                "error": str(e)
            }
    
    def handle_command(self, cmd_line):
        """Handle commands from stdin"""
        try:
            cmd = json.loads(cmd_line)
            action = cmd.get("action")
            
            if action == "enable_wifi":
                mode = "on" if cmd.get("enabled", True) else "off"
                self.run_nmcli(["radio", "wifi", mode])
            
            elif action == "toggle_wifi":
                current = self.run_nmcli(["radio", "wifi"]) == "enabled"
                mode = "off" if current else "on"
                self.run_nmcli(["radio", "wifi", mode])
            
            elif action == "rescan_wifi":
                self.run_nmcli(["dev", "wifi", "list", "--rescan", "yes"])
            
            elif action == "connect":
                ssid = cmd.get("ssid", "")
                password = cmd.get("password", "")
                if ssid:
                    args = ["dev", "wifi", "connect", ssid]
                    if password:
                        args.extend(["password", password])
                    self.run_nmcli(args)
            
            elif action == "disconnect":
                ssid = cmd.get("ssid", "")
                if ssid:
                    self.run_nmcli(["connection", "down", ssid])
            
            elif action == "forget":
                ssid = cmd.get("ssid", "")
                if ssid:
                    self.run_nmcli(["connection", "delete", ssid])
            
        except Exception as e:
            print(json.dumps({"error": f"Command error: {str(e)}"}), file=sys.stderr, flush=True)

def stdin_reader(monitor):
    """Read commands from stdin in separate thread"""
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            monitor.handle_command(line.strip())
        except:
            break

def main():
    sys.stdout.reconfigure(line_buffering=True)
    sys.stderr.reconfigure(line_buffering=True)
    
    monitor = NetworkMonitor()
    
    # Start stdin reader thread
    thread = threading.Thread(target=stdin_reader, args=(monitor,), daemon=True)
    thread.start()
    
    print(json.dumps({"status": "started"}), flush=True)
    
    while True:
        try:
            status = monitor.get_status()
            print(json.dumps(status), flush=True)
            time.sleep(1)
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(json.dumps({"error": str(e)}), flush=True)
            time.sleep(1)

if __name__ == "__main__":
    main()
