// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FishHook",
    products: [
        .library(
            name: "FishHook",
            targets: ["FishHook"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/p-x9/MachOKit-SPM.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "FishHook",
            dependencies: [
                .product(name: "MachOKit", package: "MachOKit-SPM")
            ]
        ),
        .testTarget(
            name: "FishHookTests",
            dependencies: [
                "FishHook"
            ]
        )
    ]
)
