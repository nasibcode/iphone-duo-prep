import DuoHarnessCLI
import XCTest

final class SDKCheckTests: XCTestCase {
    func testParsePinOutput() {
        let output = "Xcode 27.1\nBuild version 27A9269\n"
        XCTAssertEqual(
            SDKCheck.parse(output),
            XcodeVersion(marketing: "27.1", build: "27A9269")
        )
    }

    func testMatchAndMismatch() {
        let pin = "Xcode 27.1\nBuild version 27A9269\n"
        guard case .match = SDKCheck.evaluate(pin) else {
            return XCTFail("expected match")
        }

        let other = "Xcode 27.0\nBuild version 27A266a\n"
        guard case .mismatch(let message) = SDKCheck.evaluate(other) else {
            return XCTFail("expected mismatch")
        }
        XCTAssertTrue(message.contains("27A9269"))
        XCTAssertTrue(message.contains("27A266a"))
    }

    func testUnreadable() {
        guard case .unreadable = SDKCheck.evaluate(nil) else {
            return XCTFail("expected unreadable")
        }
        guard case .unreadable = SDKCheck.evaluate("not a version\n") else {
            return XCTFail("expected unreadable")
        }
    }
}
