# iPhone Duo Harness — Project Docs

Canonical plan, analysis, and Mac setup for **iPhone Duo Harness** (SPM product **`DuoHarness`**, repo **`duo-harness`**).

| Document | Description |
| --- | --- |
| [SETUP.md](./SETUP.md) | Clone, Xcode 27.1 beta pin, `swift build` / CLI smoke |
| [analysis.md](./analysis.md) | Feasibility, automation boundary, recommended SPM + CLI shape |
| [plan.md](./plan.md) | Locked-scope delivery plan (phases A0–A7, targets, metrics) |

**Status:** A2 — `swift run duo-harness audit SampleApps/NativeVictim`; helpers in `DuoHarness` / presets in `DuoHarnessTesting`; `duo-harness autofix <path>` rewrites `UIScreen.main.scale`.
