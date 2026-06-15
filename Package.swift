// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Wane",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Wane", targets: ["Wane"])
    ],
    targets: [
        .executableTarget(
            name: "Wane",
            dependencies: ["WaneCore"],
            path: "Sources/WaneApp"
        ),
        .target(
            name: "WaneCore",
            path: "Sources/WaneCore"
        ),
        .testTarget(
            name: "WaneTests",
            dependencies: ["WaneCore"],
            path: "Tests/WaneTests"
        )
    ]
)
