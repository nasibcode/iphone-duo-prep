# Phase A6 — Audit rules

Rule IDs, severity, and autofix eligibility for `iphone-duo-prep audit`.

| ID | Phase | Severity | Autofix | Notes |
| --- | --- | --- | --- | --- |
| `R1.UIScreenMain` | A1 | likely-bug | Mechanical for `.scale` only (`autofix`) | Prefer `DuoScreen` / `traitCollection.displayScale` |
| `R1.SafeAreaTimesTwo` | A1 | likely-bug | — | Prefer `DuoSafeArea` |
| `R1.FixedCGRect` | A1 | likely-bug | — | Size from container / presets |
| `R1.HardcodedPhoneWidth` | A1 | likely-bug | — | |
| `R1.StoryboardSizeClass` | A1 | likely-bug | — | |
| `R2.MissingSceneManifest` | A1 | blocker | — | |
| `R2.UIRequiresFullScreen` | A1 | blocker | — | |
| `R2.SingleWindow` | A1 | likely-bug | — | |
| `R3.UserInterfaceIdiom` | A1 | likely-bug | — | Prefer `DuoSizeGate` |
| `R3.OrientationLock` | A1 | likely-bug | — | |
| `R4.CustomChromeNoReserved` | A3 | product-decision | — | Templates/Arrangement |
| `R4.MissingHingeHook` | A3 | product-decision | — | `DuoHinge` |
| `R5.FrontCameraAsUser` | A4 | product-decision | **never** | Docs/CAMERA.md |
| `R5.CaptureWithoutOuterAccessory` | A4 | product-decision | **never** | Templates/OuterDisplay |
| `R6.FixedMediaQuery` | A5 | likely-bug | — | Flutter |
| `R6.OrientationLock` | A5 | likely-bug | — | Flutter |
| `R6.FixedDimensions` | A5 | likely-bug | — | RN |
| `R6.RNOrientationLock` | A5 | likely-bug | — | RN |
| `R6.MissingAdapter` | A5 | enhancement | — | Docs/ADAPTERS.md |

## A6 switches

| Flag / command | Effect |
| --- | --- |
| `audit --semantic` | Drop R1–R3 hits that sit in `//` comments or string literals |
| `audit --fail-on <severity>` | Exit 2 if any finding is at or above that severity |
| `autofix --checklist` | PR checklist markdown; no file writes |
| `matrix` | Emit Duo UI test matrix from `DuoDisplayPreset` |
| `report` / `suggest` | Artifact write / markdown suggestions |

Severity order (highest first): `blocker` → `likely-bug` → `product-decision` → `enhancement`.
