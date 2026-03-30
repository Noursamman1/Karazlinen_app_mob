#!/usr/bin/env bash
set -euo pipefail

./scripts/ci-bootstrap.sh
./scripts/check-no-secrets.sh
./scripts/validate-docs.sh
./scripts/validate-flutter.sh
./scripts/validate-bff.sh
