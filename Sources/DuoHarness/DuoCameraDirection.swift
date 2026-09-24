/// Façade for “which camera faces whom” on Duo (front ≠ user of this UI).
/// ponytail: no AVFoundation until SDK direction coordinator lands; gate flip enables real mapping.
public enum DuoCameraDirection {
    public static var isAvailable: Bool { DuoFeatureGate.differentiatedAPIsAvailable }

    /// Whether the device front camera faces the person viewing the current UI.
    /// Always false while differentiated APIs are unavailable — do not treat as “facing user.”
    public static var facingUserForCurrentUI: Bool {
        guard DuoFeatureGate.differentiatedAPIsAvailable else { return false }
        return false
    }
}
