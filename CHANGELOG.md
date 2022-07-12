# Changelog

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
