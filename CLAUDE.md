# CLAUDE.md - Claude Code instructions

Please read AGENTS.md for all project guidelines and conventions.

@AGENTS.md

## Merge Upstream

When merging from upstream (`chen08209/FlClash`), follow the step-by-step guide at `docs/merge-upstream-guide.md`. Key rules:
- Bump version one ahead of upstream (0.8.93 → 0.8.94)
- Keep Smart Core submodule (`core/Clash.Meta` → `Satar07/FlClashCore`)
- Keep own CI (Firebase, package name `com.flsmart.clash`, per-file sha256)
- Run `go mod tidy` in BOTH `core/Clash.Meta/` and `core/`