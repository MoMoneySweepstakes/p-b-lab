#!/usr/bin/env bash
set -euo pipefail
cd /opt/pbtb || exit 1

# create a small venv if missing
python3 -m venv /opt/pbtb/venv || true
source /opt/pbtb/venv/bin/activate
pip install --no-cache-dir -r requirements.txt || true

# start the main agent script (non-blocking)
nohup python3 /opt/pbtb/proxmox/agent_template/agent_main.py >> /var/log/agent_main.log 2>&1 &
