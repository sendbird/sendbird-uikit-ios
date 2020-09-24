# Change Log

### v1.2.3 (Sep 24, 2020)
* Improved logic for real-time theme changes

### v1.2.2 (Sep 17, 2020)
* Supported UserProfile feature in `SBUChannelViewController`, `SBUMemberListViewController`
  * Added `SBUUserProfileViewProtocol`, `SBUUserProfileViewDelegate`
  * Added global user profile enable setting (`SBUGlobals.UsingUserProfile`)
  * Added `SBUUserProfileTheme` theme
  * Added user profile related stringSet
* Added `SBUGlobalCustomParams` class to used when setting parameters globally in UIKit
  * `groupChannelParamsCreateBuilder`
  * `groupChannelParamsUpdateBuilder`
  * `userMessageParamsSendBuilder`
  * `userMessageParamsUpdateBuilder`
  * `fileMessageParamsSendBuilder`
  * `messageListParamsBuilder`
* Added initialize function with `SBDSender` in `SBUUser`
* Added to be able to set `messageListParams` to functions that have `SBUChannelViewController` initialization function
* Added `createAndMoveToChannel(userIds:messageListParams:)` and `createAndMoveToChannel(params:messageListParams:)` functions that creates and moves the channel that can be called anywhere in `SBUMain` 
* Added `updateUserInfo(nickname:profileImage:completionHandler:)` function in `SBDMain` for update user info with image
* Added `h3` font
* Changed access control
  * Class : `SBUActionSheet`, `SBUAlertView`, `SBUCommonItem`, `SBUUtils`
* Fixed the `loadChannel` function being called multiple times during the initialization of `SBUChannelViewController`.
* Fixed a problem the placeholder disappears when an error occurs during image load
* Fixed autolayout warning issues
* Renamed the GestureHandler functions to union the function name
* Renamed function name that `openChannel` to `moveToChannel` in `SBUMain`
* Improved - When the connection is successful, update currentUser.
* Improved for theme updates on changes at runtime

### v1.2.1 (Sep 10, 2020)
* Supported message grouping
* Improved stability

### v1.2.0 (Aug 27, 2020)
* Added operator features
  * Member managing (ban/unban, mute/unmute, promote/dismiss)
  * Moderation feature for the operator
  * Channel freezing/unfreezing
  * Channel creator will be the default operator
  * Added `SBUModerationsViewController` class
* Added GroupChannel type selector to create
* Improved image cache logic with auth key
* Fixed the problem of chat bubbles width becoming the maximum on short messages
* Fixed Bottom sheet closed automatically issue
* Improved stability
* Modified all codes indentation
* Deprecated
  * `SBUChannelSettingsViewController`
    * `cellNotificationIconColor` -> Use `cellTypeIconTintColor`
    * `cellMemberIconColor` -> Use `cellTypeIconTintColor`
    * `cellMemberButtonColor`  -> Use `cellArrowIconTintColor `
* Updated - MessagingSDK minimum version to **v3.0.200**

### v1.1.4 (Aug 15, 2020)
* Fixed - Default initialization function support for Objective-C

### v1.1.3 (Aug 14, 2020)
* Implemented - OG tag messages feature
* Fixed - Unmodified message not editable
* Updated - MessagingSDK minimum version to v3.0.198

### v1.1.2 (Aug 3, 2020)
* Fixed - Undelivered state checker in message

### v1.1.1 (Jul 17, 2020)
* Supported - access control for customizing classes and functions
* Modified - `userDidLeave` logic for `includeEmptyChannel`
* Improved - Stability

### v1.1.0 (Jul 10, 2020)
* Supported - Reaction feature
  * Added classes 
  	* `SBUReactionsViewController`
  	* `SBUMessageReactionView`
  	* `SBUReactionCollectionViewCell`
  	* `SBUEmojiManager`
  * Added methods 
  	* `setReaction(message:emojiKey:didSelect:)` in `SBUChannelViewController` class
  	* `setTapEmojiGestureHandler(cell:emojiKey:)` in `SBUChannelViewController` class
  	* `setLongTapEmojiGestureHandler(cell:emojiKey:)` in `SBUChannelViewController` class
  	* `showEmojiListModal(message:)` in `SBUChannelViewController` class

### v1.0.11 (Jun 25, 2020)
* Supported - Custom `SBDChanngeListQuery` in the initialization function of `SBUChannelListViewController`
* Supported - Custom `SBDMessageListParams` in the initialization function of `SBUChannelViewController`
* Added - Unknown type message

### v1.0.10 (Jun 18, 2020)
* Fixed - Incorrect operator check logic in frozen group channel

### v1.0.9 (Jun 8, 2020)
* Supported - customized params, Changed access control
	* `SBUChannelViewController`
		* `channel`, `messageList`, `resendableMessages` properties
		* `sendUserMessage(messageParams:)`
		* `sendFileMessage(messageParams:)`
		* `resendMessage(failedMessage:)`
		* `updateUserMessage(message:, text:)`
		* `updateUserMessage(message:, messageParams:)`
		* `deleteMessage(message:)`
	* `SBUChannelViewController`
		* `channelList` property
		* `changePushTriggerOption(option:, channel:, completionHandler:)`
		* `leaveChannel(channel:, completionHandler:)`
	* `SBUChannelSettingsViewController`
		* `updateChannel(channelName:, coverImage:)`
		* `selectChannelImage()`
		* `changeChannelName()`
	* `SBUCreateChannelViewController`
		* `createChannel(userIds:)`
		* `createChannel(params:)`
	* `SBUInviteUserViewController`
		* `inviteUsers()`
		* `inviteUsers(userIds:)`
* Added - `setFrozenModeState()` method for changing frozen channel UI in `MessageInputView`
* Fixed - Update empty view UI after receiving message

### v1.0.8 (May 28, 2020)
* Modified - File message information in channel preview
* Modified - Access control for channel objects
* Added - Required initializers

### v1.0.7 (May 21, 2020)
* Fixed - placeholder not appearing normally when loading image.

### v1.0.6 (May 14, 2020)
* Added - `setLogLevel()` for debugging from the console
* Improved - navigationBar UI

### v1.0.5 (May 6, 2020)
* Fixed - Weird creation channel navigation flow
* Modified - Empty messages string in channel

### v1.0.4 (Apr 29, 2020)
* Added - UIKit version information to User-Agent
* Fixed - Crash issue while scrolling TableView

### v1.0.3 (Apr 23, 2020)
* Fixed - Framework error issue in macOS Mojave

### v1.0.2 (Apr 16, 2020)
* Added - `setTapGestureHandler()`, `setLongTapGestureHandler()` methods for Cell on `SBUChannelViewController`
* Modified - Empty user name display policy
* Modified - Display long pressed color
* Changed - NavigationBarButton to public type
* Renamed - `SBUMessageBaseCell` to `SBUBaseMessageCell` 
* Fixed - UIStatusBarStyle issue (light/dark)
* Improved - Stability

### v1.0.1 (Apr 7, 2020)
* Supported - Bitcode

### v1.0.0 (Apr 1, 2020)
* First release.
