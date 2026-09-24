# iPhone Duo Migration Harness — Delivery Plan

**Status:** Executable plan (locked scope)  
**Date:** 2026-09-22  
**Repo:** `iphone-duo-prep` (project **iPhone Duo Harness**, SPM product **iPhoneDuoPrep**)  
**Upstream analysis:** [`analysis.md`](./analysis.md)

---

## Locked decisions (do not reopen)

| # | Decision | Implication for this plan |
| --- | --- | --- |
| 1 | **Product bar = everything** — baseline resize-ready **and** outer-display / hinge / camera | v1 includes differentiated Duo APIs and templates; still **phase delivery** so native MVP ships before Flutter/RN and camera polish |
| 2 | **Stacks = everything** — UIKit, SwiftUI, hybrid, Flutter, React Native | Native SPM/CLI is the spine; cross-platform ships as **adapters + audit rules**, not a second harness |
| 3 | **SDK = pin Xcode 27.1 beta now**; retarget when GM ships | All builds/CI use a pinned beta toolchain id; GM migration is an explicit later milestone |

Honest framing from analysis (unchanged): the product is **audit + runtime helpers + guided patches**, not zero-touch migration.

---

## 1. Goals & non-goals

### Goals (v1 “everything,” phased)

1. **Dogfoodable native MVP early** — CLI audit + SPM runtime/testing + SampleApp that teams can run without reading Apple videos first.
2. **Full Duo surface in v1** — reserved regions / hinge / Arrangement-style wrappers, outer-display scene helpers, camera accessory scaffolds — gated on `#available` + SDK detection, not delayed to a “v2 product.”
3. **All stacks covered** — first-class UIKit/SwiftUI/hybrid; Flutter and RN via plugin/module adapters that call into `iPhoneDuoPrep` (or thin native bridges) plus stack-specific audit rules.
4. **CI-ready** — JSON + Markdown reports; GitHub Actions (or equivalent) job template; severity taxonomy teams can gate on.
5. **SDK discipline** — pin Xcode 27.1 beta; documented GM retarget checklist with golden-report diffs.

### Non-goals

- Magic one-command full migration / AST rewriter that redesigns IA.
- Xcode Source Editor extension or GUI migrator (defer until CLI proves adoption).
- Guaranteeing Flutter/RN expose every native fold API if upstream frameworks lag — adapters wrap what exists and document gaps.
- App Store creative, marketing screenshots, review narratives.
- Scraping Apple Tech Talk videos for codegen; prefer headers + official docs.
- Org-wide metrics dashboard as a hosted service (in-repo reports only).

### Phasing honesty inside “everything”

| Ship early (does not wait) | Ship in parallel / immediately after MVP | Must not block native MVP |
| --- | --- | --- |
| CLI rules, SPM shims, testing presets, UIKit+SwiftUI SampleApp | Arrangement / hinge / reserved-region wrappers, outer-display templates | Flutter plugin, RN TurboModule, full camera accessory pipeline |
| One mechanical autofix | SourceKit semantic rules, autofix PR mode | Cross-platform golden apps beyond smoke hosts |
| Beta SDK pin + CI matrix stub | GM retarget playbook + dual-toolchain CI | Waiting for GM before any harness code |

**Rule:** Flutter/RN and camera **are in v1 scope**, but critical path is **native audit → native runtime → Duo-differentiated native APIs → adapters**. Adapters depend on a stable native API surface.

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  iphone-duo-prep CLI  (executable)                                  │
│  audit | suggest | autofix | report | sdk-check                 │
└────────────┬──────────────────────────────┬─────────────────────┘
             │ findings / patches           │ reads manifests
             ▼                              ▼
┌────────────────────────┐     ┌──────────────────────────────────┐
│  Rule engines          │     │  Project inputs                  │
│  • Pattern (Phase A)   │     │  .swift / .m / storyboards       │
│  • Plist / pbxproj     │     │  Info.plist, Package.swift       │
│  • SourceKit (Phase B) │     │  Flutter/RN project trees        │
│  • Stack adapters      │     │  Xcode version / SDK headers     │
└────────────────────────┘     └──────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  iPhoneDuoPrep (SPM library) — ships in the app                     │
│  Layout · Scenes · Hinge/ReservedRegion · Camera scaffolds       │
│  UIKit + SwiftUI facades; ObjC-compatible where hybrid needs it  │
├─────────────────────────────────────────────────────────────────┤
│  iPhoneDuoPrepTesting — size/pose presets, snapshot fixtures        │
└─────────────────────────────────────────────────────────────────┘
             ▲
             │ depends on native API surface
