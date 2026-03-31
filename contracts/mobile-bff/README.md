# Mobile BFF Contract

This directory contains the canonical public contract between the Flutter mobile app and the Karaz Linen Mobile BFF.

## Principles

- Versioned under `/v1`
- Mobile-oriented payloads
- Stable error model
- No raw Magento response shapes
- No direct exposure of Magento tokens or admin concepts

## Scope

This foundation covers authentication, session bootstrap, catalog browse, search, facet aggregations, configurable product variant resolution, account summary, address management, order retrieval, and the authenticated cart / checkout surface.
