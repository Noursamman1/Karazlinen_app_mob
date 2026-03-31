# Cart / Checkout Foundation

This slice establishes the production contract and BFF foundation for authenticated customer cart and checkout.

## Assumptions

- v1 covers authenticated customer checkout only.
- Magento remains the source of truth for quote, totals, shipping methods, payment methods, and order placement.
- Magento cart identifiers are stored only in server-side session context.
- Payment selection is by configured method code only; raw card data and live wallet integrations are out of scope for this wave.

## Contract Surface

- `GET /v1/cart`
- `POST /v1/cart/items`
- `PATCH /v1/cart/items/{itemId}`
- `DELETE /v1/cart/items/{itemId}`
- `PUT /v1/cart/addresses`
- `GET /v1/cart/shipping-methods`
- `PUT /v1/cart/shipping-method`
- `GET /v1/cart/payment-methods`
- `PUT /v1/cart/payment-method`
- `POST /v1/checkout/place-order`

## BFF Foundation

- Cart and checkout routes are authenticated through mobile access tokens.
- The BFF resolves Magento customer context from the active session before any cart mutation.
- The BFF persists the upstream Magento cart identifier in session storage for reuse across cart and checkout steps.
- Place-order requests require an explicit idempotency key at the contract boundary.

## Environment Notes

Concrete Magento cart orchestration still depends on:

- sandbox quote/cart configuration
- shipping methods enabled in Magento
- payment methods enabled in Magento
- test catalog and customer data that can complete checkout

Until those exist, live execution remains `blocked by environment`.
