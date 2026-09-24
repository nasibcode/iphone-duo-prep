import CoreGraphics

/// Thin Arrangement-style two-pane descriptor. Does not bind unknown SDK types.
public struct DuoArrangement: Sendable, Equatable {
    public var primary: CGSize
    public var secondary: CGSize

    public init(primary: CGSize, secondary: CGSize) {
        self.primary = primary
        self.secondary = secondary
    }

    /// Equal split of `container` along the width axis.
    public static func splitHalf(container: CGSize) -> DuoArrangement {
        let half = CGSize(width: container.width / 2, height: container.height)
        return DuoArrangement(primary: half, secondary: half)
    }

    public var isAvailable: Bool { DuoFeatureGate.differentiatedAPIsAvailable }
}
