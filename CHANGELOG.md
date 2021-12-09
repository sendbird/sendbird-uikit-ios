# Change Log

### v2.2.1 (Dec 9, 2021)
* Added `deleteResendableMessage(_:needReload:)`
* Improved stability

### v2.2.0 (Nov 23, 2021)
* Added Reply to Channel feature
    * Added `SBUGlobals.ReplyTypeToUse`
    * Added `SBUReplyType` and its `filterValue` returns `SBDReplyType`
    * Added `SBUQuoteMessageInputView` and its params for configuration
    * Added `SBUQuotedMessageViewProtocol`
    * Added `SBUQuotedBaseMessageView` and its params for configuration
    * Added `SBUQuotedUserMessageView`, `SBUQuotedFileMessageView` as subclass
* Cleaning up Message Cell code
    * Added *params* to configure message cells
    * Added `SBUViewLifeCycle`, `SBUView`, `SBUTableView`
    * Added `SBUStackView`
* Local caching support
    * Modified `SBUMain.initialize(applicationId:)` to `SBUMain.initialize(applicationId:migrationStartHandler:completionHandler:)`
    * `SBUMain.connect` can return user instance even when it's online. 

### v2.1.16 (Nov 16, 2021)
* Updated chat SDK Swift package to **v3.0.208**

### v2.1.15 (Nov 16, 2021)
* Improved stability

### v2.1.14 (Nov 1, 2021)
* Fixed issue on navigation bar in iOS 15
    * Added `sbu_setupNavigationBarAppearance(tintColor:)`
* Improved stability

### v2.1.13 (Sep 2, 2021)
* Updated minor iOS version 10 to 11.
* Modified keyboard height logic when using `isTranslucent=false` option.
* Applied property-wrapper to theme properties.
    * Removed logic that set theme to a global theme in the `setupStyles`, `updateStyles` functions.
    * Added `overlayTheme` property to classes ​that use them differently depending on the overlay.
* Added `messageInputView(_:didChangeText:)` event to `SBUMessageInputViewDelegate`.
* Modified access level of `SBUMessageStateView` to `open`
    * Added `timeFormat` which is type of `String`
    * Added `timeLabelCustomSize` which is type of `CGSize`
    * Modified access level of UI components to `public`
* Aded extensions of `Date`
    * Added `Date.DateFormat` enum.
    * Modified access level of `Date sub_toString(formatString:localizedFormat:) -> String` to public

### v2.1.12 (Aug 19, 2021)
* Added filtering logics for channel events by custom message list params
* Added filtering logics for channel list events by custom channel list query
* Changed `didReceiveError` function name to `errorHandler`.
    * Added error code in error handler.
* Modified `SBUStringSet`
    * `PhotoVideoLibrary`
    * `Message_Edited`
    * `MemberList_Unban`
* Modified on long tap gesture menu
    * stringSet `Remove` to `Delete`
    * colorSet `removeItemColor` to `deleteItemColor`
* Fixed cannot customize `rightBarButton` on `SBUOpenChannelViewController`
* Improved stability

### v2.1.11 (Jul 20, 2021)
* Changed access control of `inputHStackView` on `SBUMessageInputView`.
* Changed `SBUEmptyView` related stringSet.
* Added `emptyView` in user selection in `SBUCreateChannelViewController`.
* Added missing retry logic in `SBUCreateChannelViewController`.
* Improvement stability.

### v2.1.10 (Jun 29, 2021)
* Improvement stability 

### v2.1.9 (Jun 29, 2021)
* Supports SPM(Swift package manager)
* Expands file open and download status Toast.
    * Added strings in `SBUStringSet`
        * `Channel_Failure_Download_file`
        * `Channel_Failure_Open_file`
* Improvement stability

### v2.1.8 (Jun 11, 2021)
* Fixed an issue that failed to send typing status
* Fixed multiline text not functioning for `statusLabel` in `SBUEmptyView` class.
* Fixed multiple messages sending issue when sending a failed message.
* Changed access control  to public
  * `setEditMode(for:)` in  `SBUBaseChannelViewController` class. 

