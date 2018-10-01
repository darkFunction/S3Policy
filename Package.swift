// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "S3Policy",
    products: [
        .library(
            name: "S3Policy",
            targets: ["S3Policy"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "S3Policy",
            dependencies: []),
        .testTarget(
            name: "S3PolicyTests",
            dependencies: ["S3Policy"]),
    ]
)
