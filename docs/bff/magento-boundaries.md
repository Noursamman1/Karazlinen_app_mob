# Magento Service Boundaries

The BFF owns all Magento communication through internal provider boundaries:
- `CustomerAuthPort`
- `CatalogReadPort`
- `CartPort`
- `CheckoutPort`
- `OrderReadPort`
- `SearchPort`

This keeps Flutter decoupled from raw Magento schemas and allows later provider substitution for search.

Sandbox wiring in this phase:
- `CustomerAuthPort.authenticateCustomer` -> Magento REST customer token endpoint (`MAGENTO_CUSTOMER_TOKEN_PATH`)
- `CustomerAuthPort.fetchCustomerSummary` -> Magento GraphQL `customer` query with bearer token
- `CatalogReadPort.healthcheck` -> Magento GraphQL `storeConfig` reachability probe

Hardening policy in this phase:
- Retry only retryable upstream failures (`429` and `5xx`) with bounded backoff.
- Open a local circuit breaker after repeated Magento failures to avoid cascading latency.
- Treat invalid Magento customer credentials and expired Magento customer tokens as auth errors, not retryable upstream failures.

Cart / checkout foundation in this phase:
- Magento cart identifiers stay server-side in the mobile session context and are not exposed as client-owned authority.
- The canonical mobile surface now covers cart retrieval, mutations, address assignment, shipping method selection, payment method selection, and place-order orchestration.
- Live Magento quote and place-order wiring remains environment-dependent and is intentionally isolated behind provider interfaces.
