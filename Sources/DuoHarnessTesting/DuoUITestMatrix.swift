import CoreGraphics

// Phase A6 — UI test matrix generator from Duo display presets.
public enum DuoUITestMatrix {
    public struct Entry: Sendable, Equatable {
        public var name: String
        public var size: CGSize
    }

    public static var entries: [Entry] {
        DuoDisplayPreset.allCases.map { Entry(name: $0.rawValue, size: $0.size) }
    }

    /// One line per preset for XCTest / Swift Testing parameterized args.
    public static func argumentLines() -> [String] {
        entries.map { "(\(quote($0.name)), CGSize(width: \($0.size.width), height: \($0.size.height)))" }
    }

    public static func markdownTable() -> String {
        var lines = [
            "| Preset | Width | Height |",
            "| --- | ---: | ---: |",
        ]
        for entry in entries {
            lines.append("| `\(entry.name)` | \(Int(entry.size.width)) | \(Int(entry.size.height)) |")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func quote(_ s: String) -> String { "\"\(s)\"" }
}
