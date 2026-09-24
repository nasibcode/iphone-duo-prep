import DuoHarness

/// Copy into your app’s scene setup. Outer activation is a no-op until DuoFeatureGate flips.
public enum DuoSceneStub {
    @discardableResult
    public static func preferOuterIfAvailable() -> Bool {
        DuoSceneSession.activateOuterIfAvailable()
    }
}
