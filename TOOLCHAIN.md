# Toolchain — Xcode 27.1 beta

<!-- Phase A0 pin; Phase A7 retarget when GM ships. -->

Pin: **Xcode 27.1 beta 1**, build **27A9269** (released 2026-09-18).

`xcodebuild -version` on a correct install:

```text
Xcode 27.1
Build version 27A9269
```

`.xcode-version` records the marketing version (`27.1`) for xcodes / mise. The build id is what `sdk-check` requires, so a 27.1 GM with a different build will fail until the A7 retarget.

## Select it

```bash
# xcodes
xcodes install "27.1 Beta"
xcodes select "27.1 Beta"

# or point xcode-select at the beta app
sudo xcode-select -s /Applications/Xcode-27.1-beta.app/Contents/Developer
xcodebuild -version
```

Requires macOS Tahoe 26.6 or later. The beta installs beside Xcode 27.0; it does not replace it.

## Check

```bash
swift run duo-harness sdk-check          # exit 1 on mismatch
swift run duo-harness sdk-check --warn   # same message, exit 0
```

CI: [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) runs `sdk-check` without `--warn` after selecting this Xcode.

## Branch

Trunk is `main`. Feature work lands in short branches off `main`.

## Phase A7 — GM retarget checklist

Do **not** flip this pin until Xcode 27.1 GM is installed and golden audit diffs are reviewed.

| Step | Action |
| --- | --- |
| 1 | Install GM; dual CI matrix (beta pin + GM) for one sprint |
| 2 | Recompile; fix availability / renamed symbols; flip `DuoFeatureGate` if headers land |
| 3 | Re-run audits; write `Tests/Goldens/gm/` |
| 4 | `swift run duo-harness golden-diff Tests/Goldens/beta/NativeVictim.json Tests/Goldens/gm/NativeVictim.json` |
| 5 | Update this file, `.xcode-version`, and `ToolchainPin` (rename/retarget static); tag `xcode-27.1-gm` |
| 6 | Drop beta from default CI; keep [`Docs/toolchain-legacy/BETA.md`](./Docs/toolchain-legacy/BETA.md) for one release |

Policy: no silent “latest Xcode” in CI. Rule metadata / goldens carry the verified pin.
