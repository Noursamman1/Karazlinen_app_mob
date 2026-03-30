# ADR 0002: Auth and Session Strategy

## Status

Accepted

## Decision

The BFF owns mobile session issuance using short-lived access tokens and rotating refresh tokens. Magento authentication remains server-side.

## Consequences

- Existing website customer accounts can sign in to the app.
- The client never receives Magento tokens.
- The BFF must persist refresh session state securely.
