#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "uninstall-rootful.sh must be run as root."
  echo "Run: sudo bash uninstall-rootful.sh"
  exit 1
fi

TARGET_DIR="/etc/containers/systemd"
REMOVE_DATA="${REMOVE_DATA:-false}"

services=(
  ai-shared-network.service
  ollama-rocm.service
  open-webui.service
  podman-mcp-server.service
)

for svc in "${services[@]}"; do
  systemctl disable --now "${svc}" 2>/dev/null || true
done

rm -f "${TARGET_DIR}/ai-shared.network"
rm -f "${TARGET_DIR}/ollama-rocm.container"
rm -f "${TARGET_DIR}/open-webui.container"
rm -f "${TARGET_DIR}/podman-mcp-server.container"

systemctl daemon-reload

if [[ "${REMOVE_DATA}" == "true" ]]; then
  rm -rf "/root/.local/share/open-webui"
  echo "Removed Open WebUI persistent data at /root/.local/share/open-webui"
fi

echo "Uninstalled rootful Quadlet units and stopped services."
echo "Kept persistent data by default (Open WebUI data and Ollama volume)."
echo "Set REMOVE_DATA=true to also remove Open WebUI data."
