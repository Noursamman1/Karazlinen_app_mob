# Magento Integration Map

## Capability Mapping

### Authentication

- Customer sign-in
- Customer summary lookup for authenticated session bootstrap

### Catalog and Search

- Category tree
- Product listing
- Product detail
- Configurable option metadata
- Search and filter aggregations
- Resolved configurable variant combinations
- Price and stock summary

### Customer Account

- Customer profile summary
- Customer address book

### Orders

- Customer order list
- Customer order detail and normalized status labels

## Integration Notes

- The BFF uses capability-oriented ports rather than exposing raw Magento semantics to the app.
- Standard storefront GraphQL capabilities are preferred for catalog, customer, and order reads.
- Standard storefront REST capabilities may be used where GraphQL does not provide the needed auth or mutation path.
- Magento configurable-product responses must be normalized into mobile-ready facet payloads and resolved variant combination payloads.
- No admin credentials or admin APIs are part of this design.
