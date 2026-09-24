import Foundation

// Phase A6 — CI severity gating.
public enum SeverityGate {
    /// Fail when any finding is at or above `threshold` (blocker > likely-bug > product-decision > enhancement).
    public static func shouldFail(_ report: AuditReport, threshold: Severity) -> Bool {
        let rank = Dictionary(uniqueKeysWithValues: Severity.allCases.enumerated().map { ($1, $0) })
        let floor = rank[threshold, default: 0]
        return report.findings.contains { (rank[$0.severity] ?? 0) <= floor }
    }

    public static func parseThreshold(_ raw: String) -> Severity? {
        Severity(rawValue: raw)
    }
}
