# Toolchain — Xcode 27.1 beta

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

CI should run `sdk-check` without `--warn` after selecting this Xcode. No GitHub Actions workflow is in the repo yet (CI home is still an open item).

## Branch

Trunk is `main`. Feature work lands in short branches off `main`. No release tag until `0.1.0` is dogfoodable (after Phase A1).

## GM retarget (later, Phase A7)

Do not flip this pin until Xcode 27.1 GM is installed and golden audit diffs are reviewed. Then: update this file, `.xcode-version`, and `ToolchainPin.xcode27_1Beta`, and keep the beta instructions for one release.
