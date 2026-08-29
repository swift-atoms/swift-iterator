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
            url: "https://github.com/swift-atoms/swift-carrier.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Iterator",
            dependencies: []
        ),

        .target(
            name: "Iterator Protocol",
            dependencies: [
                .target(name: "Iterator")
            ]
        ),

        .target(
            name: "Iterator Witness",
            dependencies: [
                .target(name: "Iterator Protocol")
            ]
        ),

        .target(
            name: "Iterable",
            dependencies: [
                .target(name: "Iterator Protocol"),
                .target(name: "Iterator Chunk"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
            ]
        ),

        .target(
            name: "Iterator Once",
            dependencies: [
                .target(name: "Iterator Protocol")
            ]
        ),

        .target(
            name: "Iterator Chunk",
            dependencies: [
                .target(name: "Iterator"),
                .target(name: "Iterator Protocol"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Add", package: "swift-cardinal"),
                .product(name: "Cardinal Subtract", package: "swift-cardinal"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
            ]
        ),

        .target(
            name: "Iterator Test Support",
            dependencies: [
                .target(name: "Iterator")
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Iteration Tests",
            dependencies: [
                .target(name: "Iterator"),
                .target(name: "Iterator Protocol"),
                .target(name: "Iterator Test Support"),
                .target(name: "Iterator Witness"),
            ]
        ),
        .testTarget(
            name: "Iterator Once Tests",
            dependencies: [
                .target(name: "Iterator"),
                .target(name: "Iterator Once"),
                .target(name: "Iterator Test Support"),
            ]
        ),
        .testTarget(
            name: "Iterator Chunk Tests",
            dependencies: [
                .target(name: "Iterator"),
                .target(name: "Iterator Chunk"),
                .target(name: "Iterator Protocol"),
                .target(name: "Iterator Test Support"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
            ]
        ),
        .testTarget(
            name: "Iterable Tests",
            dependencies: [
                .target(name: "Iterable"),
                .target(name: "Iterator"),
                .target(name: "Iterator Chunk"),
                .target(name: "Iterator Protocol"),
                .target(name: "Iterator Test Support"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Add", package: "swift-cardinal"),
                .product(name: "Cardinal Subtract", package: "swift-cardinal"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
                .product(name: "Either", package: "swift-either"),
            ]
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
