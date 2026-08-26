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
            name: "Iterator Primitive",
            targets: ["Iterator Primitive"]
        ),

        .library(
            name: "Iterator Protocol",
            targets: ["Iterator Protocol"]
        ),

        .library(
            name: "Iterator Witness",
            targets: ["Iterator Witness"]
        ),

        .library(
            name: "Iterable",
            targets: ["Iterable"]
        ),

        .library(
            name: "Iterator Once",
            targets: ["Iterator Once"]
        ),

        .library(
            name: "Iterator Chunk",
            targets: ["Iterator Chunk"]
        ),

        .library(
            name: "Iterator",
            targets: ["Iterator"]
        ),

        .library(
            name: "Iterator Test Support",
            targets: ["Iterator Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-carrier.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-either.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Iterator Primitive",
            dependencies: []
        ),

        .target(
            name: "Iterator Protocol",
            dependencies: [
                "Iterator Primitive"
            ]
        ),

        .target(
            name: "Iterator Witness",
            dependencies: [
                "Iterator Protocol"
            ]
        ),

        .target(
            name: "Iterable",
            dependencies: [
                "Iterator Protocol",
                "Iterator Chunk",
                .product(name: "Either", package: "swift-either"),
                .product(name: "Cardinal", package: "swift-cardinal"),
            ]
        ),

        .target(
            name: "Iterator Once",
            dependencies: [
                "Iterator Protocol"
            ]
        ),

        .target(
            name: "Iterator Chunk",
            dependencies: [
                "Iterator Primitive",
                "Iterator Protocol",
                .product(name: "Carrier", package: "swift-carrier"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
            ]
        ),

        .target(
            name: "Iterator",
            dependencies: [
                "Iterator Primitive",
                "Iterator Protocol",
                "Iterator Witness",
                "Iterable",
                "Iterator Once",
                "Iterator Chunk",
            ]
        ),

        .target(
            name: "Iterator Test Support",
            dependencies: [
                "Iterator"
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Iteration Tests",
            dependencies: ["Iterator Test Support"]
        ),
        .testTarget(
            name: "Iterator Once Tests",
            dependencies: ["Iterator Test Support"]
        ),
        .testTarget(
            name: "Iterator Chunk Tests",
            dependencies: ["Iterator Test Support"]
        ),
        .testTarget(
            name: "Iterable Tests",
            dependencies: ["Iterator Test Support"]
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
