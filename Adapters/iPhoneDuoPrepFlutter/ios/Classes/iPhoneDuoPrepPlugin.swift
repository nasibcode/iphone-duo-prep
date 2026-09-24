// Phase A5 — Flutter MethodChannel / EventChannel bridge.
import Foundation
import CoreGraphics

#if canImport(Flutter)
import Flutter
#endif
#if canImport(iPhoneDuoPrep)
import iPhoneDuoPrep
#endif

/// MethodChannel / EventChannel stub. Wire into a Flutter plugin registrant in the host app.
/// Channel names: `iphone_duo_prep`, `iphone_duo_prep/hinge`.
public enum iPhoneDuoPrepPlugin {
    public static let methodChannelName = "iphone_duo_prep"
    public static let hingeEventChannelName = "iphone_duo_prep/hinge"

    public static func handle(method: String, arguments: [String: Any]?) -> Any? {
        switch method {
        case "safeAreaInsets", "reservedInsets":
            return ["top": 0.0, "left": 0.0, "bottom": 0.0, "right": 0.0]
        case "isCompactWidth":
            let width = (arguments?["width"] as? Double) ?? 0
            #if canImport(iPhoneDuoPrep)
            return DuoSizeGate.isCompactWidth(CGSize(width: width, height: 1))
            #else
            return width < 600
            #endif
        case "hingeFraction":
            #if canImport(iPhoneDuoPrep)
            return DuoHinge.currentFraction
            #else
            return 0.0
            #endif
        default:
            return nil
        }
    }
}
