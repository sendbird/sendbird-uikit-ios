# Changelog

### v3.2.2 (Oct 28, 2022) with Chat SDK **v4.1.2**
* Fixed `scrollToBottom` button flickers when send a message
* Improved fileMessage related processing
* Added `messageCellConfiguration` in `SBUGlobals`
* Modified fonts and colors in `SBUTheme`
  * Renamed `ChannelListTheme` to `SBUGroupChannelListTheme` (also `SBUTheme.groupChannelListTheme`)
  * Renamed `ChannelCellTheme` to `SBUGroupChannelCellTheme` (also `SBUTheme.groupChannelCellTheme`)
  * Renamed `SBUTheme.setChannelList(channelListTheme:channelCellTheme:)` to `SBUTheme.setGroupChannelList(channelListTheme:channelCellTheme:)`
  * `SBUGroupChannelListTheme`
    * `notificationOnTintColor`: light (`SBUColorSet.background50` -> `SBUColorSet.ondark01`)
  * `SBUGroupChannelCellTheme`
    * Added `fileIconBackgroundColor`, `fileIconTintColor`
  * `SBUOpenChannelCellTheme`
    * `participantCountFont`: light(`SBUColorSet.caption1` -> `SBUColorSet.caption2`)
  * `SBUChannelTheme`
    * Added `openChannelOGTitleColor`, `buttonBackgroundColor`, `buttonTitleColor`, `sideButtonIconColor`, `newMessageBadgeColor`
    * `menuItemDisabledColor`: light(`SBUColorSet.ondark04` -> `SBUColorSet.onlight04`) 
    * `mentionLimitGuideTextFont`: (`SBUFontSet.body1` -> `SBUFontSet.body3`)
    * `quotedMessageBackgroundColor`: light(removed alpha value 0.5)
  * `SBUMessageCellTheme`
    * Renamed `unknownMessageDescTextColor` to `unknownMessageDescLeftTextColor`
    * Added `unknownMessageDescRightTextColor`
  * `SBUChannelSettingsTheme`
    * `userNameFont` (subtitle1 -> h1)
    * `urlFont` (body3 -> body1)
    * `cellDescriptionTextFont` (subtitle3 -> body3)
  * `SBUCreateOpenChannelTheme`
    * `textFieldFont` (body3 -> subtitle1)
* Fixed bcsymbolmap issue for SPM

### v3.2.1 (Oct 13, 2022) with Chat SDK **v4.0.15**
* Added `contentMode` parameter to `setImage(withImage:backgroundColor:makeCircle:)` in `SBUCoverImageView`
* Modified SendbirdUIKit initializer to synchronously
* Deprecated functions in `SBUGroupChannelListViewModel`
    * `updateChannels(_:needReload:)`
    * `upsertChannels(_:needReload:)`
    * `deleteChannels(_:needReload:)`
    * `sortChannelList(needReload:)`
* Improved stability

### v3.2.0 (Sep 21, 2022) with Chat SDK **v4.0.13**
* Support **Open channel list** features
    * Added classes
        * `SBUOpenChannelListViewController`
        * `SBUOpenChannelCell`
        * `SBUOpenChannelListViewModel`
        * `SBUOpenChannelListModule`, `SBUOpenChannelListModule.Header` and `SBUOpenChannelListModule.List`
    * Added `OpenChannelListViewController` in `SBUViewControllerSet`
    * Added `openChannelListModule` in `SBUModuleSet`    
    * Added `openChannelListTheme` and `openChannelCellTheme` in `SBUTheme`
    * Added `isPullToRefreshEnabled` property in `SBUBaseChannelListModule.List`
    * Added `pullToRefresh(_:)` function in `SBUBaseChannelListModule.List`
    * Added `baseChannelListModuleDidSelectRefresh(_:)` protocol in `SBUBaseChannelListModuleListDelegate`
    * Added `iconChannels` in `SBUIconSetType`
    * Supported openChannelList feature on `moveToChannel` function in `SendbirdUI`
