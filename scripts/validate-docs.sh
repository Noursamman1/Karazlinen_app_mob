#!/usr/bin/env bash
set -euo pipefail

test -f README.md
test -f contracts/mobile-bff/openapi.yaml
test -f docs/architecture/blueprint.md
test -f adr/0001-mobile-commerce-architecture.md
echo "Documentation contract files are present"
