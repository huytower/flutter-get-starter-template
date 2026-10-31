#!/usr/bin/env bash
set -e

echo "Setting up Firebase configuration files from templates..."

find . -name "*.template" | while read -r template; do
  target="${template%.template}"
  mkdir -p "$(dirname "$target")"
  if [ ! -f "$target" ]; then
    cp "$template" "$target"
    echo "Created $target from $template"
  else
    echo "Skipped $target (already exists)"
  fi
done

echo "Firebase configuration setup complete."