* Support **Create open channel** features
    * Added classes
        * `SBUCreateOpenChannelViewController`
        * `SBUCreateOpenChannelViewModel`
        * `SBUCreateOpenChannelModule`, `SBUCreateOpenChannelModule.Header` and `SBUCreateOpenChannelModule.ProfileInput`
    * Added `CreateOpenChannelViewController` in `SBUViewControllerSet`
    * Added `createOpenChannelModule` in `SBUModuleSet`
    * Added `createOpenChannelTheme` in `SBUTheme`
    * Added `openChannelParamsCreateBuilder` in `SBUGlobalCustomParams`
    * Added create open channel related Strings in `SBUStringSet` 
        * `CreateOpenChannel_Create`, `CreateOpenChannel_Header_Title`, `CreateOpenChannel_ProfileInput_Placeholder`
    * Added `user` object in `SBUUser` for accessing ChatSDK's user 
* Added  `openChannelModule(_:didTapMediaView:)` in `OpenChannelModuleMediaDelegate` method.
* Added `UITextField` related classes 
    * `UITextField+SBUIKit`
    * `SBUUnderLineTextField`
* Added `tag` parameter in `SBUCommonItem`
* Added `delete` case in `MediaResourceType`
* Added `SBUBaseChannelListViewModel`
* Added `SBUBaseChannelListModule`, `SBUBaseChannelListModule.Header`, `SBUBaseChannelListModule.List` classes
* Renamed `SBUGroupChannelListModuleListDelegate` functions
    * `channelListModule(_:didSelectRowAt:)` to `groupChannelListModule(_:didSelectRowAt:)`
    * `channelListModule(_:didDetectPreloadingPosition:)` to `groupChannelListModule(_:didDetectPreloadingPosition:)`
    * `channelListModule(_:didSelectLeave:)` to `groupChannelListModule(_:didSelectLeave:)`
    * `channelListModule(_:didChangePushTriggerOption:channel:)` to `groupChannelListModule(_:didChangePushTriggerOption:channel:)`
    * `channelListModuleDidSelectRetry(_:)` to `groupChannelListModuleDidSelectRetry(_:)`
* Renamed `SBUGroupChannelListModuleListDataSource` function
    * `channelListModule(_:channelsInTableView:)` to `groupChannelListModule(_:channelsInTableView:)`
* Renamed `channelListModule` in `SBUModuleSet` to `groupChannelListModule`
* Renmaed `defaultLeftButton`, `defaultRightButton` to `defaultLeftBarButton`, `defaultRightBarButton`
* Replaced `setPlaceholderImage(iconSize:)` to `setPlaceholder(type:iconSize:)` in `SBUCoverImageView`
    * Added `setPlaceholder(type:iconSize:)`
    * Deprecated `setPlaceholderImage(iconSize:)`

### v3.1.3 (Sep 15, 2022) with Chat SDK **v4.0.12**
* Improved stability

### v3.1.2 (Aug 31, 2022) with Chat SDK **v4.0.9**
* Added message menu interfaces and events to `BaseChannelModuleList`
  * List
    * `showMessageMenu(on:forRowAt:)`
    * `showFailedMessageMenu(on:)`
    * `showDeleteMessageAlert(on:oneTimeTheme:)`
    * `showMessageMenuSheet(for:cell:)`
    * `showMessageContextMenu(for:cell:forRowAt:)`
    * `createMessageMenuItems(for:) -> [SBUMenuItem]`
    * `createCopyMenuItem(for:) -> SBUMenuItem`
    * `createDeleteMenuItem(for:) -> SBUMenuItem`
    * `createEditMenuItem(for:) -> SBUMenuItem`
    * `createSaveMenuItem(for:) -> SBUMenuItem`
    * `createReplyMenuItem(for:) -> SBUMenuItem`
  * Delegate
    * `baseChannelModule(_:didTapRetryFailedMessage:)`
    * `baseChannelModule(_:didTapDeleteFailedMessage:)`
    * `baseChannelModule(_:didTapCopyMessage:)`
    * `baseChannelModule(_:didTapDeleteMessage:)`
    * `baseChannelModule(_:didTapEditMessage:)`
    * `baseChannelModule(_:didTapSaveMessage:)`
    * `baseChannelModule(_:didTapReplyMessage:)`
    * `baseChannelModule(_:didReactToMessage:withEmoji:selected:)`
    * `baseChannelModule(_:didTapMoreEmojisOnMessage:)`
    * `baseChannelModule(_:didDismissMenuForCell:)`
  * DataSource
    * `baseChannelModule(_:parentViewControllerDisplayMenuItems:) -> UIViewController?`
