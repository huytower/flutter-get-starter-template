#!/usr/bin/env bash
set -e

DEVICE="${1:-$DEVICE_ID}"

echo "Preparing workspace..."
melos run rebuild

if [ -n "$DEVICE" ]; then
  echo "Running app in release mode (prod flavor) on device: $DEVICE"
  flutter run --release -d "$DEVICE" --flavor prod -t lib/main_prod.dart
else
  echo "Running app in release mode (prod flavor)..."
  flutter run --release --flavor prod -t lib/main_prod.dart
fi
