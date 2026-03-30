# Error Model

## Public Contract

The BFF exposes a normalized problem-details style response:

```json
{
  "type": "https://api.karazlinen.example/errors/auth-session-expired",
  "title": "Session expired",
  "status": 401,
  "detail": "Your session has expired. Please sign in again.",
  "instance": "/v1/orders",
  "code": "AUTH_SESSION_EXPIRED",
  "request_id": "req_123",
  "errors": []
}
```

## Error Families

- `AUTH_*`
- `VALIDATION_*`
- `RATE_LIMIT_*`
- `UPSTREAM_MAGENTO_*`
- `NOT_FOUND_*`
- `CONFLICT_*`
- `INTERNAL_*`

## Mapping Rules

- Magento-specific failures are translated into BFF-owned codes.
- Internal diagnostics stay in server logs only.
- Validation errors may include field-level details.
- Retryability is implied by status and code, not raw upstream content.
