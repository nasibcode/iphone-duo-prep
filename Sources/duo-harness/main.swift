import DuoHarness
import DuoHarnessCLI
import Foundation

@main
enum DuoHarnessMain {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        switch args.first {
        case "version":
            print("duo-harness \(DuoHarness.version)")
        case "sdk-check":
            let warnOnly = args.dropFirst().contains("--warn")
            switch SDKCheck.evaluate(XcodeBuild.versionOutput()) {
            case .match(let version):
                print("sdk-check: Xcode \(version.marketing) (\(version.build)) matches the pin.")
            case .mismatch(let message), .unreadable(let message):
                let handle = warnOnly ? FileHandle.standardOutput : FileHandle.standardError
                handle.write(Data((message + "\n").utf8))
                if !warnOnly { exit(1) }
            }
        case "audit":
            runAudit(Array(args.dropFirst()))
        case "help", "--help", "-h", nil:
            print(usage)
        default:
            FileHandle.standardError.write(Data((usage + "\n").utf8))
            exit(64)
        }
    }

    private static let usage = """
    duo-harness \(DuoHarness.version)

    Usage:
      duo-harness version
      duo-harness sdk-check [--warn]
      duo-harness audit <path> [--format json|markdown]
    """

    private static func runAudit(_ args: [String]) {
        var format = "markdown"
        var path: String?
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg == "--format" {
                guard index + 1 < args.count else { failUsage() }
                format = args[index + 1]
                index += 2
                continue
            }
            if arg.hasPrefix("-") { failUsage() }
            guard path == nil else { failUsage() }
            path = arg
            index += 1
        }
        guard let path, format == "json" || format == "markdown" else { failUsage() }

        let report: AuditReport
        do {
            report = try Audit.scan(root: URL(fileURLWithPath: path))
        } catch {
            FileHandle.standardError.write(Data("audit: cannot read \(path)\n".utf8))
            exit(1)
        }
        if format == "json" {
            print(Audit.jsonString(report), terminator: "")
        } else {
            print(Audit.markdown(report))
        }
    }

    private static func failUsage() -> Never {
        FileHandle.standardError.write(Data((usage + "\n").utf8))
        exit(64)
    }
}
