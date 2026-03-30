# Agent 5 Implementation Plan

- Build protected account surfaces on top of `accountRepositoryProvider` and shared session routing.
- Keep account UX read-oriented and session-aware, with BFF-backed mutations deferred behind the existing address form scaffold.
- Use the normalized customer and order models from `app/lib/core/models/customer_models.dart`.
- Keep account, address book, and orders feature code isolated under their own directories and avoid catalog/product imports.
- Reuse shared design-system cards, spacing, and async feedback components for consistency with the foundation layer.
