// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "TinyPipeline",
    products: [ .library(name: "TinyPipeline", targets: ["TinyPipeline"]), ],
    dependencies: [ .package(path: "../tiny-combine"), ],
    targets: [
        .target(name: "TinyPipeline", dependencies: [ "TinyCombine", ]),
        .testTarget(
            name: "TinyPipelineTests",
            dependencies: [ "TinyCombine", "TinyPipeline", ]
        ),
    ]
)
