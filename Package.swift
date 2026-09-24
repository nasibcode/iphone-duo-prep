// swift-tools-version: 6.2
// Phase A0 — SPM multi-target spine (iPhoneDuoPrep / Testing / CLI / NativeHost).

import PackageDescription

let package = Package(
    name: "iphone-duo-prep",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "iPhoneDuoPrep", targets: ["iPhoneDuoPrep"]),
        .library(name: "iPhoneDuoPrepTesting", targets: ["iPhoneDuoPrepTesting"]),
        .library(name: "NativeHost", targets: ["NativeHost"]),
        .executable(name: "iphone-duo-prep", targets: ["iphone-duo-prep"]),
    ],
    targets: [
        .target(name: "iPhoneDuoPrep"), // Phase A2 + A3
        .target(name: "iPhoneDuoPrepTesting"), // Phase A2 + A6 matrix
        .target(
            name: "NativeHost", // Phase A2/A3/A4 demos
            dependencies: ["iPhoneDuoPrep", "iPhoneDuoPrepTesting"],
            path: "SampleApps/NativeHost"
        ),
        .target(name: "iPhoneDuoPrepCLI", dependencies: ["iPhoneDuoPrep"]), // Phase A1–A7 CLI
        .executableTarget(
            name: "iphone-duo-prep",
            dependencies: ["iPhoneDuoPrepCLI", "iPhoneDuoPrepTesting"] // A6 matrix subcommand
        ),
        .testTarget(name: "iPhoneDuoPrepTests", dependencies: ["iPhoneDuoPrep"]),
        .testTarget(name: "iPhoneDuoPrepTestingTests", dependencies: ["iPhoneDuoPrepTesting"]),
        .testTarget(name: "iPhoneDuoPrepCLITests", dependencies: ["iPhoneDuoPrepCLI"]),
        .testTarget(name: "NativeHostTests", dependencies: ["NativeHost"]),
    ]
)