┌────────────┴────────────────────────────────────────────────────┐
│  Cross-platform adapters                                         │
│  iPhoneDuoPrepFlutter (plugin)  ·  iPhoneDuoPrepRN (TurboModule)       │
│  Thin bridges + JS/Dart APIs mirroring native helpers            │
└─────────────────────────────────────────────────────────────────┘

Templates/     — Scene, Arrangement, outer display, camera stubs
SampleApps/    — NativeVictim, SwiftUIVictim, FlutterHost, RNHost
Docs/          — runbooks mapped to Apple Prepare / Design / Duo hub
```

### Layer contracts

| Layer | Owns | Does not own |
| --- | --- | --- |
| **CLI** | Detection, severity, suggested fix class, optional mechanical diffs, SDK pin verification | Runtime behavior in production apps |
| **iPhoneDuoPrep** | Safe layout/scene/hinge/camera helpers; feature detection | Product IA (one-pane vs split vs overlay) |
| **iPhoneDuoPrepTesting** | Named configs (`duoOuterPortrait`, `duoInnerRegular`, `duoSplitHalf`, pose variants) | Golden image policy for consuming apps |
| **Templates** | Boilerplate after a human chose a pattern | Automated pattern choice |
| **Flutter/RN adapters** | Bridging + stack-specific audit hooks | Replacing Flutter/RN layout engines |

### Severity model (CLI output)

- `blocker` — will fail baseline resize / scene requirements under Duo SDK expectations  
- `likely-bug` — high-confidence anti-pattern (e.g. `UIScreen.main` layout)  
- `product-decision` — outer display, hinge chrome, camera face-whom (human required)  
- `enhancement` — differentiated experience opportunities  

Reports: **JSON** (CI) + **Markdown** (humans). Autofix only for rules marked `mechanical`.

---

## 3. Workstreams & phases

### Critical path (recommended)

```
A0 Toolchain pin
 → A1 CLI + pattern rules + SampleApp (dogfood)
 → A2 iPhoneDuoPrep + Testing presets
 → A3 Duo-differentiated native wrappers (hinge / reserved / Arrangement / scenes)
 → A4 Templates + camera scaffolds
 → A5 Flutter + RN adapters
 → A6 SourceKit + autofix + CI hardening
 → A7 Xcode GM retarget
```

**Dogfood gate:** after A1–A2, a new engineer runs `swift run iphone-duo-prep audit SampleApps/NativeVictim` and gets a prioritized report. Differentiated features (A3–A5) land on that spine without rewriting it.

### Phase A0 — Toolchain & repo skeleton

| | |
| --- | --- |
| **Deliver** | Branch strategy; `Package.swift` multi-target layout; `.xcode-version` / `mise`/`xcodes` pin to **Xcode 27.1 beta**; `sdk-check` stub; README stub |
| **Depends on** | Locked SDK decision (done) |
| **Exit** | Documented install steps; CI can detect wrong Xcode and fail with a clear message |

### Phase A1 — Native MVP auditor (first dogfoodable slice)

| | |
| --- | --- |
| **Deliver** | `iphone-duo-prep` executable; 8–12 high-signal pattern + plist/project rules; Markdown/JSON report; `SampleApps/NativeVictim` with intentional failures |
| **Depends on** | A0 |
| **Exit** | Clone → `swift run iphone-duo-prep audit …` → scored backlog without watching Apple videos |

**Rules (initial set):** `UIScreen.main`, symmetric `safeAreaInsets * 2`, idiom/orientation branches, missing `UIApplicationSceneManifest`, `UIRequiresFullScreen`, fixed `CGRect` heuristics, storyboard size-class absence, hardcoded phone widths, single-window assumptions in flagged files.

### Phase A2 — Runtime + testing kit

| | |
| --- | --- |
| **Deliver** | `iPhoneDuoPrep` (safe-area helpers, screen-API shims, trait/size gates); `iPhoneDuoPrepTesting` presets; UIKit + SwiftUI SampleApp usage; ≥1 mechanical autofix (e.g. scale → `traitCollection.displayScale`) |
| **Depends on** | A1 (CLI shape stable enough to reference helpers in suggestions) |
| **Exit** | SampleApp links SPM; tests run against named Duo size presets; suggestions cite concrete APIs |

### Phase A3 — Duo-differentiated native surface

| | |
| --- | --- |
| **Deliver** | Feature-detected wrappers for reserved regions, hinge observers, Arrangement-style containers, multi-scene / outer-display session helpers; audit rules that emit `product-decision` + link to templates |
| **Depends on** | A2; Xcode 27.1 beta headers available in build env (or stubbed `#available` shims if headers lag) |
| **Exit** | Compiles under pinned beta; demos in SampleApp for fold-safe chrome + optional Arrangement path; no hard CI fail on missing symbols when SDK detection says unavailable |

