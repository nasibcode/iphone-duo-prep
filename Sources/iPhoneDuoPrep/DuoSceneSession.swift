// Phase A3 — outer / multi-scene session helpers.
/// Outer / multi-scene session helpers. Returns false when differentiated APIs are unavailable (never throws).
public enum DuoSceneSession {
    public static var preferOuterDisplay: Bool { false }

    /// Attempts to activate an outer-display session. Always false until SDK symbols land.
    @discardableResult
    public static func activateOuterIfAvailable() -> Bool {
        guard DuoFeatureGate.differentiatedAPIsAvailable else { return false }
        return false
    }
}
