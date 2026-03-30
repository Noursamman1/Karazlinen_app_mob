# Architecture Blueprint

## Overview

Karaz Linen mobile commerce is structured as:

1. Flutter mobile application
2. Mobile BFF/API Gateway
3. Magento 2 commerce platform

The mobile app never calls Magento directly. All application traffic flows through the BFF.

## Design Principles

- Keep sensitive business logic and upstream integration logic on the server.
- Normalize Magento responses into mobile-oriented contracts.
- Keep brand styling replaceable through Flutter design tokens.
- Treat Magento as the source of truth for customers, catalog, prices, stock, carts, and orders.
- Prefer explicit contracts, defensive error handling, and operational observability.

## Bounded Responsibilities

### Flutter app

- Rendering, navigation, localization, RTL behavior, and accessibility
- Local caching for non-authoritative read models
- Session token storage in secure device storage
- Lightweight validation for user input hygiene

### Mobile BFF

- Authentication brokering and mobile session management
- Authorization, request validation, and response shaping
- Error normalization and upstream fault isolation
- Rate limiting, logging, traceability, and cache policy enforcement
- Provider abstraction around Magento storefront capabilities

### Magento 2

- Customer identity and existing website account continuity
- Categories, products, configurable options, prices, stock, and order data
- Cart and checkout source of truth for future flows

## Non-Goals

- Direct Magento access from the mobile app
- Storage of Magento secrets or admin credentials in this repository
- Client-side calculation of prices, stock, or order-state business rules
