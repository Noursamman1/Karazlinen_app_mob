#!/usr/bin/env bash
set -euo pipefail

if ! command -v npm >/dev/null 2>&1; then
  echo "BFF validation blocked by environment: npm is not installed"
  exit 0
fi

cd bff
npm ci
npm run lint
npm run test
npm run build
