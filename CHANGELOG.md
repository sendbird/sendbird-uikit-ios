# Change Log

### v1.0.10 (Jun 18, 2020)
* Fixed - Incorrect operator check logic in frozen group channel

### v1.0.9 (Jun 8, 2020)
* Supported customized params, Changed access control
	* **`SBUChannelViewController`**
		* `channel`, `messageList`, `resendableMessages` properties
		* `sendUserMessage(messageParams:)`
		* `sendFileMessage(messageParams:)`
		* `resendMessage(failedMessage:)`
		* `updateUserMessage(message:, text:)`
		* `updateUserMessage(message:, messageParams:)`
		* `deleteMessage(message:)`
	* **`SBUChannelViewController`**
		* `channelList` property
		* `changePushTriggerOption(option:, channel:, completionHandler:)`
		* `leaveChannel(channel:, completionHandler:)`
	* **`SBUChannelSettingsViewController`**
		* `updateChannel(channelName:, coverImage:)`
		* `selectChannelImage()`
		* `changeChannelName()`
	* **`SBUCreateChannelViewController`**
		* `createChannel(userIds:)`
		* `createChannel(params:)`
	* **`SBUInviteUserViewController`**
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
