# iPhone Duo Prep

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](./LICENSE)

Audit, runtime helpers, and guided patches to prepare apps for **iPhone Duo** (fold / dual display / hinge).

Not a one-click migrator. It finds high-signal anti-patterns, points at concrete APIs and templates, and applies only *mechanical* autofixes. Product choices (outer display, camera “who faces whom”, Arrangement chrome) stay human.

Package / CLI: **`iphone-duo-prep`**. SPM products: **`iPhoneDuoPrep`**, **`iPhoneDuoPrepTesting`**.

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Features](#features)
- [Repository map](#repository-map)
- [Toolchain](#toolchain)
- [Adapters](#adapters)
- [What this will not do](#what-this-will-not-do)
- [Docs](#docs)
- [Contributing](#contributing)
- [License](#license)

## Background

Duo breaks assumptions most phone apps still encode:

| Old phone assumption | Duo reality |
| --- | --- |
| `UIScreen.main` is “the” screen | Windows can sit on inner *or* outer displays |
| Safe area is symmetric (`top * 2`) | Fold / reserved regions are asymmetric |
| Phone vs pad idiom drives layout | Container size / traits matter more |
| Orientation locks always stick | Inner display may ignore them |
| Front camera = person using *this* UI | Outer capture can face someone else |
| One window / full-screen-only | Scenes, Split View, multi-display sessions |

iPhone Duo Prep shortens the path from Apple’s Prepare/Design guidance to a **scored backlog** and reusable helpers. See [analysis.md](./analysis.md).

## Install

Pin: **Xcode 27.1 beta** (build `27A9269`). Full pin notes: [TOOLCHAIN.md](./TOOLCHAIN.md), [SETUP.md](./SETUP.md).

### Dependencies

- macOS with Xcode 27.1 beta selected (`xcode-select` / `DEVELOPER_DIR`)
- Swift 6.2 toolchain from that Xcode

### From source

```bash
git clone https://github.com/nasibcode/iphone-duo-prep.git
cd iphone-duo-prep
swift build
swift test
swift run iphone-duo-prep sdk-check
```

### As a package dependency

```swift
// Package.swift / Xcode → Package Dependencies
.package(url: "https://github.com/nasibcode/iphone-duo-prep.git", from: "0.1.0")
```

```swift
.product(name: "iPhoneDuoPrep", package: "iphone-duo-prep")
.product(name: "iPhoneDuoPrepTesting", package: "iphone-duo-prep")
```

## Usage

First win: audit `SampleApps/NativeVictim` (intentional Duo anti-patterns).

```bash
swift run iphone-duo-prep audit SampleApps/NativeVictim
```

Example output (abridged):

```text
2 blocker · 8 likely-bug · 4 product-decision

blocker
- R2.MissingSceneManifest  Info.plist:1 — … Add UIApplicationSceneManifest.
- R2.UIRequiresFullScreen  Info.plist:1 — … Remove it so Split View can run.

likely-bug
- R1.UIScreenMain  VictimViewController.swift:7 — … Use DuoScreen …
- R1.SafeAreaTimesTwo  VictimViewController.swift:8 — … Use DuoSafeArea …
…

product-decision
- R4.CustomChromeNoReserved … Use DuoReservedRegion; see Templates/Arrangement/.
- R5.FrontCameraAsUser … Use DuoCameraDirection; see Docs/CAMERA.md.
```

CI / gates:

```bash
swift run iphone-duo-prep audit SampleApps/NativeVictim --format json > NativeVictim-report.json
swift run iphone-duo-prep audit path/to/YourApp --fail-on blocker   # exit 2 if at/above severity
swift run iphone-duo-prep audit path/to/YourApp --semantic          # drop comment/string false positives
```

### CLI

```text
iphone-duo-prep version
iphone-duo-prep sdk-check [--warn]
iphone-duo-prep audit <path> [--format json|markdown] [--semantic] [--fail-on <severity>]
iphone-duo-prep suggest <path>
iphone-duo-prep report <path> --output <file> [--format json|markdown] [--semantic]
iphone-duo-prep autofix <path> [--checklist]
iphone-duo-prep matrix [--format markdown|args]
iphone-duo-prep golden-diff <left.json> <right.json> [--left-label beta] [--right-label gm]
```

| Command | Use when |
| --- | --- |
| `audit` | Local or CI backlog |
| `suggest` | Same as markdown audit |
| `report` | Write an artifact to disk |
| `autofix` | Mechanical `UIScreen.main.scale` → `traitCollection.displayScale` |
| `autofix --checklist` | PR body / migration checklist (no writes) |
| `matrix` | Seed XCTest / Swift Testing size args |
| `sdk-check` | Enforce the pinned Xcode in CI |
| `golden-diff` | Compare beta vs GM audit goldens |

### Library

Phone-era:

```swift
let scale = UIScreen.main.scale
let pad = view.safeAreaInsets.top * 2
if traitCollection.userInterfaceIdiom == .phone { /* … */ }
```

Duo-aware:

```swift
import iPhoneDuoPrep

let scale = DuoScreen.displayScale(from: traitCollection)
let insets = DuoSafeArea.insets(from: view)   // keep top/bottom separate
if DuoSizeGate.isCompactWidth(view.bounds.size) { /* … */ }

let reserved = DuoReservedRegion.layoutGuideInsets(for: view)
_ = DuoHinge.observe { fraction in /* … */ }
```

Scaffold product decisions (not forced):

| Need | Copy from |
| --- | --- |
| Multi-scene / outer activation | `Templates/Scene/` |
| Two-pane Arrangement path | `Templates/Arrangement/` |
| Outer preview accessory | `Templates/OuterDisplay/` + [Docs/CAMERA.md](./Docs/CAMERA.md) |
| Camera “who faces whom” | `Templates/Camera/` |

### Testing

```swift
import iPhoneDuoPrepTesting
import Testing

@Test(arguments: DuoUITestMatrix.entries)
func layoutFitsPreset(_ entry: DuoUITestMatrix.Entry) {
    #expect(entry.size.width > 0)
}
```

```bash
swift run iphone-duo-prep matrix                  # markdown table
swift run iphone-duo-prep matrix --format args    # Swift Testing argument lines
```

## Features

| Layer | Role |
| --- | --- |
| **CLI (`iphone-duo-prep`)** | Scan a project tree → Markdown/JSON findings; mechanical autofix; CI gates |
| **`iPhoneDuoPrep` (SPM)** | Safe-area, screen, size-gate, hinge/reserved/Arrangement/scene/camera façades |
| **`iPhoneDuoPrepTesting`** | Named Duo size presets + UI-test matrix dump |
| **Templates/** | Copy-paste stubs for scenes, Arrangement, outer accessory, camera direction |
| **Adapters/** | Thin Flutter / React Native bridges |
| **SampleApps/** | Intentional failures (`NativeVictim`) and dogfood hosts |

Severity (highest first): `blocker` → `likely-bug` → `product-decision` → `enhancement`.  
Autofix is mechanical only (today: `UIScreen.main.scale`). Camera findings are **never** autofixed. Rule catalog: [Docs/RULES.md](./Docs/RULES.md).

## Repository map

```text
Sources/iPhoneDuoPrep/          Runtime helpers (layout, scenes, hinge, camera façades)
Sources/iPhoneDuoPrepTesting/   DuoDisplayPreset + DuoUITestMatrix
Sources/iPhoneDuoPrepCLI/       Audit engine, autofix, semantic refine, gates
Sources/iphone-duo-prep/         CLI executable
Adapters/                    Flutter + React Native thin bridges
Templates/                   Scene / Arrangement / OuterDisplay / Camera stubs
SampleApps/NativeVictim/     Intentional audit failures (golden fixture)
SampleApps/NativeHost/       Links SPM helpers (UIKit + SwiftUI demos)
SampleApps/FlutterHost|RNHost/  Cross-platform smoke + R6 dogfood
Tests/Goldens/beta|gm/       Expected audit JSON per toolchain
.github/workflows/ci.yml     sdk-check → test → audit golden → golden-diff
```

## Toolchain

Active pin: **Xcode 27.1 beta 1** (`27A9269`). Wrong Xcode → `sdk-check` exits 1 (`--warn` soft-fails locally).

When GM ships: dual goldens under `Tests/Goldens/gm/`, `golden-diff`, then flip the pin — checklist in [TOOLCHAIN.md](./TOOLCHAIN.md). Beta archive: [Docs/toolchain-legacy/BETA.md](./Docs/toolchain-legacy/BETA.md).

## Adapters

Flutter / React Native bridges under `Adapters/` mirror size / hinge / reserved helpers. Smoke hosts: `SampleApps/FlutterHost`, `SampleApps/RNHost`.

```bash
swift run iphone-duo-prep audit SampleApps/FlutterHost
swift run iphone-duo-prep audit SampleApps/RNHost
```

Install notes + gap register: [Docs/ADAPTERS.md](./Docs/ADAPTERS.md).

## What this will not do

- Redesign your information architecture or pick Arrangement vs single-pane for you
- Force camera / outer-display product choices (those stay `product-decision`)
- Guarantee Flutter/RN expose every native Duo API (see the adapter gap register)
- Replace reading Apple’s Duo Prepare / Design materials for high-stakes UX

## Docs

| Document | Description |
| --- | --- |
| [SETUP.md](./SETUP.md) | Clone, pin, build, smoke commands |
| [TOOLCHAIN.md](./TOOLCHAIN.md) | Xcode pin + GM retarget checklist |
| [Docs/RULES.md](./Docs/RULES.md) | Rule IDs, severity, autofix eligibility |
| [Docs/CAMERA.md](./Docs/CAMERA.md) | Camera / outer-display product decisions |
| [Docs/ADAPTERS.md](./Docs/ADAPTERS.md) | Flutter / RN install + gap register |
| [Docs/toolchain-legacy/BETA.md](./Docs/toolchain-legacy/BETA.md) | Archived beta pin |
| [plan.md](./plan.md) | Delivery plan (phases A0–A7) |
| [analysis.md](./analysis.md) | Feasibility and automation boundary |

**Status:** Phases A0–A7 implemented. Pin remains Xcode 27.1 beta until GM; `Tests/Goldens/gm/` are placeholders until then.

## Contributing

Questions and bugs: [GitHub Issues](https://github.com/nasibcode/iphone-duo-prep/issues). Pull requests are welcome.

Use the pinned Xcode from [TOOLCHAIN.md](./TOOLCHAIN.md). Run `swift test` and `swift run iphone-duo-prep audit SampleApps/NativeVictim` before opening a PR. Keep camera / outer-display behavior as product decisions — do not add autofix for those rules.

## License

[MIT](./LICENSE) © 2026 Nasib Ali Ansari
