// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FishHook",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "FishHook",
            targets: ["FishHook"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/p-x9/MachOKit.git", from: "0.16.0")
    ],
    targets: [
        .target(
            name: "FishHook",
            dependencies: [
                .product(name: "MachOKit", package: "MachOKit")
            ]
        ),
        .testTarget(
            name: "FishHookTests",
            dependencies: [
                "FishHook"
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker",
                    "-interposable"
                ])
            ]
        )
    ]
)