* Improved stability
  * Improved logic in `SBUUserListViewController`
  * Fixed typo in `SBUViewControllerSet`

### v3.1.1 (Aug 17, 2022)
* Improved stability

### v3.1.0 (Aug 3, 2022) with Chat SDK **v4.0.8**
* Support moderation in OpenChannel
    * `SBUModuleSet`
        * Deprecated `moderationsModule` property, use `groupModerationsModule` or `openModerationsModule` instead
        * Deprecated `registerOperatorModule` property, use `groupRegisterOperatorModule` or `openRegisterOperatorModule` instead
        * Deprecated `userListModule` property, use `groupUserListModule` or `openUserListModule` instead
        * Deprecated `init(channelListModule:baseChannelModule:groupChannelModule:openChannelModule:inviteUserModule:registerOperatorModule:userListModule:groupChannelPushSettingsModule:createChannelModule:groupChannelSettingsModule:openChannelSettingsModule:moderationsModule:messageSearchModule:)` function, use `init(channelListModule:baseChannelModule:groupChannelModule:openChannelModule:inviteUserModule:groupRegisterOperatorModule:openRegisterOperatorModule:groupUserListModule:openUserListModule:groupChannelPushSettingsModule:createChannelModule:groupChannelSettingsModule:openChannelSettingsModule:groupModerationsModule:openModerationsModule:messageSearchModule:)` instead
    * `SBUViewControllerSet`
        * Renmaed `groupChannelPushSettingsViewController` to `GroupChannelPushSettingsViewController`
        * Deprecated `RegisterOperatorViewController`, use `GroupChannelRegisterOperatorViewController` or `OpenChannelRegisterOperatorViewController` instead
        * Deprecated `UserListViewController`, use `GroupUserListViewController` or `OpenUserListViewController` instead
        * Deprecated `ModerationsViewController`, use `GroupModerationsViewController` or `OpenModerationsViewController` instead
    * `SBUEnums`
        * Added `allTypes(channel:)` function in `ModerationItemType` enum
        * Added `noMutedParticipants` case in `EmptyViewType`
    * `SBUModerationsViewController`
      * Deprecated `init(channelURL:)`, use `init(channelURL:channelType:)` instead
      * Deprecated `createViewModel(channel:channelURL:)`, use `createViewModel(channel:)` or `createViewModel(channelURL:channelType:)` instead
    * Added functions in `SBUOpenChannelSettingsViewController` class
        * `showModerationList()`
        * `showDeleteChannelAlert()`
    * Deprecated function in `SBUModerationsViewModel` class
      * `init(channe:channelURL:delegate:)` -> Use `init(channel:delegate:)` or `init(channelURL:channelType:delegate:)` instead
    * Added `channelType` parameter in configuration function of `SBUUserListModule.Header`
    * Added `channelType` parameter in initialization function of `SBURegisterOperatorViewController`
    * Added `participantListQuery` parameter in initialization function of `SBUBaseSelectUserViewModel`
    * Added `mutedParticipantListQuery` parameter in initialization function of `SBUUserListViewModel`
    * Added `sbu_updateOperatorStatus(channel:)`
    * Improved list item customization of Group/OpenChannelSettings
      * Added `SBUChannelSettingItem`
      * Added `SBUBaseChannelSettingCell`, `SBUGroupChannelSettingCell` and `SBUOpenChannelSettingCell`
      * Added did select related delegates in `SBUGroupChannelSettingsModule.List` and `SBUOpenChannelSettingsModule.List`
      * Modified `configureCell` of `SBUGroupChannelSettingsModule.List` and `SBUOpenChannelSettingsModule.List` to use `SBUChannelSettingItem`
    * Added moderations menu in OpenChannelSettings
      * Added `itemDeleteTextColor` property in `SBUChannelSettingsTheme`
      * Added strings
        * `ChannelSettings_Delete_Question_Mark`
        * `ChannelSettings_Delete_Description`
