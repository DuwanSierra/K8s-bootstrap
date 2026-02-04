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

# Configuración de reintentos/timeout (pueden sobreescribirse por variables de entorno)
RETRIES="${RETRIES:-45}"
RETRY_SLEEP_SECONDS="${RETRY_SLEEP_SECONDS:-30}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-10}"
SERVER_ALIVE_INTERVAL="${SERVER_ALIVE_INTERVAL:-10}"
SERVER_ALIVE_COUNT_MAX="${SERVER_ALIVE_COUNT_MAX:-3}"

TMP_FILE="$(mktemp)"

mkdir -p "$(dirname "$DEST_PATH")"

attempt=1
while true; do
  if scp \
    -i "$SSH_KEY_PATH" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ConnectTimeout="$CONNECT_TIMEOUT" \
    -o ServerAliveInterval="$SERVER_ALIVE_INTERVAL" \
    -o ServerAliveCountMax="$SERVER_ALIVE_COUNT_MAX" \
    "${SSH_USER}@${SERVER_IP}:/etc/rancher/k3s/k3s.yaml" \
    "$TMP_FILE"; then
    break
  fi

  if [[ $attempt -ge $RETRIES ]]; then
    echo "[ERROR] scp falló luego de ${RETRIES} intentos." >&2
    exit 1
  fi

  echo "[WARN] scp falló (intento ${attempt}/${RETRIES}). Reintentando en ${RETRY_SLEEP_SECONDS}s..." >&2
  attempt=$((attempt + 1))
  sleep "$RETRY_SLEEP_SECONDS"
done

# Reemplaza el endpoint local por la IP/punto final del Load Balancer
sed -i "s/127.0.0.1/${API_SERVER_IP}/g" "$TMP_FILE"

mv "$TMP_FILE" "$DEST_PATH"
chmod 600 "$DEST_PATH"
touch "$READY_MARKER"
echo "[INFO] kubeconfig actualizado en $DEST_PATH"
