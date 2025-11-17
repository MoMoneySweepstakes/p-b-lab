#!/usr/bin/env python3
import time, socket, requests, os
HOSTNAME = os.uname().nodename
ORCH = os.environ.get("ORCH_URL", "http://192.168.1.250:9001")  # change HOST.IP to orchestrator host IP

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

def register():
    ip = get_ip()
    data = {"hostname": HOSTNAME, "ip": ip}
    try:
        requests.post(f"{ORCH}/register", json=data, timeout=5)
        print("Registered with orchestrator:", data)
    except Exception as e:
        print("Registration failed:", e)

def heartbeat_loop():
    while True:
        try:
            requests.post(f"{ORCH}/heartbeat", json={"hostname": HOSTNAME}, timeout=3)
        except Exception:
            pass
        time.sleep(10)

if __name__ == "__main__":
    register()
    heartbeat_loop()
