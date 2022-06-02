# Changelog

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
