# [SendBird](https://sendbird.com) UIKit for iOS
SendBird UIKit is a development kit with an user interface that enables an easy and fast integration of standard chat features into new or existing client apps. From the overall theme to individual styles such as colors and fonts, components can be fully customized to create an in-app chat experience unique to your brand identity.


[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)](https://github.com/sendbird/sendbird-uikit-ios)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-green.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Commercial License](https://img.shields.io/badge/license-Commercial-brightgreen.svg)](https://github.com/sendbird/sendbird-uikit-ios/blob/master/LICENSE.md)

## Documentation
[SendBird UIKit for iOS](https://docs.sendbird.com/ios)

## Install SendBird UIKit Framework from CocoaPods

Add below into your Podfile on Xcode.

```
use_frameworks!

target YOUR_PROJECT_TARGET do
  pod 'SendBirdUIKit'
end
```

Install SendBird UIKit Framework through CocoaPods.

```
pod install
```

Update SendBird UIKit Framework through CocoaPods.

```
pod update SendBirdUIKit
```

Now you can see installed SendBird UIKit framework by inspecting YOUR_PROJECT.xcworkspace.

> Note: `SendBirdUIKit` is dependent with `SendBird SDK`. If you install `SendBirdUIKit`, Cocoapods automatically install `SendBird SDK` as well. And the minimum version of `SendBird SDK` is **3.0.175**.

## Install SendBird Framework from Carthage

1. Add `github "sendbird/sendbird-uikit-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Go to your Xcode project's "General" settings. Open `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build/iOS` in Finder and drag `SendBirdUIKit.framework` to the "Embedded Binaries" section in Xcode. Make sure `Copy items if needed` is selected and click `Finish`.

## Sample
For a sample of uikit, please check the repository below.

[SendBird-iOS Sample](https://github.com/sendbird/SendBird-iOS)
