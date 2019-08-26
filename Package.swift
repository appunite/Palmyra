// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "LocalizableValidator",
    platforms: [.macOS(.v10_14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "LocalizableValidator",
            dependencies: ["LocalizableValidatorCore"]
        ),
        .target(
            name: "LocalizableValidatorCore",
            dependencies: ["SPMUtility"]
        ),
        .testTarget(
            name: "LocalizableValidatorTests",
            dependencies: ["LocalizableValidatorCore", "SPMUtility"])
    ]
)