### Phase A4 — Templates & camera scaffolds

| | |
| --- | --- |
| **Deliver** | Templates for scene stubs, Arrangement skeletons, outer-display accessory, camera direction coordinator hooks; docs for privacy/product decisions |
| **Depends on** | A3 API shapes |
| **Exit** | Engineer can scaffold outer-display capture path in &lt;30 minutes; camera remains opt-in product work, not forced by auditor |

### Phase A5 — Flutter & React Native

| | |
| --- | --- |
| **Deliver** | `iPhoneDuoPrepFlutter` plugin + `iPhoneDuoPrepRN` module; Dart/TS APIs mirroring size/hinge/reserved helpers where bridgeable; CLI rules for common Flutter/RN anti-patterns (fixed `MediaQuery`, orientation locks, missing platform views); smoke host apps |
| **Depends on** | A2 minimum; A3 for fold/hinge parity; does **not** block A1–A2 exit |
| **Exit** | Host apps call through adapters; `iphone-duo-prep audit` understands Flutter/`android`/`ios` trees enough to flag native-side gaps; gap doc lists APIs not yet exposed by Flutter/RN |

### Phase A6 — Stronger automation & CI

| | |
| --- | --- |
| **Deliver** | SourceKit (or equivalent) semantic rules; optional `autofix` / checklist-PR mode; GitHub Action; severity gating config; UI test matrix generator |
| **Depends on** | A1–A2 mature; A3 symbols stable enough not to thrash |
| **Exit** | Mid-size app audit &lt; 5 minutes; actionable ≥80%; noise dismissals &lt;15%; CI template in docs |

### Phase A7 — GM retarget

| | |
| --- | --- |
| **Deliver** | Retarget pin to Xcode 27.1 GM (or shipping successor); dual-run golden report diff; API deprecation scrub; release notes |
| **Depends on** | GM availability; A3–A6 feature-complete enough to compare |
| **Exit** | Single source of truth pin updated; CI green on GM; beta pin archived as `toolchain-legacy` for one release |

---

## 4. Concrete work breakdown

### Packages / targets (in `/workspace`)

```
/
  Package.swift
  Sources/
    iPhoneDuoPrep/                 # runtime library
    iPhoneDuoPrepTesting/          # test fixtures
    iphone-duo-prep/                # CLI executable target
  Adapters/
    iPhoneDuoPrepFlutter/          # Flutter plugin package
    iPhoneDuoPrepRN/               # RN native module + JS package
  Templates/
    Scene/
    Arrangement/
    OuterDisplay/
    Camera/
  SampleApps/
    NativeVictim/               # intentional audit failures (UIKit)
    SwiftUIVictim/
    FlutterHost/                # Phase A5
    RNHost/                     # Phase A5
  Tests/
    iPhoneDuoPrepTests/
    iPhoneDuoPrepCLITests/
    iPhoneDuoPrepTestingTests/
  .github/workflows/            # or org CI equivalent
  Docs/                         # developer-facing; keep in sync with store docs as needed
  README.md
  TOOLCHAIN.md                  # Xcode pin + GM migration
```

### Audit rule sets (build incrementally)

