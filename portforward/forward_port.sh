#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [host_to_forward_to] [port_to_forward]"
    exit 1
fi

FORWARD_TO_HOST=$1
FORWARD_PORT=$2
echo "Forwarding localhost:${FORWARD_PORT} -> ${FORWARD_TO_HOST}:${FORWARD_PORT}"
sudo -u nobody socat -d TCP-LISTEN:${FORWARD_PORT},fork TCP:${FORWARD_TO_HOST}:${FORWARD_PORT}
if [$# -ne 2]; then 
