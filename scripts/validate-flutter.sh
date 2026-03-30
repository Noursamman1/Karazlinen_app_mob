#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter validation blocked by environment: flutter is not installed"
  exit 0
fi

cd app
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
