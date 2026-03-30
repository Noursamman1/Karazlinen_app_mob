# BFF Error Model

The BFF publishes RFC 7807 style problem details with:
- `type`
- `title`
- `status`
- `detail`
- `instance`
- `code`
- `request_id`

Magento-originated failures are translated into BFF-owned codes before reaching clients.
