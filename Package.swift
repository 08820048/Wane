// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Wane",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Wane", targets: ["Wane"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.3")
    ],
    targets: [
        .executableTarget(
            name: "Wane",
            dependencies: ["WaneCore"],
            path: "Sources/WaneApp"
        ),
        .target(
            name: "WaneCore",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/WaneCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "WaneTests",
            dependencies: ["WaneCore"],
            path: "Tests/WaneTests"
        )
    ]
)
