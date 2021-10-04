# [Sendbird](https://sendbird.com) UIKit for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)](https://github.com/sendbird/sendbird-uikit-ios)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-green.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Commercial License](https://img.shields.io/badge/license-Commercial-brightgreen.svg)](https://github.com/sendbird/sendbird-uikit-ios/blob/master/LICENSE.md)

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
- **Sources** is where you can find the open source code. Check out [UIKit Open Source Guidelines](https://github.com/sendbird/sendbird-uikit-ios/blob/master/OPENSOURCE_GUIDELINES.md) for more information regarding our stance on open source.
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
- Swift 5.0+ / Objective-C
- Sendbird Chat SDK for iOS 3.0.226+

<br />

## Getting started

This section gives you information you need to get started with Sendbird UIKit for iOS.

### Try the sample app

Our sample app has all the core features of Sendbird UIKit for iOS. Download the app from our GitHub repository to get an idea of what you can build with the actual UIKit before building your own project.

- https://github.com/sendbird/sendbird-uikit-ios/tree/master/Sample


### Create a project

You can get started by creating a project. Sendbird UIKit supports both `Objective-c` and `Swift`, so you can create and work on a project in the language you want to develop with.

![Create a project](https://static.sendbird.com/docs/uikit/ios/getting-started-01_20200416.png)


### Install UIKit for iOS 

UIKit for iOS can be installed through either [`CocoaPods`](https://cocoapods.org/), [`Carthage`](https://github.com/Carthage/Carthage) or [`Swift Package Manager`](https://swift.org/package-manager/): 

> Note: Sendbird UIKit for iOS is Sendbird Chat SDK-dependent. The minimum requirement of the Chat SDK for iOS is 3.0.226 or higher.


#### - CocoaPods

1. Add `SendBirdUIKit` into your `Podfile` in Xcode as below:
```bash
platform :ios, '11' 
use_frameworks! 

target YOUR_PROJECT_TARGET do
    pod 'SendBirdUIKit'
end
```

2. Install the `SendBirdUIKit` framework through `CocoaPods`.
```bash
$ pod install
```

3. Update the `SendBirdUIKit` framework through `CocoaPods`.
```bash
$ pod update 
```

#### - Carthage

1. Add `SendBirdUIKit` and `SendBirdSDK` into your `Cartfile` as below:

```bash
github "sendbird/sendbird-uikit-ios"
github "sendbird/sendbird-ios-framework" == 3.0.226
```

2. Install the `SendBirdUIKit` framework through `Carthage`.

```bash
$ carthage update --use-xcframeworks
```

> __Note__: Building or creating the `SendbirdUIKit` framework with `Carthage` can only be done using the latest `Swift`. If your `Swift` is not the most recent version, the framework should be copied into your project manually.

3. Go to your Xcode project target's **General settings** tab in the `Frameworks and Libraries` section. Then drag and drop on the disk each framework from the `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build` folder.

>__Note__: Errors may occur if you're building your project with Xcode 11.3 or earlier versions. To fix these errors, refer to [Handle errors caused by unknown attributes](https://github.com/sendbird/sendbird-uikit-ios-sources#handling-errors-caused-by-unknown-attributes) in the sample app.

#### - Swift Package Manager
1. File -> Swift Packages -> Add package dependency...

2. Choose Package Repository as the Sendbird UIKit repository with below link:
```bash
https://github.com/sendbird/sendbird-uikit-ios.git
```

3. Select Up to Next Major rules and click the Next button to add the package.

#### - Handle errors caused by unknown attributes

If you are building with Xcode 11.3 or earlier version, you may face two following errors caused by `Swift`'s new annotation processing applied on `Swift` 5.2 which is used in Xcode 11.4.

```bash
- Unknown attribute '_inheritsConvenienceInitializers'
- Unknown attribute '_hasMissingDesignatedInitializers'
```

When these errors happen, follow the steps below which remove the annotations by executing the necessary script in the build steps in advance.

1. Open the **edit scheme** menu of the project target.
![EditScheme](https://static.sendbird.com/docs/uikit/ios/getting-started-handling-errors-01_20200623.png)
2. Select the **Build** > **Pre-actions** menu and add **new run script action**.
![NewRunScriptAction](https://static.sendbird.com/docs/uikit/ios/getting-started-handling-errors-02_20200623.png)
3. After adding the script below, select the target to apply the script.
![ApplyScript](https://static.sendbird.com/docs/uikit/ios/getting-started-handling-errors-03_20200623.png)
```bash
# Cocoapods
if [ -d "${PROJECT_DIR}/Pods/SendBirdUIKit" ]; then
    find ${PROJECT_DIR}/Pods/SendBirdUIKit/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_inheritsConvenienceInitializers '// {} +
    find ${PROJECT_DIR}/Pods/SendBirdUIKit/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_hasMissingDesignatedInitializers '// {} +
fi

# Carthage
if [ -d "${PROJECT_DIR}/Carthage/Build/iOS/SendBirdUIKit.framework" ]; then
    find ${PROJECT_DIR}/Carthage/Build/iOS/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_inheritsConvenienceInitializers '// {} +
    find ${PROJECT_DIR}/Carthage/Build/iOS/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_hasMissingDesignatedInitializers '// {} +
fi
```

4. Try to build and run.

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

In order to use the Chat SDK's features, you must initialize the `SendBirdUIKit` instance with `APP_ID`. This step also initializes the Chat SDK for iOS. 

Initialize the `SendBirdUIKit` instance through `AppDelegate` as below:

```objectivec
// AppDelegate.m
@import SendBirdUIKit;
...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...
    NSString *APP_ID = @"2D7B4CDB-932F-4082-9B09-A1153792DC8D";	// The ID of the Sendbird application which UIKit sample app uses..
    [SBUMain initializeWithApplicationId:APP_ID];
    ...
    
```

```swift
// AppDelegate.swift

import SendBirdUIKit
...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ...
    
    let APP_ID = "2D7B4CDB-932F-4082-9B09-A1153792DC8D"	// The ID of the Sendbird application which UIKit sample app uses.
    SBUMain.initialize(applicationId: APP_ID)
    ...

}
```

> **Note**: In the above, you should specify the ID of your Sendbird application in place of the `APP_ID`.

### Set the current user

User information must be set as `CurrentUser` in the `SBUGlobal` prior to launching Sendbird UIKit. This information will be used within the kit for various tasks. The `userId` field must be specified whereas other fields such as `nickname` and  `profileUrl` are optional and filled with default values if not specified.  

Set the `CurrentUser` for UIKit through the `AppDelegate` as below:

> **Note**: Even if you don’t use the `AppDelegate`, you should register user information before launching a chat service.
 
```objectivec
// AppDelegate.m

@import SendBirdUIKit;
...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...
    
    // Case 1: USER_ID only
    [SBUGlobals setCurrentUser:[[SBUUser alloc] initWithUserId:{USER_ID} nickname:nil profileUrl:nil]];
    
    // Case 2: Specify all fields
    [SBUGlobals setCurrentUser:[[SBUUser alloc] initWithUserId:{USER_ID} nickname:{(opt)NICKNAME} profileUrl:{(opt)PROFILE_URL}]];
    ...

}
```

```swift
// AppDelegate.swift

import SendBirdUIKit
...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ...
    
    // Case 1: USER_ID only
    SBUGlobals.CurrentUser = SBUUser(userId: {USER_ID})
    
    // Case 2: Specify all fields
    SBUGlobals.CurrentUser = SBUUser(userId: {USER_ID}, nickname:{(opt)NICKNAME} profileUrl:{(opt)PROFILE_URL})
    ...
	
}
```

> **Note**: If the `CurrentUser` is not set in advance, there will be restrictions to your usage of UIKit.

### Channel list

UIKit allows you to create a channel specifically for 1-on-1 chat and to list 1-on-1 chat channels so that you can easily view and manage them. With the `SBUChannelListViewController` class, you can provide end users a complete chat service featuring a [channel list](https://sendbird.com/docs/uikit/v1/ios/guides/key-functions#2-list-channels). 

Implement the code below wherever you want to start UIKit.

```objectivec
@import SendBirdUIKit;
...

SBUChannelListViewController *channelListVC = [[SBUChannelListViewController alloc] init];
UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:channelListVC];
[self presentViewController:naviVC animated:YES completion:nil];

...
```

```swift
import SendBirdUIKit
...

let channelListVC = SBUChannelListViewController()
let naviVC = UINavigationController(rootViewController: channelListVC)
self.present(naviVC, animated: true)

...
```

>__Note__: If you are already using a navigation controller, you can use `pushViewController` function.

> **Note**: **At this point**, you can confirm if the service is working by running your client app.

### Channel

With the `SBUChannelViewController` class, you can build a channel-based chat service instead of a channel list-based one.

> **Note**: You should have either a `SBDChannel` object or a `ChannelUrl` in order to run a channel-based chat service. 

Use the following code to implement the chat service.

```objectivec
@import SendBirdUIKit;
...

SBUChannelViewController *channelVC = [[SBUChannelViewController alloc] initWithChannelUrl:{CHANNEL_URL}];
UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:channelVC];
[self presentViewController:naviVC animated:YES completion:nil];
```

```swift
import SendBirdUIKit
...

let vc = SBUChannelViewController(channelUrl: {CHANNEL_URL})
let naviVC = UINavigationController(rootViewController: vc)
present(naviVC, animated: true)
```

#### - For Objective-C 

UIKit is a `Swift`-based framework. However, If your project is in `Objective-C`, configuring just a few additional steps allows you to run the kit in your client app. Go to your Xcode project target's **Build settings** tab and then set the `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` to **YES**.

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
|SBUChannelListViewController|A `ViewController` that manages a channel list.|
|SBUChannelViewController|A `ViewController` that manages a 1-on-1 chat channel.|
|SBUChannelSettingViewController|A `ViewController` that manages the channel settings.|
|SBUCreateChannelViewController|A `ViewController` that creates a channel.|
|SBUInviteUserViewController|A `ViewController` that invites a user to a channel.|
|SBUMemberListViewController|A `ViewController` that shows a list of members in a channel.|
|SBUTheme|A singleton that manages themes.|
|SBUColorSet|A singleton that manages color sets.|
|SBUFontSet|A singleton that manages font sets.|
|SBUMain|A class that contains static functions required when using Sendbird UIKit.|
|SBUGlobalSet|A class that contains static attributes required when using Sendbird UIKit.|
