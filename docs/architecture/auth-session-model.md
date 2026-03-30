# Auth and Session Model

## Goals

- Reuse existing website customer accounts
- Keep Magento authentication artifacts hidden from the mobile client
- Support secure mobile session renewal and device-scoped logout

## Flow

1. The app submits credentials to `POST /v1/auth/login`.
2. The BFF validates credentials against Magento storefront customer authentication.
3. The BFF creates a mobile session record and returns:
   - short-lived access token
   - rotating refresh token
   - expiry metadata
4. The app uses the BFF access token for protected requests.
5. The app rotates the refresh token through `POST /v1/auth/refresh`.
6. The BFF revokes sessions through `POST /v1/auth/logout`.

## Rules

- Access tokens are BFF-issued bearer tokens.
- Refresh tokens are opaque and rotated on every successful refresh.
- Refresh token replay revokes the affected session chain.
- Magento customer tokens are never returned to the client.
- Protected app routes depend on BFF session state only.
- Global logout is deferred; device-scoped logout is included in the foundation.
