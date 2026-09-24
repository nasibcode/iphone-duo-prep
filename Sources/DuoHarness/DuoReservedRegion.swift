// Phase A3 — reserved-region / fold chrome insets.
import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

/// Fold / division reserved-region insets. Zero when differentiated APIs are unavailable.
public enum DuoReservedRegion {
    public static func insets(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) -> DuoEdgeInsets {
        guard DuoFeatureGate.differentiatedAPIsAvailable else {
            return DuoEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return DuoEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    #if canImport(UIKit)
    /// Until reserved-region layout guides ship, fall back to safe-area edges (still asymmetric-aware via DuoSafeArea).
    public static func layoutGuideInsets(for view: UIView) -> DuoEdgeInsets {
        guard DuoFeatureGate.differentiatedAPIsAvailable else {
            return DuoSafeArea.insets(from: view)
        }
        return DuoSafeArea.insets(from: view)
    }
    #endif
}
