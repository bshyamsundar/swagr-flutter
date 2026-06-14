#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo ""
echo "============================================"
echo "  Financial Sentiment App - Starting..."
echo "============================================"
echo ""

if ! command -v flutter &>/dev/null; then
  echo "[ERROR] Flutter is not installed."
  echo "Run: bash scripts/check_setup.sh"
  echo "Or see README.md"
  exit 1
fi

echo "Installing app dependencies..."
flutter pub get

echo ""
echo "Launching app in Chrome..."
echo "(First launch may take several minutes.)"
echo "Press Q in this terminal to quit the app when done."
echo ""

if flutter run -d chrome; then
  exit 0
fi

echo ""
echo "Chrome not available. Trying first available device..."
flutter run
