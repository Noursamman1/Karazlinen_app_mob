# ADR 0004: Cache and Sync Policy

## Status

Accepted

## Decision

Magento remains authoritative. Read-heavy catalog data may be cached briefly at the BFF and client layers; customer-specific data is not shared-cached.

## Consequences

- Price, stock, and order state are treated as freshness-sensitive.
- Sync behavior is explicit rather than implicit.
