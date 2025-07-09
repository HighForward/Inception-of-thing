#!/bin/bash

MASTER_IP=$1

if [ -z "$MASTER_IP" ]; then
  echo "Usage: $0 <MASTER_IP>"
  exit 1
fi

TOKEN_FILE="/vagrant/confs/token"

echo "Waiting for token file from master at $TOKEN_FILE..."
while [ ! -f "$TOKEN_FILE" ]; do
  sleep 2
done
echo "Token file found."

TOKEN=$(cat "$TOKEN_FILE")

if [ -z "$TOKEN" ]; then
  echo "Error: Token file is empty. Exiting."
  exit 1
fi

echo "Joining K3s cluster at https://$MASTER_IP:6443..."
curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="$TOKEN" sh -s - --node-ip=192.168.56.111
