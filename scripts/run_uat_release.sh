#!/usr/bin/env bash
# Clean, fetch deps, codegen, then launch the app on a device (uat flavor, release build).
#
# Usage:
#   bash scripts/run_uat_release.sh [device-id] [flutter run extra args...]
#   melos run run:uat:release -- [device-id] [flutter run extra args...]
#
# Device resolution order: first CLI arg, then $DEVICE_ID env var, then the
# default UDID below (same default device as run_uat.sh).

set -euo pipefail

DEFAULT_DEVICE_ID="00008101-001A259E1AE9003A"
ENTRY_POINT="lib/main_uat.dart"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DEVICE_ID="${1:-${DEVICE_ID:-$DEFAULT_DEVICE_ID}}"
if [[ $# -gt 0 ]]; then
  shift
fi

echo "==> [1/4] flutter clean"
flutter clean

echo "==> [2/4] flutter pub get"
flutter pub get

echo "==> [3/4] melos run gen"
melos run gen

echo "==> [4/4] flutter run -d $DEVICE_ID --release -t $ENTRY_POINT $*"
flutter run -d "$DEVICE_ID" --release -t "$ENTRY_POINT" "$@"
