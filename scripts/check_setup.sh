#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "============================================"
echo "  Financial Sentiment App - Setup Check"
echo "============================================"
echo ""

if ! command -v flutter &>/dev/null; then
  echo "[ERROR] Flutter is NOT installed or not on your PATH."
  echo ""
  echo "Install Flutter:"
  echo "  macOS:  https://docs.flutter.dev/get-started/install/macos"
  echo "  Linux:  https://docs.flutter.dev/get-started/install/linux"
  echo ""
  exit 1
fi

echo "[OK] Flutter found:"
flutter --version
echo ""

echo "Running Flutter health check..."
echo "(Yellow warnings are often fine. Red errors need attention.)"
echo ""
flutter doctor
echo ""

echo "Checking for a device to run the app..."
flutter devices
echo ""

echo "============================================"
echo "  Setup check complete"
echo "============================================"
echo ""
echo "If Flutter is installed and Chrome appears above,"
echo "run:  bash scripts/run_app.sh"
echo ""
