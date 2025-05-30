// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CadaEuroDomain",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CadaEuroDomain",
            targets: ["CadaEuroDomain"]),
    ],
    dependencies: [
        // Dependências internas
        .package(path: "../CadaEuroKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CadaEuroDomain",
            dependencies: [
                .product(name: "CadaEuroKit", package: "CadaEuroKit"),
            ]),
        .testTarget(
            name: "CadaEuroDomainTests",
            dependencies: ["CadaEuroDomain"]
        ),
    ]
)
