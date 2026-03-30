# Caching and Sync Rules

## Source of Truth

Magento is authoritative for customer, catalog, price, stock, address, cart, and order data.

## BFF Cache Policy

- Categories: short-to-medium TTL
- Product lists and details: short TTL
- Search results: short TTL per query/filter tuple
- Price and stock: very short TTL, always revalidated before critical mutations
- Account, addresses, and orders: no shared cache

## Mobile Cache Policy

- Cache read models for smooth UX and resume behavior
- Treat prices, stock, and order status as stale-on-resume
- Refresh protected data on app foreground, manual pull-to-refresh, and after auth refresh

## Sync Triggers

- App cold start
- App foreground resume
- Session refresh
- Manual refresh
- Before critical commerce mutations in future cart and checkout flows
