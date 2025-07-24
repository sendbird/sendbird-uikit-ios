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
            from: "4.26.0"
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SendbirdUIKit",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/1.0.999/SendbirdUIKit.xcframework.zip", // SendbirdUIKit_URL
            checksum: "cb526ef087b255ce299de454490ebb4be45af25983fe5566bff9272b35d010ee" // SendbirdUIKit_CHECKSUM
        ),
        .binaryTarget(
            name: "SendbirdUIMessageTemplate",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/1.0.999/SendbirdUIMessageTemplate.xcframework.zip", // SendbirdUIMessageTemplate_URL
            checksum: "2fee4293fbc3a9832fdf9b9f439dd39d5443cafdbc35396e9be299cacd32db4c" // SendbirdUIMessageTemplate_CHECKSUM
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
