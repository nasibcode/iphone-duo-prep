/// Compile/runtime gate for Duo-differentiated SDK symbols.
/// ponytail: always false until Xcode 27.1 beta headers expose Arrangement/hinge/reserved APIs; flip here, not at call sites.
public enum DuoFeatureGate {
    public static var differentiatedAPIsAvailable: Bool { false }
}
