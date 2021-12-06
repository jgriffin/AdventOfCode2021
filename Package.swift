// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode2021",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AdventOfCode2021",
            targets: ["AdventOfCode2021"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.3.1"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "0.2.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AdventOfCode2021",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing"),
            ]
        ),
        .testTarget(
            name: "AdventOfCode2021Tests",
            dependencies: [
                "AdventOfCode2021",
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            resources: [.process("resources")]
        ),
    ]
)
