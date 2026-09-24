import Foundation

public enum Severity: String, Codable, CaseIterable, Equatable, Sendable {
    case blocker
    case likelyBug = "likely-bug"
    case productDecision = "product-decision"
    case enhancement
}

public struct Finding: Codable, Equatable, Sendable {
    public var id: String
    public var severity: Severity
    public var file: String
    public var line: Int
    public var message: String
    public var suggestion: String
}

public struct AuditReport: Codable, Equatable, Sendable {
    public var findings: [Finding]
}

public enum AuditScanError: Error, Equatable {
    case unreadableRoot(String)
}

public enum Audit {
    /// Line and plist scan. Paths in findings are relative to `root`.
    /// ponytail: line and plist-key scan, no comment/string lexer. SourceKit is A6.
    public static func scan(root: URL) throws -> AuditReport {
        let root = root.standardizedFileURL
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: root.path, isDirectory: &isDirectory),
              FileManager.default.isReadableFile(atPath: root.path) else {
            throw AuditScanError.unreadableRoot(root.path)
        }

        var findings: [Finding] = []
        var sawInfoPlist = false
        if isDirectory.boolValue {
            let enumerator = FileManager.default.enumerator(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: []
            )
            while let item = enumerator?.nextObject() as? URL {
                let directory = (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if directory {
                    if skipDirectories.contains(item.lastPathComponent) {
                        enumerator?.skipDescendants()
                    }
                    continue
                }
                findings += scanFile(item, root: root, sawInfoPlist: &sawInfoPlist)
            }
        } else {
            findings += scanFile(root, root: root.deletingLastPathComponent(), sawInfoPlist: &sawInfoPlist)
        }

        if !sawInfoPlist {
            let file = isDirectory.boolValue ? "." : root.lastPathComponent
            findings.append(sceneManifest(file: file, message: "No Info.plist with UIApplicationSceneManifest."))
        }

        return AuditReport(findings: sorted(findings))
    }

