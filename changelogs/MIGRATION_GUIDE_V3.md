# Migration guide

UIKit for iOS has newly released v3 beta. The biggest change from v2 to v3 is modularization, which allows you to build and customize views at a component level. You can execute [key functions](https://sendbird.com/docs/uikit/v3/ios/key-functions/overview) of UIKit using a view controller, which is composed of a module and a view model. In each key function, the module is used to create and display everything UI-related while the view model is in charge of managing data from Chat SDK to apply to each view. This new architecture allows for easier and more detailed customization.

When migration from v2 to v3, there are several breaking changes you need to be aware of. Since modules and view models are one of the main parts of the new architecture, you need to make changes to the existing codes in your client app. Refer to the breaking changes below in each key function.

---

## Modules

In every key function provided by Sendbird UIKit, there's a [module](https://sendbird.com/docs/uikit/v3/ios/modules/overview), which is composed of several components, in each view controller. These components, also referred to as module components, make up the view in the corresponding key function to create and display an interactive UI. Unlike v2 where the view controller handled all UI-related features, the modules and components now manage the UI of each view controller in v3. These modules and components are customizable to fit your own design needs.

All modules are owned and managed by the `SBUModuleSet` global class. If you don't want to use the default module and component provided by UIKit, you can set a custom module and component in the `SBUModuleSet` so the customized objects become the default setting throughout the entire client app.

All components use a delegate to send events that occur in the view to the view controller and a data source object to receive necessary data from the view controller. Refer to the table below to learn about the relationship between key function, module, component, and view controller.

#### Module relationship table

<div component="AdvancedTable" type="4B">

|Key function|Module|Component|View controller|
|---|---|---|---|
|[List channels](https://sendbird.com/docs/uikit/v3/ios/key-functions/list-channels)|SBUGroupChannelListModule|Header, List|SBUGroupChannelListViewController|
|[Chat in a group channel](https://sendbird.com/docs/uikit/v3/ios/key-functions/chatting-in-a-channel/chat-in-group-channel)|SBUGroupChannelModule|Header, List, Input|SBUGroupChannelViewController|
|[Chat in an open channel](https://sendbird.com/docs/uikit/v3/ios/key-functions/chatting-in-a-channel/chat-in-open-channel)|SBUOpenChannelModule|Header, List, Input, Media|SBUOpenChannelViewController|
|[Create a group channel](https://sendbird.com/docs/uikit/v3/ios/key-functions/creating-a-channel/create-group-channel)|SBUCreateChannelModule|Header, List|SBUCreateChannelViewController|
|[Invite users](https://sendbird.com/docs/uikit/v3/ios/key-functions/invite-users-or-promote-to-operator)|SBUInviteUserModule|Header, List|SBUInviteUserViewController|
|[Promote members to operator](https://sendbird.com/docs/uikit/v3/ios/key-functions/invite-users-or-promote-to-operator)|SBUPromoteMemberModule|Header, List|SBUPromoteMemberViewController|
|[List channel members or participants](https://sendbird.com/docs/uikit/v3/ios/key-functions/list-channel-members-or-participants)|SBUMemberListModule|Header, List|SBUMemberListViewController|
|[Configure group channel settings](https://sendbird.com/docs/uikit/v3/ios/key-functions/configuring-channel-settings/configure-group-channel-settings)|SBUGroupChannelSettingsModule|Header, List|SBUGroupChannelSettingsViewController|
|[Configure open channel settings](https://sendbird.com/docs/uikit/v3/ios/key-functions/configuring-channel-settings/configure-open-channel-settings)|SBUOpenChannelSettingsModule|Header, List|SBUOpenChannelSettingsViewController|
|[Moderate channels and members](https://sendbird.com/docs/uikit/v3/ios/key-functions/moderate-channels-and-members)|SBUModerationsModule|Header, List|SBUModerationsViewController|
|[Search messages](https://sendbird.com/docs/uikit/v3/ios/key-functions/search-messages)|SBUMessageSearchModule|Header, List|SBUMessageSearchViewController|

</div>

---

## View model

In a key function, each view controller has a corresponding view model, which processes and requests data directly from Sendbird Chat SDK. Without needing to call the Chat SDK interface, the view controller can simply use a view model to manage and process data needed to build a view in UIKit. Every view model has a delegate that is used to send data updates in the form of events to the view controller. It also uses a data source object to gather necessary data from the view controller.

Refer to the table below to learn about the relationship between key function, view model, and view controller.

#### View model relationship table

<div component="AdvancedTable" type="3B">

|Key function|View model|View controller|
|---|---|---|
|List channels|SBUGroupChannelListViewModel|SBUGroupChannelListViewController|
|Chat in a group channel|SBUGroupChannelViewModel|SBUGroupChannelViewController|
|Chat in an open channel|SBUOpenChannelViewModel|SBUOpenChannelViewController|
|Create a group channel|SBUCreateChannelViewModel|SBUCreateChannelViewController|
|Invite users|SBUInviteUserViewModel|SBUInviteUserViewController|
|Promote members to operator|SBUPromoteMemberViewModel|SBUPromoteMemberViewController|
|List channel members or participants|SBUMemberListViewModel|SBUMemberListViewController|
|Configure group channel settings|SBUGroupChannelSettingsViewModel|SBUGroupChannelSettingsViewController|
|Configure open channel settings|SBUOpenChannelSettingsViewModel|SBUOpenChannelSettingsViewController|
|Moderate channels and members|SBUModerationsViewModel|SBUModerationsViewController|
|Search messages|SBUMessageSearchViewModel|SBUMessageSearchViewController|

</div>

---

## Added SBUViewControllerSet and SBUModuleSet

Starting in v3 of UIKit for iOS, `SBUViewControllerSet` and `SBUModuleSet` have been added to minimize inheriting and overriding when customizing views. In v3, you can now set a custom view controller and module in `SBUViewControllerSet` and `SBUModuleSet` respectively, in order to make changes to the view.

### SBUViewControllerSet

In Sendbird UIKit, there is a `SBUViewControllerSet` global class that manages the view controllers of all key functions. `SBUViewControllerSet` is a property that's composed of class types of all the view controller classes.

If you don't want to use the default view controller provided by the UIKit, you can set a custom view controller within `SBUViewControllerSet`. By implementing a view controller that's been customized in the global class, you can use it across the entire client app without having to change it each time. Refer to the example code below:

```swift
class CustomGroupChannelListViewController: SBUGroupChannelListViewController {
    ...
}

// Implement anywhere before using `GroupChannelListViewController`.
SBUViewControllerSet.GroupChannelListViewController = CustomGroupChannelListViewController.self
```

You can also still use the existing customization method in v2 where you directly implement your own custom view controller.

When creating a custom view controller instance, Sendbird UIKit follows the order of usage below:

1. A view controller that's been customized upon initial setting.
2. A view controller that's been customized within `SBUViewControllerSet`.
3. A non-customized, default view controller provided by Sendbird UIKit.

If you didn't set your own custom view controller, then a view controller that's been customized within `SBUViewControllerSet` is used instead throughout the UIKit. If there are no custom view controllers, the default view controller provided by Sendbird UIKit in `SBUViewControllerSet` is used.

### SBUModuleSet

In Sendbird UIKit, there is a `SBUModuleSet` global class that manages all modules and each module is composed of various components. The global `SBUModuleSet` provides the corresponding module and its components to each view controller.

If you don't want to use the default module and component provided by the UIKit, you can set a custom module and component in `SBUModuleSet` so the customized objects become the default setting throughout the entire UIKit without having to change them each time. Refer to the example codes below:

#### Set a custom module

```swift
class CustomModule: SBUGroupChannelListModule {
    ...
}

// Implement anywhere before using `channelListModule`.
SBUModuleSet.channelListModule = CustomModule()
```

#### Set a custom component

```swift
class CustomComponent: SBUChannelListModule.Header {
    ...
}

// Implement anywhere before using `channelListModule.headerComponent`.
SBUModuleSet.channelListModule.headerComponent = CustomComponent()
```

When using a customized module or its component, the view controller follows the order below:

1. A module or component that's been customized in the view controller.
2. A custom module or component that's been customized in `SBUModuleSet`.
3. A non-customized, default module and component provided by Sendbird UIKit.

If you didn't set a custom module or component in the view controller, then a custom module or component that's been set in `SBUModuleSet` is used instead throughout the UIKit. If there are no custom modules or components, the default objects provided by Sendbird UIKit in `SBUModuleSet` are used.

---

## Breaking changes

See the breaking changes below in each key function.

> __Note__ : You'll be notified of changes in the code through warning and error messages in the build phase of Xcode.

### All key functions

The following tables show what changes were made from v2 to v3.

#### Changed UIKit SDK name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|SendBirdUIKit|SendbirdUIKit|

</div>

#### Changed UIKit main class name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|SBUMain|SendbirdUI|

</div>

#### Changed method and event delegate names in all view controllers

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|setupAutolayout()|setupLayouts()|
|updateAutolayout()|updateLayouts()|
|didReceiveError(_:_:)|errorHandler(_:_:)|
|shouldShowLoadingIndicator()<br /><br />shouldDismissLoadingIndicator()|shouldUpdateLoadingState(_:)|

</div>

#### Changed property names in SBUGlobals

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|ApplicationId|applicationId|
|AccessToken|accessToken|
|CurrentUser|currentUser|
|UsingMessageGrouping|isMessageGroupingEnabled|
|ReplyTypeToUse|replyType|
|UsingPHPicker|isPHPickerEnabled|
|UsingUserProfile|isUserProfileEnabled|
|UsingUserProfileInOpenChannel|isOpenChannelUserProfileEnabled|
|UsingImageCompression|isImageCompressionEnabled|

</div>

### List channels

The following tables show what changes were made in `SBUChannelListViewController` from v2 to v3.

#### Changed view controller name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|SBUChannelListViewController|SBUGroupChannelListViewController|

</div>

#### Added new components and view model

The following objects have been added to `SBUGroupChannelListViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/list-channels#2-usage) section of the view controller page.

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|emptyView|listComponent.emptyView|List|
|tableView|listComponent.tableView|List|
|channelCell|listComponent.channelCell|List|
|customCell|listComponent.customCell|List|

</div>

#### Moved properties to view model

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|channelListQuery|viewModel.channelListQuery|
|includeEmptyChannel|viewModel.includeEmptyChannel|

</div>

#### Moved property to view model and changed name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|limit|viewModel.channelLoadLimit|

</div>

#### Deprecated properties

Due to the addition of [local caching](/docs/chat/v3/ios/guides/local-caching), the following properties have been deprecated in v3:

* `isLoading`
* `lastUpdatedTimestamp`
* `lastUpdatedToken`

#### Moved methods to component

<div component="AdvancedTable" type="2B">

|Method|Component|
|---|---|
|register(channelCell:nib:)|List|
|register(customCell:nib:)|List|
|reloadTableView()|List|
|didSelectRetry()|List|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadNextChannelList(reset:)`
* `sortChannelList(needReload:)`
* `updateChannels(_:needReload:)`
* `upsertChannels(_:needReload:)`
* `deleteChannels(channelUrls:needReload:)`
* `changePushTriggerOption(option:channel:completionHandler:)`
* `leaveChannel(_:completionHandler:)`

#### Moved method to view model and changed name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|resetChannelList()|viewModel.reset()|

</div>

#### Changed method name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|setLoading(_:_:)|showLoading(_:)|

</div>

#### Deprecated methods

Due to the addition of [local caching](/docs/chat/v3/ios/guides/local-caching), the following methods have been deprecated in v3:

* `channel(_:userDidJoin user:)`
* `channel(_:userDidLeave user:)`
* `channelWasChanged(_:)`
* `channel(_:messageWasDeleted:)`
* `channelWasFrozen(_:)`
* `channelWasUnfrozen(_:)`
* `channel(_:userWasBanned:)`
* `didSucceedReconnection()`

### Chat in a channel

The following tables show what changes were made in `SBUBaseChannelViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUBaseChannelViewController` in v3:

* `baseHeaderComponent`
* `baseListComponent`
* `baseInputComponent`
* `baseViewModel`

Depending on the channel type, the base components and base view model become channel-specific. The appropriate components and view model are then used in each `SBUGroupChannelViewController` and `SBUOpenChannelViewController`.

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|messageInputView|inputComponent.messageInputView|Input|
|userProfileView|listComponent.userProfileView|List|
|tableView|listComponent.tableView|List|
|emptyView|listComponent.emptyView|List|

</div>

#### Moved properties to view model

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|channelUrl|viewModel.channelUrl|
|inEditingMessage|viewModel.inEditingMessage|
|messageListParams|viewModel.messageListParams|
|messageList|viewModel.messageList|
|fullMessageList|viewModel.fullMessageList|

</div>

#### Moved methods to component

<div component="AdvancedTable" type="2B">

|Method|Component|
|---|---|
|setScrollBottomView(hidden:)|List|
|didSelectMessage(userId:)|List|
|didSelectClose()|List|
|didSelectRetry()|List|

</div>

#### Moved methods to component and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|sendImageFileMessage(info:)|pickImageFile(info:)|Input|
|sendVideoFileMessage(info:)|pickVideoFile(info:)|Input|
|sendDocumentFileMessage(documentUrls:)|pickDocumentFile(documentUrls:)|Input|

</div>

#### Moved methods to component's delegate and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|scrollToBottom(animated:)|baseChannelModuleDidTapScrollToButton(_:animated:)|List|
|setUserProfileTapGestureHandler(_:)|baseChannelModule(_:didTapUserProfile:)|List|
|messageInputView(_:didSelectSend:)|baseChannelModule(_:didTapSend:parentMessage:)|Input|
|messageInputView(_:didSelectResource:)|baseChannelModule(_:didTapResource:)|Input|
|messageInputView(_:didSelectEdit:)|baseChannelModule(_:didSelectEdit:)|Input|
|messageInputView(_:didChangeText:)|baseChannelModule(_:didChangeText:)|Input|
|messageInputView(_:willChangeMode:message:)|baseChannelModule(_:willChangeMode:message:)|Input|
|messageInputView(_:didChangeMode:message:)|baseChannelModule(_:didChangeMode:)|Input|
|messageInputViewDidStartTyping()|baseChannelModuleDidStartTyping(_:)|Input|
|messageInputViewDidEndTyping()|baseChannelModuleDidEndTyping(_:)|Input|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadChannel(channelUrl:messageListParams:)`
* `clearMessageList()`
* `upsertMessagesInList(messages:needUpdateNewMessage:needReload:)`
* `deleteMessagesInList(messageIds:excludeResendableMessages:needReload:)`
* `deleteResendableMessage(_:needReload:)`
* `deleteResendableMessages(requestIds:needReload:)`
* `sortAllMessageList(needReload:)`
* `updateUserMessage(message:text:)`
* `updateUserMessage(message:messageParams:)`
* `resendMessage(failedMessage:)`
* `sendUserMessage(text:)`
* `sendUserMessage(text:parentMessage:)`
* `sendUserMessage(messageParams:parentMessage:)`
* `sendFileMessage(fileData:fileName:mimeType:)`
* `sendFileMessage(fileData:fileName:mimeType:parentMessage:)`
* `sendFileMessage(messageParams:parentMessage:)`

#### Moved method to view model and changed name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|deleteMessagesInList(messageIds:needReload:)|deleteMessagesInList(messageIds:excludeResendableMessages:needReload:)|

</div>

#### Changed method names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|deleteMessage(message:)|showDeleteMessageMenu(message:)|
|setLoading(_:_:)|showLoading(_:)|

</div>

### Chat in a group channel

The following tables show what changes were made in `SBUChannelViewController` from v2 to v3.

#### Changed view controller name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|SBUChannelViewController|SBUGroupChannelViewController|

</div>

#### Added new components and view model

The following objects have been added to `SBUGroupChannelViewController` in v3:

* `headerComponent`
* `listComponent`
* `inputComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/chatting-in-a-channel/chat-in-group-channel#2-usage) section of the view controller page.

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|newMessageInfoView|listComponent.newMessageInfoView|List|
|channelStateBanner|listComponent.channelStateBanner|List|
|scrollBottomView|listComponent.scrollBottomView|List|
|adminMessageCell|listComponent.adminMessageCell|List|
|userMessageCell|listComponent.userMessageCell|List|
|fileMessageCell|listComponent.fileMessageCell|List|
|customMessageCell|listComponent.customMessageCell|List|
|unknownMessageCell|listComponent.unknownMessageCell|List|

</div>

#### Moved methods to component

<div component="AdvancedTable" type="2B">

|Method|Component|
|---|---|
|register(userMessageCell:nib:)|List|
|register(fileMessageCell:nib:)|List|
|register(adminMessageCell:nib:)|List|
|register(customMessageCell:nib:)|List|
|updateMessageInputModeState()|List|
|getMessageGroupingPosition(currentIndex:)|List|
|setScrollBottomView(hidden:)|List|
|generateCellIdentifier(by:)|List|

</div>

#### Moved methods to component and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|checkSameDayAsNextMessage(currentIndex:)|checkSameDayAsNextMessage(currentIndex:fullMessageList:)|List|
|setUserMessageCellGestures(_:userMessage:indexPath:)<br /><br />setFileMessageCellGestures(_:fileMessage:indexPath:)<br /><br />setUnknownMessageCellGestures(_:unknownMessage:indexPath:)|setMessageCellGestures(_:message:indexPath:)|List|

</div>

#### Moved methods to component's delegate and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|onClickScrollBottom(sender:)|baseChannelModuleDidTapScrollToButton(_:animated:)|List|
|setTapGestureHandler(_:message:)|channelModule(_:didTapMessage:forRowAt:)|List|
|setLongTapGestureHandler(_:message:indexPath:)|channelModule(_:didLongTapMessage:forRowAt:)|List|
|setEmojiTapGestureHandler(_:emojiKey:)|channelModule(_:didTapEmoji:messageCell:)|List|
|setEmojiLongTapGestureHandler(_:emojiKey:)|channelModule(_:didLongTapEmoji:messageCell:)|List|
|messageInputViewDidEndTyping()|baseChannelModuleDidEndTyping(_:)|Input|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `channel(_:didReceive:)`
* `channel(_:didUpdate:)`
* `channel(_:messageWasDeleted:)`
* `didSucceedReconnection()`

#### Moved methods to view model's delegate and changed names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|channelWasChanged(_:)<br /><br />channelWasFrozen(_:)<br /><br />channelWasUnfrozen(_:)<br /><br />channel(_:userWasMuted:)<br /><br />channel(_:userWasUnmuted:)<br /><br />channelDidUpdateOperators(_:)<br /><br />channel(_:userWasBanned:)<br /><br />channel(_:userDidEnter:)<br /><br />channel(_:userDidExit:)<br /><br />channelWasDeleted(_:channelType:)|baseChannelViewModel(_:didChangeChannel:withContext:)|

</div>

#### Changed method names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|onClickSetting()|showChannelSettings()|
|setLoading(_:_:)|showLoading(_:)|

</div>

### Chat in an open channel

The following tables show what changes were made in `SBUOpenChannelViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUOpenChannelViewController` in v3:

* `headerComponent`
* `listComponent`
* `inputComponent`
* `mediaComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/chatting-in-a-channel/chat-in-open-channel#2-usage) section of the view controller page.

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|channelInfoView|listComponent.channelInfoView|Header|
|mediaView|mediaComponent.mediaView|Media|
|newMessageInfoView|listComponent.newMessageInfoView|List|
|channelStateBanner|listComponent.channelStateBanner|List|
|adminMessageCell|listComponent.adminMessageCell|List|
|userMessageCell|listComponent.userMessageCell|List|
|fileMessageCell|listComponent.fileMessageCell|List|
|customMessageCell|listComponent.customMessageCell|List|
|unknownMessageCell|listComponent.unknownMessageCell|List|

</div>

#### Moved methods to component

<div component="AdvancedTable" type="2B">

|Method|Component|
|---|---|
|register(userMessageCell:nib:)|List|
|register(fileMessageCell:nib:)|List|
|register(adminMessageCell:nib:)|List|
|register(customMessageCell:nib:)|List|
|updateMessageInputModeState()|List|
|getMessageGroupingPosition(currentIndex:)|List|
|setScrollBottomView(hidden:)|List|
|generateCellIdentifier(by:)|List|

</div>

#### Moved methods to component and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|checkSameDayAsNextMessage(currentIndex:)|checkSameDayAsNextMessage(currentIndex:fullMessageList:)|List|
|setUserMessageCellGestures(_:userMessage:indexPath:)<br /><br />setFileMessageCellGestures(_:fileMessage:indexPath:)<br /><br />setUnknownMessageCellGestures(_:unknownMessage:indexPath:)|setMessageCellGestures(_:message:indexPath:)|List|

</div>

#### Moved methods to component's delegate and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|onClickScrollBottom(sender:)|baseChannelModuleDidTapScrollToButton(_:animated:)|List|
|setTapGestureHandler(_:message:)|channelModule(_:didTapMessage:forRowAt:)|List|
|setLongTapGestureHandler(_:message:indexPath:)|channelModule(_:didLongTapMessage:forRowAt:)|List|
|onClickParticipantsList()|openChannelModuleDidTapParticipantList(_:)|Header|
|didSelectChannelInfo()|channelModule(_:didTapRightItem:)|Header|
|didSelectChannelParticipants()|    openChannelModuleDidTapParticipantList(_:)|Header|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadChannel(channelUrl:messageListParams:)`
* `updateMessagesInList(messages:needReload:)`
* `channel(_:didUpdate:)`
* `channel(_:messageWasDeleted:)`
* `didSucceedReconnection()`

#### Moved methods to view model's delegate and changed names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|channelWasChanged(_:)<br /><br />channelWasFrozen(_:)<br /><br />channelWasUnfrozen(_:)<br /><br />channel(_:userWasMuted:)<br /><br />channel(_:userWasUnmuted:)<br /><br />channelDidUpdateOperators(_:)<br /><br />channel(_:userWasBanned:)<br /><br />channel(_:userDidEnter:)<br /><br />channel(_:userDidExit:)<br /><br />channelWasDeleted(_:channelType:)|baseChannelViewModel(_:didChangeChannel:withContext:)|

</div>

#### Changed method names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|deleteMessage(message:)|showDeleteMessageMenu(message:)|
|onClickSetting()|showChannelSettings()|
|setLoading(_:_:)|showLoading(_:)|

</div>

### Create a group channel

The following tables show what changes were made in `SBUCreateChannelViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUCreateChannelViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/creating-a-channel/create-group-channel#2-usage) section of the view controller page.

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|emptyView|listComponent.emptyView|List|
|tableView|listComponent.tableView|List|
|userCell|listComponent.userCell|List|

</div>

#### Moved property to view model

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|userListQuery|viewModel.userListQuery|

</div>

#### Moved methods to component

<div component="AdvancedTable" type="2B">

|Method|Component|
|---|---|
|register(userCell:nib:)|List|
|didSelectRetry()|List|

</div>

#### Moved methods to component and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|reloadData()<br /><br />reloadUserList()|listComponent.reloadTableView()|List|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadNextUserList(reset:users:)`
* `createChannel(userIds:)`
* `createChannel(params:messageListParams:)`
* `selectUser(user:)`

#### Moved method to view model's data source and changed name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|nextUserList()|createChannelViewModel(_:nextUserListForChannelType:)|

</div>

#### Changed method names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|showLoading(state:)|showLoading(_:)|
|onClickCreate()|reateChannelWithSelectedUsers()|

</div>

### Invite users or promote members to operator

In v3, the `SBUInviteUserViewController` class has separated into `SBUInviteUserViewController` and `SBUPromoteMemberViewController` and `SBUBaseSelectUserViewController` was added to include shared properties and methods between the two features. The following tables show what changes were made in `SBUInviteUserViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUInviteUserViewController` and `SBUPromoteMemberViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/invite-users-or-promote-to-operator#2-usage) section of the view controller page.

#### Divided SBUInviteUserViewController class

<div component="AdvancedTable" type="2B">

|Invite users|Promote users|
|---|---|
|SBUInviteUserViewController|SBUPromoteMemberViewController|

</div>

#### Removed types in initializers

After the view controller class got separated into two view controllers, the `type` parameter has been removed from the initializers.

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|init(channel:type:)|init(channel:)|
|init(channel:users:type:)|init(channel:users:)|
|init(channelUrl:type:)|init(channelUrl:)|
|init(channelUrl:users:type:)|init(channelUrl:users:)|

</div>

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|tableView|listComponent.tableView|List|
|userCell|listComponent.userCell|List|

</div>

#### Moved properties to view model

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|inviteListType|viewModel.inviteListType|
|joinedUserIds|viewModel.joinedUserIds|
|userListQuery|viewModel.userListQuery|
|memberListQuery|viewModel.memberListQuery|

</div>

#### Moved method to component

<div component="AdvancedTable" type="2B">

|Method|Component|
|---|---|
|register(userCell:nib:)|List|

</div>

#### Moved method to component and changed name

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|reloadData()|listComponent.reloadTableView()|List|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadChannel(channelUrl:)`
* `loadNextUserList(reset:users:)`
* `inviteUsers(userIds:)`
* `promoteToOperators(memberIds:)`
* `resetUserList()`
* `selectUser(user:)`

#### Changed method names

<div component="AdvancedTable" type="3B">

|v2|v3|Class|
|---|---|---|
|inviteUsers()|inviteSelectedUsers()|SBUInviteUserViewController|
|promoteToOperators()|promoteSelectedMembers()|SBUPromoteMemberViewController|
|onClickInviteOrPromote()|inviteSelectedUsers()<br /><br />promoteSelectedMembers()|SBUInviteUserViewController<br /><br />SBUPromoteMemberViewController|

</div>

### List channel members or participants

The following tables show what changes were made in `SBUMemberListViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUMemberListViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/list-channel-members-or-participants) section of the view controller page.

#### Changed initializers

The `type` parameter name has been changed to `memberListType`.

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|init(channel:type:)|init(channel:memberListType:)|
|init(channel:members:type:)|init(channel:members:memberListType:)|
|init(channelUrl:type:)|init(channelUrl:channelType:memberListType:)|
|init(channelUrl:members:type:)|init(channelUrl:channelType:members:memberListType:)|

</div>

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|emptyView|listComponent.emptyView|List|
|tableView|listComponent.tableView|List|
|userCell|listComponent.userCell|List|

</div>

#### Moved list query properties to view model

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|memberListQuery|viewModel.memberListQuery|
|operatorListQuery|viewModel.operatorListQuery|
|mutedMemberListQuery|viewModel.mutedMemberListQuery|
|bannedMemberListQuery|viewModel.bannedMemberListQuery|
|participantListQuery|viewModel.participantListQuery|

</div>

#### Moved methods to component

<div component="AdvancedTable" type="2B">

|Method|Component|
|---|---|
|register(userCell:nib:)|List|
|didSelectRetry()|List|

</div>

#### Moved methods to component and changed names

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|reloadData()|listComponent.reloadTableView()|List|
|setMoreMenuActionHandler(_:)|setMoreMenuTapAction(_:)|List|
|setUserProfileTapGestureHandler(_:)|setUserProfileTapAction(_:)|List|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadNextMemberList(reset:members:)`
* `promoteToOperator(member:)`
* `dismissOperator(member:)`
* `mute(member:)`
* `unmute(member:)`
* `ban(member:)`
* `unban(member:)`
* `resetMemberList()`
* `channelDidUpdateOperators(_:)`
* `channel(_:userDidJoin:)`
* `channel(_:userDidLeave:)`
* `channel(_:userDidExit:)`
* `channel(_:userDidEnter:)`

#### Moved methods to view model and change names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|loadChannel(channelUrl:)|loadChannel(channelUrl:type:)|
|loadMembers()|loadNextMemberList(reset:)|
|reloadMemberList()|resetMemberList()|

</div>

#### Moved method to view model's data source

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|nextMemberList()|memberListViewModel(_:nextMemberListForChannel:)|

</div>

#### Changed method name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|onClickInviteUser()|showInviteUser()|

</div>

### Configure channel settings

The following tables show what changes were made in `SBUBaseChannelSettingViewController` from v2 to v3.

#### Changed view controller name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|SBUBaseChannelSettingViewController|SBUBaseChannelSettingsViewController|

</div>

#### Added new components and view model

The following objects have been added to `SBUBaseChannelSettingsViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|tableView|listComponent.tableView|List|
|userInfoView|listComponent.userInfoView|List|

</div>

#### Moved property to view model

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|isOperator|viewModel.isOperator|

</div>

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadChannel(channelUrl:)`
* `updateChannel(channelName:coverImage:)`
* `channel(_:userDidEnter:)`
* `channel(_:userDidExit:)`
* `channel(_:userDidJoin:)`
* `channel(_:userDidLeave:)`

#### Changed method name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|onClickEdit()|showChannelEditActionSheet()|

</div>

### Configure group channel settings

The following tables show what changes were made in `SBUChannelSettingsViewController` from v2 to v3.

#### Changed view controller name

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|SBUChannelSettingsViewController|SBUGroupChannelSettingsViewController|

</div>

#### Added new components and view model

The following objects have been added to `SBUGroupChannelSettingsViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/configuring-channel-settings/configure-group-channel-settings#2-usage) section of the view controller page.

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadChannel(channelUrl:)`
* `updateChannel(channelName:coverImage:)`
* `updateChannel(params:)`
* `changeNotification(isOn:)`
* `leaveChannel()`

#### Changed method names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|onClickEdit()|showChannelEditActionSheet()|
|updateChannelInfo(channelName:)|updateChannel(channelName:coverImage:)|

</div>

### Configure open channel settings

The following lists show what changes were made in `SBUOpenChannelSettingsViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUOpenChannelSettingsViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/configuring-channel-settings/configure-open-channel-settings) section of the view controller page.

#### Moved methods to view model

The following methods have been moved to the view model in v3:

* `loadChannel(channelUrl:)`
* `updateChannel(channelName:coverImage:)`
* `updateChannel(params:)`
* `deleteChannel()`

### Moderate channels and members

The following tables show what changes were made in `SBUModerationsViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUModerationsViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/moderate-channels-and-members#2-usage) section of the view controller page.

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|titleView|headerComponent.titleView|Header|
|leftBarButton|headerComponent.leftBarButton|Header|
|rightBarButton|headerComponent.rightBarButton|Header|
|tableView|listComponent.tableView|List|

</div>

#### Moved method to view model

The following method has been moved to the view model in v3:

* `loadChannel(channelUrl:)`

#### Moved methods to view model and changed names

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|freezeChannel(completionHandler:)|freezeChannel(_:)|
|unfreezeChannel(completionHandler:)|unfreezeChannel(_:)|

</div>

### Search messages

The following tables show what changes were made in `SBUMessageSearchViewController` from v2 to v3.

#### Added new components and view model

The following objects have been added to `SBUMessageSearchViewController` in v3:

* `headerComponent`
* `listComponent`
* `viewModel`

To learn more, go to the [Usage](https://sendbird.com/docs/uikit/v3/ios/key-functions/search-messages#2-usage) section of the view controller page.

#### Moved view properties to component

<div component="AdvancedTable" type="3B">

|v2|v3|Component|
|---|---|---|
|searchBar|headerComponent.titleView|Header|
|emptyView|listComponent.emptyView|List|
|tableView|listComponent.tableView|List|

</div>

#### Moved properties to view model

<div component="AdvancedTable" type="2B">

|v2|v3|
|---|---|
|channel|viewModel.channel|
|messageListParams|viewModel.messageListParams|
|messageSearchResultCell|viewModel.messageSearchResultCell|

</div>

#### Moved methods to component

|Method|Component|
|---|---|
|updateSearchBarStyle(with:)|Header|
|register(messageSearchResultCell:nib:)|List|

</div>

#### Moved method to view model

The following method has been moved to the view model in v3:

* `message(at:)`
