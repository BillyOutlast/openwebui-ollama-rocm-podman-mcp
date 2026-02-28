#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
QUADLETS_DIR="${SCRIPT_DIR}/quadlets"
TARGET_DIR="${HOME}/.config/containers/systemd"
STACK_ENV="${TARGET_DIR}/stack.env"

mkdir -p "${TARGET_DIR}"

cp "${QUADLETS_DIR}"/*.network "${TARGET_DIR}/"
cp "${QUADLETS_DIR}"/*.container "${TARGET_DIR}/"

if [[ ! -f "${STACK_ENV}" ]]; then
  cp "${QUADLETS_DIR}/stack.env.example" "${STACK_ENV}"
  echo "Created ${STACK_ENV}. Set HF_TOKEN before first start."
fi

systemctl --user daemon-reload
systemctl --user enable --now ai-shared-network.service
systemctl --user enable --now vllm-rocm.service
systemctl --user enable --now open-webui.service
systemctl --user enable --now podman-mcp-server.service

echo
echo "Installed and started services:"
echo "  - ai-shared-network.service"
echo "  - vllm-rocm.service"
echo "  - open-webui.service"
echo "  - podman-mcp-server.service"
echo
echo "Endpoints:"
echo "  - Open WebUI:        http://localhost:3000"
echo "  - vLLM OpenAI API:   http://localhost:8000/v1"
echo "  - Podman MCP server: http://localhost:8080/mcp"
