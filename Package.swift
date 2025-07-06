// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HotReloading",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "HotReloading",
            targets: ["HotReloading"]
        ),
    ],
    targets: [
        .target(
            name: "HotReloading",
            dependencies: []
        ),
        .testTarget(
            name: "HotReloadingTests",
            dependencies: ["HotReloading"]
        ),
    ]
)
