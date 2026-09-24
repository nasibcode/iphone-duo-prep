import DuoHarness

/// Copy when capture + outer preview is a product choice. Never forced by the auditor.
public enum DuoOuterAccessoryStub {
    @discardableResult
    public static func registerIfProductWantsOuterPreview() -> Bool {
        DuoOuterAccessory.registerPreviewAccessoryIfAvailable()
    }
}
