// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CadaEuroUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CadaEuroUI",
            targets: ["CadaEuroUI"]),
    ],
    dependencies: [
        // Dependências internas
        .package(path: "../CadaEuroDomain"),
        .package(path: "../CadaEuroKit"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CadaEuroUI",
            dependencies: [
                .product(name: "CadaEuroDomain", package: "CadaEuroDomain"),
                .product(name: "CadaEuroKit", package: "CadaEuroKit"),
            ]),
        .testTarget(
            name: "CadaEuroUITests",
            dependencies: ["CadaEuroUI"]
        ),
    ]
)
