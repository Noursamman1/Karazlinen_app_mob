# BFF Overview

The Mobile BFF is the only backend surface the Flutter app calls directly.

Core responsibilities:
- authenticate existing Magento storefront customers through the BFF
- issue mobile access and refresh tokens
- normalize Magento responses into mobile-safe contracts
- enforce validation, rate limiting, request tracing, and error mapping

Magento sandbox integration status in this phase:
- `POST /v1/auth/login` now brokers Magento customer token creation via the BFF.
- `GET /v1/auth/me` resolves profile data from Magento GraphQL using server-side session context.
- `GET /health/ready` checks Magento GraphQL reachability through the provider boundary.

Hardening status in this phase:
- session rotation, revocation ownership, and device binding are enforced server-side
- retry, timeout, and circuit-breaker rules are defined at the Magento client boundary
- logs and problem details stay structured without exposing secrets or tokens

Cart / checkout foundation status in this phase:
- canonical `/v1/cart` and `/v1/checkout` contracts are now defined for authenticated customer checkout
- the BFF now owns server-side cart context in session storage, preparing Magento quote orchestration without exposing quote IDs to Flutter
- concrete Magento cart / checkout execution may still be blocked by sandbox configuration until a live verification pass
