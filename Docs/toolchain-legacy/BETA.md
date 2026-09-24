# Toolchain legacy — Xcode 27.1 beta (archived at A7)

**Status:** Keep for one release after GM pin flip. Active pin lives in [`TOOLCHAIN.md`](../../TOOLCHAIN.md).

| Field | Value |
| --- | --- |
| Marketing | 27.1 |
| Build | 27A9269 |
| Label | Xcode 27.1 beta 1 (2026-09-18) |
| Goldens | `Tests/Goldens/beta/` |

## When this was active

CI selected this Xcode via `DEVELOPER_DIR` / `xcode-select`. `iphone-duo-prep sdk-check` required build `27A9269`.

## After GM retarget

1. Update root `TOOLCHAIN.md` + `.xcode-version` + `ToolchainPin` to GM.
2. Re-run audits → write `Tests/Goldens/gm/`.
3. `swift run iphone-duo-prep golden-diff Tests/Goldens/beta/… Tests/Goldens/gm/…` and review.
4. Leave this file until the next major pin drop.
