#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Git repository not initialized"
  exit 1
fi

echo "Changed scope check is available; enforce branch-specific rules in CI as the team formalizes agent workflows."
