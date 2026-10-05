# Agent loop

Use this when fixing an app for iPhone Duo. The build-tool plugin and `iPhoneDuoPrep` already ban the old pattern and compile on a current iPhone and on Duo. Apply only what the audit marked as safe.

1. Run `iphone-duo-prep audit <app> --format json --semantic`.
2. For `blocker` and `likely-bug`, apply that finding's `suggestion`. Run `autofix` only for `R1.UIScreenMain` when the line is `UIScreen.main.scale`. Call `DuoScreen`, `DuoSafeArea`, or `DuoSizeGate`. Do not hand-write `#available` or Arrangement symbols.
3. On `product-decision` (`R4.*`, `R5.*`), stop and ask the human. Camera rules are never autofixed. `DuoHinge`, `DuoReservedRegion`, `DuoArrangement`, `DuoCameraDirection`, and `DuoOuterAccessory` compile and then do nothing.
4. Re-run the audit. Done when blockers and likely-bugs are gone.

Do not clean `SampleApps/NativeVictim`. It is the golden fixture.

Rule catalog: [Docs/RULES.md](Docs/RULES.md).
