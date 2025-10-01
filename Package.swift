// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ParsingKit",
    defaultLocalization: "en",
    platforms: [ .iOS(.v14), .macOS(.v12), .tvOS(.v14) ],
    products: [ .library(name: "ParsingKit", targets: ["ParsingKit"]) ],
    targets: [
        .target(
            name: "ParsingKit",
            dependencies: [],
            path: "Sources/ParsingKit",
            swiftSettings: [
                .define("PARSINGKIT_SIMD_DOUBLE", .when(configuration: .release))
            ]
        )
    ]
)
