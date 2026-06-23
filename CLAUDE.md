# CLAUDE.md - Claude Code instructions

Please read AGENTS.md for all project guidelines and conventions.

@AGENTS.md

## Rebase Upstream

When updating from upstream, follow the rebase guide at `REBASE_UPSTREAM.md`. Key rules:
- **Core submodule** (`core/Clash.Meta`): `git rebase origin/Alpha` (1 FlClash patch on top of mihomo)
- **App repo**: `git rebase upstream/main` (4 Smart patches on top of chen08209/FlClash)
- Keep Smart Core submodule (`core/Clash.Meta` → `Satar07/FlClashCore`, branch `FlClash-smart-rebase`)
- Keep own CI (Firebase, package name `com.flsmart.clash`)
- Run `go mod tidy` in BOTH `core/Clash.Meta/` and `core/` after rebase