// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "BSGImageLoader",
    platforms: [ .iOS(.v15) ],
    products: [
        .library(name: "BSGImageLoader", targets: ["BSGImageLoader"])
    ],
    dependencies: [],
    targets: [
        .target(name: "BSGImageLoader", dependencies: [], path: "Sources", exclude: ["Info.plist"]
        ),
        .testTarget(name: "BSGImageLoaderTests", dependencies: ["BSGImageLoader"], path: "Tests", exclude: ["Info.plist"]
        )
    ]
)
