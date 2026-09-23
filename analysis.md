# iPhone Duo Migration Harness — Analysis

**Audience:** iOS eng leads deciding whether to build a developer harness that makes Duo support “mostly automatic.”  
**Date:** 2026-09-22  
**Repo:** `duo-harness` — initial SPM scaffold (`DuoHarness` product).  
**Verdict:** A harness is feasible and valuable as an **audit + runtime helpers + guided patches** product. A true **zero-manual-migration** tool is not realistic. Ship MVP as SPM + CLI first.

---

## 1. What “iPhone Duo support” likely means

### Known from public Apple signals (treat as constraints)

| Signal | Source class | Implication for apps |
| --- | --- | --- |
| Book-style foldable with **5.4″ outer** + **7.6″ inner** displays, **matched aspect ratio** | Apple product / specs pages | Content can scale between closed and open; “one layout that resizes” is the baseline story |
| Ships with **iOS 27.1**; marketing highlights **poses/orientations**, **Split View** side-by-side apps, StandBy-style outer-display use | Apple marketing + developer hub | Apps must survive continuous resize, multitasking half-widths, and posture changes — not a single fixed phone size |
| Apple Developer hub: *Get ready for iPhone Duo* — Tech Talks on design, prepare, vertical bars, adaptive layouts, **multiple displays and scenes** | [developer.apple.com/iphone-duo](https://developer.apple.com/iphone-duo/) | Dual-display / scene awareness is a first-class theme, not “just a bigger phone” |
| HIG entry *Designing for iPhone Duo* live; written *Preparing your app…* and **Xcode 27.1 beta** were still rolling out through mid/late September | Apple Developer hub (status fluctuates) | SDK surface is new and still stabilizing; harness must version against SDK headers, not blog posts |
| Rebuild SDK changes how much screen the app gets (older SDK → letterboxed / familiar size; newest → edge-to-edge + system chrome adaptations) | Repeated in secondary write-ups citing Apple overview | “Support” includes **rebuilding with the Duo-capable SDK**, not only new UI |

**Practical definition for most UIKit/SwiftUI apps:**

1. **Resize-correct** on outer and inner displays (and Split View halves).  
2. **Scene/window-safe** (no `UIScreen.main` assumptions; UIScene lifecycle).  
3. **Fold-aware** where custom chrome or grids cross the hinge.  
4. **Pose-aware** only where product needs it (camera preview on outer display, media, productivity two-pane).  
5. **System chrome compatible** (asymmetric safe areas / vertical bars on some poses).

### Secondary / unverified until headers confirm (label carefully)

Community write-ups derived from Tech Talks/HIG (not yet independently verified against shipped Xcode 27.1 headers in this workspace) describe APIs such as:

- `ArrangementView` / `UIArrangementViewController` (split vs overlay around the fold)
- `reservedRegions` (division = fold; occlusion = cameras)
- Hinge observers (`onHingeChange` / `UIHingeInteraction`)
- Vertical toolbar/tab bar behavior + opt-outs
- Camera direction coordinator + outer-display capture accessories / scene accessories

**Harness rule:** treat these names as **likely shape**, gate codegen on `#available` + SDK detection, and never hard-fail CI on symbols until the team pins an SDK version.

### Speculation (product, not platform)

- Whether every third-party app gets a rich outer-display session vs “paused until open” for untouched apps  
- Exact App Store review criteria / badges for “Duo optimized”  
- How much Flutter / React Native will ever expose fold features natively  

Do not bake those into v1 automation.

---

## 2. Recommended harness shape

**Recommendation: SPM package + CLI auditor (+ optional Xcode templates).**  
Do **not** start with an Xcode plugin or full AST-rewriting “migrate my app” product.

| Layer | Role | Why |
| --- | --- | --- |
| **1. CLI (`duo-harness`)** | Static scan of Swift / storyboards / Info.plist / project settings; emit prioritized findings + patch suggestions | Fastest value for any existing codebase; CI-friendly |
| **2. SPM library (`DuoHarness` / `DuoKit`)** | Runtime helpers: trait/size wrappers, reserved-region adapters, safe layout helpers, test fixtures, optional Arrangement wrappers | Catches what static analysis cannot; ships with the app |
| **3. Templates / snippets** | Scene delegate stubs, ArrangementView skeletons, camera accessory scaffolds, XCTest / snapshot size matrices | Reduces boilerplate after human decisions |
| **4. Lint rules (SwiftLint custom / SourceKit)** | Ban patterns: `UIScreen.main`, symmetric `safeAreaInsets.left * 2`, orientation locks keyed off idiom | Continuous prevention |
| **5. Codegen (limited)** | Generate size-class test matrices, Info.plist scene manifests, “checklist PRs” | Only for mechanical files |
| **Defer:** Xcode Source Editor extension / GUI migrator | High maintenance, low incremental value over CLI | Revisit after CLI proves adoption |

### Why this beats “just a plugin”

- Works in CI and for monorepos / Tuist / Bazel-ish setups where plugins are awkward.  
- Separates **detection** (CLI) from **behavior** (SPM).  
- Matches how successful Apple-platform readiness tools work (e.g. scene migration checklists, accessibility scanners): audit → guided fix → runtime safety net.

### Concrete package sketch (illustrative only — not implemented)

```
DuoHarness/
  Sources/DuoHarness/          # runtime: SizeClassGate, ReservedRegionLayout, HingeBridge
  Sources/DuoHarnessTesting/   # preset display configs for UI tests
Plugins/ or Tools/duo-harness/ # CLI: audit, report, suggest
Templates/                     # Scene + Arrangement starters
```

CLI outputs: JSON + Markdown report with severity (`blocker` / `likely-bug` / `product-decision` / `enhancement`).

---

## 3. Automation boundary — where “zero manual work” fails

| Fully / mostly automatic | Semi-automatic (human confirms) | Human judgment required |
| --- | --- | --- |
| Detect `UIScreen.main`, deprecated screen APIs | Propose traitCollection / scene replacements | Whether a screen should be one-pane vs Arrangement split vs overlay |
| Detect missing UIScene lifecycle / scene manifest gaps | Generate scene configuration stubs | Navigation IA: what is primary vs secondary across the fold |
| Detect orientation locks & idiom branches | Suggest size-class refactors | Which orientations/poses the product supports |
| Flag symmetric safe-area math | Suggest inset-by-safeArea rewrite | Custom drawing that must avoid fold vs intentionally span it |
| Flag `UIRequiresFullScreen` / fixed frame layouts | Suggest Auto Layout / flexible constraints | Brand-critical layouts that “look wrong” when tall/wide |
| Enumerate storyboards without adaptive size classes | List candidates | Visual redesign of marketing/onboarding |
| Scaffold camera accessory / dual-front-camera hooks | Wire into existing capture pipeline | Privacy UX, which camera faces whom, preview on outer display |
| Generate XCTest size matrices (outer/inner/Split View) | Add to scheme | Snapshot baselines / golden images |
| Checklist App Store / SDK build target | Bump deployment / SDK in project | Marketing copy, screenshots, review notes |

**Unrealistic promise:** “run one command, ship Duo-ready.”  
**Realistic promise:** “run one command, get a scored backlog; apply safe mechanical fixes; use SPM helpers for the rest; reserve designer/eng time for the 20% that is product.”

---

## 4. Migration surface area (checklist for the harness)

### Layouts & chrome
- Auto Layout / SwiftUI flexible layout vs fixed widths  
- Asymmetric safe areas (vertical bars / Split View half)  
- Custom tab/toolbars vs system containers (system gets fold avoidance “for free”)  
- Grids/columns interacting with fold **division** regions  

### Scenes, windows, multitasking
- UIScene lifecycle (hard requirement when building with modern iOS 27 SDKs per secondary Apple-derived guidance)  
- Multiple windows / activation actions where relevant  
- Split View half-size testing (reportedly not optional on Duo for multitasking users)  
- State restoration across open/close and display handoff  

### Orientation & pose
- Inner display may ignore traditional orientation locks (secondary Tech Talk summaries)  
- Partial fold (“standing” / laptop-like) layouts — product feature, not default  
- Hinge-driven UI only where it adds value (don’t hinge-animate everything)  

### Input & focus
- First responder / keyboard avoidance across fold  
- Pointer / Pencil (Apple Pencil support called out on Duo hardware messaging)  
- Drag-and-drop across Split View apps  

### Deep links & continuity
- URL / universal links when scene count or display changes  
- Handoff / Continuity assumptions tied to a single screen  
- Live Activities / Dynamic Island interaction with outer camera occlusion  

### Media & camera
- Front camera no longer equals “facing the user of this UI”  
- Outer-display preview / capture accessories (opt-in product work)  
- Video players: often want horizontal bars (vertical-bar opt-out)  

### Tests
- UI tests for outer, inner, Split View, pose transitions  
- Snapshot tests with reserved-region fixtures  
- Performance under dual-display / thermal scenarios (secondary to layout)  

### Store / capabilities / build
- Build with Duo-capable SDK (27.1+) when available  
- Info.plist scene configs, orientation keys, required device capabilities  
- App Store screenshots for both displays / Split View (manual creative)  
- April 2027-style SDK requirements for uploads (track Apple’s published deadlines)  

---

## 5. Phased approach & success metrics

### Phase 0 — Spec lock (days of calendar avoided; do this before coding)
- Pin target OS/SDK (27.1 vs “latest beta”).  
- Decide “baseline ready” vs “Duo-differentiated” product bar.  
- Inventory UIKit vs SwiftUI vs hybrid vs cross-platform.

### Phase 1 — MVP harness (recommended first build in this empty repo)
1. CLI auditor: pattern rules + Info.plist/project scan + Markdown/JSON report.  
2. SPM stub: safe-area helper, screen-API shims, test size presets.  
3. Doc pack: “baseline ready” checklist mapped to Apple’s Prepare/Design pages.  
4. Sample “victim” mini-app in-repo to dogfood the auditor (synthetic bad patterns).

**MVP success metrics**
- Time-to-first-report on a mid-size app &lt; 5 minutes.  
- ≥80% of findings are actionable (file:line + suggested fix class).  
- False-positive rate low enough that teams keep the CI job on (target &lt;15% dismissed-as-noise).  
- At least one mechanical autofix (e.g. `UIScreen.main.scale` → trait displayScale) with reviewable diff.

### Phase 2 — Stronger automation
- SourceKit-based semantic rules (not only regex).  
- Optional autofix PR mode for safe replacements.  
- ArrangementView / reserved-region wrappers once SDK symbols are stable.  
- UI test matrix generator + example XCUITest host.

### Phase 3 — Differentiated Duo experiences
- Templates for outer-display camera accessory, two-pane productivity, media pose.  
- Design-time lint for “product decisions still open.”  
- Metrics dashboard: % screens resize-clean / % custom chrome fold-safe.

**Developer success metrics (org-level)**
- Median eng-hours from first audit → “baseline ready” build.  
- Crash-free / layout-bug rate on Duo vs prior phone in beta.  
- % of top screens with automated size-matrix coverage.  
- Adoption: teams running harness in CI weekly.

---

## 6. Risks & open questions

### Risks
| Risk | Mitigation |
| --- | --- |
| SDK/API churn while Xcode 27.1 stabilizes | Feature-detect; version package; don’t ship brittle codegen |
| Over-promising “zero manual work” | Product copy: audit + helpers + guided fixes |
| Regex false positives / missing Swift macros | Move to SourceKit ASAP for Phase 2 |
| Cross-platform (Flutter/RN) gap | Separate adapters; don’t pretend native fold APIs exist yet |
| Teams treating Duo as iPad clone incorrectly | Teach continuum-of-sizes model; still test phone-outer + fold |
| Legal/ToS if scraping Apple videos for “skills” | Prefer official docs + headers; cite Apple sources |

### Open questions for the user / stakeholders
1. **Product bar:** Baseline resize-correct only, or differentiated outer-display / hinge / camera features in v1?  
2. **Target stack mix:** % UIKit vs SwiftUI vs hybrid; any Flutter/RN?  
3. **SDK pin:** Build against shipping Xcode 27.1 beta as soon as available, or wait for GM?  
4. **Org constraints:** Can a CLI + SPM land in CI, or is an Xcode-only workflow mandatory?  
5. **Scope of “most iOS apps”:** First-party catalog size, monorepo vs many repos, ObjC remaining?  
6. **Success definition:** Store readiness by Duo launch (Oct 23, 2026 availability messaging) vs longer quality bar?

---

## 7. Recommended next build slice (this empty repo)

**Do not** implement a full migrator yet. Build a **dogfoodable MVP** that proves the automation boundary:

1. **Scaffold** Swift package `DuoHarness` + executable target `duo-harness`.  
2. **Ship 8–12 high-signal audit rules** (UIScreen.main, safeArea `* 2`, idiom/orientation branches, missing UIApplicationSceneManifest, UIRequiresFullScreen, fixed CGRect layouts in flagged files, storyboard size-class absence heuristic).  
3. **Add** `DuoHarnessTesting` with named size presets: `duoOuterPortrait`, `duoInnerRegular`, `duoSplitHalf`.  
4. **Add** a tiny SampleApp with intentional failures so `duo-harness audit` demonstrates value.  
5. **README:** how to run CLI, interpret severities, map findings → Apple Prepare/Design docs.  
6. **Defer** Arrangement/hinge/camera wrappers until SDK headers are available in the build environment.

**Exit criteria for the slice:** a new engineer can clone, run `swift run duo-harness audit SampleApp`, and get a prioritized report without reading Apple’s videos first.

---

## Sources & confidence

| Claim area | Confidence | Notes |
| --- | --- | --- |
| Hardware dual display, sizes, Split View marketing, poses | High | Apple.com product + specs |
| Developer themes (adaptive layout, multi display/scenes, vertical bars) | High | Apple Developer Duo hub session titles + HIG pointer |
| Exact API spellings / availability | Medium until headers checked | Secondary transcripts & guides; verify in Xcode 27.1 |
| Outer-display third-party baseline behavior | Low–medium | Apple has framed the problem; defaults still clarifying in press |
| Zero-manual full migration | N/A | Rejected on engineering grounds, independent of Apple |

---

## Bottom line

Build a **CLI auditor + SPM runtime/testing kit**, not a magic migrator. Automate detection and mechanical fixes; leave layout IA, camera/outer-display product choices, and visual QA to humans. That is the maximum honest automation for “most iOS apps” needing Duo support before and after the iOS 27.1 SDK fully lands.
