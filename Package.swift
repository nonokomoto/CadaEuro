// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CadaEuroApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CadaEuroApp",
            targets: ["CadaEuroApp"]),
    ],
    dependencies: [
        // Dependências internas (local packages)
        .package(path: "Packages/CadaEuroUI"),
        .package(path: "Packages/CadaEuroDomain"),
        .package(path: "Packages/CadaEuroData"),
        .package(path: "Packages/CadaEuroKit"),
        .package(path: "Packages/CadaEuroLLM"),
        .package(path: "Packages/CadaEuroOCR"),
        .package(path: "Packages/CadaEuroSpeech"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CadaEuroApp",
            dependencies: [
                .product(name: "CadaEuroUI", package: "CadaEuroUI"),
                .product(name: "CadaEuroDomain", package: "CadaEuroDomain"),
                .product(name: "CadaEuroData", package: "CadaEuroData"),
                .product(name: "CadaEuroKit", package: "CadaEuroKit"),
                .product(name: "CadaEuroLLM", package: "CadaEuroLLM"),
                .product(name: "CadaEuroOCR", package: "CadaEuroOCR"),
                .product(name: "CadaEuroSpeech", package: "CadaEuroSpeech"),
            ]),
        .testTarget(
            name: "CadaEuroAppTests",
            dependencies: ["CadaEuroApp"]
        ),
    ]
)
