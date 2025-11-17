#!/usr/bin/env python3
from flask import Flask, request, jsonify
import threading, time

app = Flask(__name__)
AGENTS = {}  # hostname -> info dict

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    hostname = data.get("hostname")
    if not hostname:
        return "bad", 400
    AGENTS[hostname] = {"hostname": hostname, "ip": data.get("ip"), "last_seen": time.time()}
    return "ok"

@app.route("/heartbeat", methods=["POST"])
def hb():
    data = request.get_json()
    hostname = data.get("hostname")
    if hostname in AGENTS:
        AGENTS[hostname]["last_seen"]=time.time()
    return "ok"

@app.route("/agents", methods=["GET"])
def agents():
    # return list of agents
    return jsonify(list(AGENTS.values()))

def cleanup_loop():
    import time
    while True:
        now = time.time()
        for k in list(AGENTS.keys()):
            if now - AGENTS[k]["last_seen"] > 60:
                del AGENTS[k]
        time.sleep(10)

if __name__ == "__main__":
    t = threading.Thread(target=cleanup_loop, daemon=True)
    t.start()
    app.run(host="0.0.0.0", port=9001)
