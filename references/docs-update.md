# Docs Update Rules — Code-to-Docs Mapping

Full mapping table. See [CLAUDE.md](../CLAUDE.md) for the tracked-docs inventory and the always-loaded "update docs in the same PR" boundary.

This is a **library/SDK** repo (public surface = exported Dart classes/methods in `auth0_flutter` and `auth0_flutter_platform_interface`), not a CLI.

| When this changes | Update these docs |
|-------------------|-------------------|
| Public API surface (`Auth0`, `Auth0Web`, or any exported class/method in `auth0_flutter/lib/` or `auth0_flutter_platform_interface/lib/`) | `auth0_flutter/README.md` (feature overview), `auth0_flutter/EXAMPLES.md` (matching example section), `auth0_flutter/example/` app if it demonstrates the area |
| Configuration options (`*Options` classes, `CredentialsManagerConfiguration`, `ClientOptions`) | `auth0_flutter/README.md`, `auth0_flutter/EXAMPLES.md` |
| Authentication / authorization flow (Web Auth, Passwordless, Passkeys, MFA, Custom Token Exchange) | `auth0_flutter/README.md` (What's New / Getting Started), `auth0_flutter/EXAMPLES.md` (relevant section) |
| Install / package name / minimum platform version requirements | `auth0_flutter/README.md` (Requirements/Installation table) |
| Any new public method or exported class added | `auth0_flutter/EXAMPLES.md` (add a usage sample) |
| Any public method or exported class removed or renamed | `auth0_flutter/README.md`, `auth0_flutter/EXAMPLES.md` (remove/update affected samples) — and see the Ask-First breaking-change boundary in `CLAUDE.md` |
| New integration pattern supported (e.g. a new platform) | `auth0_flutter/EXAMPLES.md`, `README.md` (root package table) |

Not tracked here: `auth0_flutter/CHANGELOG.md` and `auth0_flutter_platform_interface/CHANGELOG.md` (release-flow artifacts, not updated as part of a feature PR), and `auth0_flutter/MIGRATION_GUIDE.md` (version-specific; only touched when a breaking change is explicitly approved — see Boundaries in `CLAUDE.md`).
