// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "BSGAsyncImage",
    platforms: [ .iOS(.v15) ],
    products: [
        .library(
            name: "BSGAsyncImage",
            targets: ["BSGAsyncImage"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BSGAsyncImage",
            dependencies: [],
            path: "BSGAsyncImage/BSGAsyncImage/Sources"
        ),
        .testTarget(
            name: "BSGAsyncImageTests",
            dependencies: ["BSGAsyncImage"],
            path: "BSGAsyncImage/BSGAsyncImageTests/Sources"
        )
    ]
)
