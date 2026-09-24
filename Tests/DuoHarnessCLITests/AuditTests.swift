import Foundation
import Testing
@testable import DuoHarnessCLI

struct AuditTests {
    @Test(arguments: [
        ("R1.UIScreenMain", "let screen = UIScreen.main.bounds\n"),
        ("R1.SafeAreaTimesTwo", "let pad = view.safeAreaInsets.top * 2\n"),
        ("R1.SafeAreaTimesTwo", "let pad = view.safeAreaInsets.top + view.safeAreaInsets.bottom\n"),
        ("R1.FixedCGRect", "view.frame = CGRect(x: 0, y: 0, width: 200, height: 400)\n"),
        ("R1.HardcodedPhoneWidth", "view.bounds.size.width = 390\n"),
        ("R2.SingleWindow", "_ = UIApplication.shared.windows\n"),
        ("R3.UserInterfaceIdiom", "if traitCollection.userInterfaceIdiom == .phone {}\n"),
        ("R3.OrientationLock", "if UIDevice.current.orientation == .portrait {}\n"),
        ("R4.CustomChromeNoReserved", "UIToolbar().frame = view.bounds\n"),
        ("R4.MissingHingeHook", "let a = hingeAngle\n"),
        ("R5.FrontCameraAsUser", "let p = AVCaptureDevice.Position.front\n"),
        ("R5.CaptureWithoutOuterAccessory", "AVCaptureSession().startRunning() // outer\n"),
    ])
    func lineRule(id: String, source: String) throws {
        let findings = try scan(name: "Fixture.swift", source)
        let severity: Severity = (id.hasPrefix("R4.") || id.hasPrefix("R5.")) ? .productDecision : .likelyBug
        #expect(findings.contains { $0.id == id && $0.severity == severity })
    }

    @Test(arguments: [
        ("R6.FixedMediaQuery", "main.dart", "final w = MediaQuery.of(context).size.width;\n"),
        ("R6.OrientationLock", "main.dart", "SystemChrome.setPreferredOrientations([Orientation.portrait]);\n"),
        ("R6.FixedDimensions", "App.tsx", "const { width } = Dimensions.get('window');\n"),
        ("R6.RNOrientationLock", "App.tsx", "ScreenOrientation.lock();\n"),
        ("R6.MissingAdapter", "main.dart", "final w = MediaQuery.of(context).size.width;\n"),
    ])
    func r6LineRule(id: String, name: String, source: String) throws {
        let findings = try scan(name: name, source)
        let severity: Severity = id == "R6.MissingAdapter" ? .enhancement : .likelyBug
        #expect(findings.contains { $0.id == id && $0.severity == severity })
    }

    @Test func r6MissingAdapterSkippedWhenAdapterCited() throws {
        let findings = try scan(
            name: "ok.dart",
            "final w = MediaQuery.of(context).size.width; // duo_harness\n"
        )
        #expect(findings.contains { $0.id == "R6.FixedMediaQuery" })
        #expect(!findings.contains { $0.id == "R6.MissingAdapter" })
    }

    @Test func lineNegatives() throws {
        let source = """
        let screen = UIScreen()
        let top = view.safeAreaInsets.top
        let padded = view.safeAreaInsets.top * 20
        let zero = CGRect.zero
        view.bounds.size.width = 200
        """
        let ids = Set(try scan(name: "Clean.swift", source).map(\.id))
        #expect(!ids.contains("R1.UIScreenMain"))
        #expect(!ids.contains("R1.SafeAreaTimesTwo"))
        #expect(!ids.contains("R1.FixedCGRect"))
        #expect(!ids.contains("R1.HardcodedPhoneWidth"))
    }

    @Test func plistWithoutSceneManifestRequiresFullScreen() throws {
        let findings = try scan(name: "Info.plist", infoPlist(fullScreen: true, sceneManifest: false))
        #expect(findings.contains { $0.id == "R2.MissingSceneManifest" && $0.severity == .blocker })
        #expect(findings.contains { $0.id == "R2.UIRequiresFullScreen" && $0.severity == .blocker })
    }

    @Test func plistAllowsSplitViewAndDeclaresScenes() throws {
        let findings = try scan(
            name: "Info.plist",
            infoPlist(fullScreen: false, sceneManifest: true)
        )
        #expect(findings.isEmpty)
    }

