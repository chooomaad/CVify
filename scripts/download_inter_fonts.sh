#!/usr/bin/env bash
# Optional: bundle Inter locally (run on macOS/Linux with network).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FONT_DIR="$ROOT/assets/fonts"
mkdir -p "$FONT_DIR"
BASE="https://github.com/rsms/inter/raw/master/fonts/ttf"
for f in Inter-Regular Inter-Medium Inter-SemiBold Inter-Bold Inter-ExtraBold; do
  curl -fsSL "$BASE/${f}.ttf" -o "$FONT_DIR/${f}.ttf"
done
echo "Fonts saved to $FONT_DIR — add fonts: section to pubspec.yaml if embedding Inter."
