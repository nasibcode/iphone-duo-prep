# Setup — iPhone Duo Harness (Mac)

<!-- Phase A0 -->

Pin: **Xcode 27.1 beta** (see [TOOLCHAIN.md](./TOOLCHAIN.md)).

## Prerequisites

1. Install Xcode 27.1 beta; select it with `xcode-select`.
2. Confirm: `xcodebuild -version` and `swift --version`.
3. Clone:

```bash
git clone https://github.com/nasibcode/iphone-duo-prep.git
cd iphone-duo-prep
```

## Build & smoke

```bash
swift build
swift test
swift run iphone-duo-prep version
swift run iphone-duo-prep sdk-check
# Phase A1
swift run iphone-duo-prep audit SampleApps/NativeVictim
# Phase A2
swift run iphone-duo-prep autofix SampleApps/NativeVictim
# Phase A6
swift run iphone-duo-prep audit SampleApps/NativeVictim --semantic --fail-on blocker; echo exit:$?
swift run iphone-duo-prep autofix SampleApps/NativeVictim --checklist
swift run iphone-duo-prep matrix
# Phase A7
swift run iphone-duo-prep golden-diff Tests/Goldens/beta/NativeVictim.json Tests/Goldens/gm/NativeVictim.json
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
.package(url: "https://github.com/nasibcode/iphone-duo-prep.git", from: "0.1.0")
```

```swift
.product(name: "iPhoneDuoPrep", package: "iphone-duo-prep")
.product(name: "iPhoneDuoPrepTesting", package: "iphone-duo-prep")
```