    @Test func plistOrientationLock() throws {
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        <key>UIApplicationSceneManifest</key><dict/>
        <key>UISupportedInterfaceOrientations</key>
        <array><string>UIInterfaceOrientationPortrait</string></array>
        </dict></plist>
        """
        let findings = try scan(name: "Info.plist", plist)
        #expect(findings.contains { $0.id == "R3.OrientationLock" && $0.severity == .likelyBug })
    }

    @Test func projectRequiresFullScreen() throws {
        let findings = try scan(name: "App.pbxproj", "INFOPLIST_KEY_UIRequiresFullScreen = YES;\n")
        #expect(findings.contains { $0.id == "R2.UIRequiresFullScreen" && $0.severity == .blocker })
    }

    @Test func storyboardWithoutSizeClass() throws {
        let findings = try scan(name: "Main.storyboard", "<rect key=\"frame\" width=\"390\" height=\"844\"/>\n")
        #expect(findings.contains { $0.id == "R1.StoryboardSizeClass" && $0.severity == .likelyBug })
    }

    @Test func storyboardWithSizeClass() throws {
        let findings = try scan(
            name: "Main.storyboard",
            "<variation key=\"heightClass=regular-widthClass=regular\"/>\n"
        )
        #expect(!findings.contains { $0.id == "R1.StoryboardSizeClass" })
    }

    @Test func directoryWithoutInfoPlist() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let findings = try Audit.scan(root: dir).findings
        #expect(findings.count == 1)
        #expect(findings[0].id == "R2.MissingSceneManifest")
        #expect(findings[0].file == ".")
        #expect(findings[0].line == 1)
        #expect(findings[0].severity == .blocker)
    }

    @Test func severityRawValuesRoundTrip() throws {
        let expected = [
            "blocker",
            "likely-bug",
            "product-decision",
            "enhancement",
        ]
        let encoded = try Severity.allCases.map { severity in
            let data = try JSONEncoder().encode(severity)
            let decoded = try JSONDecoder().decode(Severity.self, from: data)
            #expect(decoded == severity)
            return severity.rawValue
        }
        #expect(encoded == expected)
    }

    @Test func nativeVictimMatchesGolden() throws {
        let report = try Audit.scan(root: packageRoot.appendingPathComponent("SampleApps/NativeVictim"))
        let actual = Set(report.findings.map { "\($0.id)|\($0.file)|\($0.severity.rawValue)" })
        let expected: Set<String> = [
            "R2.MissingSceneManifest|Info.plist|blocker",
            "R2.UIRequiresFullScreen|Info.plist|blocker",
            "R1.UIScreenMain|VictimViewController.swift|likely-bug",
            "R1.SafeAreaTimesTwo|VictimViewController.swift|likely-bug",
            "R1.FixedCGRect|VictimViewController.swift|likely-bug",
            "R1.HardcodedPhoneWidth|VictimViewController.swift|likely-bug",
            "R3.UserInterfaceIdiom|VictimViewController.swift|likely-bug",
            "R3.OrientationLock|VictimViewController.swift|likely-bug",
            "R4.CustomChromeNoReserved|VictimViewController.swift|product-decision",
            "R4.MissingHingeHook|VictimViewController.swift|product-decision",
            "R5.FrontCameraAsUser|VictimViewController.swift|product-decision",
            "R5.CaptureWithoutOuterAccessory|VictimViewController.swift|product-decision",
            "R2.SingleWindow|AppDelegate.swift|likely-bug",
            "R1.StoryboardSizeClass|Base.lproj/Main.storyboard|likely-bug",
        ]
        #expect(report.findings.count == expected.count)
        #expect(actual == expected)

        let golden = packageRoot.appendingPathComponent("Tests/Goldens/beta/NativeVictim.json")
        let expectedJSON = try String(contentsOf: golden, encoding: .utf8)
        #expect(Audit.jsonString(report) == expectedJSON)

        let markdown = Audit.markdown(report)
        let blocker = try #require(markdown.range(of: "## blocker"))
        let likely = try #require(markdown.range(of: "## likely-bug"))
        let product = try #require(markdown.range(of: "## product-decision"))
        #expect(blocker.lowerBound < likely.lowerBound)
        #expect(likely.lowerBound < product.lowerBound)
        for id in ["R2.MissingSceneManifest", "R2.UIRequiresFullScreen"] {
            let hit = try #require(markdown.range(of: id))
            #expect(hit.lowerBound < likely.lowerBound)
        }
        #expect(!markdown.contains("## enhancement"))
        #expect(report.findings.contains { $0.id == "R1.UIScreenMain" && $0.suggestion.contains("DuoScreen") })
        #expect(report.findings.contains { $0.id == "R1.SafeAreaTimesTwo" && $0.suggestion.contains("DuoSafeArea") })
        #expect(report.findings.contains { $0.id == "R3.UserInterfaceIdiom" && $0.suggestion.contains("DuoSizeGate") })
        #expect(report.findings.contains {
            $0.id == "R4.CustomChromeNoReserved" && $0.suggestion.contains("DuoReservedRegion")
        })
        #expect(report.findings.contains { $0.id == "R4.MissingHingeHook" && $0.suggestion.contains("DuoHinge") })
        #expect(report.findings.contains {
            $0.id == "R5.FrontCameraAsUser" && $0.suggestion.contains("DuoCameraDirection")
        })
        #expect(report.findings.contains {
            $0.id == "R5.CaptureWithoutOuterAccessory" && $0.suggestion.contains("DuoOuterAccessory")
        })
    }

    @Test func autofixReplacesMainScale() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("Scale.swift")
        try "let s = UIScreen.main.scale\n".write(to: file, atomically: true, encoding: .utf8)
        let result = try Autofix.run(root: dir)
        #expect(result.filesChanged == 1)
        #expect(result.replacements == 1)
        let text = try String(contentsOf: file, encoding: .utf8)
        #expect(text.contains("traitCollection.displayScale"))
        #expect(!text.contains("UIScreen.main.scale"))
    }

    private func scan(name: String, _ source: String) throws -> [Finding] {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try source.write(to: dir.appendingPathComponent(name), atomically: true, encoding: .utf8)
        return try Audit.scan(root: dir).findings
    }

    private func infoPlist(fullScreen: Bool, sceneManifest: Bool) -> String {
        let full = fullScreen ? "<true/>" : "<false/>"
        let scene = sceneManifest
            ? "<key>UIApplicationSceneManifest</key><dict/>"
            : ""
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        \(scene)
        <key>UIRequiresFullScreen</key>
        \(full)
        </dict></plist>
        """
    }

    private var packageRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
