# iPhone Duo Harness — Project Docs

Canonical plan, analysis, and Mac setup for **iPhone Duo Harness** (SPM product **`DuoHarness`**, repo **`duo-harness`**).

| Document | Description |
| --- | --- |
| [SETUP.md](./SETUP.md) | Clone, Xcode 27.1 beta pin, `swift build` / CLI smoke |
| [analysis.md](./analysis.md) | Feasibility, automation boundary, recommended SPM + CLI shape |
| [plan.md](./plan.md) | Locked-scope delivery plan (phases A0–A7, targets, metrics) |
| [Docs/RULES.md](./Docs/RULES.md) | Rule IDs, severity, autofix eligibility (A6) |
| [Docs/CAMERA.md](./Docs/CAMERA.md) | Camera / outer-display privacy & product decisions (opt-in) |
| [Docs/ADAPTERS.md](./Docs/ADAPTERS.md) | Flutter / RN bridges + gap register |
| [Docs/toolchain-legacy/BETA.md](./Docs/toolchain-legacy/BETA.md) | Archived beta pin (A7) |
| [TOOLCHAIN.md](./TOOLCHAIN.md) | Active Xcode pin + GM checklist |

**Status:** A0–A7 implemented. Active pin remains **Xcode 27.1 beta** (`27A9269`); GM goldens are placeholders until GM ships — see A7 checklist in TOOLCHAIN.md.
