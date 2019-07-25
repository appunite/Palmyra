// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocalizableValidator",
    platforms: [.macOS(.v10_14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LocalizableValidator",
            dependencies: ["SPMUtility"]),
        .testTarget(
            name: "LocalizableValidatorTests",
            dependencies: ["LocalizableValidator"]),
    ]
)
