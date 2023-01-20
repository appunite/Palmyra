// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Palmyra",
    platforms: [.macOS(.v10_14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMajor(from: "0.4.0")),
    ],
    targets: [
        .target(
            name: "Palmyra",
            dependencies: ["PalmyraCore"]
        ),
        .target(
            name: "PalmyraCore",
            dependencies: ["SwiftToolsSupport-auto"]
        ),
        .testTarget(
            name: "PalmyraTests",
            dependencies: ["PalmyraCore", "SwiftToolsSupport-auto"])
    ]
)