* Added ChannelSetting item's notification strings
  * `ChannelSettings_Notifications_On`
  * `ChannelSettings_Notifications_Off`
  * `ChannelSettings_Notifications_Mentiones_Only`
* Modified `loadAllEmojis(completionHandler:)` function access level to `public` in `SBUEmojiManager` class
* Improved stability


### v3.0.0 (Jul 12, 2022) with Chat SDK **v4.0.5**
* UIKit v3.0.0 officially version
    * Support `modules` and `components` in the UIKit
    * See more details and breaking changes. [[details](/changelogs/BREAKING_CHANGES_V3.md)]
    * See the Migration Guide for Converting V2 to V3. [[details](/changelogs/MIGRATION_GUIDE_V3.md)]
---
* Applied `SBUSelectablePhotoViewDelegate` and `PHPickerViewControllerDelegate` to `SBUBaseChannelSettingViewController`
  * Added `showCamera()`, `showPhotoLibraryPicker()`, `showLimitedPhotoLibraryPicker()` and `showPermissionAlert()` to `SBUBaseChannelSettingViewController`
* Added `init(mediaType:)` to `SBUSelectablePhotoViewController`
* Added `startHandler` to `SendbirdUI` initializer
  * Renamed to `initialize(applicationId:startHandler:migrationHandler:completionHandler:)`
* Set `setMemberInfoInMessage` option to `true`
* Added muted mode feature in OpenChannel
* Fixed quoted message long name layout issue
* Modified access level of message cell interfaces
* Added `messageInputView(_:willChangeMode:message:mentionManager:)` to `SBUGroupChannelModule.Input`
* Changed `SBUMessageInputView option` to read-only
* Renamed `SBUStringSet`
	* `ChannelSettings_Banned_Members` to `ChannelSettings_Banned_Users`
	* `Empty_No_Banned_Members` to `Empty_No_Banned_Users`
	* `InviteChannel_Header_Select_Members` to `InviteChannel_Header_Select_Users`
	* `InviteChannel_Add` to `InviteChannel_Register`
	* `MemberList_Me` to `UserList_Me`
	* `MemberList_Ban` to `UserList_Ban`
	* `MemberList_Unban` to `UserList_Unban`
	* `MemberList_Mute` to `UserList_Mute`
	* `MemberList_Unmute` to `UserList_Unmute`
	* `MemberList_Dismiss_Operator` to `UserList_Unregister_Operator`
	* `MemberList_Promote_Operator` to `UserList_Register_Operator`
	* `MemberList_Title_Members` to `UserList_Title_Members`
	* `MemberList_Title_Operators` to `UserList_Title_Operators`
	* `MemberList_Title_Muted_Members` to `UserList_Title_Muted_Members`
	* `MemberList_Title_Banned_Members` to `UserList_Title_Banned_Users`
	* `MemberList_Title_Participants` to `UserList_Title_Participants`
	* `UserProfile_Promote` to `UserProfile_Register`
	* `UserProfile_Dismiss` to `UserProfile_Unregister`
* Added new `SBUStringSet`
	* `UserList_Title_Muted_Participants`
	* `Empty_No_Muted_Participants`
