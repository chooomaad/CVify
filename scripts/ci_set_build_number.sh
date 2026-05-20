#!/usr/bin/env bash
# Sets a unique iOS build number in pubspec.yaml before each CI/archive build.
# Codemagic: uses CM_BUILD_NUMBER (auto-increments every workflow run).
# Local: keeps pubspec value or IOS_BUILD_NUMBER override.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT/pubspec.yaml"

if [ ! -f "$PUBSPEC" ]; then
  echo "ERROR: pubspec.yaml not found at $PUBSPEC"
  exit 1
fi

CURRENT_LINE=$(grep '^version:' "$PUBSPEC")
VERSION_NAME=$(echo "$CURRENT_LINE" | sed -E 's/version: ([0-9.]+)\+[0-9]+.*/\1/')
COMMITTED_BUILD=$(echo "$CURRENT_LINE" | sed -E 's/.*\+([0-9]+).*/\1/')

# Minimum build already uploaded to App Store Connect (update when Apple rejects duplicates).
MIN_BUILD="${IOS_MIN_BUILD_NUMBER:-10}"

if [ -n "${IOS_BUILD_NUMBER:-}" ]; then
  BUILD_NUMBER="$IOS_BUILD_NUMBER"
elif [ -n "${CM_BUILD_NUMBER:-}" ]; then
  # Codemagic sequential ID — unique per workflow execution.
  BUILD_NUMBER="$CM_BUILD_NUMBER"
  if [ "$BUILD_NUMBER" -lt "$MIN_BUILD" ]; then
    BUILD_NUMBER=$((MIN_BUILD + CM_BUILD_NUMBER - 1))
  fi
  if [ "$BUILD_NUMBER" -le "$COMMITTED_BUILD" ]; then
    BUILD_NUMBER=$((COMMITTED_BUILD + 1))
  fi
else
  BUILD_NUMBER="${COMMITTED_BUILD}"
fi

NEW_VERSION="version: ${VERSION_NAME}+${BUILD_NUMBER}"

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i '' "s/^version: .*/${NEW_VERSION}/" "$PUBSPEC"
else
  sed -i "s/^version: .*/${NEW_VERSION}/" "$PUBSPEC"
fi

echo "iOS build number set -> ${VERSION_NAME}+${BUILD_NUMBER} (min=$MIN_BUILD, committed=$COMMITTED_BUILD, CM=${CM_BUILD_NUMBER:-n/a})"
grep '^version:' "$PUBSPEC"
