# [Sendbird](https://sendbird.com) UIKit for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Languages](https://img.shields.io/badge/language-Swift-orange.svg)](https://github.com/sendbird/sendbird-uikit-ios)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-green.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-green.svg)](https://github.com/sendbird/sendbird-uikit-ios-spm)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-green.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Commercial License](https://img.shields.io/badge/license-Commercial-green.svg)](https://github.com/sendbird/sendbird-uikit-ios/blob/main/LICENSE.md)

We are introducing a new version of the Sendbird UIKit. Version 3 features a new modular architecture with more granular components that give you enhanced flexibility to customize your web and mobile apps. Check out our [migration guides](changelogs/MIGRATION_GUIDE_V3.md) and download our [samples](/Sample)


With the official release of the v3 version, the name of the `master` branch was changed to the `main` branch, and the `main` branch was changed to the contents of the v3. If you have to keep using v2, please use the `main-v2` branch.
* v3: `main`
* v2: `main-v2`


## Table of contents

  1. [Introduction](#introduction)
  1. [Before getting started](#before-getting-started)
  1. [Getting started](#getting-started)
  1. [Implementation guide](#implementation-guide) 
  1. [UIKit at a glance](#uikit-at-a-glance)  
  
<br />

## Introduction

**Sendbird UIKit** for iOS is a development kit with an user interface that enables an easy and fast integration of standard chat features into new or existing client apps. From the overall theme to individual styles such as colors and fonts, components can be fully customized to create an in-app chat experience unique to your brand identity.

> **Note**: Currently, UIKit for iOS now supports both group channels and open channels.

![ThemeLight](https://static.sendbird.com/docs/uikit/ios/theme-light_20200416.png)

This repository houses the UIKit source code and UIKit sample in addition to a UIKit Framework.
- **Sources** is where you can find the open source code. Check out [UIKit Open Source Guidelines](/OPENSOURCE_GUIDELINES.md) for more information regarding our stance on open source.
- **Sample** is a chat app which contains custom sample code for various key features written in `Swift`. 

### Benefits

- Easy installation
- Fully-featured chat with a minimal amount of code
- Customizable components, events, and views
- Customizable user list to enable chat among specified users

### More about Sendbird UIKit for iOS

Find out more about Sendbird UIKit for iOS on [UIKit for iOS doc](https://sendbird.com/docs/uikit/v1/ios/getting-started/about-uikit). If you have any comments or questions regarding bugs and feature requests, visit [Sendbird community](https://community.sendbird.com). 

<br />

## Before getting started

This section shows the prerequisites you need to check to use Sendbird UIKit for iOS.

### Requirements

The minimum requirements for Sendbird UIKit for iOS are:

- iOS 11+
- Swift 5.0+
- Sendbird Chat SDK for iOS 4.0.15+

<br />

## Getting started

This section gives you information you need to get started with Sendbird UIKit for iOS.

### Try the sample app

Our sample app has all the core features of Sendbird UIKit for iOS. Download the app from our GitHub repository to get an idea of what you can build with the actual UIKit before building your own project.

- [Samples](/Sample)


### Create a project

You can get started by creating a project. Sendbird UIKit support `Swift`, so you can create and work on a project in the language you want to develop with.

![Create a project](https://static.sendbird.com/docs/uikit/ios/getting-started-01_20200416.png)


### Install UIKit for iOS 

UIKit for iOS can be installed through either [`CocoaPods`](https://cocoapods.org/), [`Carthage`](https://github.com/Carthage/Carthage) or [`Swift Package Manager`](https://swift.org/package-manager/): 

> Note: Sendbird UIKit for iOS is Sendbird Chat SDK-dependent. The minimum requirement of the Chat SDK for iOS is 4.0.15 or higher.


#### - Swift Packages

1. Go to your Swift Package Manager's **File** tab and select **Swift Packages**. Then choose **Add package dependency...**.

2. Add `SendbirdUIKit` into your `Package Repository` as below:

```bash
https://github.com/sendbird/sendbird-uikit-ios-spm.git
```

3. To add the package, select **Branch Rules**, input `main` and click **Next**.

#### - CocoaPods

1. Add `SendBirdUIKit` into your `Podfile` in Xcode as below:

```bash
platform :ios, '11.0'
use_frameworks!

target YOUR_PROJECT_TARGET do
    pod 'SendBirdUIKit'
end
```

2. Install the `SendbirdUIKit` framework through `CocoaPods`.

```bash
$ pod install
```

3. Update the `SendbirdUIKit` framework through `CocoaPods`.

```bash
$ pod update
```

> Note: Cocoapod uses the name of Send**B**irdUIKit, not Send**b**irdUIKit.

#### - Carthage

1. Add `SendbirdUIKit` and `SendBirdSDK` into your `Cartfile` as below:

```bash
github "sendbird/sendbird-uikit-ios"
github "sendbird/sendbird-chat-sdk-ios"
```

2. Install the `SendbirdUIKit` framework through `Carthage`.

```bash
$ carthage update --use-xcframeworks
```

> __Note__: Building or creating the `SendbirdUIKit` framework with `Carthage` can only be done using the latest `Swift`. If your `Swift` is not the most recent version, the framework should be copied into your project manually.

3. Go to your Xcode project target's **General settings** tab in the `Frameworks and Libraries` section. Then drag and drop `SendbirdUIKit.framework` from the `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build` folder.

>__Note__: Errors may occur if you're building your project with Xcode 11.3 or earlier versions. To fix these errors, refer to [Handle errors caused by unknown attributes](https://github.com/sendbird/sendbird-uikit-ios#--handle-errors-caused-by-unknown-attributes).

### Get attachment permission

Sendbird UIKit offers features to attach or save files such as photos, videos, and documents. To use those features, you need to request permission from end users.

#### - Media attachment permission

Applications must acquire permission from end users to use their photo assets or to save assets into their library. Once the permission is granted, users can send image or video messages and save media assets.

```xml
...
<key>NSPhotoLibraryUsageDescription</key>
    <string>$(PRODUCT_NAME) would like access to your photo library</string>
<key>NSCameraUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to use your camera</string>
<key>NSMicrophoneUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to use your microphone (for videos)</string>
<key>NSPhotoLibraryAddUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to save photos to your photo library</string>
...

```

![Media attachment permission](https://static.sendbird.com/docs/uikit/ios/getting-started-02_20200416.png)

#### *(Optional)* Document attachment permission

If you want to attach files from `iCloud`, you must activate the `iCloud` feature. Once it is activated, users can also send a message with files from `iCloud`. 

Go to your Xcode project's **Signing & Capabilities** tab. Then, click **+ Capability** button and select **iCloud**. Check **iCloud Documents**.

![Document attachment permission](https://static.sendbird.com/docs/uikit/ios/getting-started-03_20200416.png)

<br />

## Implementation guide

### Initialize with APP_ID

In order to use the Chat SDK's features, you must initialize the `SendbirdUIKit` instance with `APP_ID`. This step also initializes the Chat SDK for iOS. 

Initialize the `SendbirdUIKit` instance through `AppDelegate` as below:

```swift
// AppDelegate.swift

import SendbirdUIKit

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let APP_ID = "2D7B4CDB-932F-4082-9B09-A1153792DC8D"    // The ID of the Sendbird application which UIKit sample app uses.
    SendbirdUI.initialize(applicationId: APP_ID) {
        // Do something to display the start of the SendbirdUIKit initialization.
    } migrationHandler: {
        // Do something to display the progress of the DB migration.
    } completionHandler: { error in
        // Do something to display the completion of the SendbirdChat initialization.
    }
    
}
```

> **Note**: In the above, you should specify the ID of your Sendbird application in place of the `APP_ID`.

### Set the current user

User information must be set as `currentUser` in the `SBUGlobal` prior to launching Sendbird UIKit. This information will be used within the kit for various tasks. The `userId` field must be specified whereas other fields such as `nickname` and  `profileURL` are optional and filled with default values if not specified.  

Set the `currentUser` for UIKit through the `AppDelegate` as below:

> **Note**: Even if you don’t use the `AppDelegate`, you should register user information before launching a chat service.
 
```swift
// AppDelegate.swift

import SendbirdUIKit

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Case 1: USER_ID only
    SBUGlobals.currentUser = SBUUser(userId: {USER_ID})
    
    // Case 2: Specify all fields
    SBUGlobals.currentUser = SBUUser(userId: {USER_ID}, nickname:{(opt)NICKNAME} profileURL:{(opt)PROFILE_URL})
    
}
```

> **Note**: If the `currentUser` is not set in advance, there will be restrictions to your usage of UIKit.

### Channel list

UIKit allows you to create a channel specifically for 1-on-1 chat and to list 1-on-1 chat channels so that you can easily view and manage them. With the `SBUChannelListViewController` class, you can provide end users a complete chat service featuring a [List channels](https://sendbird.com/docs/uikit/v3/ios/key-functions/list-channels). 

Implement the code below wherever you want to start UIKit.

```swift
import SendbirdUIKit

let groupChannelListVC = SBUGroupChannelListViewController()
let naviVC = UINavigationController(rootViewController: groupChannelListVC)
self.present(naviVC, animated: true)

```

>__Note__: If you are already using a navigation controller, you can use `pushViewController` function.

> **Note**: **At this point**, you can confirm if the service is working by running your client app.

### Channel

With the `SBUGroupChannelViewController` class, you can build a channel-based chat service instead of a channel list-based one.

> **Note**: You should have either a `Channel` object or a `ChannelURL` in order to run a channel-based chat service. 

Use the following code to implement the chat service.

```swift
import SendbirdUIKit

let channelVC = SBUGroupChannelViewController(channelURL: {CHANNEL_URL})
let naviVC = UINavigationController(rootViewController: channelVC)
present(naviVC, animated: true)

```

### Distribution setting 

UIKit is distributed in the form of a fat binary, which contains information on both **Simulator** and **Device** architectures. Add the script below if you are planning to distribute your application in the App Store and wish to remove unnecessary architectures in the application's build phase.

Go to your Xcode project target's **Build Phases** tab. Then, click **+** and select **New Run Script Phase**. Append this script.

```bash
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
    FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
    FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
    echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"
    
    EXTRACTED_ARCHS=()
    
    for ARCH in $ARCHS
    do
        echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
        lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
        EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
    done
    
    echo "Merging extracted architectures: ${ARCHS}"
    lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
    rm "${EXTRACTED_ARCHS[@]}"
    
    echo "Replacing original executable with thinned version"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
done
```

<br />

## UIKit at a glance

UIKit for iOS manages the lifecycle of its `ViewController` along with various views and data from the Chat SDK for iOS. UIKit Components are as follows:

|Component|Description|
|---|---|
|SBUGroupChannelListViewController|A `ViewController` that manages a group channel list.|
|SBUGroupChannelViewController|A `ViewController` that manages a 1-on-n group chat channel.|
|SBUOpenChannelViewController|A `ViewController` that manages a open chat channel.|
|SBUCreateChannelViewController|A `ViewController` that creates a channel.|
|SBUInviteUserViewController|A `ViewController` that invites a user to a channel.|
|SBURegisterOperatorViewController|A `ViewController` that registers as operator in a channel.|
|SBUUserListViewController|A `ViewController` that shows a list of members or participants in a channel.|
|SBUGroupChannelSettingsViewController|A `ViewController` that configures a group channel.|
|SBUOpenChannelSettingsViewController|A `ViewController` that configures a open channel.|
|SBUModerationsViewController|A `ViewController` that moderates a channel.|
|SBUMessageSearchViewController|A `ViewController` that searches messages in a channel.|
|SBUTheme|A singleton that manages themes.|
|SBUColorSet|A singleton that manages color sets.|
|SBUFontSet|A singleton that manages font sets.|
|SendbirdUI|A class that contains static functions required when using Sendbird UIKit.|
|SBUGlobalSet|A class that contains static attributes required when using Sendbird UIKit.|
