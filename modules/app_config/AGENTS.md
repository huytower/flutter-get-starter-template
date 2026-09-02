# AGENTS.md — modules/app_config

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

Environment management, feature flags, storage, and DI discovery. Env must finish loading (`initEnv()`) before
anything else in the boot sequence — DI and feature flags in every other package depend on it. Don't add
anything here that itself depends on DI being ready yet; that would create a circular boot dependency.
