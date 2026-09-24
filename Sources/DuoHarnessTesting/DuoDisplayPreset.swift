// Phase A2 — named Duo size presets for tests.
import CoreGraphics

public enum DuoDisplayPreset: String, CaseIterable, Sendable {
    case duoOuterPortrait
    case duoInnerRegular
    case duoSplitHalf

    // ponytail: placeholder point sizes until Apple publishes Duo test matrices; retarget in A7.
    public var size: CGSize {
        switch self {
        case .duoOuterPortrait: CGSize(width: 402, height: 874)
        case .duoInnerRegular: CGSize(width: 740, height: 1024)
        case .duoSplitHalf: CGSize(width: 370, height: 1024)
        }
    }
}
