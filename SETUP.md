# Setup — iPhone Duo Harness (Mac)

<!-- Phase A0 -->

Pin: **Xcode 27.1 beta** (see [TOOLCHAIN.md](./TOOLCHAIN.md)).

## Prerequisites

1. Install Xcode 27.1 beta; select it with `xcode-select`.
2. Confirm: `xcodebuild -version` and `swift --version`.
3. Clone:

```bash
git clone https://github.com/nasibcode/duo-harness.git
cd duo-harness
```

## Build & smoke

```bash
swift build
swift test
swift run duo-harness version
swift run duo-harness sdk-check
# Phase A1
swift run duo-harness audit SampleApps/NativeVictim
# Phase A2
swift run duo-harness autofix SampleApps/NativeVictim
# Phase A6
swift run duo-harness audit SampleApps/NativeVictim --semantic --fail-on blocker; echo exit:$?
swift run duo-harness autofix SampleApps/NativeVictim --checklist
swift run duo-harness matrix
# Phase A7
swift run duo-harness golden-diff Tests/Goldens/beta/NativeVictim.json Tests/Goldens/gm/NativeVictim.json
```

## Docs in this folder

| File | Contents |
| --- | --- |
| [analysis.md](./analysis.md) | Feasibility / automation boundary |
| [plan.md](./plan.md) | Phased delivery plan (A0–A7) |
| [README.md](./README.md) | Doc index |
| [Docs/RULES.md](./Docs/RULES.md) | Rule catalog |

## Add as a dependency

```swift
.package(url: "https://github.com/nasibcode/duo-harness.git", from: "0.1.0")
```

```swift
.product(name: "DuoHarness", package: "duo-harness")
.product(name: "DuoHarnessTesting", package: "duo-harness")
```
