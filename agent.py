#!/usr/bin/env python3
import os, time, requests, json, psutil, platform
SERVER = "http://nikadatech.ddns.net"
AUTH_URL = f"{SERVER}/api/auth/login"
LOG_URL = f"{SERVER}/api/agent/logs"
VERSION_FILE_URL = "https://raw.githubusercontent.com/NiKaDa2808/NiKaDa-client-setup/main/version.txt"
LOCAL_VERSION_FILE = "version.txt"
UPDATE_SCRIPT = "update_client.sh"
TOKEN_FILE = "client_token.txt"
EMAIL = os.getenv("CYBERAI_EMAIL")
PASSWORD = os.getenv("CYBERAI_PASSWORD")
def authenticate(retries=3):
    for attempt in range(retries):
        try:
            res = requests.post(AUTH_URL, json={"email": EMAIL, "password": PASSWORD})
            if res.status_code == 200:
                token = res.json().get("access_token")
                open(TOKEN_FILE, "w").write(token)
                return token
        except Exception as e:
            print(f"⚠️ Login error: {e}")
        time.sleep(5)
    return None
def get_token():
    return open(TOKEN_FILE).read().strip() if os.path.exists(TOKEN_FILE) else authenticate()
def check_for_update():
    try:
        local = open(LOCAL_VERSION_FILE).read().strip()
        r = requests.get(VERSION_FILE_URL)
        if r.ok and r.text.strip() != local:
            os.system(f"bash {UPDATE_SCRIPT}")
            exit()
    except Exception as e:
        print("Update check failed:", e)
def collect_system_stats():
    return {
        "cpu_percent": psutil.cpu_percent(),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": psutil.disk_usage('/').percent,
        "boot_time": psutil.boot_time(),
        "hostname": platform.node(),
        "platform": platform.system(),
        "running_processes": len(psutil.pids())
    }
def send_log():
    token = get_token()
    if not token: return
    headers = {"Authorization": f"Bearer {token}"}
    data = {
        "input_data": json.dumps(collect_system_stats()),
        "prediction_result": "system_status",
        "model_type": "agent_monitor"
    }
    try:
        requests.post(LOG_URL, json=data, headers=headers)
    except Exception as e:
        print("Log send error:", e)
if __name__ == "__main__":
    while True:
        check_for_update()
        send_log()
        time.sleep(60)
