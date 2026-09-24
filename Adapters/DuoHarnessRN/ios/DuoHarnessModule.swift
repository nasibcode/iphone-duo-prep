// Phase A5 — RN native module bridge.
import Foundation
import CoreGraphics

#if canImport(DuoHarness)
import DuoHarness
#endif

/// TurboModule / RCT_EXTERN stub. Export as `DuoHarness` to match `NativeModules.DuoHarness`.
public enum DuoHarnessModule {
    public static let moduleName = "DuoHarness"

    public static func safeAreaInsets() -> [String: Double] {
        ["top": 0, "left": 0, "bottom": 0, "right": 0]
    }

    public static func reservedInsets() -> [String: Double] {
        ["top": 0, "left": 0, "bottom": 0, "right": 0]
    }

    public static func isCompactWidth(_ width: Double) -> Bool {
        #if canImport(DuoHarness)
        return DuoSizeGate.isCompactWidth(CGSize(width: width, height: 1))
        #else
        return width < 600
        #endif
    }

    public static func hingeFraction() -> Double {
        #if canImport(DuoHarness)
        return DuoHinge.currentFraction
        #else
        return 0
        #endif
    }
}
