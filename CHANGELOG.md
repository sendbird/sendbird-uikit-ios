# Changelog

### v3.16.0 (Feb 08, 2024)

- Replaced the `SuggestedReplies` and `Form` interfaces with the ChatSDK model-based
    - Added Interfaces
        - Added `groupChannelModule(_:form:messageCell:)` in `SBUGroupChannelModuleListDelegate`
        - Added `formFieldView(_:SBUFormFieldView,didUpdate:SendbirdChatSDK.FormField)` in `SBUFormFieldViewDelegate`
        - Added `formField` property in `SBUFormFieldView`
        - Added `configure(form:field:delegate:)` in `SBUFormFieldView`
        - Added `SBUFormFieldInputType` interface
        - Added `formView(_:SBUFormView, didSubmit: SendbirdChatSDK.Form)` in `SBUFormViewDelegate`
        - Added `groupChannelModule(_:didSubmit:messageCell:)` in `SBUGroupChannelModuleListDelegate`
        - Added `formFieldView(_:formField:)` in `SBUFormFieldViewDelegate`
        - Added `formField` property in `SBUFormFieldView`
        - Added `configure(form:field:delegate:)` in `SBUFormFieldView`
        - Added `groupChannelModule(_:didSubmit:messageCell:)` in `SBUGroupChannelViewController`
        - Added `submitForm(message:form:)` in `SBUGroupChannelViewModel`
        - Replaced `form` property type in `SBUFormView`
        - Replaced `createFormFieldViews(with:)` interface type in `SBUFormView`
        - Replaced `formFieldView(_:didUpdate:)` in `SBUFormView`
        - Replaced `form` property type in `SBUFormViewParams`
    - Removed SBUForm Interfaces
        - Removed `asForms` in `BaseMessage` class
        - Removed `SBUForm` interface
        - Removed `SBUForm.Answer` interface 
        - Removed `SBUForm.Field` interface
        - Removed `SBUForm.Field.Updated` interface
        - Remvoed `forms` property in `SBUExtendedMessagePayload`
        - Removed `formAnswers` property in SBUUserMessageCellParams
        - Removed `updateFormView(with:,answers:)` function in `SBUUserMessageCell`
        - Removed `formView(_:SBUFormView, didSubmit: SBUForm.Answer)` in `SBUFormViewDelegate`
        - Removed `formView(_:SBUFormView, didUpdate: SBUForm.Answer)` in `SBUFormViewDelegate`
        - Removed `formFieldView(_:SBUFormFieldView,didUpdate: SBUForm.Field.Updated)` in `SBUFormFieldViewDelegate`
        - Removed `init(messageId: Int64, form: SBUForm)` in `SBUFormViewParams`
        - Removed `answer` property in `SBUFormView`
        - Removed `createFormFieldViews(with: SBUForm?)` function in `SBUFormView`
        - Removed `formFieldView(_:SBUFormFieldView,didUpdate:SBUForm.Field.Updated)` in `SBUFormView`
        - Removed `configure(form:field:value:delegate:)` in `SBUFormFieldView`
        - Removed `groupChannelModule(_:didSubmit:messageCell:)` in `SBUGroupChannelModuleListDelegate`
        - Removed `groupChannelModule(_:didUpdate:messageCell:)` in `SBUGroupChannelModuleListDelegate`
        - Removed `groupChannelModule(_:didSubmit:messageCell:)` in `SBUGroupChannelViewController`
        - Removed `groupChannelModule(_:didUpdate:messageCell:)` in `SBUGroupChannelViewController`
        - Removed `groupChannelModule(_:answersFor:) -> [SBUForm.Answer]?` in `SBUGroupChannelViewController`
        - Removed `SBUFormFieldView.StatusType` interface
        - Removed `submitForm(message:answer:)` in `SBUGroupChannelViewModel`
        - Removed `updateForm(message:answer:)` in `SBUGroupChannelViewModel`
        - Removed `groupChannelModule(_:answersFor:)` in `SBUGroupChannelModuleListDataSource`
    - Deprecated `asSuggestedReplies` in `BaseMessage`, use `BaseMessage.suggestedReplies`
- Fixed voice message preview string in the channel list not working issue
- Deprecated `getFileTypeString(by:)` function of `SBUUtils` class: renamed to `getFileTypePreviewString(by:)`
- Added disable chat input based on last message response
- Added `SBULoadingDatasource` for customizing touch events in the loading view

### v3.15.0 (Feb 01, 2024)

- Fixed a bug where duplicated deleted messages in the response of the message changeglogs cause a crash
- Limited the maximum corner radius of the category filter to half of the height

- Added `isFeedbackEnabled` config property for `SBUConfig.GroupChannel`
- Added `SBUToastView`

