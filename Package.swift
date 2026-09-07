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
        .library(name: "Iterator", targets: ["Iterator"]),

        .library(name: "Iterator Foundation Integration", targets: ["Iterator Foundation Integration"]),
        .library(name: "Iterator Test Support", targets: ["Iterator Test Support"]),
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
            dependencies: [
                .product(name: "Either", package: "swift-either"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Carrier", package: "swift-carrier"),
            ],
            path: "Sources/Iterator"
        ),
        
        .target(
            name: "Iterator Foundation Integration",
            dependencies: [
                .target(name: "Iterator"),
            ],
            path: "Sources/Iterator Foundation Integration"
        ),
        .target(
            name: "Iterator Test Support",
            dependencies: [
                .target(name: "Iterator"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Iterator Tests",
            dependencies: [
                .target(name: "Iterator"),
                .target(name: "Iterator Test Support"),
                .product(name: "Carrier", package: "swift-carrier"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "Iterator Foundation Integration"),
            ],
            path: "Tests/Iterator Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