| Set | Phase | Examples |
| --- | --- | --- |
| **R1 Baseline layout** | A1 | `UIScreen.main`, fixed frames, symmetric safe area math |
| **R2 Scenes / multitasking** | A1–A2 | Scene manifest, `UIRequiresFullScreen`, single-screen Continuity assumptions |
| **R3 Orientation / idiom** | A1 | Idiom switches, orientation locks likely ignored on inner display |
| **R4 Duo-differentiated** | A3 | Custom chrome spanning fold without reserved-region awareness; missing hinge hooks where templates recommend |
| **R5 Camera / outer** | A4 | Front-camera-as-user assumptions; missing accessory scaffolding when capture + outer preview flagged |
| **R6 Flutter/RN** | A5 | Fixed design sizes, unsafe platform channel gaps, missing iOS scene config in host |
| **R7 Semantic** | A6 | SourceKit refinements of R1–R3; lower false positives |

### Runtime APIs (SPM — names illustrative; gate on headers)

- **Layout:** `DuoSafeArea`, size-class gates, reserved-region layout guide adapters  
- **Scenes:** outer/inner session helpers, activation helpers  
- **Hinge / Arrangement:** thin wrappers around SDK Arrangement / hinge APIs once confirmed  
- **Camera:** direction coordinator façade + accessory registration helpers  
- **Testing:** `DuoDisplayPreset` enum + XCTest helpers  

All public APIs: availability annotations + runtime SDK check; degrade gracefully on older SDKs.

### Flutter / RN adapter strategy

1. **Native-first:** implement behavior in `iPhoneDuoPrep`.  
2. **Bridge thin:** Flutter MethodChannel/EventChannel or RN TurboModule exposing presets, hinge stream, reserved insets.  
3. **Audit second:** CLI walks `ios/` (and key Dart/TS patterns) and points to adapter adoption.  
4. **Gap register:** markdown table of Duo APIs without framework parity — update every SDK pin bump.  
5. **Do not** fork Flutter/RN layout; document when apps must drop to platform views.

### SampleApp(s)

| App | Purpose |
| --- | --- |
| NativeVictim | Dogfood auditor; known finding count as CLI regression fixture |
| SwiftUIVictim | SwiftUI-specific rules + SPM helpers |
| (later) FlutterHost / RNHost | Adapter smoke + cross-platform audit |

### CI

- Job: resolve pinned Xcode → `swift test` → `iphone-duo-prep audit SampleApps/NativeVictim` → assert finding IDs present  
- Optional: severity gate (`blocker` fails build) configurable  
- Artifact: Markdown report upload  
- A7: matrix job beta-archive vs GM during migration window  

### Docs (ship with repo)

- README: install, audit, interpret severities, map to Apple Duo Prepare/Design  
- TOOLCHAIN.md: beta pin, `sdk-check`, GM checklist  
- ADAPTERS.md: Flutter/RN install + gaps  
- RULES.md: rule IDs, severity, autofix eligibility  

---

## 5. SDK pinning strategy (27.1 beta → GM)

### Now (locked)

1. Record exact **Xcode 27.1 beta** build number in `TOOLCHAIN.md` + CI env (`DEVELOPER_DIR` / `xcode-select`).  
2. CLI subcommand `iphone-duo-prep sdk-check` — fail or warn if local toolchain ≠ pin (policy flag).  
3. Feature detection: compile against beta headers; wrap new symbols; never assume final API names until verified in this environment.  
4. Snapshot **golden audit reports** per SampleApp under `Tests/Goldens/beta/`.  

### Follow-up when GM ships

| Step | Action |
| --- | --- |
| 1 | Install GM; dual CI matrix (beta pin + GM) for one sprint |
| 2 | Recompile; fix availability / renamed symbols |
| 3 | Re-run audits; diff goldens → `Tests/Goldens/gm/` |
| 4 | Update pin docs; tag `iphone-duo-prep` release `xcode-27.1-gm` |
| 5 | Drop beta from default CI; keep beta instructions under `toolchain-legacy` for 1 release |

### Policy

- No silent “latest Xcode” in CI.  
- Codegen and rule metadata carry `minXcode` / `verifiedSDK`.  
- Breaking API renames in `iPhoneDuoPrep` get semver minor/major per stability promise in README.

---

## 6. Risks, assumptions, open items

### Risks & mitigations

| Risk | Mitigation |
| --- | --- |
| Beta API churn | Feature-detect; version wrappers; goldens per toolchain |
| “Everything” scope slips MVP | Critical path A1–A2 first; A5 explicit non-blocker |
| Regex false positives | Promote hot rules to SourceKit in A6; track dismiss rate |
| Flutter/RN API lag | Gap register; ship bridges for what exists |
| Teams treat Duo as iPad | Docs + presets stress outer phone + fold continuum |
| Camera privacy / product complexity | Templates + `product-decision` severity; no forced autofix |