* Removed unused `SBUStringSet`
	* `MemberList_Header_Title`
* Renamed `SBUEnums`
	* `ChannelMemberListType` to `ChannelUserListType`
	* `channelMembers`, `mutedMembers`, `bannedMembers` to `members`, `muted`, `banned` in `ChannelMemberListType`
	* `bannedMembers` to `bannedUsers` in `ModerationItemType`
	* `channelMembers`, `inviteUser`, `mutedMembers`, `bannedMembers` to `members`, `invite`, `muted`, `banned` in `UserListType`
	* `noBannedMembers` to `noBannedUsers` in `EmptyViewType`
* Renamed `SBUMemberListViewController` to `SBUUserListViewController`
* Renamed properties, functions in `SBUMemberListViewController`
	* `memberList`, `memberListType` to `userList`, `userListType`
	* `init(channel:memberListType:)` to `init(channel:userListType:)`
	* `init(channel:members:type:)` to `init(channel:users:userListType:)`
	* `init(channelURL:channelType:members:memberListType:)` to `init(channelURL:channelType:users:userListType:)`

### v3.0.0-beta.4 (Jun 21, 2022)
* Modified some view to be able to change its date format
  * Opened `SBUMessageDateView`
  * Opened `SBUChannelCell`
  * Added `SBUMessageDateView.dateFormat`
  * Added `SBUOpenChannelContentBaseMessageCell.dateFormat`
  * Added `SBUMessageSearchResultCell.dateFormat`
  * Added parameters to `SBUChannelCell buildLastUpdatedDate()`: `dateFormat`, `timeFormat`
* Added public classes and interfaces regarding message cells
  * Added open/public interfaces in message cells.
  * Added `SBULinkClickableTextView`  
  * Added `SBUMessageWebView` , `SBUMessageWebViewModel` and `SBUOpenChannelMessageWebView`
  * Added `SBUUserMessageTextViewDelegate` , `SBUUserMessageTextViewModel` and `SBUUserMessageTextView`
  * Added `SBUUserNameView`
  * Added `SBUFileViewerDelegate` and `SBUFileViewer`
  * Added `QuotedFileCommonContentView` and `QuotedFileImageContentView`
  * Added `SBUMessageReactionView`
* Added `SBUDateFormatSet`
* Added `Date.sbu_toString(dateFormat:localizedFormat)`
* Changed `Date.lastUpdatedTime` function in `Data+SBUIKit` access level to public
* Fixed not called completion handler on unregister pushToken

### v3.0.0-beta.3 (Jun 2, 2022)
* Added channel push settings feature.
  * Added `SBUGroupChannelPushSettingsViewController` class.
  * Added `SBUGroupChannelPushSettingsModule`, `SBUGroupChannelPushSettingsModule.Header` and  
`SBUGroupChannelPushSettingsModule.List` classes.
  * Added `SBUGroupChannelPushSettingsViewModel` class.
  * Added `ChannelPushSettings_Header_Title`, `ChannelPushSettings_Notification_Title`, `ChannelPushSettings_Item_All`, `ChannelPushSettings_Item_Mentions_Only`, `ChannelPushSettings_Notification_Description`.
* Added `keyword` to `SBUHighlightInfo`
* Modify parameter `highlight` to `highlightKeyword` in `SBUCommonContentView`
* Modified searched message cell display method (highlight -> animation)
* Added mentioned user nickname highlighting.
* Added show mini profile function when touch mentioned nickname. 
* Added initialize function in `SBUCreateChannelVC`.
* Renamed `SBUStringSet.Channel_Header_Typing` to `SBUStringSet.Channel_Typing`
* Updated `SBUTheme.channelCell`
  * Added `succeededStateColor`
  * Added `deliveryReceiptStateColor`
  * Added `readReceiptStateColor`
* Added `leftBarButton` to `SBUSelectablePhotoViewController`
  * Added `leftBarButton`
  * Added `didTapLeftBarButton()`
