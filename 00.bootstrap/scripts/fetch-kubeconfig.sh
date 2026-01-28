#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 6 ]]; then
  echo "Uso: $0 <ssh_user> <server_ip> <ssh_key_path> <dest_path> <api_server_ip> <ready_marker>" >&2
  exit 1
fi

SSH_USER="$1"
SERVER_IP="$2"
SSH_KEY_PATH="$3"
DEST_PATH="$4"
API_SERVER_IP="$5"
READY_MARKER="$6"

TMP_FILE="$(mktemp)"

mkdir -p "$(dirname "$DEST_PATH")"

scp \
  -i "$SSH_KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  "${SSH_USER}@${SERVER_IP}:/etc/rancher/k3s/k3s.yaml" \
  "$TMP_FILE"

# Reemplaza el endpoint local por la IP/punto final del Load Balancer
sed -i "s/127.0.0.1/${API_SERVER_IP}/g" "$TMP_FILE"

mv "$TMP_FILE" "$DEST_PATH"
chmod 600 "$DEST_PATH"
touch "$READY_MARKER"
echo "[INFO] kubeconfig actualizado en $DEST_PATH"
