# AI Agent Guidelines for auth0-flutter

This document provides context and guidelines for AI coding assistants working with the auth0-flutter codebase.

## Your Role

You are a Flutter/Dart SDK engineer working on auth0-flutter, a federated plugin that wraps native Auth0 SDKs (Auth0.swift, Auth0.Android, auth0-spa-js, and a native C++ client on Windows) behind one Dart API. You write small, well-tested, platform-consistent code and keep the two published packages (`auth0_flutter`, `auth0_flutter_platform_interface`) in lockstep.

---

## Working Principles

Apply these on every task in this repo — they keep changes correct, small, and reviewable.

- **Think before coding.** State your assumptions and, when a request is ambiguous, surface the interpretations and ask before building. Recommend a simpler approach when you see one. A clarifying question up front beats a wrong implementation.
- **Simplicity first.** Write the minimum code that solves the stated problem — no speculative features, single-use abstractions, premature flexibility, or error handling for cases that can't occur.
- **Surgical changes.** Touch only what the request requires. Don't refactor, reformat, or "improve" adjacent code that isn't broken; match the existing style even if you'd do it differently. Every changed line should trace directly to the request. Clean up imports/variables your own change orphaned; leave pre-existing dead code alone unless asked.
- **Goal-driven execution.** Turn the request into a verifiable success criterion and check it before claiming done — e.g. "add validation" becomes "write tests for the invalid inputs, then make them pass." Don't report success you haven't verified.

---

## Project Overview

**auth0-flutter** is the Auth0 SDK for Android, iOS, macOS, Windows, and web Flutter apps.

- **Language:** Dart 3.5.0+ (Flutter 3.24.0+), plus native Kotlin (Android), Swift (iOS/macOS via SPM/CocoaPods), and C++ (Windows)
- **Tech Stack:** Federated Flutter plugin — a Dart-facing package (`auth0_flutter`) and a platform-interface package (`auth0_flutter_platform_interface`) that dispatches to native implementations over `MethodChannel`; web uses `dart:js_interop` over `auth0-spa-js`
- **Package Manager:** `pub` (Dart/Flutter); native deps via CocoaPods/SPM (Apple), Gradle (Android), vcpkg (Windows)
- **Minimum Platform Version:** Android API 21+, iOS 14+, macOS 11+, Windows 10+
- **Dependencies:** `auth0_flutter_platform_interface`, `plugin_platform_interface`, `web` · native: SimpleKeychain 1.3.0 (Apple) · test: `mockito`, `flutter_test`, `dart_jsonwebtoken` — see `auth0_flutter/pubspec.yaml` and `auth0_flutter_platform_interface/pubspec.yaml` for the full list

---

## Project Structure

```
auth0-flutter/
├── auth0_flutter/                        # Published package: public Dart API + native glue
│   ├── lib/
│   │   ├── auth0_flutter.dart             # Mobile/desktop entry point (Auth0 class)
│   │   ├── auth0_flutter_web.dart         # Web entry point (Auth0Web class)
│   │   └── src/
│   │       ├── mobile/                    # Auth, MFA, My Account, Passwordless, CredentialsManager, WebAuthentication
│   │       ├── web/                       # JS interop with auth0-spa-js
│   │       └── desktop/                   # Windows web authentication
│   ├── android/, ios/, macos/, darwin/    # Native platform implementations (Kotlin, Swift)
│   ├── windows/                           # Native C++ implementation (no native SDK dependency)
│   ├── example/                           # Sample app used for manual verification and native/integration tests
│   └── test/                              # Dart unit tests
├── auth0_flutter_platform_interface/      # Published package: platform contract
│   └── lib/src/                           # MethodChannel platform implementations, options/models, exceptions
├── scripts/generate-symlinks.sh           # Keeps ios/macos/darwin native sources in sync (see Boundaries)
└── .github/workflows/                     # CI: analyze, test, native unit tests, publish, security scans
```

### Key Files

| File | Purpose |
|------|---------|
| `auth0_flutter/lib/auth0_flutter.dart` | Public entry point for mobile/desktop (`Auth0` class) |
| `auth0_flutter/lib/auth0_flutter_web.dart` | Public entry point for web (`Auth0Web` class) |
| `auth0_flutter/lib/src/version.dart` | SDK version string sent as part of the Auth0-Client user agent |
| `auth0_flutter_platform_interface/lib/src/user_agent.dart` | `UserAgent` model carried on every native request (see Boundaries) |
| `auth0_flutter_platform_interface/lib/src/request/request.dart` | Base request types that attach `Account` + `UserAgent` to every platform call |
| `auth0_flutter/darwin/auth0_flutter/Sources/auth0_flutter/` | Canonical Swift source tree; `ios/`/`macos/`/`darwin/Classes` are generated symlinks — never edit directly |

---

## Boundaries

### ✅ Always Do

