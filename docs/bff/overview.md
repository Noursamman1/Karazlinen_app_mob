# BFF Overview

The Mobile BFF is the only backend surface the Flutter app calls directly.

Core responsibilities:
- authenticate existing Magento storefront customers through the BFF
- issue mobile access and refresh tokens
- normalize Magento responses into mobile-safe contracts
- enforce validation, rate limiting, request tracing, and error mapping
