// Phase A2 — mechanical autofix (UIScreen.main.scale → traitCollection.displayScale).
import Foundation

public enum Autofix {
    public struct Result: Sendable, Equatable {
        public var filesChanged: Int
        public var replacements: Int

        public init(filesChanged: Int, replacements: Int) {
            self.filesChanged = filesChanged
            self.replacements = replacements
        }
    }

    private static let needle = "UIScreen.main.scale"
    private static let replacement = "traitCollection.displayScale"
    private static let textExtensions: Set<String> = ["swift", "m", "mm", "h"]
    private static let skipDirectories: Set<String> = [
        ".git", ".build", "DerivedData", "Pods", "node_modules", "checkouts",
    ]

    public static func run(root: URL) throws -> Result {
        let root = root.standardizedFileURL
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: root.path, isDirectory: &isDirectory),
              FileManager.default.isReadableFile(atPath: root.path) else {
            throw AuditScanError.unreadableRoot(root.path)
        }
        var filesChanged = 0
        var replacements = 0
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
                let (changed, count) = fixFile(item)
                if changed {
                    filesChanged += 1
                    replacements += count
                }
            }
        } else {
            let (changed, count) = fixFile(root)
            if changed {
                filesChanged = 1
                replacements = count
            }
        }
        return Result(filesChanged: filesChanged, replacements: replacements)
    }

    private static func fixFile(_ url: URL) -> (Bool, Int) {
        guard textExtensions.contains(url.pathExtension.lowercased()) else { return (false, 0) }
        guard var text = try? String(contentsOf: url, encoding: .utf8) else { return (false, 0) }
        let parts = text.components(separatedBy: needle)
        let count = parts.count - 1
        guard count > 0 else { return (false, 0) }
        text = parts.joined(separator: replacement)
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return (true, count)
        } catch {
            return (false, 0)
        }
    }
}
