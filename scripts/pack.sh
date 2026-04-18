#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$REPO_ROOT/dist"
RELEASES="$REPO_ROOT/releases"

if [ ! -d "$DIST" ]; then
  echo "ERROR: dist/ not found. Run scripts/build.sh first." >&2
  exit 1
fi

mkdir -p "$RELEASES"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ZIP_PATH="$RELEASES/extension-$TIMESTAMP.zip"

echo "==> Packaging dist/ → $ZIP_PATH"
(cd "$DIST" && zip -r "$ZIP_PATH" . --exclude "*.DS_Store")

SIZE=$(du -sh "$ZIP_PATH" | cut -f1)
echo "✅ Packed: $ZIP_PATH ($SIZE)"
