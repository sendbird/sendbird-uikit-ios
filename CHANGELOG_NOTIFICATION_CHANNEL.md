# Changelog Notification Channel

### v3.5.0-beta.0 (Feb 6, 2022) with Chat SDK v4.3.0

#### **Notification Channel**

A notification channel is a new group channel dedicated to receiving one way marketing and transactional messages.To allow users to view messages sent through Sendbird Message Builder with the correct rendering, you need to implement the notification channel view using `SBUNotificationChannelViewController` or `SBUNotificationChannelModule`.

* Added new viewController
    * Added `SBUNotificationChannelViewController` class
    * Added `NotificationChannelViewController` static property to `SBUViewControllerSet`
* Added new module
    * Added `SBUNotificationChannelModule` class
    * Added `notificationChannelModule` static property to `SBUModuleSet`
    * Added header component
        * Added `SBUNotificationChannelModule.Header` class
        * Added `SBUNotificationChannelModuleHeaderDelegate` protocol
    * Added list component
        * Added `SBUNotificationChannelModule.List` class
        * Added `SBUNotificationChannelModuleListDelegate` protocol
        * Added `SBUNotificationChannelModuleListDataSource` protocol
        * Added `SBUNotificationMessageCell` class
* Added new strings to `SBUStringSet`
    * Added `Empty_No_Notifications` static property
    * Added `Notification_Channel_CustomType` static property
    * Added `Notification_Channel_URL` static property
    * Added `Notification_Channel_Name_Default` static property
    
#### **Message Template**

* Added Message Template classes
    * Added `SBUMessageTemplate` class 
    * Added `SBUMessageTemplate.Action` class
* Added new theme
    * Added `SBUMessageTemplateTheme` class
    * Added `messageTemplateTheme` static property to `SBUTheme`
* Added new strings to `SBUStringSet`
    * Added `Message_Template_Error` static property
    

