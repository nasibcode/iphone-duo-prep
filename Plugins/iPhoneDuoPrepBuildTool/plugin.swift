import Foundation
import PackagePlugin

// SwiftLint-shaped build tool: Xcode runs this on the app target. Nothing is linked into the app.
// https://docs.swift.org/latest/documentation/packagemanagerdocs/writingbuildtoolplugin/
@main
struct iPhoneDuoPrepBuildTool: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceFiles = target.sourceModule?.sourceFiles else { return [] }
        return Self.commands(
            tool: try context.tool(named: "iphone-duo-prep").url,
            files: sourceFiles.map(\.url),
            stamp: context.pluginWorkDirectoryURL.appending(path: "iPhoneDuoPrep.lint.swift")
        )
    }

    fileprivate static let scannedExtensions: Set<String> = [
        "swift", "m", "mm", "h", "plist", "storyboard", "xib", "pbxproj",
        "dart", "ts", "tsx", "js", "jsx",
    ]

    fileprivate static func commands(tool: URL, files: [URL], stamp: URL) -> [Command] {
        let inputs = files.filter { scannedExtensions.contains($0.pathExtension.lowercased()) }
        guard !inputs.isEmpty else { return [] }
        // ponytail: argv file list; switch to a response file if a target exceeds ARG_MAX
        // buildCommand, not prebuild: SPM rejects source-built tools in prebuild commands.
        // .swift output is scheduled and compiled. A non-source stamp is copied into the app bundle.
        return [
            .buildCommand(
                displayName: "iPhone Duo Prep",
                executable: tool,
                arguments: [
                    "audit", "--files", "--format", "xcode", "--semantic", "--fail-on", "blocker",
                    "--stamp", stamp.path,
                ] + inputs.map(\.path),
                inputFiles: inputs,
                outputFiles: [stamp]
            ),
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension iPhoneDuoPrepBuildTool: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        Self.commands(
            tool: try context.tool(named: "iphone-duo-prep").url,
            files: target.inputFiles.map(\.url),
            stamp: context.pluginWorkDirectoryURL.appending(path: "iPhoneDuoPrep.lint.swift")
        )
    }
}
#endif
