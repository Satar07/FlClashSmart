# CLAUDE.md

This repository uses [AGENTS.md](AGENTS.md) as the canonical agent entry point.
Read that file first, then follow the `.agents/` references it routes to.

## Merge Upstream

When merging from upstream (`chen08209/FlClash`), follow the step-by-step guide at `REBASE_UPSTREAM.md`. Key rules:
- Bump version one ahead of upstream
- Keep Smart Core submodule (`core/Clash.Meta` → `Satar07/FlClashCore`)
- Keep own CI (Firebase, package name `com.flsmart.clash`, per-file sha256)
- Run `go mod tidy` in BOTH `core/Clash.Meta/` and `core/`
