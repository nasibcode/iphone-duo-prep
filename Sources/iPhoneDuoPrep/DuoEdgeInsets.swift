// Phase A2 — asymmetric insets (never sum top+bottom).
import CoreGraphics

/// Separate edges — never sum top and bottom for Duo layouts.
public struct DuoEdgeInsets: Sendable, Equatable {
    public var top: CGFloat
    public var left: CGFloat
    public var bottom: CGFloat
    public var right: CGFloat

    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}
