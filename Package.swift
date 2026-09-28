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
    traits: [
        .trait(name: "Empty", description: "Empty iterator conformance"),
        .trait(name: "Single", description: "Borrowed iteration of single values"),
        .trait(name: "Search", description: "Pattern search integration"),
        .trait(name: "Repetition", description: "Bounded execution integration"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-empty.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-single.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-repetition.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-predicate.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-search.git", branch: "main"),
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
        .testTarget(name: "Iterator Selection Tests", dependencies: [
            .product(name: "Repetition", package: "swift-repetition", condition: .when(traits: ["Repetition"])),
            .target(name: "Iterator"),
            .product(name: "Search", package: "swift-search", condition: .when(traits: ["Search"])),
                .product(name: "Predicate", package: "swift-predicate", condition: .when(traits: ["Repetition"])),
            .product(name: "Either", package: "swift-either"),
            .product(name: "Cardinal", package: "swift-cardinal"),
        ]),
        .target(
            name: "Iterator",
            dependencies: [
                .product(name: "Empty", package: "swift-empty", condition: .when(traits: ["Empty"])),
                .product(name: "Single", package: "swift-single", condition: .when(traits: ["Single"])),
                .product(name: "Repetition", package: "swift-repetition", condition: .when(traits: ["Repetition"])),
                .product(name: "Search", package: "swift-search", condition: .when(traits: ["Search"])),
                .product(name: "Predicate", package: "swift-predicate", condition: .when(traits: ["Repetition"])),
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
