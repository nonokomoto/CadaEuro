// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CadaEuroLLM",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CadaEuroLLM",
            targets: ["CadaEuroLLM"]),
    ],
    dependencies: [
        // Dependências internas
        .package(path: "../CadaEuroKit"),
        
        // Dependências externas comentadas temporariamente
        // .package(url: "https://github.com/OpenAI/openai-swift.git", exact: "1.0.0"),
        // .package(url: "https://github.com/google/generative-ai-swift.git", exact: "0.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CadaEuroLLM",
            dependencies: [
                .product(name: "CadaEuroKit", package: "CadaEuroKit"),
                // Dependências externas comentadas temporariamente
                // .product(name: "OpenAI", package: "openai-swift"),
                // .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
            ]),
        .testTarget(
            name: "CadaEuroLLMTests",
            dependencies: ["CadaEuroLLM"]
        ),
    ]
)
