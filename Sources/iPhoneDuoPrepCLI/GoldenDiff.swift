import Foundation

// Phase A7 — dual-run golden report diff (beta vs gm).
public enum GoldenDiff {
    public struct Result: Sendable, Equatable {
        public var onlyInLeft: [String]
        public var onlyInRight: [String]
        public var identical: Bool { onlyInLeft.isEmpty && onlyInRight.isEmpty }
    }

    /// Compare two JSON audit reports by finding identity `id|file|severity`.
    public static func compare(leftJSON: String, rightJSON: String) throws -> Result {
        let left = try decodeKeys(leftJSON)
        let right = try decodeKeys(rightJSON)
        return Result(
            onlyInLeft: left.subtracting(right).sorted(),
            onlyInRight: right.subtracting(left).sorted()
        )
    }

    public static func markdown(_ result: Result, leftLabel: String, rightLabel: String) -> String {
        if result.identical {
            return "golden-diff: \(leftLabel) ≡ \(rightLabel) (identical finding set)\n"
        }
        var lines = ["golden-diff: \(leftLabel) ≠ \(rightLabel)", ""]
        if !result.onlyInLeft.isEmpty {
            lines.append("## only in \(leftLabel)")
            lines += result.onlyInLeft.map { "- `\($0)`" }
            lines.append("")
        }
        if !result.onlyInRight.isEmpty {
            lines.append("## only in \(rightLabel)")
            lines += result.onlyInRight.map { "- `\($0)`" }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private static func decodeKeys(_ json: String) throws -> Set<String> {
        let data = Data(json.utf8)
        let report = try JSONDecoder().decode(AuditReport.self, from: data)
        return Set(report.findings.map { "\($0.id)|\($0.file)|\($0.severity.rawValue)" })
    }
}
