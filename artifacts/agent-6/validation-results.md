# Agent 6 Validation Results

- `bash scripts/validate-docs.sh`: passed
- `bash scripts/validate-flutter.sh`: blocked by environment
  - Reason: `flutter` is not installed in this shell
- `bash scripts/check-no-secrets.sh`: blocked by environment
  - Reason: `gitleaks` is not installed in this shell
- `bash scripts/check-changed-scopes.sh`: passed (advisory output)
- `bash scripts/validate-all.sh`: passed overall
  - Includes docs + BFF checks and reports Flutter/gitleaks as blocked by environment
- Workflow parsing with `actionlint`: blocked by environment
  - Reason: `actionlint` is not installed
