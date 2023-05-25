// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BSGImageLoader",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BSGImageLoader",
            targets: ["BSGImageLoader"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BSGImageLoader",
            dependencies: [],
            path: "Sources",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "BSGImageLoaderTests",
            dependencies: ["BSGImageLoader"],
            path: "Tests",
            exclude: ["Info.plist"]
        ),
    ]
)
