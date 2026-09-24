import CoreGraphics
import DuoHarness

/// Copy for a two-pane Arrangement path. Reserved chrome insets are zero until the gate flips.
public enum DuoArrangementSkeleton {
    public static func split(container: CGSize) -> (DuoArrangement, DuoEdgeInsets) {
        (DuoArrangement.splitHalf(container: container), DuoReservedRegion.insets())
    }
}
