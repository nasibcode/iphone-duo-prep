import Foundation

public struct XcodeVersion: Equatable, Sendable {
    public var marketing: String
    public var build: String

    public init(marketing: String, build: String) {
        self.marketing = marketing
        self.build = build
    }
}

public struct ToolchainPin: Equatable, Sendable {
    public var marketing: String
    public var build: String

    public init(marketing: String, build: String) {
        self.marketing = marketing
        self.build = build
    }

    /// Xcode 27.1 beta 1 (2026-09-18). `xcodebuild -version` prints both lines.
    public static let xcode27_1Beta = ToolchainPin(marketing: "27.1", build: "27A9269")
}

public enum SDKCheckResult: Equatable, Sendable {
    case match(XcodeVersion)
    case mismatch(String)
    case unreadable(String)
}

public enum SDKCheck {
    public static func parse(_ output: String) -> XcodeVersion? {
        var marketing: String?
        var build: String?
        for line in output.split(whereSeparator: \.isNewline) {
            let text = line.trimmingCharacters(in: .whitespaces)
            if text.hasPrefix("Xcode ") {
                marketing = String(text.dropFirst("Xcode ".count))
            } else if text.hasPrefix("Build version ") {
                build = String(text.dropFirst("Build version ".count))
            }
        }
        guard let marketing, let build, !marketing.isEmpty, !build.isEmpty else { return nil }
        return XcodeVersion(marketing: marketing, build: build)
    }

    public static func evaluate(_ output: String?, pin: ToolchainPin = .xcode27_1Beta) -> SDKCheckResult {
        guard let output, let actual = parse(output) else {
            return .unreadable(
                "sdk-check: could not read `xcodebuild -version`. Select the pinned Xcode with xcode-select. See TOOLCHAIN.md."
            )
        }
        if actual.marketing == pin.marketing, actual.build == pin.build {
            return .match(actual)
        }
        return .mismatch(
            """
            sdk-check: toolchain mismatch.
              wanted: Xcode \(pin.marketing) (\(pin.build))
              found:  Xcode \(actual.marketing) (\(actual.build))
            Install Xcode \(pin.marketing) beta and point xcode-select at it. See TOOLCHAIN.md.
            """
        )
    }
}

public enum XcodeBuild {
    public static func versionOutput() -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["xcodebuild", "-version"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
