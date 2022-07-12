# Breaking Changes

## v3.0.0 (Jul 12, 2022)

#### **Common**

* Because the UIKit is based on the chat v4, please refer to [migration guide of Chat SDK v4 for iOS](https://sendbird.com/docs/chat/v4/ios/getting-started/migration-guide) before customization or migrating UIKit v2 to v3.

* The structure has been changed to use `Module` for functions related to UI, and to use `ViewModel` for functions related to data processing.
  > Please refer to the [migration guide](MIGRATION_GUIDE_V3.md). (This link will be changed to Sendbird docs page.)

##### Added
* Added `SBUViewControllerSet` class
* Added `SBUModuleSet` class

##### Renamed
* Renamed `SendBirdUIKit` to `SendbirdUIKit`.
* Renamed `SBUMain` to `SendbirdUI`.

##### Replaced
* Replaced below functions in all viewControllers
  * `setupAutolayout()` to `setupLayouts()`
  * `updateAutolayout()` to `updateLayouts()`
  * `shouldShowLoadingIndicator()` and `shouldDismissLoadingIndicator()` to `shouldUpdateLoadingState(_:)`
<br><br>

#### **Intialization**
* `SendbirdUI`
  ##### Replaced
  * `initialize(applicationId:migrationStartHandler:completionHandler:)` to `initialize(applicationId:startHandler:migrationHandler:completionHandler:)`

#### **List Channels**
* Common
  * Renamed `SBUChannelListViewController` to `SBUGroupChannelListViewController`
  * Added `SBUGroupChannelListModule` (`Header` and `List` components) class
  * Added `SBUGroupChannelListViewModel` class
<br><br>

* SBUGroupChannelListViewController
  ##### Added
  * Added `headerComponent` and `listComponent` 
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUGroupChannelListModuleHeaderDelegate`
    * `SBUGroupChannelListModuleListDelegate`
    * `SBUGroupChannelListModuleListDataSource`
    * `SBUGroupChannelListViewModelDelegate`
    * `SBUCommonViewModelDelegate`
  * Added `enableCreateChannelTypeSelector`
  * Added `createViewModel(channelListQuery:)`
  * Added `loadChannelTypeSelector()`
  * Added `showCreateChannelOrTypeSelector()`
  
  ##### Moved
  * Moved `titleView`, `leftBarButton` and `rightBarButton` into `SBUGroupChannelListModule.Header`
  * Moved `tableView`, `channelCell`, `customCell` and `emptyView` into `SBUGroupChannelListModule.List`
  * Moved funtions into `SBUGroupChannelListModule.List`
    * `register(channelCell:nib:)`
    * `register(customCell:nib:)`
    * `reloadTableView()`
    * `didSelectRetry()`
  * Moved `channelListQuery` and `includeEmptyChannel` into `SBUGroupChannelListViewModel`
  * Moved funtions into `SBUGroupChannelListViewModel`
    * `initChannelList()`
    * `changePushTriggerOption(option:channel:completionHandler)`
    * `leaveChannel(_:completionHandler:)`
    * `resetChannelList()`
    * `loadNextChannelList(reset:)`
    * `sortChannelList(needReload:)`
    * `updateChannels(_:needReload:)`
    * `upsertChannels(_:needReload:)`
    * `deleteChannels(channelUrls:needReload:)`

  ##### Replaced
  * Replaced `setLoading(_:_:)` to `showLoading(_:)`
  * Replaced `limit` to use `channelLoadLimit` in `SBUGroupChannelListViewModel`
  * Replaced delegate functions and moved into `SBUGroupChannelListViewModel`
    * `channelListDidChange(_:needToReload:)` to `groupChannelListViewModel(_:didChangeChannelList:needsToReload:)`
    * `channelDidUpdate(_:)` to `groupChannelListViewModel(_:didUpdateChannel:)`
    * `channelDidLeave(_:)` to `groupChannelListViewModel(_:didLeaveChannel:)`

  ##### Removed
  * Removed `isLoading`, `lastUpdatedTimestamp` and `lastUpdatedToken`
  * Removed functions
    * `channel(_:userDidJoin user:)`
    * `channel(_:userDidLeave user:)`
    * `channelWasChanged(_:)`
    * `channel(_:messageWasDeleted:)`
    * `channelWasFrozen(_:)`
    * `channelWasUnfrozen(_:)`
    * `channel(_:userWasBanned:)`
    * `didSucceedReconnection()`


---
<br>

#### **Create a channel**
* Common
  * Added `SBUCreateChannelModule` (`Header` and `List` components) class
  * Added `SBUCreateChannelViewModel` class
<br><br>

* SBUCreateChannelViewController
  ##### Added
  * Added `headerComponent` and `listComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUCreateChannelModuleHeaderDelegate`
    * `SBUCreateChannelModuleHeaderDataSource`
    * `SBUCreateChannelModuleListDataSource`
    * `SBUCreateChannelModuleListDelegate`
    * `SBUCommonViewModelDelegate`
    * `SBUCreateChannelViewModelDataSource`
    * `SBUCreateChannelViewModelDelegate`
  * Added `createViewModel(users:type:)`
  * Added `createChannelWithSelectedUsers()`

  ##### Moved
  * Moved `titleView`, `leftBarButton` and `rightBarButton` into `SBUCreateChannelModule.Header`
  * Moved `tableView`, `channelCell`, and `emptyView` into `SBUCreateChannelModule.List`
  * Moved funtions into `SBUCreateChannelModule.List`
    * `register(userCell:nib:)`
    * `didSelectRetry()`
  * Moved `userListQuery` into `SBUCreateChannelModuleViewModel`
  * Moved funtions into `SBUCreateChannelModuleViewModel`
    * `loadNextUserList(reset:users:)`
    * `selectUser(user:)`
    * `createChannel(userIds:)`
    * `createChannel(params:messageListParams)`
    * `nextUserList()`
    
  ##### Replaced
  * Replaced `onClickCreate()` to `createChannelWithSelectedUsers()`
  * Replaced `reloadData()` to use `reloadTableView()` in `SBUCreateChannelModule.List`
  * Replaced `nextUserList()` to use `createChannelViewModel(_:nextUserListForChannelType:)` in `SBUCreateChannelViewModelDataSource`
  * Replaced `showLoading(state:)` to `showLoading(_:)`
  
---
<br>

#### **Chat in a channel**
* Common
  * Renamed `SBUChannelViewController` to `SBUGroupChannelViewController`
  * Added `SBUBaseChannelModule` (`Header`, `List` and `Input` components) class
  * Added `SBUBaseChannelViewModel` class
  * Added `SBUGroupChannelModule` (`Header`, `List` and `Input` components) class
  * Added `SBUGroupChannelViewModel` class
  * Added `SBUOpenChannelModule` (`Header`, `List` and `Input` components) class
  * Added `SBUOpenChannelViewModel` class
  * Moved `titleView`, `leftBarButton` and `rightBarButton` into `SBUBaseChannelModule.Header`
  * Moved `channelStateBanner`, `newMessageInfoView`, `scrollBottomView` into `SBUBaseChannelModule.List`
<br><br>

* SBUBaseChannelViewController
  ##### Added
  * Added `baseHeaderComponent`, `baseListComponent`, `baseInputComponent`
  * Added `baseViewModel`
  * Added Delegate, DataSource functions
    * `SBUBaseChannelViewModelDelegate`
    * `SBUBaseChannelModuleHeaderDelegate`
    * `SBUBaseChannelModuleListDelegate`
    * `SBUBaseChannelModuleListDataSource`
    * `SBUBaseChannelModuleInputDelegate`
    * `SBUBaseChannelModuleInputDataSource`
    * `SBUBaseChannelViewModelDataSource`
    * `SBUCommonViewModelDelegate`
  * Added `createViewModel(channel:channelUrl:messageListParams:startingPoint:showIndicator:)`
  * Added `updateChannelTitle()`
  * Added `updateChannelStatus()`
  * Added `showMenuViewController(_:message:)`
  * Added `showMenuModal(_:indexPath:message:)`
  * Added `showDeleteMessageMenu(message:oneTimetheme:)`
  * Added `updateNewMessageInfo(hidden:)`
  * Added `openFile(fileMessage:)`
  
  ##### Moved
  * Moved `tableView`, `emptyView`, `userProfileView` into `SBUBaseChannelModule.List`
  * Moved functions into `SBUBaseChannelModule.List`
    * `reloadTableView()`
    * `updateMessageInputModeState()`
    * `setScrollBottomView(hidden:)`
  * Moved `getMessageGroupingPosition(currentIndex:)` to `SBUGroupChannelModule.List` (or `SBUOpenChannelModule.List`)
  * Moved `messageInputView` and `currentQuotedMessage` into `SBUBaseChannelModule.Input`
  * Moved `channel`, `channelUrl`, `startingPoint`, `inEditingMessage`, `messageListParams`, `customizedMessageListParams`, `messageList` and `fullMessageList` into `SBUBaseChannelViewModel`
  * Moved functions into `SBUBaseChannelViewModel`
    * `loadChannel(channelUrl:messageListParams:)`
    * `clearMessageList()`
    * `setReaction(message:emojiKey:didSelect:)`
    * `updateMessagesInList(messages:needReload:)`
    * `upsertMessagesInList(messages:needUpdateNewMessage:needReload:)`
    * `deleteMessagesInList(messageIds:excludeResendableMessages:needReload:)`
    * `deleteResendableMessage(_:needReload:)`
    * `deleteResendableMessages(requestIds:needReload:)`
    * `sortAllMessageList(needReload:)`
    * `sendUserMessage(text:)`
    * `sendUserMessage(text:parentMessage:)`
    * `sendUserMessage(messageParams:parentMessage:)`
    * `sendFileMessage(fileData:fileName:mimeType:)`
    * `sendFileMessage(fileData:fileName:mimeType:parentMessage:)`
    * `sendFileMessage(messageParams:parentMessage:)`
    * `updateUserMessage(message:text:)`
    * `updateUserMessage(message:messageParams:)`
    * `resendMessage(failedMessage:)`
    * `didSucceedReconnection()`

  ##### Renamed 
  * Renamed `setEditMode(for:)` to `setMessageInputViewMode(_:message:)`
  * Renamed `deleteMessage(message:)` to `showDeleteMessageMenu(message:)`

  ##### Replaced
  * Replaced `setLoading(_:_:)` to `showLoading(_:)`
  * Replaced functions and moved into `SBUBaseChannelModule.List`
    * `checkSameDayAsNextMessage(currentIndex:)` to `checkSameDayAsNextMessage(currentIndex:fullMessageList:)`
  * Replaced delegate functions and moved into `SBUBaseChannelModuleListDelegate`
    * `scrollToBottom(animated:)` to `baseChannelModuleDidTapScrollToButton(_:animated:)`
    * `setTapGestureHandler(_:message:)` to `channelModule(_:didTapMessage:cell:)`
    * `setLongTapGestureHandler(_:message:indexPath:)` to `channelModule(_:didLongTapMessage:cell:)`
    * `setUserProfileTapGestureHandler(_:)` to `channelModule(_:didTapUserProfile:cell:)`
  * Replaced functions and moved into `SBUBaseChannelViewModel`
    * `deleteMessagesInList(messageIds:needReload:)` to `deleteMessagesInList(messageIds:excludeResendableMessages:needReload:)`
    * `channel(_:didUpdate message:)` to `channel(_:didUpdate:)`
    * `channel(_:messageWasDeleted messageId:)` to `channel(_:messageWasDeleted:)`
  * Replaced `isScrollNearBottom()` to use `baseChannelViewModel(_:isScrollNearBottomInChannel:)` in `SBUBaseChannelViewModelDataSource`
  * Replaced delegate functions and moved into `SBUBaseChannelViewModelDelegate`
    * `channelDidChange(_:context:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelDidReceiveNewMessage(_:message:)` to `baseChannelViewModel(_:didReceiveNewMessage:forChannel:)`
    * `channelShouldFinishEditMode(_:)` to `baseChannelViewModel(_:shouldFinishEditModeForChannel:)`
    * `channelShouldDismiss(_:)` to `baseChannelViewModel(_:shouldDismissForChannel:)`
    * `channelWasChanged(_:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelWasFrozen(_:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelWasUnfrozen(_:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channel(_:userWasMuted user:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channel(_:userWasUnmuted user:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelDidUpdateOperators(_:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channel(_:userWasBanned user:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channel(_:userDidEnter user:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channel(_:userDidExit user:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelWasDeleted(_:channelType:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `messageListDidChange(_:needToReload:isInitialLoad:)` to `baseChannelViewModel(_:didChangeMessageList:needsToReload:initialLoad:)`
    * `messageListShouldUpdateScroll(_:context:keepScroll:)` to `baseChannelViewModel(_:shouldUpdateScrollInMessageList:forContext:keepsScroll:)`
    * `message(_:didUpdateReaction reaction:)` to `baseChannelViewModel(_:didUpdateReaction:forMessage:)`
  * Replaced functions and moved into `SBUChannelModule.Input`
    * `sendImageFileMessage(info:)` to `pickImageFile(info:)`
    * `sendVideoFileMessage(info:)` to `pickVideoFile(info:)`
    * `sendDocumentFileMessage(documentUrls:)` to `pickDocumentFile(info:)`
  * Replaced delegate functions and moved into `SBUBaseChannelModuleInputDelegate`
    * `messageInputView(_:didSelectSend text:)` to `baseChannelModule(_:didTapSend:parentMessage:)`
    * `messageInputView(_:didSelectResource type:)` to `baseChannelModule(_:didTapResource:)`
    * `messageInputView(_:didSelectEdit text:)` to `baseChannelModule(_:didSelectEdit:)`
    * `messageInputView(_:didChangeText text:)` to `baseChannelModule(_:didChangeText:)`
    * `messageInputView(_:willChangeMode mode:message:)` to `baseChannelModule(_:willChangeMode:message:)`
    * `messageInputView(_:didChangeMode mode:message:)` to `baseChannelModule(_:didChangeMode:)`
    * `messageInputViewDidStartTyping()` to `baseChannelModuleDidStartTyping(_:)`
    * `messageInputViewDidEndTyping()` to `baseChannelModuleDidEndTyping(_:)`
<br><br>

* SBUGroupChannelViewController
  ##### Added
  * Added `headerComponent`, `listComponent`, `inputComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUGroupChannelViewModelDelegate`
    * `SBUGroupChannelViewModelDataSource`
    * `SBUGroupChannelModuleHeaderDelegate`
    * `SBUGroupChannelModuleListDelegate`
    * `SBUGroupChannelModuleListDataSource`
    * `SBUGroupChannelModuleInputDelegate`
    * `SBUGroupChannelModuleInputDataSource`

  ##### Moved
  * Moved `adminMessageCell`, `userMessageCell`, `fileMessageCell`, `customMessageCell`, `unknownMessageCell` into `SBUGroupChannelModule.List`
  * Moved funtions into `SBUGroupChannelModule.List`
    * `register(adminMessageCell:nib:)`
    * `register(userMessageCell:nib:)`
    * `register(fileMessageCell:nib:)`
    * `register(customMessageCell:nib:)`
    * `generateCellIdentifier(by:)`

  ##### Replaced
  * Replaced functions and moved into `SBUGroupChannelModule.List`
    * `setUserMessageCellGestures(_:userMessage:indexPath:)` to `listComponent.setMessageCellGestures(_:message:indexPath:)`
    * `setFileMessageCellGestures(_:fileMessage:indexPath:)` to `listComponent.setMessageCellGestures(_:message:indexPath:)`
    * `setUnkownMessageCellGestures(_:unknownMessage:indexPath:)` to `listComponent.setMessageCellGestures(_:message:indexPath:)`
    * `scrollViewDidScroll(_:)` to `scrollViewDidScroll(_:)`
  * Replaced delegate functions and moved into `SBUGroupChannelModuleListDelegate`
    * `setEmojiTapGestureHandler(_:emojiKey:)` to `channelModule(_:didTapEmoji:messageCell:)`
    * `setEmojiLongTapGestureHandler(_:emojiKey:)` to `channelModule(_:didLongTapEmoji:messageCell:)`
    * `setTapGestureHandler(_:message:)` to `channelModule(_:didTapMessage:cell:)`
    * `setLongTapGestureHandler(` to `channelModule(_:didLongTapMessage:cell:)`
    * `onClickScrollBottom(sender:)` to `baseChannelModuleDidTapScrollToButton(_:animated:)`
    * `channel(_:updatedReaction reactionEvent:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelDidUpdateReadReceipt(_:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelDidUpdateDeliveryReceipt(_:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
    * `channelDidUpdateTypingStatus(_:)` to `baseChannelViewModel(_:didChangeChannel:withContext:)`
<br><br>

* SBUOpenChannelViewController
  ##### Added
  * Added `headerComponent`, `listComponent`, `inputComponent` and `mediaComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUOpenChannelViewModelDelegate`
    * `SBUOpenChannelViewModelDataSource`
    * `SBUOpenChannelModuleHeaderDelegate`
    * `SBUOpenChannelModuleListDelegate`
    * `SBUOpenChannelModuleInputDelegate`
    * `SBUOpenChannelModuleMediaDelegate`
    * `SBUOpenChannelModuleListDataSource`
    * `SBUOpenChannelModuleInputDataSource`

  ##### Moved
  * Moved `channelInfoView` into `SBUOpenChannelModule.Header`
  * Moved `mediaView` into `SBUOpenChannelModule.Media`
  * Moved `adminMessageCell`, `userMessageCell`, `fileMessageCell`, `customMessageCell` and `unknownMessageCell` into `SBUOpenChannelModule.List`
  * Moved funtions into `SBUOpenChannelModule.List`
    * `register(adminMessageCell:nib:)`
    * `register(userMessageCell:nib:)`
    * `register(fileMessageCell:nib:)`
    * `register(customMessageCell:nib:)`
    * `generateCellIdentifier(by:)`

  ##### Replaced
  * Repaced `updateRatio(mediaView:messageList:)` to `updateMessageListRatio(to:)`
    * `onClickScrollBottom(sender:)` to ``baseChannelModuleDidTapScrollToButton(_:animated:)`
  * Replaced delegate function and moved into `SBUBaseChannelModuleHeaderDelegate`
    * `didSelectChannelInfo()` to `channelModule(_:didTapRightItem:)`
    * `didSelectChannelParticipants()` to `openChannelModuleDidTapParticipantList(_:)`
    * `onClickParticipantsList()` to `openChannelModuleDidTapParticipantList(_:)`
  * Replaced functions and moved into `SBUOpenChannelModule.List`
    * `setTapGestureHandler(_:message:)` to `setTapGesture(_:message:indexPath:)`
    * `setLongTapGestureHandler(_:message:indexPath:)` to `setLongTapGesture(_:message:indexPath:)`
    * `setUserMessageCellGestures(_:userMessage:indexPath:)` to `setMessageCellGestures(_:)`
    * `setFileMessageCellGestures(_:fileMessage:indexPath:)` to `setMessageCellGestures(_:)`
    * `setUnkownMessageCellGestures(_:unknownMessage:indexPath:)` to `setMessageCellGestures(_:)`
    * `scrollViewDidScroll(_:)` to `scrollViewDidSScroll(_:)`
  * Replaced delegate function and moved into `SBUBaseChannelModuleListDelegate`
<br><br>

---

#### Invite users or register users as operators
* Common
  * Added `SBUBaseSelectUserViewController` class
  * Added `SBURegisterOperatorViewController` class
    > `SBUInviteUserViewController` class was subdivided
    > * Invite user: `SBUInviteUserViewController`
    > * Register operator: `SBURegisterOperatorViewController`
    > * The common functions of the two classes are in the `SBUBaseSelectUserViewController` class
  * Added `SBUBaseSelectUserModule` (`Header` and `List` components) class
  * Added `SBUBaseSelectUserViewModel` class
  * Added `SBUInviteUserModule` (`Header` and `List` components) class
  * Added `SBUInviteUserViewModel` class
  * Added `SBURegisterOperatorModule` (`Header` and `List` components) class
  * Added `SBURegisterOperatorViewModel` class
<br><br>

* SBUInviteUserViewController
  ##### Added
  * Added `headerComponent` and `listComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUInviteUserViewModelDataSource`
    * `SBUInviteUserModuleListDataSource`
    * `SBUInviteUserModuleHeaderDataSource`
    * `SBUInviteUserModuleHeaderDelegate`
    * `SBUInviteUserModuleListDelegate`
    * `SBUInviteUserViewModelDelegate`
  * Added `createViewModel(channel:channelUrl:channelType:users:)`
  * Added `inviteSelectedUsers()`
  
  ##### Moved
  * Moved `titleView`, `leftBarButton` and `rightBarButton` into `SBUInviteUserModule.Header`
  * Moved `tableView`, `userCell` and `emptyView` into `SBUInviteUserModule.List`
  * Moved functions into `SBUInviteUserModule.List`
    * `register(userCell:nib:)`
  * Moved `joinedUserIds`, `userListQuery`, `memberListQuery` and `inviteListType` into `SBUBaseSelectUserViewModel`
  * Moved functions into `SBUBaseSelectUserViewModel`
    * `resetUserList`
    * `loadNextUserList(reset:users:)`
    * `selectUser(user:)`

  ##### Replaced
  * Replaced `loadChannel(channelUrl:)` to use `loadChannel(channelUrl:type:)` in `SBUBaseSelectUserViewModel`
  * Replaced `inviteUsers()` to `inviteSelectedUsers()`
  * Replaced `inviteUsers(userIds:)` to use `invite(userIds:)` in `SBUInviteUserViewModel`
  * Replaced `promoteToOperators()` to `registerSelectedUsers()`
  * Replaced `promoteToOperators(memberIds:)` to use `registerAsOperators(userIds:)` in `SBURegisterOperatorViewModel`
  * Replaced `reloadData()` to use `reloadTableView()` in `SBUBaseSelectUserModule.List`
  
  ##### Removed
  * Removed `init(channel:type:)`, `init(channel:users:type:)`
    * use `init(channel:users:)` in `SBUInviteUserViewController` or `SBURegisterOperatorViewController` instead
  * Removed `init(channelUrl:type:)`, `init(channelUrl:users:type:)`
    * use `init(channelUrl:users:)` in `SBUInviteUserViewController` or `SBURegisterOperatorViewController` instead
  * Removed `onClickInviteOrPromote()`
    * use `inviteSelectedUsers()` in `SBUInviteUserViewController` or `registerSelectedUsers()` in `SBURegisterOperatorViewController` instead

* [NEW] SBURegisterOperatorViewController

* [NEW] SBUBaseSelectUserViewController
  
---
<br>

#### **List channel users**
* Common
  * Renamed `SBUMemberListViewController` to `SBUUserListViewController`
  * Added `SBUUserListModule` (`Header` and `List` components) class
  * Added `SBUUserListViewModel` class
<br><br>

* SBUUserListViewController
  ##### Added
  * Added `headerComponent` and `listComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUUserListModuleHeaderDelegate`
    * `SBUUserListModuleListDelegate`
    * `SBUUserListModuleListDataSource`
    * `SBUCommonViewModelDelegate`
    * `SBUUserListViewModelDelegate`
    * `SBUUserListViewModelDataSource`
  * Added `createViewModel(channel:channelUrl:channelType:users:type:)`
  * Added `showUserProfile(with user:)`
  
  ##### Moved
    * Moved `titleView`, `leftBarButton` and `rightBarButton` into `SBUUserListModule.Header`
    * Moved `tableView`, `userCell` and `emptyView` into `SBUUserListModule.List`
    * Moved functions into `SBUUserListModule.List`
      * `register(userCell:nib:)`
    * Moved `memberListQuery`, `operatorListQuery`, `mutedMemberListQuery`, `bannedUserListQuery` and `participantListQuery` into `SBUUserListViewModel`
    * Moved functions into `SBUUserListViewModel`
      * `loadChannel(channelUrl:)`
      * `didSelectRetry()`
      * `channelDidUpdateOperators(_:)`
      * `channel(_:userDidJoin user:)`
      * `channel(_:userDidLeave user:)`
      * `channel(_:userDidExit user:)`
      * `channel(_:userDidEnter user:)`

  ##### Renamed
  * Renamed `memberList`, `memberListType` to `userList`, `userListType`
  * Renamed `bannedMemberListQuery` to `bannedUserListQuery`
  * Renamed `init(channel:type:)` to `init(channel:userListType:)`
  * Renamed `init(channel:members:type:)` to `init(channel:users:userListType:)`
  * Renamed `init(channelURL:channelType:members:memberListType:)` to `init(channelURL:channelType:users:userListType:)`
  * Renamed `onClickInviteUser()` to `showInviteUser()`

  ##### Replaced / Renamed
  * Replaced `loadNextMemberList(reset:members:)` to use `loadNextUserList(reset:users:)` in `SBUUserListViewModel`
  * Replaced `loadMembers()` to use `loadUsers()` in `SBUUserListViewModel`
  * Replaced `preLoadNextMemberList(indexPath:)` to use `preLoadNextUserList(indexPath)` in `SBUUserListViewModel`
  * Replaced `promoteToOperator(member:)` to use `registerAsOperator(user:)` in `SBUUserListViewModel`
  * Replaced `dismissOperator(member:)` to use `unregisterOperator(user:)` in `SBUUserListViewModel`
  * Replaced `mute(member:)` to use `mute(user:)` in `SBUUserListViewModel`
  * Replaced `unmute(member:)` to use `unmute(user:)` in `SBUUserListViewModel`
  * Replaced `ban(member:)` to use `ban(user:)` in `SBUUserListViewModel`
  * Replaced `unban(member:)` to use `unban(user:)` in `SBUUserListViewModel`
  * Replaced `resetMemberList()`, `reloadMemberList()` to use `resetUserList()` in `SBUUserListViewModel`  
  * Replaced `nextMemberList()` to use `userListViewModel(_:nextUserListForChannel:)` in `SBUUserListViewModelDataSource`
  * Replaced `setMoreMenuActionHandler(_:)` to use `setMoreMenuTapAction(_:)` in `SBUUserListModule.List`
  * Replaced `setUserProfileTapGestureHandler(_:)` to use `setUserProfileTapAction(_:)` in `SBUUserListModule.List`
  * Replaced `register(userCell:nib:)` to use `register(userCell:nib:)` in `SBUUserListModule.List`
  * Replaced `reloadData()` to use `reloadTableView()` in `SBUUserListModule.List`

---
<br>

#### **Moderate channels and users**
* Common
  * Added `SBUModerationsModule` (`Header` and `List` components) class
  * Added `SBUModerationsViewModel` class
<br><br>

* SBUModerationsViewController
  ##### Added
  * Added `headerComponent` and `listComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUModerationsModuleHeaderDelegate`
    * `SBUModerationsModuleListDelegate`
    * `SBUModerationsModuleListDataSource`
    * `SBUCommonViewModelDelegate`
    * `SBUModerationsViewModelDelegate`
  * Added `createViewModel(channel:channelUrl:)`
  
  ##### Moved
  * Moved `titleView`, `leftBarButton` and `rightBarButton` into `SBUModerationsModule.Header`
  * Moved `tableView` into `SBUModerationsModule.List`
  * Moved `register(userCell:nib:)` into `SBUModerationsModule.List`
  * Moved functions into `SBUModerationsViewModel`
    * `loadChannel(channelUrl:)`
    * `freezeChannel(completionHandler:)`
    * `unfreezeChannel(completionHandler:)`

  ##### Renamed
  * Renamed `showBannedMeberList()` to `showBannedUserList()`

---
<br>

#### **Search messages**
* Common
  * Added `SBUMessageSearchModule` (`Header` and `List` components) class
  * Added `SBUMessageSearchViewModel` class
<br><br>

* SBUMessageSearchViewController
  ##### Added
  * Added `headerComponent` and `listComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUMessageSearchModuleHeaderDelegate`
    * `SBUMessageSearchModuleListDelegate`
    * `SBUMessageSearchModuleListDataSource`
    * `SBUCommonViewModelDelegate`
    * `SBUMessageSearchViewModelDelegate`
  * Added `createViewModel(channel:)`
  
  ##### Moved
  * Moved `tableView`, `messageSearchResultCell`, and `emptyView` into `SBUMessageSearchModule.List`
  * Moved `messageListParams` in `SBUMessageSearchViewModel`
  * Moved `message(at:)` in `SBUMessageSearchViewModel`

  ##### Replaced
  * Replaced `searchBar` to use `titleView` in `SBUMessageSearchModule.Header`
  * Replaced `setupSearchBarStyle(searchBar:)` to use `updateSearchBarStyle(with:)` in `SBUMessageSearchModule.Header`
  * Replaced `register(messageSearchResultCell:nib:)` to use in `SBUMessageSearchModule.List`

---
<br>

#### **Configure channel settings**
* Common
  * Renamed `SBUBaseChannelSettingViewController` to `SBUBaseChannelSettingsViewController`
  * Renamed `SBUChannelSettingsViewController` to `SBUGroupChannelSettingsViewController`
  * Added `SBUBaseChannelSettingsModule` (`Header` and `List` components) class
  * Added `SBUBaseChannelSettingsViewModel` class
  * Added `SBUGroupChannelSettingsModule` (`Header` and `List` components) class
  * Added `SBUGroupChannelSettingsViewModel` class
  * Added `SBUOpenChannelSettingsModule` (`Header` and `List` components) class
  * Added `SBUOpenChannelSettingsViewModel` class
<br><br>

* SBUBaseChannelSettingsViewController
  ##### Added
  * Added `baseHeaderComponent` and `baseListComponent`
  * Added `baseViewModel`
  * Added Delegate functions
    * `SBUCommonViewModelDelegate`
    * `SBUBaseChannelSettingsViewModelDelegate`
  * Added `showChannelEditActionSheet()`
  * Added `showChannelImagePicker(with type:)`
  * Added `createViewModel(channel:channelUrl:)`
  * Added `updateRightBarButton()`
  
  ##### Moved
  * Moved `titleView`, `leftBarButton` and `rightBarButton` into `SBUBaseChannelSettingsModule.Header`
  * Moved `tableView` into `SBUBaseChannelSettingsModule.List`
  * Moved functions into `SBUBaseChannelSettingsViewModel`
    * `loadChannel(channelUrl:)`
    * `updateChannel(channelName:coverImage:)`
    * `channel(_:userDidJoin user:)`
    * `channel(_:userDidLeave user:)`
    * `channel(_:userDidExit user:)`
    * `channel(_:userDidEnter user:)`

  ##### Replaced / Renamed
  * Replaced `userInfoView` to use `channelInfoView` in `SBUBaseChannelSettingsModule.List`
  * Renamed `onClickEdit()` to `showChannelEditActionSheet()`
<br><br>

* SBUGroupChannelSettingsViewController (SBUChannelSettingsViewController)
  ##### Added
  * Added `headerComponent` and `listComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUGroupChannelSettingsModuleHeaderDelegate`
    * `SBUGroupChannelSettingsModuleHeaderDataSource`
    * `SBUGroupChannelSettingsModuleListDelegate`
    * `SBUGroupChannelSettingsModuleListDataSource`
    * `SBUGroupChannelSettingsViewModelDelegate`
  * Added `createViewModel(channel:channelUrl:)`
  
  ##### Moved
  * Moved functions into `SBUGroupChannelSettingsViewModel`
    * `updateChannel(params:)`
    * `changeNotification(isOn:)`
    * `leaveChannel()`
<br><br>

* SBUOpenChannelSettingsViewController
  ##### Added
  * Added `headerComponent` and `listComponent`
  * Added `viewModel`
  * Added Delegate, DataSource functions
    * `SBUOpenChannelSettingsModuleHeaderDelegate`
    * `SBUOpenChannelSettingsModuleListDelegate`
    * `SBUOpenChannelSettingsModuleListDataSource`
    * `SBUOpenChannelSettingsViewModelDelegate`
  * Added `createViewModel(channel:channelUrl:)`
  
  ##### Moved
  * Moved functions into `SBUGroupChannelSettingsViewModel`
    * `updateChannel(params:)`
    * `deleteChannel()`

---
<br>

#### **StringSet**
* SBUStringSet
  ##### Added
  * Added `UserList_Title_Muted_Participants`
  * Added `Empty_No_Muted_Participants`

  ##### Renamed
  * Renamed `ChannelSettings_Banned_Members` to `ChannelSettings_Banned_Users`
  * Renamed `Empty_No_Banned_Members` to `Empty_No_Banned_Users`
  * Renamed `InviteChannel_Header_Select_Members` to `InviteChannel_Header_Select_Users`
  * Renamed `MemberList_Me` to `UserList_Me`
  * Renamed `MemberList_Ban` to `UserList_Ban`
  * Renamed `MemberList_Unban` to `UserList_Unban`
  * Renamed `MemberList_Mute` to `UserList_Mute`
  * Renamed `MemberList_Unmute` to `UserList_Unmute`
  * Renamed `MemberList_Dismiss_Operator` to `UserList_Unregister_Operator`
  * Renamed `MemberList_Promote_Operator` to `UserList_Register_Operator`
  * Renamed `MemberList_Title_Members` to `UserList_Title_Members`
  * Renamed `MemberList_Title_Operators` to `UserList_Title_Operators`
  * Renamed `MemberList_Title_Muted_Members` to `UserList_Title_Muted_Members`
  * Renamed `MemberList_Title_Banned_Members` to `UserList_Title_Banned_Users`
  * Renamed `MemberList_Title_Participants` to `UserList_Title_Participants`
  * Renamed `UserProfile_Promote` to `UserProfile_Register`
  * Renamed `UserProfile_Dismiss` to `UserProfile_Unregister`

  ##### Removed
  * Removed `MemberList_Header_Title`


#### **SBUEnums**
* Common
  ##### Renamed
  * Renamed `ChannelMemberListType` to `ChannelUserListType`

* `ChannelMemberListType`
  ##### Renamed
  * Renamed `channelMembers`, `mutedMembers`, `bannedMembers` to `members`, `muted`, `banned`

* `ModerationItemType`
  ##### Renamed
  * Renamed `bannedMembers` to `bannedUsers`

* `UserListType`
  ##### Renamed
  * Renamed `channelMembers`, `inviteUser`, `mutedMembers`, `bannedMembers` to `members`, `invite`, `muted`, `banned`

* `EmptyViewType`
  ##### Renamed
  * Renamed `noBannedMembers` to `noBannedUsers`
