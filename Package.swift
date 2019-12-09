// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "TinyPipeline",
    platforms: [ .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6), ],
    products: [ .library(name: "TinyPipeline", targets: ["TinyPipeline"]), ],
    targets: [
        .target(name: "TinyPipeline"),
        .testTarget(
            name: "TinyPipelineTests",
            dependencies: [ "TinyPipeline", ]
        ),
    ]
)
