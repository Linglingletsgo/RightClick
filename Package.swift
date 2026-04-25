// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RightClickCore",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "RightClickCore", targets: ["RightClickCore"])
    ],
    targets: [
        .target(name: "RightClickCore"),
        .testTarget(
            name: "RightClickCoreTests",
            dependencies: ["RightClickCore"],
            path: "RightClickTests"
        )
    ]
)
