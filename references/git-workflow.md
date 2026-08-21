# Git Workflow

## Branch naming

No enforced convention (no branch-name CI check detected). Recent history uses `feat/<short-description>` and `fix/<short-description>` (e.g. `feat/web-passkeys`).

## Commit messages

Conventional Commits, matching recent `git log` history: `feat:`, `fix:`, `fix(ci):`, `build(deps):`, `build(deps-dev):`, `docs:`, `chore:`, `chore(example):`. Dependabot commits follow `build(deps):`/`build(deps-dev):` automatically.

## Pull requests

- **Title:** must start with `af:` (changes to `auth0_flutter`) or `afpi:` (changes to `auth0_flutter_platform_interface`) — enforced by the `pr-title-checker` workflow reading `.github/pr-title-checker-config.json`. Add the `ignore title check` or `dependencies` label to bypass for non-package PRs (e.g. workflow-only changes).
- **Body:** follow `.github/PULL_REQUEST_TEMPLATE.md` exactly — it requires checking off "covered by tests" and "documentation added" boxes, and filling in **Changes**, **References**, and **Testing** sections. PRs with an incomplete checklist are closed per the template.
- **Symlinks:** if the PR touches `auth0_flutter/darwin/auth0_flutter/Sources/`, the `check-symlinks` workflow will fail unless `scripts/generate-symlinks.sh` was run and its output committed.