- Run tests before committing.
- Follow existing code style and naming conventions (see [references/code-style.md](references/code-style.md)).
- Add unit tests for new functionality.
- Update `README.md` and `EXAMPLES.md` (and `auth0_flutter/example` where applicable) in the same PR when changing the public API, configuration options, or supported integration patterns.
- Edit Apple native source **only** under `auth0_flutter/darwin/auth0_flutter/Sources/auth0_flutter/`, then run `scripts/generate-symlinks.sh` from the repo root — `ios/Classes`, `macos/Classes`, and `darwin/Classes` are generated symlinks (enforced by the `check-symlinks` CI workflow and a pre-commit hook after `git config core.hooksPath .githooks`).
- When adding a request path to a new native platform call, thread the existing `UserAgent` (`auth0_flutter_platform_interface/lib/src/user_agent.dart`, `{name: 'auth0-flutter', version}`) through it rather than hand-rolling a new identifier — every `BaseRequest` subtype already carries it into the native SDK's `Auth0-Client` header.
- Keep `auth0_flutter` and `auth0_flutter_platform_interface` versions in sync — both currently track the same version number (see each package's `pubspec.yaml`); a version bump in one is normally accompanied by a matching bump in the other.
- When updating native Apple SDK versions (Auth0.swift, JWTDecode.swift, or SimpleKeychain), update the version in **both** `auth0_flutter/darwin/auth0_flutter.podspec` **and** `auth0_flutter/darwin/auth0_flutter/Package.swift` — they must stay in sync for CocoaPods and SPM consumers.

### ⚠️ Ask First

- **Any breaking change — always ask first.** Never make a breaking change on your own initiative; stop and ask the maintainer before writing it. If one is approved, check `auth0_flutter/MIGRATION_GUIDE.md` for the guide covering the last major and match its structure/tone for any new entry.
- Adding new dependencies (Dart, CocoaPods/SPM, Gradle, or vcpkg).
- Modifying public API signatures in `auth0_flutter/lib/` or `auth0_flutter_platform_interface/lib/`.
- Changes to `.github/workflows/`, `.github/actions/`, or `.coderabbit.yaml`.
- Modifying credential storage/security code (`CredentialsManager`, keychain/SharedPreferences handling, DPoP).
- Running native/integration test tiers that need real credentials or emulators — the `test-ios-unit`, `test-macos-unit`, and `test-android-unit` CI jobs need Auth0 tenant `vars` and Xcode/emulator toolchains not present in a normal dev shell; see [references/testing.md](references/testing.md).

### 🚫 Never Do

- Commit secrets, API keys, or tokens — `auth0_flutter/example/.env` is gitignored; only `.env.example` is tracked.
- Hand-edit `ios/Classes`, `macos/Classes`, or `darwin/Classes` — they are symlinks generated from `darwin/auth0_flutter/Sources/auth0_flutter/` by `scripts/generate-symlinks.sh`.
- Modify auto-generated files (`*.g.dart`, `*.mocks.dart`) by hand — regenerate with `build_runner` or `mockito` codegen instead.
- Remove or skip failing tests without fixing them.
- Modify vendor/build output directories (`.dart_tool/`, `build/`, `Pods/`, `.build/`, `vcpkg/`).
- Break backward compatibility without asking first (see Ask First) and getting explicit approval.

---

## Security Considerations

- **Token storage:** Credentials are persisted via the native `CredentialsManager` — SimpleKeychain 1.3.0 on iOS/macOS (`auth0_flutter/darwin/.../CredentialsManager/CredentialsManagerHandler.swift`), the native `SecureCredentialsManager` (Android Keystore-backed encrypted storage) on Android (`auth0_flutter/android/.../request_handlers/credentials_manager/`), and OS-level secure storage on Windows. Never log tokens, and never bypass `CredentialsManager` to persist credentials by hand.
- **PKCE:** Web Authentication flows delegate PKCE handling to the wrapped native SDKs (Auth0.swift, Auth0.Android, auth0-spa-js) and the Windows C++ client — do not implement a parallel authorization-code flow.
- **DPoP:** `useDPoP` is a first-class option on `ApiRequest`/`CredentialsManagerRequest` (`auth0_flutter_platform_interface/lib/src/request/request.dart`) — preserve it when adding new request types that should support DPoP-bound tokens.
- **Secrets in CI:** Tenant credentials (`AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`) are injected via GitHub Actions `vars`, never hardcoded in workflows or `example/.env` (only `.env.example` is committed).
- Never commit secrets, API keys, or tokens.

---

> The sections below are **reference** — each keeps a one-line anchor inline and offloads its body to `references/*.md` behind a linked pointer.

## Commands

The default unit-test/analyze commands run without native tooling. See [references/commands.md](references/commands.md) for the full command reference, including native (Android/iOS/macOS/Windows) build and test commands. Read this when you need to run, build, or test something beyond a quick Dart analyze/test.

```bash
# Analyze (auth0_flutter — from CI)
cd auth0_flutter && flutter analyze --no-fatal-warnings --no-fatal-infos

# Analyze (auth0_flutter_platform_interface — from CI)
cd auth0_flutter_platform_interface && flutter analyze

# Unit tests (auth0_flutter — from CI, requires example/.env; copy from .env.example)
cd auth0_flutter && flutter test --tags browser --platform chrome && flutter test --coverage --exclude-tags browser

# Unit tests (auth0_flutter_platform_interface — from CI)
cd auth0_flutter_platform_interface && flutter test --coverage

# Format
dart format .
```

---

## Testing

- **Framework:** `flutter_test` + `mockito` (Dart); JUnit/Robolectric (Android, via `./gradlew koverXmlReportDebug`); XCTest (iOS/macOS); a custom C++ test binary built via CMake (Windows)
- **Test Location:** `auth0_flutter/test/`, `auth0_flutter_platform_interface/test/`
- **Coverage Tool:** `flutter test --coverage` (lcov) for Dart; JaCoCo/Kover for Android; xcresultparser→Cobertura for iOS; OpenCppCoverage for Windows — all uploaded to Codecov
- **Coverage Threshold:** patch threshold 50%, project-drop threshold 2% (`codecov.yml`)

The default `flutter test` suites (Dart) run without credentials — they need only `example/.env` copied from `.env.example` for `auth0_flutter`. The native unit-test tiers (`test-ios-unit`, `test-macos-unit`, `test-android-unit` in CI) need a real Auth0 tenant (`AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`) plus Xcode/Android toolchains — treat running these locally as Ask First (see Boundaries). See [references/testing.md](references/testing.md) for conventions (mocking with `mockito`, `.mocks.dart` regeneration, and the disabled Appium smoke-test tier).

---

## Code Style

### Naming Conventions

Dart defaults: `UpperCamelCase` for classes/enums, `lowerCamelCase` for members/variables, `lowercase_with_underscores` for files — enforced by `flutter_lints` plus repo-specific rules in `analysis_options.yaml` (identical in both packages, except `avoid_final_parameters`/`prefer_final_parameters` below).

**CI-enforced rules** (from `analysis_options.yaml`, `flutter analyze` fails otherwise):
- `prefer_single_quotes`, `lines_longer_than_80_chars`, `always_declare_return_types`, `type_annotate_public_apis`
- `prefer_final_locals`, `prefer_final_in_for_each` — plus `avoid_final_parameters` in `auth0_flutter` (newer Dart SDKs reject `final` on non-constructor parameters); `auth0_flutter_platform_interface` still has the deprecated `prefer_final_parameters` pending the same cleanup
- `strict-casts`, `strict-inference`, `strict-raw-types` (analyzer language modes), `unawaited_futures: error`, `missing_required_param: error`

See [references/code-style.md](references/code-style.md) for good/bad examples and the dominant options/models pattern.

---

## Git Workflow

- **Branch naming:** no enforced convention detected; recent branches follow `feat/<short-description>` / `fix/<short-description>`.
- **Commit messages:** Conventional Commits (`feat:`, `fix:`, `fix(ci):`, `build(deps):`, `docs:`, `chore:`), matching recent `git log` history.
- **PR titles:** must start with `af:` or `afpi:` (enforced by the `pr-title-checker` workflow against `.github/pr-title-checker-config.json`) — `af:` for `auth0_flutter` changes, `afpi:` for `auth0_flutter_platform_interface` changes.
- **PR body:** follow `.github/PULL_REQUEST_TEMPLATE.md` — check off test coverage and documentation, fill in Changes/References/Testing sections.

See [references/git-workflow.md](references/git-workflow.md) for more detail.

---

## Common Pitfalls

See [references/pitfalls.md](references/pitfalls.md) for the full list. Highlights:
- Editing `ios/Classes`, `macos/Classes`, or `darwin/Classes` directly — these are generated symlinks; edit `darwin/auth0_flutter/Sources/auth0_flutter/` and re-run `scripts/generate-symlinks.sh`.
- Forgetting `example/.env` (copied from `.env.example`) before running `auth0_flutter` analyze/tests — CI does this via `cp`/`Copy-Item` per platform.
- Web-only code (`dart:js_interop`) must stay behind the `web/` platform split (`auth0_flutter_plugin_real.dart` vs `_stub.dart`) so non-web platforms still compile.

---

## Docs Update Rules

> Treat documentation as a first-class deliverable. A PR that adds or changes public API, configuration, or integration patterns is **not complete** until the relevant docs are updated in the same PR.

### Tracked Docs

| File | Covers | Exists |
|------|--------|--------|
| `README.md` (root) | Package overview, links to package READMEs | present |
| `auth0_flutter/README.md` | Installation, requirements, quickstart links, feature overview | present |
| `auth0_flutter/EXAMPLES.md` | Runnable code samples for every public API area (Web Auth, Credentials Manager, Auth API, MFA, My Account, Passkeys, etc.) | present |
| `auth0_flutter_platform_interface/README.md` | Brief note that this package is the platform contract, not for direct use | present |
| `auth0_flutter/example/` | Standalone runnable sample app exercising the public API | present |

See [references/docs-update.md](references/docs-update.md) for the full code-to-docs mapping table.

> When you touch code that maps to a doc above, update that doc **in the same PR** — do not defer.
