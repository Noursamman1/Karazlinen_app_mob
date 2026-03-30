# ADR 0005: Catalog Contract Completion for Search, Filters, and Variant Resolution

## Status

Accepted

## Context

The Flutter catalog and search baseline can proceed on demo data using the current canonical BFF contracts, but three gaps now affect production-ready UI closure:

- `GET /v1/catalog/products` does not yet define a first-class `query` / `search` parameter.
- The same listing contract does not yet define filter aggregation or facet payloads needed for stable filtering UX.
- `ProductDetail` exposes configurable options, but not the resolved variant outcome per option combination, including `resolvedSku`, price, image, and availability.

## Decision

Extend the canonical mobile contract in three places:

- `GET /v1/catalog/products` now defines an explicit `query` parameter for mobile search input.
- The same listing response now includes `aggregations` so the app can render stable facet/filter UX from BFF-owned payloads instead of inferring it locally.
- `ProductDetail` now includes `variantResolution`, which exposes normalized configurable combinations with:
  - selected option map per combination
  - `resolvedSku`
  - resolved `availability`
  - resolved `image`
  - resolved `price`

The BFF remains responsible for normalizing Magento configurable-product semantics into this contract. The Flutter client may render selection state and provisional UX, but it does not derive authoritative variant outcomes on its own.

## Consequences

- Slice 2 placeholder facet behavior is now a temporary implementation detail rather than an unresolved contract gap.
- Slice 3 can be finalized only after the BFF implementation and Flutter integration consume the new `variantResolution` shape.
- Contract-compatible documentation must stay aligned with `contracts/mobile-bff/openapi.yaml`.
