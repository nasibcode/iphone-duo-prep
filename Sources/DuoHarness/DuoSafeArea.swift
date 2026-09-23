import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

public enum DuoSafeArea {
    /// Keeps vertical insets separate; Duo safe area is asymmetric across the fold.
    public static func insets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> DuoEdgeInsets {
        DuoEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    #if canImport(UIKit)
    public static func insets(from view: UIView) -> DuoEdgeInsets {
        let safe = view.safeAreaInsets
        return DuoEdgeInsets(top: safe.top, left: safe.left, bottom: safe.bottom, right: safe.right)
    }
    #endif
}
