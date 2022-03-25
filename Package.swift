// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftLint",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "xcissues", targets: ["xcissues"]),
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.1.1")),
    ],
    targets: [
        .executableTarget(
            name: "xcissues",
            dependencies: [
                "XcodeIssues",
            ]
        ),
        .target(
            name: "XcodeIssues",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
