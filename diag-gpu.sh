#!/usr/bin/env bash
set -euo pipefail

ok() { echo "[OK]   $*"; }
warn() { echo "[WARN] $*"; }
fail() { echo "[FAIL] $*"; }
info() { echo "[INFO] $*"; }

FAILED=0

echo "ROCm + Podman GPU diagnostics"
echo

if [[ -e /dev/kfd ]]; then
  ok "/dev/kfd is present"
else
  fail "/dev/kfd is missing"
  FAILED=1
fi

if [[ -d /dev/dri ]]; then
  ok "/dev/dri directory is present"
else
  fail "/dev/dri directory is missing"
  FAILED=1
fi

shopt -s nullglob
DRI_NODES=(/dev/dri/renderD* /dev/dri/card*)
shopt -u nullglob

if (( ${#DRI_NODES[@]} > 0 )); then
  ok "Detected DRM device nodes under /dev/dri"
  ls -l /dev/dri/renderD* /dev/dri/card* 2>/dev/null || true
else
  fail "No /dev/dri/renderD* or /dev/dri/card* device nodes found"
  FAILED=1
fi

echo
info "Raw device listing"
ls -l /dev/kfd 2>/dev/null || true
ls -la /dev/dri 2>/dev/null || true

echo
if lsmod | grep -q '^amdgpu'; then
  ok "Kernel module amdgpu is loaded"
else
  warn "Kernel module amdgpu is not loaded"
fi

if command -v podman >/dev/null 2>&1; then
  ok "podman is installed"
  if podman info >/dev/null 2>&1; then
    ok "podman info succeeded"
  else
    warn "podman info failed (check podman setup/permissions)"
  fi
else
  fail "podman is not installed"
  FAILED=1
fi

if command -v rocminfo >/dev/null 2>&1; then
  ok "rocminfo is installed"
  if rocminfo >/dev/null 2>&1; then
    ok "rocminfo executed successfully"
  else
    warn "rocminfo exists but failed to execute"
  fi
else
  warn "rocminfo not found (install ROCm userspace tools for deeper checks)"
fi

echo
if [[ "${FAILED}" -eq 0 ]]; then
  ok "Diagnostic passed: host exposes required GPU device nodes for ollama-rocm"
  exit 0
fi

fail "Diagnostic failed: fix missing device nodes/driver setup, then rerun"
exit 1
