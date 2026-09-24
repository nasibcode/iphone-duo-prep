<!-- Phase A4 -->
# Camera & outer display — product decisions

Duo breaks the phone assumption that **front camera = person using this UI**. Outer-display capture / preview is **opt-in product work**, not a baseline migration fix.

## Decisions the auditor will not make for you

| Topic | Guidance |
| --- | --- |
| Who faces whom | Use `DuoCameraDirection` / `Templates/Camera/` instead of assuming `.front` faces the current UI user. |
| Outer preview | Only register accessories (`DuoOuterAccessory` / `Templates/OuterDisplay/`) when the product wants capture or preview on the outer display. |
| Autofix | **None.** Camera findings are `product-decision` only — never forced by `iphone-duo-prep autofix`. |

## Scaffold path (&lt; 30 min)

1. Copy `Templates/Camera/CameraDirectionCoordinator.swift` and call `frontFacesCurrentUIUser` before picking a capture device.
2. If outer preview is in scope, copy `Templates/OuterDisplay/OuterAccessoryStub.swift` and call `registerIfProductWantsOuterPreview()`.
3. Wire scene activation via `Templates/Scene/SceneStub.swift` when multi-display sessions matter.
4. Re-run `swift run iphone-duo-prep audit …` — R5 findings should clear once hooks appear on the flagged lines (or accept as intentional product debt).

See also: `Templates/Arrangement/` for fold-safe chrome; R4 for hinge/reserved-region decisions.
