<!-- Phase A5 -->
# Flutter & React Native adapters

Thin bridges over `DuoHarness` (native-first). Copy or path-depend; not published to pub.dev / npm.

## Install

| Stack | Path | Host wiring |
| --- | --- | --- |
| Flutter | `Adapters/DuoHarnessFlutter/` | Add Dart package path; register `DuoHarnessPlugin` MethodChannel `duo_harness` (+ EventChannel `duo_harness/hinge`) in the iOS runner |
| React Native | `Adapters/DuoHarnessRN/` | Import `src/index.ts`; export native module name `DuoHarness` from the iOS target |

Smoke hosts: `SampleApps/FlutterHost`, `SampleApps/RNHost`.

## Bridged methods

| Dart / TS | Native (`DuoHarness`) |
| --- | --- |
| `safeAreaInsets` | `DuoSafeArea` (asymmetric insets) |
| `isCompactWidth` | `DuoSizeGate.isCompactWidth` |
| `hingeFraction` / `observeHinge` | `DuoHinge` |
| `reservedInsets` | `DuoReservedRegion` |

When the channel / module is missing, APIs return zeros / compact heuristic — same degrade as `DuoFeatureGate`.

## Gap register (not bridged)

| Native API | Status |
| --- | --- |
| `DuoCameraDirection` | Native / Templates only — product-decision; see `Docs/CAMERA.md` |
| `DuoOuterAccessory` | Native / Templates only |
| `DuoArrangement` / `DuoSceneSession` | Native / Templates only |
| Arrangement chrome / multi-scene activation | Drop to platform views or native modules; do not fork Flutter/RN layout |

Update this table on each SDK pin bump (A7).

## Audit

`duo-harness audit` scans `.dart` / `.ts` / `.tsx` / `.js` / `.jsx` for R6 anti-patterns (`FixedMediaQuery`, `OrientationLock`, `FixedDimensions`, `RNOrientationLock`, `MissingAdapter`) and still walks host `ios/` plists for R2/R3. No R6 autofix.
