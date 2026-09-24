import Foundation

// Phase A6 — SourceKit-equivalent refinements (no SourceKitten dep).
/// Drops R1–R3 line findings whose match sits in a `//` comment or string literal.
/// ponytail: lexer-lite; full SourceKit when FP rate needs AST.
public enum Semantic {
    public static func refine(_ report: AuditReport, root: URL) -> AuditReport {
        let kept = report.findings.filter { finding in
            guard finding.id.hasPrefix("R1.") || finding.id.hasPrefix("R2.") || finding.id.hasPrefix("R3.")
            else { return true }
            guard finding.line > 0 else { return true }
            let url = root.appendingPathComponent(finding.file)
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { return true }
            let lines = text.components(separatedBy: "\n")
            guard finding.line <= lines.count else { return true }
            return isCodeContext(lines[finding.line - 1], needle: needle(for: finding.id))
        }
        return AuditReport(findings: kept)
    }

    private static func needle(for id: String) -> String {
        switch id {
        case "R1.UIScreenMain": "UIScreen.main"
        case "R1.SafeAreaTimesTwo": "safeAreaInsets"
        case "R1.FixedCGRect": "CGRect"
        case "R1.HardcodedPhoneWidth": "width"
        case "R2.SingleWindow": "windows"
        case "R3.UserInterfaceIdiom": "userInterfaceIdiom"
        case "R3.OrientationLock": "orientation"
        default: ""
        }
    }

    /// True when `needle` appears outside `//` / `/* */` comments and outside `"…"` / `'…'` literals.
    public static func isCodeContext(_ line: String, needle: String) -> Bool {
        guard !needle.isEmpty, let range = line.range(of: needle) else { return true }
        let prefix = String(line[..<range.lowerBound])
        if prefix.contains("//") { return false }
        if oddQuotes(prefix, "\"") || oddQuotes(prefix, "'") { return false }
        return true
    }

    private static func oddQuotes(_ text: String, _ mark: Character) -> Bool {
        text.filter { $0 == mark }.count % 2 == 1
    }
}
