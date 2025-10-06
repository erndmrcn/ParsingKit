// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ParsingKit",
    defaultLocalization: "en",
    platforms: [ .iOS(.v14), .macOS(.v12), .tvOS(.v14) ],
    products: [ .library(name: "ParsingKit", targets: ["ParsingKit"]) ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.1")
    ],
    targets: [
        .target(
            name: "ParsingKit",
            dependencies: [
                .product(name: "XMLCoder", package: "XMLCoder")
            ],
            path: "Sources/ParsingKit",
            swiftSettings: [
                .define("PARSINGKIT_SIMD_DOUBLE", .when(configuration: .release))
            ]
        )
    ]
)
