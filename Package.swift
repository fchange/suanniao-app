// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SuanNiaoSuanNiao",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "SuanNiaoSuanNiao",
            targets: ["SuanNiaoSuanNiao"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SuanNiaoSuanNiao",
            path: "Sources/SuanNiaoSuanNiao"
        )
    ]
)
