// swift-tools-version: 6.2

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
        .executable(name: "duo-harness", targets: ["duo-harness"]),
    ],
    targets: [
        .target(name: "DuoHarness"),
        .target(name: "DuoHarnessTesting"),
        .target(name: "DuoHarnessCLI", dependencies: ["DuoHarness"]),
        .executableTarget(name: "duo-harness", dependencies: ["DuoHarnessCLI"]),
        .testTarget(name: "DuoHarnessCLITests", dependencies: ["DuoHarnessCLI"]),
    ]
)
