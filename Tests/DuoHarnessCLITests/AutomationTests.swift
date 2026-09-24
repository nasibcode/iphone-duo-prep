import Foundation
import Testing
@testable import DuoHarnessCLI

// Phase A6 / A7 — semantic refine, severity gate, checklist, golden-diff.
struct AutomationTests {
    @Test func semanticDropsCommentAndStringHits() {
        #expect(!Semantic.isCodeContext("// let x = UIScreen.main", needle: "UIScreen.main"))
        #expect(!Semantic.isCodeContext("let s = \"UIScreen.main\"", needle: "UIScreen.main"))
        #expect(Semantic.isCodeContext("let s = UIScreen.main.bounds", needle: "UIScreen.main"))
    }

    @Test func semanticRefineFiltersCommentedFinding() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        <key>UIApplicationSceneManifest</key><dict/>
        </dict></plist>
        """.write(to: dir.appendingPathComponent("Info.plist"), atomically: true, encoding: .utf8)
        try "// UIScreen.main is mentioned only in a comment\n".write(
            to: dir.appendingPathComponent("Note.swift"), atomically: true, encoding: .utf8
        )
        let raw = try Audit.scan(root: dir)
        #expect(raw.findings.contains { $0.id == "R1.UIScreenMain" })
        let refined = Semantic.refine(raw, root: dir)
        #expect(!refined.findings.contains { $0.id == "R1.UIScreenMain" })
    }

    @Test func severityGateRanks() {
        let report = AuditReport(findings: [
            Finding(
                id: "R2.MissingSceneManifest",
                severity: .blocker,
                file: ".",
                line: 1,
                message: "m",
                suggestion: "s"
            ),
        ])
        #expect(SeverityGate.shouldFail(report, threshold: .blocker))
        #expect(SeverityGate.shouldFail(report, threshold: .enhancement))
        let clean = AuditReport(findings: [])
        #expect(!SeverityGate.shouldFail(clean, threshold: .blocker))
        #expect(SeverityGate.parseThreshold("likely-bug") == .likelyBug)
    }

    @Test func checklistMentionsFindings() {
        let report = AuditReport(findings: [
            Finding(
                id: "R1.UIScreenMain",
                severity: .likelyBug,
                file: "A.swift",
                line: 2,
                message: "bad",
                suggestion: "fix"
            ),
        ])
        let md = ChecklistPR.markdown(from: report)
        #expect(md.contains("R1.UIScreenMain"))
        #expect(md.contains("[ ]"))
        #expect(md.contains("mechanical autofix"))
    }

    @Test func goldenDiffIdenticalAndDivergent() throws {
        let left = """
        {"findings":[{"file":"A.swift","id":"R1.UIScreenMain","line":1,"message":"m","severity":"likely-bug","suggestion":"s"}]}
        """
        let same = try GoldenDiff.compare(leftJSON: left, rightJSON: left)
        #expect(same.identical)
        let right = """
        {"findings":[{"file":"B.swift","id":"R1.UIScreenMain","line":1,"message":"m","severity":"likely-bug","suggestion":"s"}]}
        """
        let diff = try GoldenDiff.compare(leftJSON: left, rightJSON: right)
        #expect(!diff.identical)
        #expect(diff.onlyInLeft.count == 1)
        #expect(diff.onlyInRight.count == 1)
        let md = GoldenDiff.markdown(diff, leftLabel: "beta", rightLabel: "gm")
        #expect(md.contains("only in beta"))
        #expect(md.contains("only in gm"))
    }

    @Test func gmNativeVictimGoldenMatchesBeta() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let beta = try String(
            contentsOf: root.appendingPathComponent("Tests/Goldens/beta/NativeVictim.json"),
            encoding: .utf8
        )
        let gm = try String(
            contentsOf: root.appendingPathComponent("Tests/Goldens/gm/NativeVictim.json"),
            encoding: .utf8
        )
        let result = try GoldenDiff.compare(leftJSON: beta, rightJSON: gm)
        #expect(result.identical)
    }
}
