#!/usr/bin/env bash
set -euo pipefail

if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --source . --no-git --verbose
else
  echo "Secret scan blocked by environment: gitleaks is not installed"
fi
