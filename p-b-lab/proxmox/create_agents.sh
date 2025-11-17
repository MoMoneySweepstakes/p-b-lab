


#!/bin/bash

# --- SETTINGS ---
AGENT_NAME=$1

if [ -z "$AGENT_NAME" ]; then
  echo "Usage: ./create_agent.sh <agent-name>"
  exit 1
fi

# VM/LXC template settings
TEMPLATE_ID=9000
NEW_ID=$((200 + RANDOM % 500))

# Download if template not found
if ! qm status $TEMPLATE_ID &> /dev/null; then
  echo "Downloading Debian template..."
  pveam update
  pveam download local debian-12-standard_12.0-1_amd64.tar.zst
  TEMPLATE_ID=local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst
fi

# Create container
echo "Creating container..."
pct create $NEW_ID $TEMPLATE_ID \
  -hostname $AGENT_NAME \
  -cores 1 \
  -memory 1024 \
  -net0 name=eth0,bridge=vmbr0,ip=dhcp,type=veth

# Start the agent
pct start $NEW_ID

echo "$AGENT_NAME created with ID $NEW_ID"
