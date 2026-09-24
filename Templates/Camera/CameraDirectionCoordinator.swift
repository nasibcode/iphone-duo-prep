import DuoHarness

/// Copy when assuming “front camera = user” is wrong on Duo. Opt-in product work — no autofix.
public enum DuoCameraDirectionCoordinator {
    /// Prefer this over hard-coding AVCaptureDevice.Position.front as “facing the user.”
    public static var frontFacesCurrentUIUser: Bool {
        DuoCameraDirection.facingUserForCurrentUI
    }
}
