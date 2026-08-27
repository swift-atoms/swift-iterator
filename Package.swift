// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-iterator",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Iterator",
            targets: ["Iterator"]
        ),
        .library(
            name: "Iterator Standard Library Integration",
            targets: ["Iterator Standard Library Integration"]
        ),
        .library(
            name: "Iterator Apple Foundation Integration",
            targets: ["Iterator Apple Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Iterator",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
            ]
        ),
        .target(
            name: "Iterator Standard Library Integration",
            dependencies: ["Iterator"]
        ),
        .target(
            name: "Iterator Apple Foundation Integration",
            dependencies: [
                "Iterator",
                "Iterator Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Iterator Tests",
            dependencies: [
                "Iterator",
                .product(name: "Cardinal", package: "swift-cardinal"),
            ],
            path: "Tests/Iterator Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