- Added `Feedback` feature
    - Added `SBUFeedbackAnswer` for handling internal data
    - Added `groupChannelModule(_ listComponent:didUpdate:messageCell:)` in `SBUGroupChannelModuleListDelegate`
    - Added `SBUFeedbackViewDelegate`
    - Added `SBUFeedbackView` and `SBUSimpleFeedbackView`
    - Added `SBUFeedbackViewParams`
    - Added `shouldHideFeedback` in `SBUBaseMessageCellParams`
    - Added `updateFeedbackView(with:)` method in `SBUBaseMessageCell`
    - Added `shouldHideFeedback` and `feedbackView` properties in `SBUBaseMessageCell`
    - Added `feedbackView(_ view:didAnswer:)` delegate method in `SBUBaseMessageCell`
    - Added `groupChannelModule(_ listComponent:didUpdate:messageCell:)` in `SBUBaseChannelViewController`
    - Added feedback handling methods in `SBUGroupChannelViewModel`
        - Added `submitFeedback(message:answer:completionHandler:)`
        - Added `updateFeedback(message:answer:completionHandler:)` 
        - Added `deleteFeedback(message:completionHandler:)`

- Updated theme values in `SBUMessageCellTheme`
    - Added `feedbackRadius`
    - Added `feedbackIconColor`
    - Added `feedbackIconSelectColor`
    - Added `feedbackIconDeselectColor`
    - Added `feedbackBorderColor`
    - Added `feedbackBorderSelectColor`
    - Added `feedbackBorderDeselectColor`
    - Added `feedbackBackgroundNormalColor`
    - Added `feedbackBackgroundSelectColor`
    - Added `feedbackBackgroundDeselectColor`

- Updated theme values in `SBUComponentTheme`
        - Added `toastContainerColor`
        - Added `toastTitleColor`
        - Added `feedbackToastUpdateDoneColor`

- Updated StringSet values in `SBUMessageCellTheme`
    - Added `Feedback_Comment_Title`
    - Added `Feedback_Comment_Placeholder`
    - Added `Feedback_Edit_Comment`
    - Added `Feedback_Remove`
    - Added `Feedback_Update_Done`

- Updated icons in `SBUIconSet`
    - Added `iconGood`
    - Added `iconBad`
### v3.14.0 (Jan 19, 2024)

