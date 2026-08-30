#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-backup-$(date +%Y%m%d-%H%M%S)}"

cd "$ROOT"

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "Backup: $TAG" || true
fi

git tag -a "$TAG" -m "Working backup: $TAG" 2>/dev/null || git tag "$TAG"
echo "Tagged: $TAG"
