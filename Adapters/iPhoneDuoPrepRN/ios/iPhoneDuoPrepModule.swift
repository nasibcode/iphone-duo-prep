// Phase A5 — RN native module bridge.
import Foundation
import CoreGraphics

#if canImport(iPhoneDuoPrep)
import iPhoneDuoPrep
#endif

/// TurboModule / RCT_EXTERN stub. Export as `iPhoneDuoPrep` to match `NativeModules.iPhoneDuoPrep`.
public enum iPhoneDuoPrepModule {
    public static let moduleName = "iPhoneDuoPrep"

    public static func safeAreaInsets() -> [String: Double] {
        ["top": 0, "left": 0, "bottom": 0, "right": 0]
    }

    public static func reservedInsets() -> [String: Double] {
        ["top": 0, "left": 0, "bottom": 0, "right": 0]
    }

    public static func isCompactWidth(_ width: Double) -> Bool {
        #if canImport(iPhoneDuoPrep)
        return DuoSizeGate.isCompactWidth(CGSize(width: width, height: 1))
        #else
        return width < 600
        #endif
    }

    public static func hingeFraction() -> Double {
        #if canImport(iPhoneDuoPrep)
        return DuoHinge.currentFraction
        #else
        return 0
        #endif
    }
}
