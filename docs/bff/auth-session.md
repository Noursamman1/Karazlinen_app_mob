# Auth and Session Notes

- Access tokens are BFF-issued JWT bearer tokens.
- Refresh tokens are opaque and rotated on every refresh.
- Magento credentials and customer tokens never leave the server.
- Session persistence and rate-limit counters use Redis-backed abstractions.
