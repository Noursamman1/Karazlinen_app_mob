# ADR 0003: BFF Contract and Error Standard

## Status

Accepted

## Decision

Expose a versioned REST contract under `/v1` with a normalized problem-details error shape.

## Consequences

- Mobile feature code depends on stable BFF semantics instead of upstream Magento semantics.
- Contract changes must be documented in `contracts/mobile-bff/openapi.yaml`.
