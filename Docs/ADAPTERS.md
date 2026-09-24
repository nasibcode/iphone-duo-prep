<!-- Phase A5 -->
# Flutter & React Native adapters

Thin bridges over `iPhoneDuoPrep` (native-first). Copy or path-depend; not published to pub.dev / npm.

## Install

| Stack | Path | Host wiring |
| --- | --- | --- |
| Flutter | `Adapters/iPhoneDuoPrepFlutter/` | Add Dart package path; register `iPhoneDuoPrepPlugin` MethodChannel `iphone_duo_prep` (+ EventChannel `iphone_duo_prep/hinge`) in the iOS runner |
| React Native | `Adapters/iPhoneDuoPrepRN/` | Import `src/index.ts`; export native module name `iPhoneDuoPrep` from the iOS target |

Smoke hosts: `SampleApps/FlutterHost`, `SampleApps/RNHost`.

## Bridged methods

| Dart `IPhoneDuoPrep` / TS | Native (`iPhoneDuoPrep`) |
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

`iphone-duo-prep audit` scans `.dart` / `.ts` / `.tsx` / `.js` / `.jsx` for R6 anti-patterns (`FixedMediaQuery`, `OrientationLock`, `FixedDimensions`, `RNOrientationLock`, `MissingAdapter`) and still walks host `ios/` plists for R2/R3. No R6 autofix.
