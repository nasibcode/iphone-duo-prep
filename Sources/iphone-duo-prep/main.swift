import iPhoneDuoPrep
import iPhoneDuoPrepCLI
import iPhoneDuoPrepTesting
import Foundation

// Phase A0 — CLI entry; subcommands grow per phase (A1 audit, A2 autofix, A6 gate/checklist, A7 golden-diff).
@main
enum iPhoneDuoPrepMain {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        switch args.first {
        case "version":
            print("iphone-duo-prep \(iPhoneDuoPrep.version)")
        case "sdk-check":
            // Phase A0
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
            // Phase A1 (+ A6 --semantic / --fail-on)
            runAudit(Array(args.dropFirst()))
        case "suggest":
            // Phase A6 — human-oriented audit (markdown suggestions)
            runAudit(Array(args.dropFirst()) + ["--format", "markdown"])
        case "report":
            // Phase A6 — write audit artifact
            runReport(Array(args.dropFirst()))
        case "autofix":
            // Phase A2 mechanical; Phase A6 --checklist
            runAutofix(Array(args.dropFirst()))
        case "matrix":
            // Phase A6 — dump UI test matrix
            runMatrix(Array(args.dropFirst()))
        case "golden-diff":
            // Phase A7
            runGoldenDiff(Array(args.dropFirst()))
        case "help", "--help", "-h", nil:
            print(usage)
        default:
            FileHandle.standardError.write(Data((usage + "\n").utf8))
            exit(64)
        }
    }

    private static let usage = """
    iphone-duo-prep \(iPhoneDuoPrep.version)

    Usage:
      iphone-duo-prep version
      iphone-duo-prep sdk-check [--warn]
      iphone-duo-prep audit <path> [--format json|markdown] [--semantic] [--fail-on <severity>]
      iphone-duo-prep suggest <path>
      iphone-duo-prep report <path> --output <file> [--format json|markdown] [--semantic]
      iphone-duo-prep autofix <path> [--checklist]
      iphone-duo-prep matrix [--format markdown|args]
      iphone-duo-prep golden-diff <left.json> <right.json> [--left-label beta] [--right-label gm]
    """

    private static func runAudit(_ args: [String]) {
        let opts = parseAuditOptions(args)
        guard let path = opts.path, opts.format == "json" || opts.format == "markdown" else { failUsage() }

        var report: AuditReport
        do {
            report = try Audit.scan(root: URL(fileURLWithPath: path))
        } catch {
            FileHandle.standardError.write(Data("audit: cannot read \(path)\n".utf8))
            exit(1)
        }
        if opts.semantic {
            report = Semantic.refine(report, root: URL(fileURLWithPath: path))
        }
        if opts.format == "json" {
            print(Audit.jsonString(report), terminator: "")
        } else {
            print(Audit.markdown(report))
        }
        if let threshold = opts.failOn, SeverityGate.shouldFail(report, threshold: threshold) {
            exit(2)
        }
    }

    private static func runReport(_ args: [String]) {
        var format = "markdown"
        var path: String?
        var output: String?
        var semantic = false
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg == "--format" {
                guard index + 1 < args.count else { failUsage() }
                format = args[index + 1]
                index += 2
                continue
            }
            if arg == "--output" {
                guard index + 1 < args.count else { failUsage() }
                output = args[index + 1]
                index += 2
                continue
            }
            if arg == "--semantic" {
                semantic = true
                index += 1
                continue
            }
            if arg.hasPrefix("-") { failUsage() }
            guard path == nil else { failUsage() }
            path = arg
            index += 1
        }
        guard let path, let output, format == "json" || format == "markdown" else { failUsage() }
        var report: AuditReport
        do {
            report = try Audit.scan(root: URL(fileURLWithPath: path))
        } catch {
            FileHandle.standardError.write(Data("report: cannot read \(path)\n".utf8))
            exit(1)
        }
        if semantic {
            report = Semantic.refine(report, root: URL(fileURLWithPath: path))
        }
        let body = format == "json" ? Audit.jsonString(report) : Audit.markdown(report) + "\n"
        do {
            try body.write(to: URL(fileURLWithPath: output), atomically: true, encoding: .utf8)
            print("report: wrote \(output)")
        } catch {
            FileHandle.standardError.write(Data("report: cannot write \(output)\n".utf8))
            exit(1)
        }
    }

    private static func runAutofix(_ args: [String]) {
        let checklist = args.contains("--checklist")
        let pathArgs = args.filter { $0 != "--checklist" }
        guard pathArgs.count == 1, let path = pathArgs.first, !path.hasPrefix("-") else { failUsage() }
        if checklist {
            let report: AuditReport
            do {
                report = try Audit.scan(root: URL(fileURLWithPath: path))
            } catch {
                FileHandle.standardError.write(Data("autofix: cannot read \(path)\n".utf8))
                exit(1)
            }
            print(ChecklistPR.markdown(from: report), terminator: "")
            return
        }
        let result: Autofix.Result
        do {
            result = try Autofix.run(root: URL(fileURLWithPath: path))
        } catch {
            FileHandle.standardError.write(Data("autofix: cannot read \(path)\n".utf8))
            exit(1)
        }
        print("autofix: \(result.filesChanged) file(s), \(result.replacements) replacement(s)")
    }

    private static func runMatrix(_ args: [String]) {
        var format = "markdown"
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg == "--format" {
                guard index + 1 < args.count else { failUsage() }
                format = args[index + 1]
                index += 2
                continue
            }
            failUsage()
        }
        switch format {
        case "markdown":
            print(DuoUITestMatrix.markdownTable(), terminator: "")
        case "args":
            print(DuoUITestMatrix.argumentLines().joined(separator: "\n"))
        default:
            failUsage()
        }
    }

    private static func runGoldenDiff(_ args: [String]) {
        var leftLabel = "beta"
        var rightLabel = "gm"
        var paths: [String] = []
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg == "--left-label" {
                guard index + 1 < args.count else { failUsage() }
                leftLabel = args[index + 1]
                index += 2
                continue
            }
            if arg == "--right-label" {
                guard index + 1 < args.count else { failUsage() }
                rightLabel = args[index + 1]
                index += 2
                continue
            }
            if arg.hasPrefix("-") { failUsage() }
            paths.append(arg)
            index += 1
        }
        guard paths.count == 2 else { failUsage() }
        guard
            let left = try? String(contentsOf: URL(fileURLWithPath: paths[0]), encoding: .utf8),
            let right = try? String(contentsOf: URL(fileURLWithPath: paths[1]), encoding: .utf8)
        else {
            FileHandle.standardError.write(Data("golden-diff: cannot read JSON inputs\n".utf8))
            exit(1)
        }
        do {
            let result = try GoldenDiff.compare(leftJSON: left, rightJSON: right)
            print(GoldenDiff.markdown(result, leftLabel: leftLabel, rightLabel: rightLabel), terminator: "")
            if !result.identical { exit(3) }
        } catch {
            FileHandle.standardError.write(Data("golden-diff: invalid JSON\n".utf8))
            exit(1)
        }
    }

    private struct AuditOptions {
        var path: String?
        var format = "markdown"
        var semantic = false
        var failOn: Severity?
    }

    private static func parseAuditOptions(_ args: [String]) -> AuditOptions {
        var opts = AuditOptions()
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg == "--format" {
                guard index + 1 < args.count else { failUsage() }
                opts.format = args[index + 1]
                index += 2
                continue
            }
            if arg == "--fail-on" {
                guard index + 1 < args.count, let severity = SeverityGate.parseThreshold(args[index + 1])
                else { failUsage() }
                opts.failOn = severity
                index += 2
                continue
            }
            if arg == "--semantic" {
                opts.semantic = true
                index += 1
                continue
            }
            if arg.hasPrefix("-") { failUsage() }
            guard opts.path == nil else { failUsage() }
            opts.path = arg
            index += 1
        }
        return opts
    }

    private static func failUsage() -> Never {
        FileHandle.standardError.write(Data((usage + "\n").utf8))
        exit(64)
    }
}
