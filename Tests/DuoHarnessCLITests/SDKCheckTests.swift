import DuoHarnessCLI
import Testing

// Phase A0 — toolchain pin unit tests (Swift Testing).
struct SDKCheckTests {
    @Test func parsePinOutput() {
        let output = "Xcode 27.1\nBuild version 27A9269\n"
        #expect(SDKCheck.parse(output) == XcodeVersion(marketing: "27.1", build: "27A9269"))
    }

    @Test func matchAndMismatch() {
        let pin = "Xcode 27.1\nBuild version 27A9269\n"
        guard case .match = SDKCheck.evaluate(pin) else {
            Issue.record("expected match")
            return
        }

        let other = "Xcode 27.0\nBuild version 27A266a\n"
        guard case .mismatch(let message) = SDKCheck.evaluate(other) else {
            Issue.record("expected mismatch")
            return
        }
        #expect(message.contains("27A9269"))
        #expect(message.contains("27A266a"))
    }

    @Test func unreadable() {
        guard case .unreadable = SDKCheck.evaluate(nil) else {
            Issue.record("expected unreadable for nil")
            return
        }
        guard case .unreadable = SDKCheck.evaluate("not a version\n") else {
            Issue.record("expected unreadable for garbage")
            return
        }
    }
}
