# ADR 0001: Mobile Commerce Architecture

## Status

Accepted

## Decision

Adopt a three-tier architecture:

- Flutter mobile app
- Mobile BFF/API Gateway
- Magento 2 backend

## Rationale

- Preserve separation between UX concerns and commerce/system concerns.
- Avoid tight coupling between the app and Magento response shapes.
- Centralize auth, observability, and upstream resilience.
