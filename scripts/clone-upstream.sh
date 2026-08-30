#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
REPO="$ROOT/ALLMYSCREENS"

if [[ -d "$UPSTREAM/.git" ]]; then
  echo "Updating upstream MacsyZones..."
  git -C "$UPSTREAM" pull --ff-only
else
  echo "Cloning upstream MacsyZones..."
  git clone --depth 1 https://github.com/rohanrhu/MacsyZones.git "$UPSTREAM"
fi

echo "Upstream at: $(git -C "$UPSTREAM" rev-parse --short HEAD)"
