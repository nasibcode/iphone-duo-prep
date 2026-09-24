// Phase A4 — outer-display accessory registration.
/// Outer-display preview / capture accessory registration.
/// ponytail: name-only stub; real scene accessory APIs when DuoFeatureGate flips.
public enum DuoOuterAccessory {
    public static var isAvailable: Bool { DuoFeatureGate.differentiatedAPIsAvailable }

    /// Registers an outer-display preview accessory when SDK symbols exist. Always false today.
    @discardableResult
    public static func registerPreviewAccessoryIfAvailable() -> Bool {
        guard DuoFeatureGate.differentiatedAPIsAvailable else { return false }
        return false
    }
}
