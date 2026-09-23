# Setup — iPhone Duo Harness (Mac)

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
```

`audit` is Phase A1 (not implemented yet) — exits with a stub message until NativeVictim lands.

## Docs in this folder

| File | Contents |
| --- | --- |
| [analysis.md](./analysis.md) | Feasibility / automation boundary |
| [plan.md](./plan.md) | Phased delivery plan (A0–A7) |
| [README.md](./README.md) | Doc index |

## Add as a dependency

```swift
.package(url: "https://github.com/nasibcode/duo-harness.git", from: "0.1.0")
```

```swift
.product(name: "DuoHarness", package: "duo-harness")
.product(name: "DuoHarnessTesting", package: "duo-harness")
```

## If this tree arrived via tarball

See Project Context media `duo-harness-scaffold.tar.gz`, or unpack over a LICENSE-only clone:

```bash
tar -xzf duo-harness-scaffold.tar.gz
git add -A
git commit -m "Scaffold iPhone Duo Harness SPM (DuoHarness)"
git push
```
