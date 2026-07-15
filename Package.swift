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
            from: "4.39.6"
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SendbirdUIKit",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/3.35.5/SendbirdUIKit.xcframework.zip", // SendbirdUIKit_URL
            checksum: "82ccf57545178a9a480188877ec2e882d39f1c74ae336514b257c532964b5c8d" // SendbirdUIKit_CHECKSUM
        ),
        .binaryTarget(
            name: "SendbirdUIMessageTemplate",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/3.35.5/SendbirdUIMessageTemplate.xcframework.zip", // SendbirdUIMessageTemplate_URL
            checksum: "9a2d4f9d74d2c375e4ae94b082a5788591059d7ced0d273c4c358022cfffe6da" // SendbirdUIMessageTemplate_CHECKSUM
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
