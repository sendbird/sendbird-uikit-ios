// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SendbirdUIKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SendbirdUIKit",
            targets: ["SendbirdUIKitTarget"]
        ),
        .library(
            name: "SendbirdUIMessageTemplate",
            targets: ["SendbirdUIMessageTemplateTarget"]
        ),
    ],
    dependencies: [
        .package(
            name: "SendbirdChatSDK",
            url: "https://github.com/sendbird/sendbird-chat-sdk-ios",
            from: "4.39.15"
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SendbirdUIKit",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/3.36.5/SendbirdUIKit.xcframework.zip", // SendbirdUIKit_URL
            checksum: "d494998306af01e7ae9bc37c63224c0a0b2f2c92c7df10249e22a9e26321ccaa" // SendbirdUIKit_CHECKSUM
        ),
        .binaryTarget(
            name: "SendbirdUIMessageTemplate",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/3.36.5/SendbirdUIMessageTemplate.xcframework.zip", // SendbirdUIMessageTemplate_URL
            checksum: "04d68250256abf1460b6ccc3e77709638f21dbb3a5ee1b9d545436ce230a282f" // SendbirdUIMessageTemplate_CHECKSUM
        ),
        .target(
            name: "SendbirdUIKitTarget",
            dependencies: [
                .target(name: "SendbirdUIKit"),
                .target(name: "SendbirdUIMessageTemplate"),
                .product(name: "SendbirdChatSDK", package: "SendbirdChatSDK")
            ],
            path: "Framework/Dependency",
            exclude: ["../../Sample", "../../Sources"]
        ),
        .target(
            name: "SendbirdUIMessageTemplateTarget",
            dependencies: [
                .target(name: "SendbirdUIMessageTemplate"),
                .product(name: "SendbirdChatSDK", package: "SendbirdChatSDK")
            ],
            path: "Framework/Module/MessageTemplate",
            exclude: ["../../Sample", "../../Sources"]
        ),
    ]
)
