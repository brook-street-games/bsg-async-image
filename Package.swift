// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "BSGImageLoader",
    platforms: [ .iOS(.v15) ],
    products: [
        .library(
            name: "BSGImageLoader",
            targets: ["BSGImageLoader"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BSGImageLoader",
            dependencies: [],
            path: "BSGImageLoader/BSGImageLoader/Sources"
        ),
        .testTarget(
            name: "BSGImageLoaderTests",
            dependencies: ["BSGImageLoader"],
            path: "BSGImageLoader/BSGImageLoaderTests/Sources"
        )
    ]
)
