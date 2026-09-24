# Phase A7 — GM goldens

Placeholder copies of `Tests/Goldens/beta/` until Xcode 27.1 GM ships.

When GM is available:

1. Install GM; dual-run CI (beta archive + GM) for one sprint.
2. Re-audit SampleApps; overwrite files in this folder.
3. `swift run duo-harness golden-diff Tests/Goldens/beta/NativeVictim.json Tests/Goldens/gm/NativeVictim.json`
4. Flip the pin in `TOOLCHAIN.md` / `.xcode-version` / `ToolchainPin`; archive beta under `Docs/toolchain-legacy/`.
