#!/usr/bin/env bash
# Validation iOS Release sur iPhone physique (macOS requis).
# Usage: ./scripts/ios_release_validation.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LOG_DIR="$ROOT/build/ios_validation_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/flutter_logs_${TIMESTAMP}.txt"

echo "==> 1/4 flutter analyze"
flutter analyze | tee "$LOG_DIR/analyze_${TIMESTAMP}.txt"
grep -q "No issues found" "$LOG_DIR/analyze_${TIMESTAMP}.txt"

DEVICE_ID="${IOS_DEVICE_ID:-}"
if [[ -z "$DEVICE_ID" ]]; then
  DEVICE_ID="$(flutter devices | awk '/iPhone|ios/ && !/simulator/ { print $3; exit }')"
fi

if [[ -z "$DEVICE_ID" ]]; then
  echo "ERREUR: aucun iPhone physique détecté. Branchez l'iPhone, activez le mode développeur, faites confiance à l'ordinateur."
  flutter devices
  exit 1
fi

echo "==> Appareil cible: $DEVICE_ID"

echo "==> 2/4 flutter run --release (iPhone)"
flutter run --release -d "$DEVICE_ID" | tee "$LOG_DIR/run_release_${TIMESTAMP}.txt" &
RUN_PID=$!

echo "==> 3/4 flutter logs (capture complète)"
flutter logs -d "$DEVICE_ID" | tee "$LOG_FILE" &
LOGS_PID=$!

echo ""
echo "Manuel — tester sur l'iPhone:"
echo "  - ouverture app (pas d'écran blanc permanent)"
echo "  - navigation home"
echo "  - création CV"
echo "  - retour arrière"
echo "  - changement thème / langue"
echo "  - sauvegarde locale"
echo ""
echo "Logs: $LOG_FILE"
echo "Arrêt: Ctrl+C puis analyse des erreurs ci-dessous."
echo ""

wait $RUN_PID || true
kill $LOGS_PID 2>/dev/null || true

echo "==> 4/4 scan des erreurs runtime"
PATTERNS=(
  "LateInitializationError"
  "null check operator used on a null"
  "MissingPluginException"
  "ProviderNotFound"
  "Unable to load asset"
  "google_fonts"
  "Unable to load asset"
  "GoException"
  "Router error"
)

FOUND=0
for p in "${PATTERNS[@]}"; do
  if grep -qi "$p" "$LOG_FILE" 2>/dev/null; then
    echo "  [!] Détecté: $p"
    FOUND=1
  fi
done

if [[ "$FOUND" -eq 0 ]]; then
  echo "OK: aucun pattern d'erreur critique trouvé dans $LOG_FILE"
else
  echo "ÉCHEC: erreurs runtime détectées — voir $LOG_FILE"
  exit 2
fi