### Assumptions

- Harness consumers can run SwiftPM + CLI in CI (not Xcode-GUI-only).  
- At least one macOS agent/image can install Xcode 27.1 beta for CI.  
- ObjC hybrid call sites are minority; covered via auditors + limited `@objc` façades, not a full ObjC rewrite.  
- Apple’s dual-display / scene themes in the analysis remain directionally correct; exact spellings verified against headers during A3.

### Open items needing user input (blocking only)

1. **CI home:** GitHub Actions on this repo vs internal CI only — affects workflow files in A0/A6.  
2. **First consuming app:** which real app (or “SampleApps only until GM”) is the primary dogfood target for false-positive tuning.  
3. **Release vehicle:** public SPM URL / private registry / monorepo path — needed before external teams adopt A2.

*Not reopening:* product bar, stack mix, beta pin.

---

## 7. Suggested sequencing for agents (build in `/workspace`)

Execute in order; parallelize only where noted.

| Step | Agent focus | Done when |
| --- | --- | --- |
| **1** | Scaffold `Package.swift` with `iPhoneDuoPrep`, `iPhoneDuoPrepTesting`, `iphone-duo-prep`; add `TOOLCHAIN.md` pin | `swift build` works on pinned toolchain (or documents blocker if Xcode absent) |
| **2** | Implement CLI `audit` + R1–R3 rules + JSON/Markdown writer | Unit tests for rule matches on fixture snippets |
| **3** | Add `SampleApps/NativeVictim` + golden expected findings | `swift run iphone-duo-prep audit SampleApps/NativeVictim` matches goldens |
| **4** | Implement SPM helpers + testing presets; wire SampleApp | XCTest using `duoOuterPortrait` / `duoInnerRegular` / `duoSplitHalf` |
| **5** | One mechanical autofix + README dogfood path | Diff is reviewable; docs complete for MVP |
| **6** *(parallel after 4)* | A3 wrappers behind availability; expand SampleApp demos | Compiles; demos run on simulator where possible |
| **7** *(parallel after 4)* | Templates + camera scaffolds + RULES.md product-decision copy | Templates referenced from CLI suggestions |
| **8** | Flutter + RN adapters + host smoke apps + R6 rules | Hosts build; gap register published |
| **9** | SourceKit rules, CI workflow, autofix mode | CI green; metrics below met |
| **10** | GM retarget playbook execution when GM available | Pin flipped; goldens updated |

**First build slice (agents start here):** steps **1–5** only. Do not start Flutter/RN or full camera pipeline until NativeVictim dogfood works.

---

## 8. Success metrics per phase

| Phase | Metrics |
| --- | --- |
| **A0** | Wrong-Xcode detection works; pin documented |
| **A1** | Time-to-first-report on SampleApp &lt; 1 min; on mid-size app &lt; 5 min; ≥80% findings actionable (file:line + fix class) |
| **A2** | ≥1 autofix; SampleApp tests green on 3+ Duo presets; suggestion→helper deep links |
| **A3** | Differentiated APIs compile under beta; SampleApp shows ≥1 fold-aware and ≥1 Arrangement/outer path; zero hard fails when SDK symbols absent |
| **A4** | New engineer scaffolds camera/outer template &lt; 30 min; zero forced camera autofixes |
| **A5** | Flutter + RN hosts call hinge/size APIs; audit flags ≥5 cross-platform anti-patterns; gap register current |
| **A6** | CI noise dismissals &lt;15%; semantic rules reduce R1 FP by measurable %; UI matrix generator used in SampleApp |
| **A7** | GM CI green; golden diff reviewed; single pin in force |

**Org-level (post-adoption, track later):** median eng-hours audit→baseline-ready; Duo layout-bug rate vs phone; % top screens with size-matrix coverage; weekly CI adoption count.

---

## Bottom line

Ship **CLI + SPM + templates** on a native critical path that dogfoods in A1–A2, then expand the same v1 product to **hinge / outer display / camera** and **Flutter/RN adapters** without waiting for GM. Pin **Xcode 27.1 beta** now; treat GM as a planned retarget with golden diffs—not a reason to delay the harness.
