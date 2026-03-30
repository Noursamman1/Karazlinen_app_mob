# System Boundaries

## Mobile Client Boundary

The client consumes only BFF contracts. It can persist UI state, cached read models, and secure session tokens, but it does not own commerce rules.

## BFF Boundary

The BFF is the anti-corruption layer between Flutter and Magento. It owns:

- Public REST contract stability
- Session issuance and refresh semantics
- Authorization checks
- Validation and error translation
- Catalog and account read orchestration
- Magento integration adapters

## Magento Boundary

Magento remains the source of truth for:

- Existing customer accounts
- Product and configurable product data
- Prices and stock
- Customer addresses
- Orders and status history

The BFF may cache read-safe data briefly, but Magento remains authoritative.

## Future Extension Points

- Dedicated search service behind the BFF search provider boundary
- Checkout and payment services behind separate contracts and ADRs
- Notification and CMS integrations behind separate adapters