* Improved stability.

### v3.0.0-beta.2 (Apr 29, 2022) with Chat SDK v3.1.13
* Added User Mention Features
  * Added Mention feature to `SBUGlobals`
    * `userMentionConfig`
    * `isUserMentionEnabled`
  * Added `Mention` to `SBUStringSet`
    * `Mention.Trigger_Key`
    * `Mention.Limit_Guide`
  * Added `SBUUserMentionConfiguration`
  * Added `SBUBaseChannelViewModel` methods
    * `sendUserMessage(text:mentionedMessageTemplate:mentionedUserIds:parentMessage:)`
    * `updateUserMessage(message:text:mentionedMessageTemplate:mentionedUserIds:)`
  * Added properties to `SBUMessageInputView`
    * `defaultAttributes`, `mentionedAttributes`
  * Added `SBUMessageInputViewDelegate` methods
    * `messageInputView(_:shouldChangeTextIn:replacementText:) -> Bool`
    * `messageInputView(_:shouldInteractWith:in:interaction:) -> Bool`
    * `messageInputView(_:didChangeSelection:)`
  * Added `SBUGroupChannelModuleInputDelegate` methods
    * `groupChannelModule(_:didTapSend:mentionedMessageTemplate:mentionedUserIds:parentMessage:)`
    * `groupChannelModule(_:didTapEdit:mentionedMessageTemplate:mentionedUserIds:)`
    * `groupChannelModule(_:shouldLoadSuggestedMentions:)`
  * Added `SBUMentionManager`, `SBUMentionManagerDelegate` and 
    * `mentionManager(_didChangeSuggestedMention:filteredText:isTriggered:)`, `mentionManager(_:didInsertMentionsTo:)``SBUMentionManagerDataSource`
  * Added `SBUSuggestedMentionList`, `SBSBUSuggestedMentionListDelegate`
    * `Mention_Limit_Guide` to `SBUStringSet`
    * `isMentionGuideEnabled`
    * `SBUMentionLimitGuideCell`
    * `suggestedUserList(_:didSelectUser:)`
  * Updated `SBUGroupChannelCell`
    * `unreadMentionLabel`
  * Updated `SBUGroupChannelModule.Input`
    * `mentionManager`
    * `suggestedMentionList`
    * `setupMentionManager`, `updateSuggestedMentionList(with:)`, `presentSuggestedMentionList()`, `dismissSuggestedMentionList()` 
  * Updated `SBUUserCell` to support `SBUSuggestedMentionList`
    * `UserListType.suggestedMention`
    * `nicknameLabel` and `userIdLabel`
    * Renamed `userNickname` to `nicknameLabel`
    * Renamed `userNameTextColor` and `userNameFont` to `nicknameTextColor` and `nicknameFont`
  * Updated `SBUTheme` for the mention features
    * `mentionTextFont`, `mentionLeftTextColor`, `mentionRightTextColor`, `mentionLeftTextBackgroundColor`, `mentionRightTextBackgroundColor` for message cell.
    * `mentionTextFont`, `mentionTextColor`, `mentionTextBackgroundColor` for message input.
    * `mentionLimitGuideTextFont`, `mentionLimitGuideTextColor`, `separatorColor` for channel.
    * `unreadMentionTextFont`, `unreadMentionTextColor` for channel cell.
    * `nicknameTextFont`, `nicknameTextColor`, `nonameTextColor`, `userIdTextFont` and `userIdTextColor`

### v3.0.0-beta (Apr 12, 2022)
* Applied modularization.
  * The structure has been changed to use `Module` for functions related to UI, and to use `ViewModel` for functions related to data processing.
* **Please refer to the [Breaking changes v3](/changelogs/BREAKING_CHANGES_V3.md).**

---

### v2.x
* **Please refer to the [Changelog v2](/changelogs/CHANGELOG_V2.md).**
