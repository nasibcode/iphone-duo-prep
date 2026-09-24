/** Phase A5 — React Native TS façade. */
/**
 * Thin TS façade over the iPhoneDuoPrep native module.
 * Defaults match DuoFeatureGate degrade when NativeModules.iPhoneDuoPrep is absent.
 */

export type DuoInsets = {
  top: number;
  left: number;
  bottom: number;
  right: number;
};

type DuoNative = {
  safeAreaInsets?: () => Promise<DuoInsets>;
  isCompactWidth?: (width: number) => Promise<boolean>;
  hingeFraction?: () => Promise<number>;
  reservedInsets?: () => Promise<DuoInsets>;
  addHingeListener?: (cb: (fraction: number) => void) => { remove: () => void };
};

const zeroInsets = (): DuoInsets => ({ top: 0, left: 0, bottom: 0, right: 0 });

function native(): DuoNative | undefined {
  try {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const { NativeModules } = require("react-native");
    return NativeModules?.iPhoneDuoPrep as DuoNative | undefined;
  } catch {
    return undefined;
  }
}

export async function safeAreaInsets(): Promise<DuoInsets> {
  return (await native()?.safeAreaInsets?.()) ?? zeroInsets();
}

export async function isCompactWidth(width: number): Promise<boolean> {
  const result = await native()?.isCompactWidth?.(width);
  return result ?? width < 600;
}

export async function hingeFraction(): Promise<number> {
  return (await native()?.hingeFraction?.()) ?? 0;
}

export async function reservedInsets(): Promise<DuoInsets> {
  return (await native()?.reservedInsets?.()) ?? zeroInsets();
}

/** Registers a hinge observer; no-ops when the native module is unavailable. */
export function observeHinge(handler: (fraction: number) => void): { remove: () => void } {
  const sub = native()?.addHingeListener?.(handler);
  if (sub) return sub;
  return { remove: () => {} };
}
