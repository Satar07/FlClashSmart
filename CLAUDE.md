# CLAUDE.md

This repository uses [AGENTS.md](AGENTS.md) as the canonical agent entry point.
Read that file first, then follow the `.agents/` references it routes to.

## Rebase Upstream

When updating from upstream, follow the rebase guide at `REBASE_UPSTREAM.md`. Key rules:
- **Core submodule** (`core/Clash.Meta`): `git rebase vernesong/Alpha` (1 FlClash adaptation patch on top of the Smart kernel)
- **App repo**: `git rebase upstream/main` (3 Smart patches on top of chen08209/FlClash)
- Keep Smart Core submodule (`core/Clash.Meta` → `Satar07/FlClashCore`, branch `FlClash-smart-rebase`)
- Keep Smart kernel capability (LightGBM/leaves) and FlClash adaptation (`GeoUpdateHook`/`RegisterGeoUpdaterWithCancel` in `component/updater/patch.go`)
- Keep own CI (`ref: smart`, package name `com.flsmart.clash`)
- Run `go mod tidy` in BOTH `core/Clash.Meta/` and `core/` after rebase
