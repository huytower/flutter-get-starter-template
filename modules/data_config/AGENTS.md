# AGENTS.md — modules/data_config

Package-scoped addendum to the root `AGENTS.md` (read that first — this file only covers what's distinctive
about this package).

This is where app-specific `Repository` interfaces defined in `domain_features`/`cc_micro_features` get their
concrete implementations and are wired into DI. If you're implementing a `Repository` interface, it belongs
here (or in `lib/` for App-Shell-level wiring) — never inline a concrete repository implementation inside the
feature package that defines the interface.
