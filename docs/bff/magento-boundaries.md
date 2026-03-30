# Magento Service Boundaries

The BFF owns all Magento communication through internal provider boundaries:
- `CustomerAuthPort`
- `CatalogReadPort`
- `OrderReadPort`
- `SearchPort`

This keeps Flutter decoupled from raw Magento schemas and allows later provider substitution for search.
