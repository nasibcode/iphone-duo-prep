// Phase A5 — RNHost adapter demo (intentional R6 hits).
// Adapter smoke — calls iPhoneDuoPrepRN size/hinge APIs.
import {
  hingeFraction,
  isCompactWidth,
  observeHinge,
  reservedInsets,
  safeAreaInsets,
} from "../../../Adapters/iPhoneDuoPrepRN/src";

export async function demoDuoHelpers(): Promise<void> {
  const insets = await safeAreaInsets();
  const compact = await isCompactWidth(400);
  const hinge = await hingeFraction();
  const reserved = await reservedInsets();
  observeHinge(() => {});
  if (insets.top < 0 || hinge < 0 || reserved.left < 0) {
    throw new Error("unexpected negative inset");
  }
  void compact;
}