### v2.1.7 (May 26, 2021)
* Fixed problems recognized as the same video file if other URL video files have the same file name
* Fixed `customizedMembers` not working in `SBUMemberListViewController`
* Modified the use of the same file name when transferring image files

### v2.1.6 (May 11, 2021)
* Fixed video thumbnail bug
* Removed `configureContentOffset` in `SBUChannelViewController` and allowed to adjust tableView  contentInset

### v2.1.5 (Apr 23, 2021)
* Added in `SBUMessageSearchViewController`
  * `searchResultList: [SBDBaseMessage]` : Holds the search results.
  * `open func message(at indexPath:) -> SBDBaseMessage?` : Retrieves the `SBDBaseMessage` object from given `IndexPath`.

### v2.1.4 (Apr 14, 2021)
* Improved stability

### v2.1.3 (Apr 13, 2021)
* Added properties in `SBUMessageInputView`.
  * `textViewMinHeight`: the minimun height of the textview.
  * `textViewMaxHeight`: the maximum height of the textview.
  * `textViewLeadingSpacing`: the spacing between the textview and the `+` button.
  * `textViewTrailingSpacing`: the spacing between the textview and the send button.
  * `layoutInsets`: the outer spacing of the `SBUMessageInputView`, relative to `safeAreaLayoutGuide`.
  * `showsSendButton`: whether to always show the send button.
* Applied tint to all `SBUIconSet`.
* Applied localization on datetime string.
* Improved stability.

### v2.1.2 (Mar 30, 2021)
* Improved stability 

### v2.1.0 (Mar 24, 2021)
* Added Message Search features.
  * Added `SBUMessageSearchViewController` and `SBUHighlightMessageInfo` classes.
  * Added `SBUChannelViewController(channelUrl:startingPoint:messageListParams:)`
  * Added `startingPoint`, `highlightInfo`, `useRightBarButtonItem` properties in `SBUChannelViewController`.
  * Added `SBUAvailable.isSupportMessageSearch()`.
* Deprecated lastSeenAt feature.
* Changes in SBUIconSet
  * Added
    * iconBan
    * iconBroadcast
    * iconCheckboxChecked
    * iconCheckboxUnchecked
    * iconChevronRight
    * iconDone
    * iconDoneAll
    * iconEmojiMore
    * iconNotificationFilled
    * iconNotificationOffFilled
    * iconQuestion
    * iconSpinner
    * iconThumbnailNone
  * Replaced
    * channelTypeBroadcast -> iconBroadcast
    * channelTypeGroup -> iconChat
    * channelTypeSupergroup -> iconSupergroup
    * emojiFail -> iconQuestion
    * emojiMoreLarge -> iconEmojiMore
    * iconActionLeave -> iconLeave
    * iconActionNotificationOff -> iconNotificationOffFilled
    * iconActionNotificationOn -> iconNotificationFilled
    * iconAvatarLight -> iconUser
    * iconBanned -> iconBan
    * iconBroadcastSmall -> iconBroadcast
    * iconBroadcastMedium -> iconBroadcast
    * iconBroadcastLarge -> iconBroadcast
    * iconCheckbox -> iconCheckboxChecked
    * iconCheckboxOff -> iconCheckboxUnchecked
    * iconDelivered -> iconDoneAll
    * iconErrorFilled -> iconError
    * iconFailed -> iconError
    * iconMuted -> iconMute
    * iconNoThumbnailLight -> iconThumbnailNone
    * iconRead -> iconDoneAll
    * iconSent -> iconDone
    * iconShevronRight -> iconChevronRight
    * iconSpinnerLarge -> iconSpinner
    * iconSpinnerSmall -> iconSpinner
    * iconThumbnailLight -> iconPhoto
  * Removed
    * emojiHeartEyes
    * emojiLaughing
    * emojiRage
    * emojiSob
    * emojiSweatSmile
    * emojiThubsdown
    * emojiThumbsup
    * iconChatHide
    * iconChatShow
    * iconCreate
    * iconDummy
