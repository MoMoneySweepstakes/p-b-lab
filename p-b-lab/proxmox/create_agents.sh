#!/usr/bin/env bash
set -euo pipefail

# EDIT THESE if needed
TEMPLATE="local:vztmpl/debian-12-standard_12.0-1_amd64.tar.gz"  # pveam usually stores under local:vztmpl/
STORAGE="local-lvm"        # change to your storage name if different
BRIDGE="vmbr0"
BASE_ID=120
NUM_AGENTS=3               # start small on low-RAM host
MEMORY_MB=512              # per container memory
CORES=1

REPO_RAW_BASE="https://raw.githubusercontent.com/YOURUSERNAME/pbtb-lab/main"

for i in $(seq 1 $NUM_AGENTS); do
  CTID=$((BASE_ID + i))
  HOSTNAME="agent-$i"
  echo "Creating container $CTID ($HOSTNAME)..."
  pct destroy $CTID --purge 2>/dev/null || true

  pct create $CTID $TEMPLATE \
    --hostname $HOSTNAME \
    --storage $STORAGE \
    --rootfs "${STORAGE}:2" \
    --memory $MEMORY_MB \
    --cores $CORES \
    --net0 name=eth0,bridge=$BRIDGE,ip=dhcp

  pct start $CTID

  echo "Waiting for container $CTID to boot..."
  sleep 5

  # Install essentials and pull agent code
  pct exec $CTID -- bash -lc "apt update && apt install -y python3 python3-venv git curl && \
      mkdir -p /opt/pbtb && cd /opt/pbtb && \
      git clone https://github.com/YOURUSERNAME/pbtb-lab.git . || (cd /opt && curl -sSL ${REPO_RAW_BASE}/proxmox/agent_template/start_agent.sh -o /usr/local/bin/start_agent.sh && chmod +x /usr/local/bin/start_agent.sh)"

  # Start agent (non-blocking) inside the container
  pct exec $CTID -- bash -lc "nohup /usr/local/bin/start_agent.sh > /var/log/start_agent.log 2>&1 &" || true

  echo "Agent $HOSTNAME created and start_agent launched."
done

echo "All done. Run 'pct list' to see containers."