    public static func jsonString(_ report: AuditReport) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = (try? encoder.encode(report)) ?? Data("{}".utf8)
        return String(decoding: data, as: UTF8.self) + "\n"
    }

    public static func markdown(_ report: AuditReport) -> String {
        var counts: [Severity: Int] = [:]
        for finding in report.findings {
            counts[finding.severity, default: 0] += 1
        }
        let summary = Severity.allCases.compactMap { severity -> String? in
            guard let count = counts[severity], count > 0 else { return nil }
            return "\(count) \(severity.rawValue)"
        }.joined(separator: " · ")

        var lines = [summary]
        for severity in Severity.allCases {
            let group = report.findings.filter { $0.severity == severity }
            if group.isEmpty { continue }
            lines.append("")
            lines.append("## \(severity.rawValue)")
            lines.append("")
            for finding in group {
                lines.append(
                    "- `\(finding.id)` `\(finding.file):\(finding.line)` — \(finding.message) \(finding.suggestion)"
                )
            }
        }
        return lines.joined(separator: "\n")
    }

    private static let skipDirectories: Set<String> = [
        ".git", ".build", "DerivedData", "Pods", "node_modules", "checkouts",
    ]
    private static let lineExtensions: Set<String> = ["swift", "m", "mm", "h"]

    private static func scanFile(_ url: URL, root: URL, sawInfoPlist: inout Bool) -> [Finding] {
        let relativePath = relative(url, to: root)
        let ext = url.pathExtension.lowercased()
        if url.lastPathComponent == "Info.plist" {
            sawInfoPlist = true
        }
        if ext == "plist" {
            return scanPlist(url, file: relativePath, isInfo: url.lastPathComponent == "Info.plist")
        }
        if ext == "pbxproj" {
            return scanPbxproj(url, file: relativePath)
        }
        if ext == "storyboard" || ext == "xib" {
            return scanInterface(url, file: relativePath)
        }
        if lineExtensions.contains(ext) {
            return scanLines(url, file: relativePath)
        }
        return []
    }

    private static func scanLines(_ url: URL, file: String) -> [Finding] {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        var findings: [Finding] = []
        for (offset, raw) in text.components(separatedBy: "\n").enumerated() {
            findings += matchLine(raw, file: file, lineNumber: offset + 1)
        }
        return findings
    }

    private static func matchLine(_ line: String, file: String, lineNumber: Int) -> [Finding] {
        var findings: [Finding] = []
        if line.contains("UIScreen.main") {
            findings.append(make(
                "R1.UIScreenMain", .likelyBug, file, lineNumber,
                "UIScreen.main does not track the window's screen.",
                "Use DuoScreen for the window scene's screen; use traitCollection.displayScale for scale."
            ))
        }
        if line.contains("safeAreaInsets"),
           line.contains(/\*\s*2\b/) || (line.contains(".top") && line.contains(".bottom")) {
            findings.append(make(
                "R1.SafeAreaTimesTwo", .likelyBug, file, lineNumber,
                "safeAreaInsets are combined symmetrically.",
                "Use DuoSafeArea; keep top and bottom insets separate."
            ))
        }
        if line.contains(/CGRect\s*\(\s*x:\s*-?\d+.*width:\s*-?\d+.*height:\s*-?\d+/) {
            findings.append(make(
                "R1.FixedCGRect", .likelyBug, file, lineNumber,
                "Frame uses a fixed CGRect.",
                "Size from the container; use DuoDisplayPreset sizes in tests."
            ))
        }
        if line.contains("width"), line.contains(/\b(320|375|390|393|402|428|430)(\.0)?\b/) {
            findings.append(make(
                "R1.HardcodedPhoneWidth", .likelyBug, file, lineNumber,
                "Width is a hardcoded phone point value.",
                "Use container width or DuoDisplayPreset, not a phone point value."
            ))
        }
        if singleWindow(line) {
            findings.append(make(
                "R2.SingleWindow", .likelyBug, file, lineNumber,
                "Code assumes a single window.",
                "Use the scene window; do not assume one UIWindow."
            ))
        }
        if line.contains("userInterfaceIdiom") || line.contains("UIUserInterfaceIdiom") {
            findings.append(make(
                "R3.UserInterfaceIdiom", .likelyBug, file, lineNumber,
                "Layout branches on userInterfaceIdiom.",
                "Use DuoSizeGate on container size, not phone/pad idiom."
            ))
        }
        if orientation(line) {
            findings.append(make(
                "R3.OrientationLock", .likelyBug, file, lineNumber,
                "Orientation is locked or read from the device.",
                "Lay out for the current size; the inner display can ignore orientation locks."
            ))
        }
        if customChromeNoReserved(line) {
            findings.append(make(
                "R4.CustomChromeNoReserved", .productDecision, file, lineNumber,
                "Custom chrome may span the fold without reserved-region awareness.",
                "Use DuoReservedRegion for fold-safe chrome; see Templates/Arrangement/."
            ))
        }
        if missingHingeHook(line) {
            findings.append(make(
                "R4.MissingHingeHook", .productDecision, file, lineNumber,
                "Fold/hinge pose is used without a DuoHinge hook.",
                "Observe via DuoHinge; see Templates/Arrangement/."
            ))
        }
        if frontCameraAsUser(line) {
            findings.append(make(
                "R5.FrontCameraAsUser", .productDecision, file, lineNumber,
                "Front camera is assumed to face the user of this UI.",
                "Use DuoCameraDirection; see Templates/Camera/ and Docs/CAMERA.md."
            ))
        }
        if captureWithoutOuterAccessory(line) {
            findings.append(make(
                "R5.CaptureWithoutOuterAccessory", .productDecision, file, lineNumber,
                "Capture/preview mentions outer display without accessory scaffolding.",
                "Use DuoOuterAccessory; see Templates/OuterDisplay/ and Docs/CAMERA.md."
            ))
        }
        return findings
    }

    private static func customChromeNoReserved(_ line: String) -> Bool {
        let chrome = line.contains("UIToolbar") || line.contains("UITabBar")
        let spans = line.contains(".frame") || line.contains("bounds")
        return chrome && spans && !line.contains("DuoReservedRegion")
    }

    private static func missingHingeHook(_ line: String) -> Bool {
        let pose =
            line.contains("hingeAngle")
            || line.contains("foldState")
            || line.contains("partialFold")
            || line.contains("standingPose")
        return pose && !line.contains("DuoHinge")
    }

    private static func frontCameraAsUser(_ line: String) -> Bool {
        let front =
            line.contains("AVCaptureDevice.Position.front")
            || line.contains("position = .front")
            || line.contains("frontCamera")
        return front && !line.contains("DuoCameraDirection")
    }

    private static func captureWithoutOuterAccessory(_ line: String) -> Bool {
        let capture =
            line.contains("AVCaptureSession")
            || line.contains("videoPreviewLayer")
            || line.contains("startRunning")
        let outer = line.contains("outer") || line.contains("OuterDisplay")
        return capture && outer && !line.contains("DuoOuterAccessory")
    }

    private static func singleWindow(_ line: String) -> Bool {
        line.contains("UIApplication.shared.windows")
            || line.contains("UIApplication.shared.keyWindow")
            || line.contains(".windows.first")
            || line.contains("connectedScenes.count == 1")
            || line.contains("windows.count == 1")
    }

    private static func orientation(_ text: String) -> Bool {
        text.contains("supportedInterfaceOrientations")
            || text.contains("UISupportedInterfaceOrientations")
            || text.contains("UIDevice.current.orientation")
    }

    private static func scanPlist(_ url: URL, file: String, isInfo: Bool) -> [Finding] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let object = try? PropertyListSerialization.propertyList(from: data, options: [], format: &format),
              let dict = object as? [String: Any] else {
            return []
        }
        var findings: [Finding] = []
        if isInfo, dict["UIApplicationSceneManifest"] == nil {
            findings.append(sceneManifest(file: file, message: "Info.plist has no UIApplicationSceneManifest."))
        }
        if (dict["UIRequiresFullScreen"] as? Bool) == true {
            findings.append(fullScreen(file: file))
        }
        if hasOrientation(dict) {
            findings.append(orientationFinding(file: file))
        }
        return findings
    }

    private static func hasOrientation(_ value: Any) -> Bool {
        switch value {
        case let dict as [String: Any]:
            for (key, nested) in dict {
                if orientation(key) || hasOrientation(nested) { return true }
            }
        case let array as [Any]:
            return array.contains(where: hasOrientation)
        case let string as String:
            return orientation(string)
        default:
            break
        }
        return false
    }

    private static func scanPbxproj(_ url: URL, file: String) -> [Finding] {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        for (offset, line) in text.components(separatedBy: "\n").enumerated() where line.contains("UIRequiresFullScreen") && line.contains("YES") {
            return [fullScreen(file: file, line: offset + 1)]
        }
        return []
    }

    private static func scanInterface(_ url: URL, file: String) -> [Finding] {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        if text.contains("widthClass") || text.contains("heightClass") { return [] }
        return [make(
            "R1.StoryboardSizeClass", .likelyBug, file, 1,
            "Storyboard has no size-class variation.",
            "Add widthClass / heightClass variations."
        )]
    }

    private static func sceneManifest(file: String, message: String) -> Finding {
        make("R2.MissingSceneManifest", .blocker, file, 1, message, "Add UIApplicationSceneManifest.")
    }

    private static func fullScreen(file: String, line: Int = 1) -> Finding {
        make(
            "R2.UIRequiresFullScreen", .blocker, file, line,
            "UIRequiresFullScreen is set.",
            "Remove it so Split View can run."
        )
    }

    private static func orientationFinding(file: String) -> Finding {
        make(
            "R3.OrientationLock", .likelyBug, file, 1,
            "Orientation is locked or read from the device.",
            "Lay out for the current size; the inner display can ignore orientation locks."
        )
    }

    private static func make(
        _ id: String,
        _ severity: Severity,
        _ file: String,
        _ line: Int,
        _ message: String,
        _ suggestion: String
    ) -> Finding {
        Finding(id: id, severity: severity, file: file, line: line, message: message, suggestion: suggestion)
    }

    private static func relative(_ file: URL, to root: URL) -> String {
        let rootPath = root.standardizedFileURL.path
        let filePath = file.standardizedFileURL.path
        let prefix = rootPath.hasSuffix("/") ? rootPath : rootPath + "/"
        guard filePath.hasPrefix(prefix) else { return file.lastPathComponent }
        return String(filePath.dropFirst(prefix.count))
    }

    private static func sorted(_ findings: [Finding]) -> [Finding] {
        let rank = Dictionary(uniqueKeysWithValues: Severity.allCases.enumerated().map { ($1, $0) })
        return findings.sorted { lhs, rhs in
            let left = rank[lhs.severity, default: 0]
            let right = rank[rhs.severity, default: 0]
            if left != right { return left < right }
            if lhs.file != rhs.file { return lhs.file < rhs.file }
            if lhs.line != rhs.line { return lhs.line < rhs.line }
            return lhs.id < rhs.id
        }
    }
}
