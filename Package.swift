// swift-tools-version: 6.2
// Phase A0 — SPM multi-target spine (DuoHarness / Testing / CLI / NativeHost).

import PackageDescription

let package = Package(
    name: "duo-harness",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "DuoHarness", targets: ["DuoHarness"]),
        .library(name: "DuoHarnessTesting", targets: ["DuoHarnessTesting"]),
        .library(name: "NativeHost", targets: ["NativeHost"]),
        .executable(name: "duo-harness", targets: ["duo-harness"]),
    ],
    targets: [
        .target(name: "DuoHarness"), // Phase A2 + A3
        .target(name: "DuoHarnessTesting"), // Phase A2 + A6 matrix
        .target(
            name: "NativeHost", // Phase A2/A3/A4 demos
            dependencies: ["DuoHarness", "DuoHarnessTesting"],
            path: "SampleApps/NativeHost"
        ),
        .target(name: "DuoHarnessCLI", dependencies: ["DuoHarness"]), // Phase A1–A7 CLI
        .executableTarget(
            name: "duo-harness",
            dependencies: ["DuoHarnessCLI", "DuoHarnessTesting"] // A6 matrix subcommand
        ),
        .testTarget(name: "DuoHarnessTests", dependencies: ["DuoHarness"]),
        .testTarget(name: "DuoHarnessTestingTests", dependencies: ["DuoHarnessTesting"]),
        .testTarget(name: "DuoHarnessCLITests", dependencies: ["DuoHarnessCLI"]),
        .testTarget(name: "NativeHostTests", dependencies: ["NativeHost"]),
    ]
)