- Initialization improving
  - Added `initialize(applicationId:initParamsBuilder:startHandler:migrationHandler:completionHandler:)` function of `SendbirdUI`class
  - For more information on the improved initialization, see [this link](https://github.com/sendbird/sendbird-uikit-ios/discussions/86)
- Fixed link image loading bug
- Remove time view from `SBUTypingIndicatorMessageCell` class
- Improving the image loading process
- Add `errorHandler(error:message:)` optional function in `SBUExtendedMessagePayloadCustomViewFactory` protocol
- Supported remote notifications on iOS 16 or later simulators

### v3.13.1 (Jan 05, 2024)

- Added functionality to log impressions for notifications
- Fixed file downloads not working issue


### v3.13.0 (Dec 13, 2023)

- Added `SBUScrollPostionConfiguration` configuration class
   - Added `scrollPostionConfiguration` peroperty in `SBUGlobals`

- Added `SBUScrollOptions` model
- Added `SBUScrollOptions.Result` model
- Added `SBUScrollPosition` enum

- Added and modified methods in `SBUBaseChannelModule.List` class
   - Modified `position` parameter in `scrollToMessage(id:enablesScrollAnimation:enablesMessageAnimation:position:)`
   - Added `scrollToMessage(message:enablesScrollAnimation:enablesMessageAnimation:position)`

- Added and modified methods in `SBUBaseChannelViewController` class
   - Modified `position` parameter in `scrollToMessage(id:enablesScrollAnimation:enablesMessageAnimation:position:)`
   - Added `scrollToMessage(message:enablesScrollAnimation:enablesMessageAnimation:position)`

- Fixed message menu sheet not showing when emojiList is empty

### v3.12.0 (Nov 29, 2023)

#### Typing Indicator Bubble
* We are now supporting a new type of a typing indicator, the **Typing Indicator Bubble**. 
* Enabling Typing Indicator Bubble shows an animated typing bubble when another member(s) in a Group Channel is/are typing. 
* You can use this feature by enabling `SendbirdUI.config.groupChannel.channel.isTypingIndicatorEnabled` to `true`, then setting `SendbirdUI.config.groupChannel.channel.typingIndicatorTypes` to `[.bubble]`.

* New enum
    * `public enum SBUTypingIndicatorType`

* New classes / structs
    * `public class SBUTypingIndicatorMessageManager`
    * `public struct SBUTypingIndicatorInfo`
    * `public class SBUTypingIndicatorMessage`
    * `public class SBUTypingIndicatorMessageCellParams`
    * `open class SBUTypingIndicatorMessageCell`
    * `public class SBUTypingIndicatorBubbleView`

* New properties
    * `public var typingIndicatorTypes: Set<SBUTypingIndicatorType>`  in `SBUConfig.GroupChannel.Channel`
    * `public var typingMessageManager` in `SBUBaseChannelViewModel`
    * `public private(set) var typingIndicatorMessageCell` in `SBUGroupChannelModule.List`
    * `public static var Message_Typers_Count` in `SBUStringSet`
    * `public lazy var profilesStackView` in `SBUContentBaseMessageCell`
    * `public lazy var numberLabel` in `SBUMessageProfileView`

* New methods 
    * `open func register(typingIndicatorMessageCell: SBUBaseMessageCell, nib: UINib? = nil)` in `SBUGroupChannelModule.List`
    * `public func configureMessageProfileViews(message:)` in `SBUContentBaseMessageCell`
    * `open func configureTyperProfileViews(typingInfo:)` in `SBUContentBaseMessageCell`
    * `open func configureUserProfileView(message:)` in `SBUContentBaseMessageCell`
    * `public func configureTyperProfileImageView()` in `SBUMessageProfileView`
    * `public func configureNumberLabel(_:)`

* New theme properties
    * `public var typingMessageProfileBorderColor: UIColor` in `SBUTheme`
    * `public var typingMessageDotColor: UIColor` in `SBUTheme`
    * `public var typingMessageDotTransformColor: UIColor` in `SBUTheme`

### v3.11.2 (Nov 24, 2023)

- Fixed navigationBar looking weird after entering message search function
  - Added `needRollbackNavigationBarSetting` property in `SBUBaseViewController`
- Applied UIKit configuration to LimitedPhotoLibraryPicker

### v3.11.1 (Nov 15, 2023)

- Improved stability

### v3.11.0 (Nov 03, 2023)

- Support **Suggested Replies** feature for user message
    - Added `SBUSuggestedReplyView` class
    - Added `SBUVerticalSuggestedReplyView` class
    - Added `SBUSuggestedReplyViewDelegate` delegate
    - Added `SBUSuggestedReplyViewParams` struct
    - Added `SBUSuggestedReplyOptionView` class
    - Added `SBUSimpleSuggestedReplyOptionView` class
    - Added `SBUSuggestedReplyOptionViewDelegate` delegate
- Support **Form Type Message** feature for user message
    - Added `SBUForm` struct
    - Added `SBUForm.Field` struct
    - Added `SBUForm.Field.InputTypeValue` enum
    - Added `SBUForm.Answer` struct
    - Added `SBUFormViewParams` struct
    - Added `SBUFormView` class
    - Added `SBUSimpleFormView` class
    - Added `SBUFormViewDelegate` protocol
    - Added `SBUFormFieldView` class
    - Added `SBUFormFieldView.StatusType` enum
    - Added `SBUSimpleFormFieldView` class
    - Added `SBUFormFieldViewDelegate` protocol
    - Added `useOnlyFromView` property in `SBUBaseMessageCellParams`
- Support **ExtendedMessagePayload CustomView** feature for user message
    - Added `SBUExtendedMessagePayloadCustomViewFactory` protocol
    - Added `SBUExtendedMessagePayloadCustomViewFactoryInternal` protocol
- Support common for new features
    - Added properties and methods in `SBUUserMessageCell`
        - `shouldHideSuggestedReplies` property
        - `suggestedReplyView` property
        - `shouldHideFormTypeMessage` property
        - `formViews` property
        - `extendedMessagePayloadCustomViewFactory` property
        - `updateSuggestedReplyView(with:)` method
        - `createSuggestedReplyView()` method
        - `updateFormView(with:answers:)` method
        - `createFormView()` method
        - `suggestedReplyView(_:didSelectOption:)` delegate method
        - `func formView(_:didSubmit:)` delegate method
        - `func formView(_:didUpdate:)` delegate method
    - Added properties in `SBUUserMessageCellParams`
        - `shouldHideSuggestedReplies` property
        - `shouldHideFormTypeMessage` property
        - `formAnswers` property
    - Added handlers in `SBUBaseMessageCell`
        - `suggestedReplySelectHandler` handler
        - `submitFormAnswerHandler` handler
        - `updateFormAnswerHandler` handler
    - Added `mainContainerVStackView` proeprty in `SBUContentBaseMessageCell`
    - Added `SBUConfig.GroupChannel` configs
        - `isFormTypeMessageEnabled` property
        - `isSuggestedRepliesEnabled` property
    - Added extension methods and properties in `BaseMessage`. 
        - `asSuggestedReplies` property
        - `asForms` property
        - `asCustomView` property
        - `decodeCustomViewData<ViewData: Decodable>()` method
    - Added methods in `SBUGroupChannelModuleListDelegate`
        - `groupChannelModule(_:didSelect:)` method
        - `groupChannelModule(_:didSubmit:messageCell:)` method
        - `groupChannelModule(_:didUpdate:messageCell:)` method
        - `groupChannelModule(_:answersFor:)` method
    - Added delegate methods in `SBUGroupChannelViewController`
        - `groupChannelModule(_:didSelect:)` method
        - `groupChannelModule(_:didSubmit:messageCell:)` method
        - `groupChannelModule(_:didUpdate:messageCell:)` method
        - `groupChannelModule(_:answersFor:)` method
    - Added methods in `SBUGroupChannelViewModel`
        - `submitForm(message:answer:)` method
        - `updateForm(message:answer:)` method
- Support actions on userList item of `SBUReactionsViewController`.        
    - Added `showUserProfile(user:)` method in `SBUBaseChannelViewController` class
    - Added `setUserProfileTapGesture(_:)` method in `SBUReactionsViewController` class
    - Added `SBUReactionsViewControllerDelegate` delegate
    - Added delegate methods in `SBUGroupChannelViewController` and `SBUMessageThreadViewController` classes
      - `reactionsViewController(_:didTapUserProfile:)`
      - `reactionsViewController(_:tableView:didSelect:forRowAt:)`

### v3.10.0 (Oct 24, 2023)

#### Multiple Files Message
  * We are now supporting **Multiple Files Message** feature!
  * You can select **multiple images and videos** in the message inputs, and send **multiple images** in a single message.
  * You can learn more about the feature in our [Multiple Files Message docs page](https://sendbird.com/docs/chat/uikit/v3/ios/features/file-sharing#2-group-channel-3-multiple-file-message).
* Added classes, structs, and enum
    * `SBUCollectionViewCell` class
    * `SBUMultipleFilesMessageCellParams` class
    * `SBUMultipleFilesMessageCell` class
    * `SBUMultipleFilesMessageCollectionView` class
    * `SBUMultipleFilesMessageCollectionViewCell` class
    * `GroupChannel.Preview` struct in `SBUStringSet` class
    * `FileUpload.Error` struct in `SBUStringSet` class
    * `SBUFileType` enum
* Added methods
    * `getFileTypeString(by:)` in `SBUUtils` class
    * `openFile(_:)` in `SBUBaseChannelViewController` class
    * `multipleFilesMessageFileSizeErrorHandler(_:)` in `SBUGroupChannelViewController` class
    * `sendMultipleFilesMessageCompletionHandler` in `SBUGroupChannelViewController` class 
    * `sendMultipleFilesMessage(fileInfoList:)` in `SBUGroupChannelViewModel` class
    * `updateMultipleFilesMessageCell(requestId:index:)` in `SBUGroupChannelViewModel` class
    * `pickMultipleImageFiles(itemProviders:)` in `SBUGroupChannelModule.Input` class (>= iOS14.0)
    * `register(multipleFilesMessageCell:nib:)` in `SBUGroupChannelModule.List` class
    * `onSelectFile(sender:)` in `SBUParentMessageInfoView` class
    * `register(multipleFilesMessageCell:nib:) in `SBUMessageThreadMoudle.List` class
    * `messageThreadModule(_:didSelectFileAt:multipleFilesMessageCell:forRowAt) in `SBUMessageThreadMoudle.List` class
    * `save(fileData:viewController:) in `SBUDownloadManager` class
    * `save(fileMessage:parent:) in `SBUDownloadManager` class
* Added properties
    * `filesCount` in `MultipleFilesMessage` class extension
    * `multipleFilesMessageFileCountLimit` in `SBUAvailable` class
    * `uploadSizeLimitBytes` in `SBUAvailable` class
    * `uploadSizeLimitMB` in `SBUAvailable` class
    * `isMultipleFilesMessageEnabled` in `SBUConfig.GroupChannel.Channel` class
    * `multipleFilesMessageParamsSendBuilder` in `SBUGlobalCustomParams` class
    * `showPhotoLibraryPicker` in `SBUGroupChannelViewController` class
    * `multipleFilesMessageCell` in `SBUGroupChannelModule.List` class
    * `isMultipleFilesMessage` in `SBUQuoteMessageInputViewParams` class
    * `fileCollectionView` in `SBUParentMessageInfoView` class
    * `fileSelectHandler` in `SBUParentMessageInfoView` class
    * `onSelectFile(sender:)` in `SBUParentMessageInfoView` class
    * `multipleFilesMessageCell` in `SBUMessageThreadMoudle.List` class
* Added delegate methods
    * `groupChannelModule(_:didPickMultipleFiles:parentMessage:)` in `SBUGroupChannelModuleInputDelegate`
    * `groupChannelModule(_:didSelectFileAt:multipleFilesMessageCell:forRowAt:)` in `SBUGroupChannelModuleListDelegate`
    
#### Common
* Fixed autolayout warnings that occur during runtime and cleaned up the entire autolayout-related logic
  * Added `sbu_activate(baseView:constraints:)` function on `NSLayoutConstraint` class extension
  * Added `Constants` struct on `SBUParentMessageInfoView` class
  * Added `updateMessageTextWidth(with:)` function on `SBUParentMessageInfoView` class
* Fixed layout issue with message time labels appearing oversized horizontally
* Fixed incorrect date separator padding size
* Modified condition to check user's `isActive` property when filtering mentionable users

### v3.9.3 (Oct 12, 2023)

- Supported enlarged font size on dateLabel of group channel list and message cell
- Added a `inputVStackView` that wraps the `messageInputView` at `SBUBaseChannelModule.Input`
- Improved stability

### v3.9.2 (Oct 06, 2023)

- Fixed an issue where deleting a message didn't work
- Fixed a problem with truncated reaction counts
- Improved stability

### v3.9.1 (Sep 25, 2023)

- Improved image cache stability
- Improved unavailable message display condition check logic
- Improved reactions related logic stability
- Modified menu item action and menu sheet dismiss timing

### v3.9.0 (Sep 14, 2023)

- Added `scrollToMessage(id:enablesScrollAnimation:enablesMessageAnimation:)` to `SBUBaseChannelModule.List` and `SBUBaseChannelViewController` 
- Supports category filtering in a feed channel. Categories by which messages can be filtered can be created and edited in the dashboard

### v3.8.0 (Sep 1, 2023)

* Improved timing of `markAsRead` calls
* Fixed an issue where pending messages were not processed when changing channels in the same view controller
* Fixed text view height not resetting on state change
* Fixed an issue when using customized userList where the first list would continue to be added after the last was loaded
* Added chatbot start interface `startChatWithAIBot(id:distinct:errorHandler:)` in `SendbirdUI`
  ```swift
  // Before using it, need to call app initialize and connect.
  SendbirdUI.startChatWithAIBot(botId: "BOT_ID_GOES_HERE", isDistinct: true) { error in
      // This code block will be invoked when there's an error
  }
  ```
* Improved stability

### v3.8.0-beta.1 (Aug 24, 2023)
* Removed beta information on `CFBundleShortVersionString`

### v3.8.0-beta (Aug 18, 2023) with Chat SDK **v4.10.0**
* Change the default authentication method for FeedChannel from WebSocket connection to API.
* Added `authenticatedFeed(completionHandler:)` in `SendbirdUI`
* Improved stability

### v3.6.2 (Jul 14, 2023) with Chat SDK **v4.9.5**
* Changed file cache key policy.
* Improved the issue of exposing empty images when message status updating from pending to succeed.
* Fixed infinite getChannel request issue when initializing `SBUGroupChannelViewController` with invalid `channelURL`
* Applied thread message policy for pending or failed state
* Modified sample rate and bit rate in recorder settings
    * sample rate: 11025
    * bit rate: 12000
* Improved stability

### v3.6.1 (Jun 26, 2023)
* Improved stability of file cache logic

### v3.6.0 (Jun 22, 2023) with Chat SDK **v4.9.2**
* Support metatype interfaces in `SBUModuleSet`
    * Added the new public static properties corresponding to the previous in `SBUModuleSet`
    * Added the new public static properties corresponding to the previous in each SBU module classes.
    * Deprecated all of the previous public static properties in `SBUModuleSet`
    * Deprecated all of the previous public static properties in each SBU module classes.
    ```swift
    SBUModuleSet.GroupChannelListModule = CustomModule.self // Metatype Type
    SBUModuleSet.GroupChannelListModule.HeaderComponent = CustomComponent.self // Metatype Type
    ```
* Support **feature configuration**
    * Added `SBUConfig` class
    * Added `config` property in `SendbirdUI` class
    * Added `SBUPrioritizedConfig` propertyWrapper
    * Applied decoder on `SBUReplyType`, `SBUThreadReplySelectType` enum
    * Deprecated
        * `replyType`, `threadReplySelectType` property in `SBUReplyType` class
        * `init(type:threadReplySelectType:)` method in `SBUReplyType` class
        * `isVoiceMessageEnabled` property in `SBUVoiceMessageConfiguration` class
        * `isChannelListTypingIndicatorEnabled` property in `SBUGlobals` class
        * `isChannelListMessageReceiptStateEnabled` property in `SBUGlobals` class
        * `isOpenChannelUserProfileEnabled` property in `SBUGlobals` class
        * `isUserMentionEnabled` property in `SBUGlobals` class
        * `isVoiceMessageEnabled` property in `SBUGlobals` class
* Fixed a problem that tintcolor is not applied properly in `SBUEmptyView` class
* Fixed an issue of changing 'AVAudioSession' before using the player.

### v3.5.9 (Jun 15, 2023) with Chat SDK **v4.9.1**
* Improved stability 

### v3.5.8 (May 26, 2023) with Chat SDK **v4.8.5**
* Improved stability 

### v3.5.7 (May 16, 2023) with Chat SDK **v4.8.3**
* Added `notifications` property in `SBUFontSet.FontFamily` class
  * This property is for the Notification feature
* Added statistics for the action of notification
* Improved stability 

### v3.5.6 (Apr 26, 2023) with Chat SDK **v4.6.7** 
* Update iOS deployment target to 11.0 for Xcode 14.1+
* Modified access level to the public of `SBUChannelTitleView` class and properties.
* Improved pending message update logic in thread message list

### v3.5.5 (Apr 19, 2023)
* Improved stability

### v3.5.4 (Apr 14, 2023) with Chat SDK **v4.6.6**
* Separated `quotedMessageBackgroundColor` as `quotedMessageLeftBackgroundColor` and `quotedMessageRightBackgroundColor` in `SBUMessageCellTheme`
  * Deprecated `quotedMessageBackgroundColor` in `SBUMessageCellTheme`
  * Added `quotedMessageLeftBackgroundColor` and `quotedMessageRightBackgroundColor` in `SBUMessageCellTheme`
* Modified access level to the public of `SBUCommonItem` properties.
* Supported multi-line title of channel cell
* Improved stability

### v3.5.3 (Mar 31, 2023)
* Modified voice message maximum recording time from 1 min to 10 min
* Improved stability

### v3.5.2 (Mar 24, 2023)
* Added `SBUCommonViewControllerSet`
  * Added `FileViewController` to `SBUCommonViewControllerSet`
  * Renamed `SBUFileViewer` to `SBUFileViewController`
* Added new static properties in `SBUGlobals`
  * Added `isTintColorEnabledForCustomizedIcon` and `isCustomizedIconResizable`
* Improved stability

### v3.5.1 (Mar 17, 2023)
* Improved stability

### v3.5.0 (Mar 14, 2023) with Chat SDK **v4.6.0**
* Added Support for Notification Channels
  * `SBUFeedNotificationChannelViewController` and `SBUFeedNotificationChannelModule` (`Header`, `List`) added
  * `SBUChatNotificationChannelViewController` and `SBUChatNotificationChannelModule` (`Header`, `List`) added
  
### v3.4.0 (Mar 6, 2023) with Chat SDK **v4.5.0**
* Support **voice message** features in Group Channel
  * Added views
    * Added `SBUVoiceMessageInputView`
    * Added `SBUVoiceContentView`
    * Added voice message features to `SBUMessageInputView`
      * Added `voiceMessageButton`
      * Added `showsVoiceMessageButton` 
  * Added delegates
    * Added `messageInputViewDidTapVoiceMessage(_:)` to `SBUMessageInputViewDelegate`
  * Added classes
    * Added `SBUVoiceRecorder`
    * Added `SBUVoicePlayer`
    * Added `SBUVoiceFileInfo`
  * Added static properties in `SBUGlobals`
    * Added `SBUVoiceMessageConfiguration` class
      * Added `isVoiceMessageEnabled` in `SBUVoiceMessageConfiguration`
      * Added `minRecordingTime` in `SBUVoiceMessageConfiguration/Recorder`
      * Added `maxRecordingTime` in `SBUVoiceMessageConfiguration/Recorder` 
    * Added `voiceMessageConfig` in `SBUGlobals`
    * Added `isAVPlayerAlwaysEnabled` in `SBUGlobals`
  * Added new strings in `SBUStringSet`
    * Added `SBUStringSet/VoiceMessage` class
      * Added `Input` nested string set class in `VoiceMessage` 
      * Added `Alert` nested string set class in `VoiceMessage` 
      * Added `Preview` nested string set class in `VoiceMessage` 
      * Added `fileName` string in `VoiceMessage`
* Opened `SBUChannelInfoHeaderView`
* Improved stability

### v3.3.7 (Feb 28, 2023) with Chat SDK **v4.4.0**
* Opened `popToChannel()` in `SBUBaseSelectUserViewController`
* Added `UITableView` header interfaces to the list components
  * Opened `tableView(_:viewForHeaderInSection:)`
  * Opened `tableView(_:heightForHeaderInSection:)`

### v3.3.6 (Feb 16, 2023)
* Improved stability

### v3.3.5 (Feb 13, 2023)
* Modify the channel initialization logic to draw first with cached messages

### v3.3.4 (Jan 25, 2023)
* Added web preview image width restriction

### v3.3.3 (Jan 20, 2023) with Chat SDK **v4.2.4** 
* Changed image compression option's default value to `true`
* Added processing for `SendbirdChat` initializer errors in `SendbirdUI` Initializer.

### v3.3.2 (Jan 5, 2023) with Chat SDK **v4.2.2**
* Added `enablesReaction` in `SBUParentMessageInfoView`
* Fixed `contentMode` issue while loading image
* Improved stability

### v3.3.1 (Dec 8, 2022)
* Added `isUserIdUsedForNickname` in `SBUGlobals`
* Improved image compression process
* Improved date formats for past year's format
  * `SBUGroupChannelCell`
  * `SBUMessageSearchResultCell`
  * `SBUMessageDateView`
  * `SBUParentMessageInfoView`
* Added formatted date getter functions in Date extension class
  * `lastUpdatedTimeForChannelCell(baseTimestamp:)`
  * `lastUpdatedTimeForMessageSearchResultCell(baseTimestamp:)`
  * `messageCreatedTimeForParentInfo(baseTimestamp:)`
  * `dateSeparatedTime(baseTimestamp:)`
* Added static properties in `SBUDateFormatSet`
  * `yyyyMMdd`
  * `MMMddhhmma`
  * `MMMddyyyyhhmma`
  * Channel
    * `lastUpdatedPastYearFormat`
  * Message * `dateSeparatorDateFormat` * `dateSeparatorPastYearFormat` * `dateSeparatorTimeFormat` * `dateSeparatorYesterdayFormat`
  * MessageSearch
    * `lastUpdatedDateFormat`
    * `lastUpdatedPastYearFormat` * `lastUpdatedTimeFormat`
  * MessageThread * `sentDateDateFormat` * `sentDatePastYearFormat` * `sentDateTimeFormat` * `sentDateYesterdayFormat`

### v3.3.0 (Nov 23, 2022) with Chat SDK **v4.1.6**
* Improved image caching and gif handling process
* Improved file data handling process
    * File name and mime type will set based on original file if possible
* Added classes
    * `SBUMessageThreadModule`
    * `SBUMessageThreadModule.Header`, `SBUMessageThreadModuleHeaderDelegate`
    * `SBUMessageThreadModule.List`, `SBUMessageThreadModuleListDelegate`, `SBUMessageThreadModuleListDataSource`
    * `SBUMessageThreadModule.Input`, `SBUMessageThreadModuleInputDelegate`, `SBUMessageThreadModuleInputDataSource`
    * `SBUThreadInfoView`, `SBUThreadInfoViewDelegate`
    * `SBUParentMessageInfoReactionView`
    * `SBUMessageThreadTitleView`, `SBUMessageThreadTitleViewDelegate`
    * `SBUMessageThreadViewController`, `SBUMessageThreadViewControllerDelegate`
    * `SBUParentMessageInfoView`, `SBUParentMessageInfoViewDelegate`
    * `SBUMessageThreadViewModel`, `SBUMessageThreadViewModelDelegate`, `SBUMessageThreadViewModelDataSource`
* Added module `SBUModuleSet`
    * `messageThreadModule`
* Added viewController in `SBUViewControllerSet`
    * `MessageThreadViewController`
* Added properties
    * `useQuotedMessage`, `useThreadInfo`, `joinedAt` in `SBUBaseMessageCellParams` class
    * `quotedMessageCreatedAt`, `messageCreatedAt`, `joinedAt` in `SBUQuotedBaseMessageViewParams` class
    * `useQuotedMessage`, `useThreadInfo`, `threadHStackView`, `threadInfoSpacing`, `threadInfoView` in `SBUContentBaseMessageCell` class
    * `emptyViewTopConstraint` in `SBUEmptyView`
    * `params` property in `SBUQuotedBaseMessageView` class
    * `sendFileMessageCompletionHandler`, `sendUserMessageCompletionHandler`, `pendingMessageManager` in `SBUBaseChannelViewModel`
* Added functions
    * `setupThreadInfoView()` function in `SBUContentBaseMessageCell` class
    * `updatePlaceholderText()` function in `SBUMessageInputView` class
    * `showMessageThread(channelURL:parentMessageId:parentMessageCreatedAt:startingPoint:)` function in `SBUBaseChannelViewController` class
    * `updateTopAnchorConstraint(constant:)` function in `SBUEmptyView` class
    * `SBUMessageThreadViewControllerDelegate` functions in `SBUGroupChannelViewController` class
    * `groupChannelModuleDidTapThreadInfoView(_:)` delegate function in `SBUGroupChannelModuleListDelegate`
    * `baseChannelModule(_:didTapTitleView:)` delegate function in `SBUBaseChannelModuleHeaderDelegate`
    * `baseChannelModule(_:pendingMessageManagerForCell:)` datasource function in `SBUBaseChannelModuleListDataSource`
    * `MessageThread()` class function in `SBUDateFormatSet`
    * `needsToRemoveMargin()` function in `SBUUserMessageTextView` class
    * `setupSendUserMessageCompletionHandlers()`, `setupSendFileMessageCompletionHandlers()` functions in `SBUOpenChannelViewModel` class
* Added parameters in function
    * `forMessageThread` parameter in functions of `SBUPendingMessageManager` class
    * `fileName` and `mimeType` parameters in `pickImageData` function of `SBUBaseChannelModule.Input` class
    * `fileName` and `mimeType` parameters in `didTapSendImageData` function of `SBUSelectablePhotoViewDelegate`
    * `imageSize` parameter in `configure` function of `SBUMessageProfileView` class
    * `removeMargin` parameter in initialize function of `SBUUserMessageTextView` class
    * `isThreadMessage` and `joinedAt` parameters in initialize function of `SBUBaseMessageCellParams`, `SBUUserMessageCellParams`, `SBUFileMessageCellParams`, and `SBUUnknownMessageCellParams` classes
    * `joinedAt` parameter in initialize function of `SBUQuotedBaseMessageViewParams` class
    * `joinedAt` parameter in `setupQuotedMessageView` function of `SBUContentBaseMessageCell` class
    * `completionHandler` parameter in `loadChannel` function of `SBUBaseChannelViewModel` class
* Added theme properties
    * in `SBUChannelTheme`
        * `messageThreadTitleColor`
        * `messageThreadTitleFont`
        * `messageThreadTitleChannelNameColor`
        * `messageThreadTitleChannelNameFont`
    * in `SBUMessageCellTheme`
        * `repliedCountTextColor`
        * `repliedCountTextFont`
        * `repliedUsersMoreIconBackgroundColor`
        * `repliedUsersMoreIconTintColor`
        * `parentInfoBackgroundColor`
        * `parentInfoUserNameTextFont`
        * `parentInfoUserNameTextColor`
        * `parentInfoDateFont`
        * `parentInfoDateTextColor`
        * `parentInfoMoreButtonTintColor`
        * `parentInfoSeparateBarColor`
        * `parentInfoReplyCountTextColor`
        * `parentInfoReplyCountTextFont`
* Added strings in `SBUStringSet`
    * `Message_Replied_Users_Count: (Int, Bool)`
    * `Message_Reply_Cannot_Found_Original`
    * `Message_Unavailable`
    * `MessageThread.Menu.replyInThread`
    * `MessageThread.MessageInput.replyInThread`
    * `MessageThread.MessageInput.replyToThread`
    * `MessageThread.Header.title`
* Added icons in `SBUIconSet`
    * `iconEmpty`
    * `iconThread`
* Added `SBUReplyConfiguration`
* Added `thread` type in `SBUReplyType` enumeration
* Added `SBUThreadReplySelectType` enumeration
* Added `dismissHandler` in `SBUAlertView`, `SBUActionSheet`
* Modified `caption3` font weight `.medium` to `.bold`
* Renamed `usingQuotedMessage` to `useQuotedMessage` in `SBUBaseMessageCellParams`, `SBUContentBaseMessageCell`, and `SBUQuotedBaseMessageViewParams` classes
* Deprecated
    * `SBUGlobals` class
        Deprecated `replyType` property, use `reply.replyType` instead
    * `SBUQuotedBaseMessageViewParams` class
        * Deprecated `init(message:position:usingQuotedMessage:joinedAt:)` function, use `init(message:position:useQuotedMessage:joinedAt:)` instead
        * Deprecated `init(messageId:messagePosition:quotedMessageNickname:replierNickname:text:usingQuotedMessage:quotedMessageCreatedAt:)` function, use `init(messageId:messagePosition:quotedMessageNickname:replierNickname:text:useQuotedMessage:quotedMessageCreatedAt:)` instead
        * Deprecated `init(messageId:messagePosition:quotedMessageNickname:replierNickname:name:type:urlString:usingQuotedMessage:quotedMessageCreatedAt:)` function, use `init(messageId:messagePosition:quotedMessageNickname:replierNickname:name:type:urlString:useQuotedMessage:quotedMessageCreatedAt:)` instead

### v3.2.3 (Nov 15, 2022)

> **IMPORTANT** If you use Swift Package Manager, Please *reset package cache* before download the current version.

* Opened keyboard events: `keyboardWillShow(_:)` and  `keyboardWillHide(_:)`
* Updated `navigationBar` shadowColor
* Modified the type of class that includes the `UIControl` type object to `NSObject`
* Improved logic to update the 'startPoint' in the channel
* Improved logic moving to the original message of a quoted message
* Improved channel initialization process.
* Improved stability

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
    * `participantCountFont`: light(`SBUFontSet.caption1` -> `SBUFontSet.caption2`)
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
  * Please add the code below in `AppDelegate` or `SceneDelegate` to use the values before the change.
	```
	SBUTheme.groupChannelListTheme.notificationOnTintColor = SBUColorSet.background50
	SBUTheme.openChannelCellTheme.participantCountFont = SBUFontSet.caption1
	SBUTheme.channelTheme.menuItemDisabledColor = SBUColorSet.ondark04
	SBUTheme.channelTheme.mentionLimitGuideTextFont = SBUFontSet.body1
	SBUTheme.channelSettingsTheme.userNameFont = SBUFontSet.subtitle1
	SBUTheme.channelSettingsTheme.urlFont = SBUFontSet.body3
	SBUTheme.channelSettingsTheme.cellDescriptionTextFont = SBUFontSet.subtitle3
	SBUTheme.createOpenChannelTheme.textFieldFont = SBUFontSet.body3
	```
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

> **IMPORTANT** If you use Swift Package Manager, Please *reset package cache* before download the current version.

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
