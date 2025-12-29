// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TodoApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "TodoApp",
            targets: ["TodoApp"]
        )
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "TodoApp",
            dependencies: [
                .product(name: "MegaNetworkKit", package: "ms-networkkit-ios")
            ],
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "TodoAppTests",
            dependencies: ["TodoApp"],
            path: "Tests",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)

