// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SendBirdUIKit",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "SendBirdUIKit",
            targets: ["SendBirdUIKitTarget"]
        ),
    ],
    dependencies: [
        .package(
            name: "SendBirdSDK",
            url: "https://github.com/sendbird/sendbird-ios-framework",
            from: "3.1.1"
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SendBirdUIKit",
            path: "Framework/SendBirdUIKit.xcframework"
        ),
        .target(
            name: "SendBirdUIKitTarget",
            dependencies: [
                .target(name: "SendBirdUIKit"),
                .product(name: "SendBirdSDK", package: "SendBirdSDK")
            ],
            path: "Framework/Dependency",
            exclude: ["Sample", "Sources"]
        ),
    ]
)
