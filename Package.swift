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
            from: "4.35.0"
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SendbirdUIKit",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/3.33.1/SendbirdUIKit.xcframework.zip", // SendbirdUIKit_URL
            checksum: "b55c89d32f9634270be305c92fc67c0c0b04c23328d4f9436e55037dce3ec9ca" // SendbirdUIKit_CHECKSUM
        ),
        .binaryTarget(
            name: "SendbirdUIMessageTemplate",
            url: "https://github.com/sendbird/sendbird-uikit-ios/releases/download/3.33.1/SendbirdUIMessageTemplate.xcframework.zip", // SendbirdUIMessageTemplate_URL
            checksum: "99be28b7f9e23a5749f28565362a335e709d2752fada6af15032879882f69542" // SendbirdUIMessageTemplate_CHECKSUM
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
