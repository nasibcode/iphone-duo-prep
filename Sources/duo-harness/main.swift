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
            FileHandle.standardError.write(Data(
                "audit is not implemented yet (Phase A1). It will score SampleApps/NativeVictim once that app lands.\n".utf8
            ))
            exit(1)
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
      duo-harness audit
    """
}