* Changes in SBUColorSet
  * Changed `primary*` colors.
  * Changed `secondary*` colors.
  * Changed `background300` color.
  * Changed `background200` color.
  * Changed `background100` color.
  * Added `background50`.
  * Added `error*` colors.
  * Removed `error` (replaced with `error300`)
* Changes in SBUFontSet
  * Changed weight of `h1`.
  * Changed size and weight of `h2`.
  * Changed size of `h3`.
  * Changed size of `body1`.
  * Changed weight of `body2`.
  * Changed weight of `body3`.
  * Changed size of `button1`.
  * Changed weight of `caption3`.
  * Changed weight of `caption4`.
* Improved stability.

### v2.0.9 (Mar 9, 2021)
* Fixed runtime debugger issue.

### v2.0.8 (Mar 2, 2021)
* Changes in `SBUChannelViewController` and `SBUOpenChannelViewController`
  * Set `keyboardDismissMode` of `tableView` to `.interactive` as default.
  * Changed `messageInputViewBottomConstraint`, `tableViewTopConstraint` properties to private access.

### v2.0.7 (Jan 28, 2021)
* Dismiss keyboard on swiping message list

### v2.0.5 (Jan 20, 2021)
* Improved stability

### v2.0.4 (Jan 15, 2021)
* Improved stability

### v2.0.3 (Jan 14, 2021)
* Improved stability
* Added `UsingImageCompression` flag in `SBUGlobals`

### v2.0.0 (Dec 24, 2020)
* Added OpenChannel features.
    *  `SBUOpenChannelViewController`
    * `SBUOpenChannelBaseMessageCell`
    * `SBUOpenChannelContentBaseMessageCell`
    * `SBUOpenChannelAdminMessageCell`
    * `SBUOpenChannelUserMessageCell`
    * `SBUOpenChannelFileMessageCell`
    * `SBUOpenChannelMessageWebView`
    * `SBUOpenChannelUnknownMessageCell`
    * `SBUOpenChannelSettingsViewController`
    * `SBUOpenChannelSettingCell`
    * `OpenChannelSettingItemType`
    * Added `UsingUserProfileInOpenChannel` to `SBUGlobals`
    * Added `overlay` themes. 
* Deprecated properties in `SBUChannelViewController` class
    * `preSendMessages` 
    * `resendableMessages` 
    * `preSendFileData`
    * `resendableFileData`
    * `fileTransferProgress`
* Ranamed classes
    * Renamed `SBUMessageBaseCell` to `SBUBaseMessageCell`
    * Renamed `MessageDateView` to `SBUMessageDateView`
    * Renamed `MessageProfileView` to `SBUMessageProfileView`
    * Renamed `UserNameView` to `SBUUserNameView`
    * Renamed `MessageStateView` to `SBUMessageStateView`
* Supported image resizing and compression
    * Added `imageCompressionRate` to `SBUGlobals`
    * Added `imageResizingSize` to `SBUGlobals`
    
* Improved stability.

### v1.2.11 (Dec 11, 2020)
* Imporved stability

### v1.2.10 (Dec 9, 2020)
* Supported loading indicator feature
    * Added `shouldShowLoadingIndicator()`
    * Added `shouldDismissLoadingIndicator()`
* Improved stability

### v1.2.9 (Dec 2, 2020)
* Improved stability

### v1.2.8 (Nov 26, 2020)
* Modified access level for delegate function
    * Opened `imagePickerControllerDidCancel(_:)`

### v1.2.7 (Nov 09, 2020)
* Modified access level for delegate functions
* Fixed `deinit` not called

### v1.2.6 (Nov 03, 2020)
* Changed SBUMessageInputView class from Xib-based to code-based

### v1.2.5 (Oct 19, 2020)
* Changed access controls
* Added documentation comments
* Fixed autolayout warnings
* Improved stability

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
