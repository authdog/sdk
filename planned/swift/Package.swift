// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AuthdogSwiftSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "AuthdogSwiftSDK",
            targets: ["AuthdogSwiftSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    ],
    targets: [
        .target(
            name: "AuthdogSwiftSDK",
            dependencies: ["Alamofire"]
        ),
        .testTarget(
            name: "AuthdogSwiftSDKTests",
            dependencies: ["AuthdogSwiftSDK"]
        ),
    ]
)
