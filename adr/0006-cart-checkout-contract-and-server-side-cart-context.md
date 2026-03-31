# ADR 0006: Cart and Checkout Contract with Server-Side Cart Context

## Status

Accepted

## Context

The baseline now covers browse, account, and orders, but not the purchase path itself. The next commercial wave needs a canonical mobile contract and BFF foundation for cart and checkout without exposing Magento quote internals directly to Flutter.

Three design constraints shape this decision:

- Magento remains the source of truth for carts, totals, addresses, shipping, payment methods, and order placement.
- The mobile client must not hold critical cart session identifiers or payment-sensitive state as its only source of truth.
- The first wave needs authenticated customer checkout only; guest checkout and live payment tokenization stay out of scope.

## Decision

Extend the canonical contract and BFF surface with:

- authenticated cart retrieval and mutation endpoints
- address assignment for checkout
- shipping method listing and selection
- payment method listing and selection
- order placement with an explicit idempotency key

The BFF stores the upstream Magento cart identifier server-side in the mobile session context alongside the Magento customer token. Flutter only receives normalized mobile-safe cart payloads.

For v1 of this wave:

- checkout is authenticated-customer only
- payment selection is by BFF-owned method code only
- raw card secrets, Apple Pay, Google Pay, coupons, and guest cart merge remain out of scope

## Consequences

- Flutter can build cart and checkout flows without direct knowledge of Magento quote schemas or IDs.
- The BFF owns quote creation, reuse, and placement orchestration as the canonical backend boundary.
- Live Magento cart orchestration still depends on sandbox configuration and will be validated separately where environment access is available.
