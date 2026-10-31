#!/usr/bin/env bash
set -e

DEVICE="${1:-$DEVICE_ID}"

echo "Preparing workspace..."
melos run rebuild

if [ -n "$DEVICE" ]; then
  echo "Running app in prod flavor on device: $DEVICE"
  flutter run -d "$DEVICE" --flavor prod -t lib/main_prod.dart
else
  echo "Running app in prod flavor..."
  flutter run --flavor prod -t lib/main_prod.dart
fi
