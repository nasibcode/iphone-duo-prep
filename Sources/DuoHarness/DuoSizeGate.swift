// Phase A2 — size-class gates (not idiom).
import CoreGraphics

public enum DuoSizeGate {
    /// Branch on container width, not `userInterfaceIdiom`.
    public static let compactWidthThreshold: CGFloat = 600

    public static func isCompactWidth(_ size: CGSize) -> Bool {
        size.width < compactWidthThreshold
    }
}
