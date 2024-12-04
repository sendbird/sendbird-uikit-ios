//
//  SendbirdUI.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// `SendbirdUI` is a main class of Sendbird UIKit.
/// It is responsible for initializing and configuring the Sendbird UIKit.
public class SendbirdUI {
    
    /// SendbirdUIKit configuration
    /// - Since: 3.6.0
    public static var config: SBUConfig = SBUConfig()
    
    /// Checks dashboard configuration load status
    static var isDashboardConfigLoaded: Bool = false
    
    // MARK: - Initialize
    
    /// This function is used to initializes SDK with applicationId.
    ///
    /// When the completion handler is called, please proceed with the next operation.
    ///
    /// - Parameters:
    ///   - applicationId: Application ID
    ///   - startHandler: Do something to display the start of the SendbirdUIKit initialization.
    ///   - migrationHandler: Do something to display the progress of the DB migration.
    ///   - completionHandler: Do something to display the completion of the SendbirdChat initialization.
    ///
    /// - Since: 3.0.0
    public static func initialize(applicationId: String,
                                  startHandler: (() -> Void)? = nil,
                                  migrationHandler: (() -> Void)? = nil,
                                  completionHandler: @escaping ((_ error: SBError?) -> Void)) {
        self.initialize(
            applicationId: applicationId,
            initParamsBuilder: nil,
            startHandler: startHandler,
            migrationHandler: migrationHandler,
            completionHandler: completionHandler
        )
    }
    /// This function is used to initializes SDK with applicationId.
    ///
    /// When the completion handler is called, please proceed with the next operation.
    ///
    /// - Parameters:
    ///   - applicationId: Application ID
    ///   - initParamsBuilder: InitParams builder.
    ///   - startHandler: Do something to display the start of the SendbirdUIKit initialization.
    ///   - migrationHandler: Do something to display the progress of the DB migration.
    ///   - completionHandler: Do something to display the completion of the SendbirdChat initialization.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SendbirdUI.initialize(
    ///     applicationId: <APP_ID>
    /// ) { params in
    ///     params?.isLocalCachingEnabled = true
    ///     params?.appVersion = SendbirdUI.versionString()
    ///     params?.needsSynchronous = true
    /// } startHandler: {
    ///
    /// } migrationHandler: {
    ///
    /// } completionHandler: { _ in
    ///     SBUGlobals.currentUser = SBUUser(userId: userId)
    ///
    ///     SendbirdUI.config.common.isUsingDefaultUserProfileEnabled = true
    ///     SendbirdUI.config.groupChannel.channel.replyType = .thread
    ///     SendbirdUI.config.groupChannel.channel.isMentionEnabled = true
    ///     SendbirdUI.config.groupChannel.channel.isVoiceMessageEnabled = true
    ///     SendbirdUI.config.groupChannel.channelList.isTypingIndicatorEnabled = true
    ///
    ///     SBUGlobals.isImageCompressionEnabled = true
    ///
    ///     // INFO: For push test
    ///     self.initializeRemoteNotification()
    /// }
    /// ```
    /// - Since: 3.14.0
    public static func initialize(applicationId: String,
                                  initParamsBuilder: ((_ params: InitParams?) -> Void)?,
                                  startHandler: (() -> Void)? = nil,
                                  migrationHandler: (() -> Void)? = nil,
                                  completionHandler: @escaping ((_ error: SBError?) -> Void)) {
        SBUGlobals.applicationId = applicationId
        
        var chatLogLevel: SendbirdChatSDK.LogLevel = .none
        if (SBULog.logType & LogType.info.rawValue) > 0 {  // info, all
            chatLogLevel = .verbose
        } else if (SBULog.logType & LogType.warning.rawValue) > 0 {
            chatLogLevel = .warning
        } else if (SBULog.logType & LogType.error.rawValue) > 0 {
            chatLogLevel = .error
        }
        let params = InitParams(
            applicationId: applicationId,
            isLocalCachingEnabled: true,
            logLevel: chatLogLevel,
            needsSynchronous: true
        )
        
        initParamsBuilder?(params)
        SBULog.info("Initialize state: initParamsBuilder called\n\(params)")
        
        startHandler?()
        SBULog.info("Initialize state: startHandler called")
        
        SBUCacheManager.Version.checkAndClearOutdatedCache()
        
        SendbirdChat.initialize(
            params: params,
            migrationStartHandler: {
                SBULog.info("Initialize state: migrationHandler called")
                migrationHandler?()
            },
            completionHandler: { error in
                defer {
                    completionHandler(error)
                    SBULog.info("Initialize state: completionHandler called")
                }
                
                guard error == nil else {
                    SBULog.error("Initialize state: Failed - \(error.debugDescription)")
                    return
                }

                self.setExtensionSettingsForSendbirdChat()
            }
        )
    }
    
    /// Sets extensions to the SendbirdChat SDK
    static func setExtensionSettingsForSendbirdChat() {
        // Call after SendbirdChat initialization
        #if SWIFTUI
        let sdkInfo = __SendbirdSDKInfo(
            product: .swiftuiChat,
            platform: .ios,
            version: SendbirdUI.shortVersion
        )
        #else
        let sdkInfo = __SendbirdSDKInfo(
            product: .uikitChat,
            platform: .ios,
            version: SendbirdUI.shortVersion
        )
        #endif
        _ = SendbirdChat.__addSendbirdExtensions(
            extensions: [sdkInfo],
            customData: nil
        )
        
        #if SWIFTUI
        SendbirdChat.__addExtension(
            SBUConstant.extensionSwiftUI,
            version: SendbirdUI.shortVersion
        )
        #else
        SendbirdChat.__addExtension(
            SBUConstant.extensionKeyUIKit,
            version: SendbirdUI.shortVersion
        )
        #endif

        SendbirdChatOptions.setMemberInfoInMessage(true)
        
        SBULog.info("Initialize state: executeAfterInitCompleteHandler called")
    }
    
    // MARK: - Connection
    /// This function is used to connect to the Sendbird server or local cahing database.
    ///
    /// Before invoking this function, `currentUser` object of `SBUGlobals` claas must be set.
    /// - Parameter completionHandler: The handler block to execute.
    public static func connect(
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        SendbirdUI.connectIfNeeded(completionHandler: completionHandler)
    }
    
    /// This function is used to check the connection state.
    ///  if connected, returns the User object, otherwise, call the connect function from the inside.
    ///  If local caching is enabled, the currentUser object is delivered and the connect operation is performed.
    ///
    /// - Parameter completionHandler: The handler block to execute.
    public static func connectIfNeeded(
        needToUpdateExtraData: Bool = true,
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        SendbirdChat.executeOrWaitForInitialization {
            SBULog.info("[Check] Connection status : \(SendbirdChat.getConnectState().rawValue)")
            
            if SendbirdChat.getConnectState() == .open {
                completionHandler(SendbirdChat.getCurrentUser(), nil)
            } else {
                SBULog.info("currentUser: \(String(describing: SendbirdChat.getCurrentUser()?.userId))")
                if SendbirdChat.isLocalCachingEnabled,
                   let currentUser = SendbirdChat.getCurrentUser() {
                    completionHandler(currentUser, nil)
                    SendbirdUI.connectAndUpdates(needToUpdateExtraData: needToUpdateExtraData) { _, _ in }
                } else {
                    SendbirdUI.connectAndUpdates(needToUpdateExtraData: needToUpdateExtraData, completionHandler: completionHandler)
                }
            }
        }
    }
    
    /// This function is used to check connection state and connect to the Sendbird server or local caching database.
    /// - Parameter completionHandler: The handler block to execute.
    static func connectAndUpdates(
        needToUpdateExtraData: Bool = true,
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        SBULog.info("[Request] Connection to Sendbird")
        
        guard let currentUser = SBUGlobals.currentUser else {
            SBULog.error("[Failed] Connection to Sendbird: CurrentUser value is not set")
            completionHandler(SendbirdChat.getCurrentUser(), nil)
            return
        }
        
        let userId = currentUser.userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = currentUser.nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        SendbirdChat.connect(userId: userId, authToken: SBUGlobals.accessToken, apiHost: SBUGlobals.apiHost, wsHost: SBUGlobals.wsHost) { [userId, nickname] user, error in
            defer {
                SBUEmojiManager.loadAllEmojis { _, _ in }
            }
            
            guard let user = user else {
                SBULog.error("[Failed] Connection to Sendbird: \(error?.localizedDescription ?? "")")
                completionHandler(nil, error)
                return
            }
            
            if let error = error {
                SBULog.warning("[Warning] Connection to Sendbird: Succeed but error was occurred: \(error.localizedDescription)")
                
                if !SendbirdChat.isLocalCachingEnabled {
                    completionHandler(user, error)
                    return
                }
            } else {
                SBULog.info("[Succeed] Connection to Sendbird")
            }
            
            var updatedNickname = nickname
            
            if updatedNickname == nil {
                if !user.nickname.isEmpty {
                    updatedNickname = user.nickname
                } else if SBUGlobals.isUserIdUsedForNickname {
                    updatedNickname = userId
                }
            }
            
            if !needToUpdateExtraData {
                completionHandler(SendbirdChat.getCurrentUser(), nil)
                return
            }
            
            SendbirdUI.updateUserInfo(
                nickname: updatedNickname,
                profileURL: currentUser.profileURL ?? user.profileURL
            ) { error in
                
                if SendbirdUI.isRemoteNotificationAvailable(),
                   let pendingPushToken = SendbirdChat.getPendingPushToken() {
                    SBULog.info("[Request] Register pending push token to Sendbird server")
                    SendbirdUI.registerPush(deviceToken: pendingPushToken) { success in
                        if !success {
                            SBULog.error("[Failed] Register pending push token to Sendbird server")
                        }
                        SBULog.info("[Succeed] Register pending push token to Sendbird server")
                    }
                }
                
                self.config.loadDashboardConfig { _ in
                    self.loadMessageTemplateList { _ in
                        self.loadNotificationChannelSettings { _ in
                            completionHandler(user, error)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - AuthenticateFeed
    /// This function is used to authenticate to the Sendbird server or local cahing database. (Feed channel only)
    ///
    /// Before invoking this function, `currentUser` object of `SBUGlobals` claas must be set.
    /// - Parameter completionHandler: The handler block to execute.
    ///
    /// - Since: 3.8.0
    public static func authenticateFeed(
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        SendbirdUI.authenticateFeedIfNeeded(completionHandler: completionHandler)
    }
    
    /// This function is used to check the authentication state.
    ///  if connected, returns the User object, otherwise, call the authenticateFeed function from the inside.
    ///  If local caching is enabled, the currentUser object is delivered and the authenticateFeed operation is performed.
    ///
    /// - Parameter completionHandler: The handler block to execute.
    ///
    /// - Since: 3.8.0
    public static func authenticateFeedIfNeeded(
        needToUpdateExtraData: Bool = true,
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        SendbirdChat.executeOrWaitForInitialization {
            SendbirdUI.authenticateFeedAndUpdates(
                needToUpdateExtraData: needToUpdateExtraData,
                completionHandler: completionHandler
            )
        }
    }
    
    /// This function is used to check authentication state and authenticate to the Sendbird server or local caching database.
    /// - Parameter completionHandler: The handler block to execute.
    static func authenticateFeedAndUpdates(
        needToUpdateExtraData: Bool = true,
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        SBULog.info("[Request] Authentication to Sendbird")
        
        guard let currentUser = SBUGlobals.currentUser else {
            SBULog.error("[Failed] Authentication to Sendbird: CurrentUser value is not set")
            completionHandler(SendbirdChat.getCurrentUser(), nil)
            return
        }
        
        let userId = currentUser.userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = currentUser.nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
        SendbirdChat.authenticate(userId: userId, authToken: SBUGlobals.accessToken, apiHost: SBUGlobals.apiHost) { [userId, nickname] user, error in
            guard let user = user else {
                SBULog.error("[Failed] Authentication to Sendbird: \(error?.localizedDescription ?? "")")
                completionHandler(nil, error)
                return
            }
            
            if let error = error {
                SBULog.warning("[Warning] Authentication to Sendbird: Succeed but error was occurred: \(error.localizedDescription)")
                
                if !SendbirdChat.isLocalCachingEnabled {
                    completionHandler(user, error)
                    return
                }
            } else {
                SBULog.info("[Succeed] Authentication to Sendbird")
            }
            
            var updatedNickname = nickname
            
            if updatedNickname == nil {
                if !user.nickname.isEmpty {
                    updatedNickname = user.nickname
                } else if SBUGlobals.isUserIdUsedForNickname {
                    updatedNickname = userId
                }
            }
            
            if !needToUpdateExtraData {
                completionHandler(SendbirdChat.getCurrentUser(), nil)
                return
            }
            
            SendbirdUI.updateUserInfo(
                nickname: updatedNickname,
                profileURL: currentUser.profileURL ?? user.profileURL
            ) { error in
                
                if SendbirdUI.isRemoteNotificationAvailable(),
                   let pendingPushToken = SendbirdChat.getPendingPushToken() {
                    SBULog.info("[Request] Register pending push token to Sendbird server")
                    SendbirdUI.registerPush(deviceToken: pendingPushToken) { success in
                        if !success {
                            SBULog.error("[Failed] Register pending push token to Sendbird server")
                        }
                        SBULog.info("[Succeed] Register pending push token to Sendbird server")
                    }
                }
                
                self.config.loadDashboardConfig { _ in
                    self.loadNotificationChannelSettings { _ in
                        completionHandler(user, error)
                    }
                }
            }
        }
    }
    
    // MARK: -
    static func loadNotificationChannelSettings(
        completionHandler: @escaping (_ succeeded: Bool) -> Void
    ) {
        guard SBUAvailable.isNotificationChannelEnabled else {
            completionHandler(false)
            return
        }

        SBUNotificationChannelManager.loadGlobalNotificationChannelSettings { success in
            if !success { SBULog.error("[Failed] Load global notification channel settings") }
            
            self.loadNotificationTemplateList(completionHandler: completionHandler)
        }
    }
    
    static func loadNotificationTemplateList(completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        SBUMessageTemplateManager.loadTemplateList(type: .notification) { success in
            if !success { SBULog.error("[Failed] Load notification message template list") }
            completionHandler(success)
        }
    }
    
    static func loadMessageTemplateList(completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        guard SBUAvailable.isGroupMessageTemplateEnabled == true else {
            completionHandler(false)
            return
        }
        
        SBUMessageTemplateManager.loadTemplateList(type: .message) { success in
            if !success { SBULog.error("[Failed] Load group message template list") }
            completionHandler(success)
        }
    }
    
    /// Updates the user information.
    ///
    /// This function is used to update the user's nickname and profile URL.
    /// It takes a completion handler as a parameter which returns an optional `SBError`.
    /// If the update is successful, the error returned is `nil`.
    /// Otherwise, it contains an instance of `SBError` with details about the failure.
    ///
    /// - Parameter completionHandler: A closure that is called when the update is complete.
    public static func updateUserInfo(completionHandler: @escaping (_ error: SBError?) -> Void) {
        guard let sbuUser = SBUGlobals.currentUser else {
            SBULog.error("[Failed] Connection to Sendbird: CurrentUser value is not set")
            completionHandler(nil)
            return
        }
        guard let user = SendbirdChat.getCurrentUser() else {
            SBULog.error("[Failed] Connection to Sendbird")
            completionHandler(nil)
            return
        }
        
        let userId = sbuUser.userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = sbuUser.nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var updatedNickname = nickname
        
        if updatedNickname == nil {
            if !user.nickname.isEmpty {
                updatedNickname = user.nickname
            } else {
                updatedNickname = userId
            }
        }
        
        SendbirdUI.updateUserInfo(
            nickname: updatedNickname,
            profileURL: sbuUser.profileURL ?? user.profileURL
        ) { error in
            
            if SendbirdUI.isRemoteNotificationAvailable(),
               let pendingPushToken = SendbirdChat.getPendingPushToken() {
                SBULog.info("[Request] Register pending push token to Sendbird server")
                SendbirdUI.registerPush(deviceToken: pendingPushToken) { success in
                    if !success {
                        SBULog.error("[Failed] Register pending push token to Sendbird server")
                    }
                    SBULog.info("[Succeed] Register pending push token to Sendbird server")
                }
            }
            
            completionHandler(error)
        }
    }
    
    /// This function is used to disconnect
    /// - Parameter completionHandler: The handler block to execute.
    public static func disconnect(completionHandler: (() -> Void)?) {
        SBULog.info("[Request] Disconnection to Sendbird")
        
        SendbirdChat.disconnect(completionHandler: {
            SBULog.info("[Succeed] Disconnection to Sendbird")
            SBUNotificationChannelManager.resetNotificationSettingCache()
            SBUGlobals.currentUser = nil
            completionHandler?()
        })
    }
    
    // MARK: - UserInfo
    /// This function is used to update user information.
    /// - Parameters:
    ///   - nickname: Nickname to use for update. If this value is nil, the nickname is not updated.
    ///   - profileURL: Profile URL to use for update. If this value is nil, the profile is not updated.
    ///   - completionHandler: The handler block to execute.
    public static func updateUserInfo(nickname: String?,
                                      profileURL: String?,
                                      completionHandler: ((_ error: SBError?) -> Void)?) {
        let params = UserUpdateParams()
        if let nickname = nickname {
            params.nickname = nickname
        }
        params.profileImageURL = profileURL
        
        self.updateUserInfo(params: params, completionHandler: completionHandler)
    }
    
    /// This function is used to update user information.
    /// - Parameters:
    ///   - nickname: Nickname to use for update. If this value is nil, the nickname is not updated.
    ///   - profileImage: Profile image to use for update. If this value is nil, the profile is not updated.
    ///   - completionHandler: The handler block to execute.
    public static func updateUserInfo(nickname: String?,
                                      profileImage: Data?,
                                      completionHandler: ((_ error: SBError?) -> Void)?) {
        let params = UserUpdateParams()
        params.nickname = nickname
        params.profileImageData = profileImage
        
        self.updateUserInfo(params: params, completionHandler: completionHandler)
    }
    
    /// This function is used to update user information.
    /// - Parameters:
    ///   - params: UserUpdateParams object for update.
    ///   - completionHandler: The handler block to execute.
    /// - Since: 3.5.6
    public static func updateUserInfo(params: UserUpdateParams,
                                      completionHandler: ((_ error: SBError?) -> Void)?) {
        if SBUAvailable.isSupportUserUpdate() {
            SBULog.info("[Request] Update user info")
            SendbirdChat.updateCurrentUserInfo(params: params, completionHandler: { error in
                self.didFinishUpdateUserInfo(error: error, completionHandler: completionHandler)
            })
        } else {
            if let user = SendbirdChat.getCurrentUser() {
                SBUGlobals.currentUser = SBUUser(
                    userId: user.userId,
                    nickname: user.nickname,
                    profileURL: user.profileURL
                )
            }
            
            completionHandler?(nil)
        }
    }
    
    private static func didFinishUpdateUserInfo(error: SBError?,
                                                completionHandler: ((_ error: SBError?) -> Void)?) {
        if let error = error {
            SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
            
            if !SendbirdChat.isLocalCachingEnabled {
                completionHandler?(error)
                return
            }
        } else {
            SBULog.info("""
            [Succeed]
            Update user info: \(String(SBUGlobals.currentUser?.description ?? ""))
            """)
        }
        
        if let user = SendbirdChat.getCurrentUser() {
            SBUGlobals.currentUser = SBUUser(
                userId: user.userId,
                nickname: user.nickname,
                profileURL: user.profileURL
            )
        }
        
        completionHandler?(error)
    }
    
    // MARK: - Common
    /// This function gets UIKit SDK's short version string. (e.g. 1.0.0)
    ///
    /// - Notice: If there is a beta version, it will return version information with beta information. (e.g. 1.0.0-beta)
    /// - Since: 2.2.0
    public static var shortVersion: String {
        if let bundle = Bundle(identifier: SBUConstant.bundleIdentifier),
            let shortVersion = bundle.infoDictionary?[SBUConstant.sbuAppVersion] {
            return "\(shortVersion)"
        } else {
            let bundle = Bundle(for: SendbirdUI.self)
            if let shortVersion = bundle.infoDictionary?["CFBundleShortVersionString"] {
                return "\(shortVersion)"
            }
        }
        
        return "0.0.0"
    }
    
    /// This function gets UIKit SDK's short version string. (e.g. 1.0.0)
    ///
    /// - Notice: If there is a beta version, it will return version information without beta information. (e.g. 1.0.0)
    /// - Since: 3.8.0
    public static var bundleShortVersion: String {
        let bundle = Bundle(identifier: SBUConstant.bundleIdentifier) ??  Bundle(for: SendbirdUI.self)
        let shortVersion: String = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return shortVersion
    }
    
    /// This function gets UIKit SDK's version string.
    /// - Returns: version string
    public static func versionString() -> String? {
        SendbirdUI.shortVersion
    }
    
    // MARK: - Push Notification
    
    /// This function is used to register push token for using push service on the Sendbird server.
    /// - Parameters:
    ///   - deviceToken: Device token
    ///   - unique: The default is `false`. If `true`, register device token after removing exsiting all device tokens of the current user. If false, just add the device token.
    ///   - completionHandler: The handler block to execute.
    public static func registerPush(
        deviceToken: Data,
        unique: Bool = false,
        completionHandler: @escaping (_ success: Bool) -> Void
    ) {
        SBULog.info("[Request] Register push token to Sendbird server")
        
        guard SendbirdUI.isRemoteNotificationAvailable() else {
            completionHandler(false)
            return
        }
        
        SendbirdChat.registerDevicePushToken(deviceToken, unique: unique) { status, error in
            switch status {
            case .success:
                SBULog.info("[Succeed] APNs push token is registered.")
                completionHandler(true)
            case .pending:
                SBULog.info("[Response] Push registration is pending.")
                completionHandler(false)
            case .error:
                SBULog.error("""
                    [Failed]
                    APNs registration failed with error: \(String(describing: error ?? nil))
                    """)
                completionHandler(false)
            @unknown default:
                SBULog.error("[Failed] Push registration: unknown default")
                completionHandler(false)
            }
        }
    }
    
    /// This function is used to unregister push token on the Sendbird server.
    /// - Parameter completionHandler: The handler block to execute.
    public static func unregisterPushToken(completionHandler: @escaping (_ success: Bool) -> Void) {
        let unregisterHandler: ((User?, SBError?) -> Void) = { _, error in
            guard error == nil else {
                completionHandler(false)
                return
            }
            
            guard SendbirdUI.isRemoteNotificationAvailable(),
                  let pendingPushToken = SendbirdChat.getPendingPushToken()
            else {
                completionHandler(false)
                return
            }
            SBULog.info("[Request] Unregister push token to Sendbird server")
            SendbirdChat.unregisterPushToken(pendingPushToken) { error in
                if let error = error {
                    SBULog.error("""
                        [Failed]
                        Push unregistration is fail: \(error.localizedDescription)
                        """)
                    completionHandler(false)
                    return
                }
                
                SBULog.info("[Succeed] Push unregistration is success.")
                completionHandler(true)
            }
        }
        
        if SendbirdChat.getConnectState() == .open {
            self.connectIfNeeded(needToUpdateExtraData: false, completionHandler: unregisterHandler)
        } else {
            self.authenticateFeedIfNeeded(needToUpdateExtraData: false, completionHandler: unregisterHandler)
        }
    }
    
    /// This function is used to unregister all push token on the Sendbird server.
    /// - Parameter completionHandler: The handler block to execute.
    public static func unregisterAllPushToken(completionHandler: @escaping (_ success: Bool) -> Void) {
        let unregisterHandler: ((User?, SBError?) -> Void) = { _, error in
            guard error == nil else {
                completionHandler(false)
                return
            }
            
            SBULog.info("[Request] Unregister all push token to Sendbird server")
            
            SendbirdChat.unregisterAllPushToken { error in
                if let error = error {
                    SBULog.error("[Failed] Push unregistration is fail: \(error.localizedDescription)")
                    completionHandler(false)
                    return
                }
                
                SBULog.info("[Succeed] Push unregistration is success.")
                completionHandler(true)
            }
        }
        
        if SendbirdChat.getConnectState() == .open {
            self.connectIfNeeded(completionHandler: unregisterHandler)
        } else {
            SendbirdUI.authenticateFeedIfNeeded(completionHandler: unregisterHandler)
        }
    }
    
    /// This is a function that moves the channel that can be called anywhere.
    ///
    /// If you wish to open an open channel view controller, or any class that subclasses `SBUOpenChannelViewController`,
    /// you must guarentee that a channel list's view controller, subclass of `SBUBaseChannelListViewController`,
    /// is present within the `UINavigationController.viewControllers` if you set the `basedOnChannelList` to `true`.
    ///
    /// - Parameters:
    ///   - channelURL: channel url for use in channel.
    ///   - basedOnChannelList: `true` for services based on the channel list. Default value is `true`
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    ///   - channelType: channel type
    ///   - rootViewController: If you use a complex hierarchy structure, ㄴet your ChannelList or Channel ViewController here.
    /// - Since: 2.2.6
    public static func moveToChannel(channelURL: String,
                                     basedOnChannelList: Bool = true,
                                     messageListParams: MessageListParams? = nil,
                                     channelType: ChannelType = .group,
                                     rootViewController: UIViewController? = nil) {
        guard SBUGlobals.currentUser != nil else { return }
        
        var rootViewController = rootViewController ?? UIApplication.shared.currentWindow?.rootViewController
        if let tabbarController: UITabBarController = rootViewController?.presentedViewController as? UITabBarController {
            rootViewController = tabbarController.selectedViewController
        } else if let tabbarController: UITabBarController = rootViewController as? UITabBarController {
            rootViewController = tabbarController.selectedViewController
        }
        
        // If search view controller is found, dismiss it first (it'll be in different navigation controller)
        if let searchViewController = findSearchViewController(rootViewController: rootViewController) {
            // Dismiss any presented view controllers before pushing other vc on top
            searchViewController.presentedViewController?.dismiss(animated: false, completion: nil)
            
            searchViewController.dismiss(animated: false) {
                let viewController: UIViewController? = findChannelListViewController(
                    rootViewController: rootViewController,
                    channelType: channelType
                )
                showChannelViewController(with: viewController ?? rootViewController,
                                          channelURL: channelURL,
                                          basedOnChannelList: basedOnChannelList,
                                          messageListParams: messageListParams,
                                          channelType: channelType)
            }
        } else {
            let viewController: UIViewController? = {
            #if SWIFTUI
                findChannelListViewControllerFromSwiftUI(
                    rootViewController: rootViewController,
                    channelType: channelType
                )
            #else
                findChannelListViewController(
                    rootViewController: rootViewController,
                    channelType: channelType
                )
            #endif
            }()
            
            showChannelViewController(with: viewController ?? rootViewController,
                                      channelURL: channelURL,
                                      basedOnChannelList: basedOnChannelList,
                                      messageListParams: messageListParams,
                                      channelType: channelType)
        }
    }
    
    /// Shows channel viewcontroller.
    private static func showChannelViewController(with viewController: UIViewController?,
                                                  channelURL: String,
                                                  basedOnChannelList: Bool,
                                                  messageListParams: MessageListParams?,
                                                  channelType: ChannelType) {
        // Dismiss any presented view controllers before pushing other vc on top
        viewController?.presentedViewController?.dismiss(animated: false, completion: nil)
        
        if let channelListViewController = viewController as? SBUBaseChannelListViewController {
            channelListViewController
                .navigationController?
                .popToViewController(channelListViewController, animated: false)
            
            if let openChannelListVC = channelListViewController as? SBUOpenChannelListViewController {
                openChannelListVC.reloadChannelList()
            }
            
            channelListViewController.showChannel(channelURL: channelURL)
        } else if let channelViewController = viewController as? SBUBaseChannelViewController {
            channelViewController.baseViewModel?.loadChannel(
                channelURL: channelURL,
                messageListParams: messageListParams
            )
        } else {
            if basedOnChannelList {
                // If based on channelList.
                let channelListVC: SBUBaseChannelListViewController
                if channelType == .group {
                    channelListVC = SBUViewControllerSet.GroupChannelListViewController.init()
                } else {
                    channelListVC = SBUViewControllerSet.OpenChannelListViewController.init()
                }
                let naviVC = UINavigationController(rootViewController: channelListVC)
                viewController?.present(naviVC, animated: true, completion: {
                    channelListVC.showChannel(channelURL: channelURL)
                })
            } else {
                // If based on channel
                let channelVC: SBUBaseChannelViewController
                if channelType == .group {
                    channelVC = SBUViewControllerSet.GroupChannelViewController.init(
                        channelURL: channelURL,
                        messageListParams: messageListParams,
                        displaysLocalCachedListFirst: true
                    )
                } else {
                    channelVC = SBUViewControllerSet.OpenChannelViewController.init(
                        channelURL: channelURL,
                        messageListParams: messageListParams
                    )
                }
                let naviVC = UINavigationController(rootViewController: channelVC)
                viewController?.present(naviVC, animated: true)
            }
        }
    }
    
    /// Finds channel list or channel viewcontroller from the navigation controller's viewcontrollers.
    ///
    /// - Returns: The `SBUBaseChannelListViewController` or `SBUBaseChannelViewController` instance , or `nil` if nothing was found.
    ///
    /// - Since: 3.1.0
    public static func findChannelListViewController(rootViewController: UIViewController?,
                                                     channelType: ChannelType) -> UIViewController? {
        guard let navigationController: UINavigationController =
                rootViewController?.presentedViewController as? UINavigationController ??
                rootViewController as? UINavigationController else { return nil }
        
        if let channelListVc = navigationController
            .viewControllers
            .first(where: {
                matchChannelListViewController($0, channelType: channelType)
            }) {
            return channelListVc
        } else {
            return navigationController
            .viewControllers
            .last(where: {
                matchChannelViewController($0, channelType: channelType)
            })
        }
    }
    
    /// Finds channel view controller from the navigation controller's view controllers.
    ///
    /// - Returns: The `SBUBaseChannelViewController` instance , or `nil` if nothing was found.
    ///
    /// - Since: 3.1.0
    public static func findChannelViewController(rootViewController: UIViewController?) -> UIViewController? {
        guard let navigationController: UINavigationController =
                rootViewController?.presentedViewController as? UINavigationController ??
                rootViewController as? UINavigationController else { return nil }
        
        let filteredVC = navigationController.viewControllers.filter {
            $0 is SBUBaseChannelViewController
        }
        guard !filteredVC.isEmpty else { return nil }
        
        return filteredVC.first
    }
    
    /// Finds instance of message shearch viewcontroller from the navigation controller's viewcontrollers.
    ///
    /// - Returns: instance of `SBUMessageSearchViewController`or `nil` if none are fonud.
    ///
    /// - Since: 3.1.0
    public static func findSearchViewController(rootViewController: UIViewController?) -> UIViewController? {
        guard let navigationController: UINavigationController =
                rootViewController?.presentedViewController as? UINavigationController ??
                rootViewController as? UINavigationController else { return nil }
        
        return navigationController
            .viewControllers
            .compactMap { $0 as? SBUMessageSearchViewController }
            .first
    }
    
    /// This is a function that creates and moves the channel that can be called anywhere.
    /// - Parameters:
    ///   - userIds: List of user ids
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    /// - Since: 1.2.2
    public static func createAndMoveToChannel(userIds: [String],
                                              messageListParams: MessageListParams? = nil) {
        SBULog.info("""
            [Request] Create channel with users,
            User: \(userIds))
            """)
        
        let params = GroupChannelCreateParams()
        params.name = ""
        params.coverURL = ""
        params.addUserIds(userIds)
        params.isDistinct = false
        
        if let currentUser = SBUGlobals.currentUser {
            params.operatorUserIds = [currentUser.userId]
        }
        
        SBUGlobalCustomParams.groupChannelParamsCreateBuilder?(params)
        
        self.createAndMoveToChannel(params: params, messageListParams: messageListParams)
    }
    
    /// This is a function that creates and moves the channel that can be called anywhere.
    /// - Parameters:
    ///   - params: `GroupChannelParams` class object
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    /// - Since: 1.2.2
    public static func createAndMoveToChannel(params: GroupChannelCreateParams,
                                              messageListParams: MessageListParams? = nil) {
        GroupChannel.createChannel(params: params) { channel, error in
            if let error = error {
                SBULog.error("""
                    [Failed] Create channel request:
                    \(String(error.localizedDescription))
                    """)
            }
            
            guard let channelURL = channel?.channelURL else {
                SBULog.error("[Failed] Create channel request: There is no channel url.")
                return
            }
            SBULog.info("[Succeed] Create channel: \(channel?.description ?? "")")
            
            SendbirdUI.moveToChannel(channelURL: channelURL, messageListParams: messageListParams)
        }
    }
    
    // MARK: - Logger
    
    /// You can activate log information for debugging.
    ///
    /// - `Objective-C` uses bit masking. (e,g, `.error|.info`)
    /// - `Swift` uses a single type in this function.
    /// - default type: .none
    /// - Parameter type: LogType
    public static func setLogLevel(_ type: LogType) {
        SBULog.logType = type.rawValue
    }
    
    ///  You can activate log information for debugging. (*Swift only*)
    ///
    /// - This function  can uses multiple types.
    /// - default type: .none
    /// - Parameter types: [LogType]
    public static func setLogLevel(_ types: [LogType]) {
        let type = types.map { $0.rawValue }.reduce(0) { $0 + $1 }
        SBULog.logType = type
    }
}

extension SendbirdUI {
    static func matchChannelListViewController(_ viewController: UIViewController, channelType: ChannelType) -> Bool {
        switch channelType {
        case .open:
            // shouldn't be instance of SBUGroupChannelListViewController since this is for group channel.
            return !(viewController is SBUGroupChannelListViewController)
                    && viewController is SBUBaseChannelListViewController
        case .group:
            return viewController is SBUGroupChannelListViewController
        case .feed:
            return viewController is SBUGroupChannelListViewController // Not used now
        @unknown default:
            return false
        }
    }
    
    static func matchChannelViewController(_ viewController: UIViewController, channelType: ChannelType) -> Bool {
        switch channelType {
        case .open:
            return viewController is SBUOpenChannelViewController
        case .group:
            return viewController is SBUGroupChannelViewController
        case .feed:
            return viewController is SBUFeedNotificationChannelViewController
        @unknown default:
            return false
        }
    }
}

extension SendbirdUI {
    private static var botUserListQuery: ApplicationUserListQuery?
    
    /// this is a function that brings up a screen to chat with the bot.
    ///
    /// - Parameters:
    ///   - botId: bot ID to join the channel.
    ///   - isDistinct: If `true`, an existing channel that exists will be used.
    ///   - errorHandler: The handler block that is executed when an error occurs.
    /// - Since: 3.8.0
    public static func startChatWithAIBot(
        botId: String,
        isDistinct: Bool,
        errorHandler: ((_ error: SBError?) -> Void)? = nil
    ) {
        guard SendbirdChat.isInitialized == true else {
            SBULog.error("[Failed] start chat with bot: need to be initialized.")
            errorHandler?(ChatError.invalidInitialization.asSBError)
            return
        }
        
        guard SBUGlobals.currentUser != nil else {
            SBULog.error("[Failed] start chat with bot: no current user.")
            errorHandler?(ChatError.invalidParameter.asSBError)
            return
        }
        
        Self.botUserListQuery = SendbirdChat.createApplicationUserListQuery(params: .init(builder: { params in
            params.userIdsFilter = [botId]
        }))
        
        Self.botUserListQuery?.loadNextPage { users, error in
            if let error = error {
                SBULog.error("[Failed] start chat with bot: \(error.description)")
                errorHandler?(ChatError.invalidParameter.asSBError)
                return
            }
            
            guard let users = users, users.count > 0 else {
                SBULog.error("[Failed] start chat with bot: no exist the bot.")
                errorHandler?(ChatError.invalidParameter.asSBError)
                return
            }
            
            let params = GroupChannelCreateParams()
            params.userIds = [botId]
            params.isDistinct = isDistinct
            
            GroupChannel.createChannel(params: params) { channel, error in
                if let error = error {
                    SBULog.error("[Failed] start chat with bot: \(error.description)")
                    errorHandler?(error)
                    return
                }
                
                guard let channel = channel else {
                    SBULog.error("[Failed] start chat with aibot: no exist the channel.")
                    errorHandler?(ChatError.internalServerError.asSBError)
                    return
                }
                
                SBULog.info("[Succeed] Create channel: \(channel.description)")
                
                SendbirdUI.moveToChannel(channelURL: channel.channelURL,
                                         basedOnChannelList: false)
            } // end create channel.
            
        } // end query load.
    }
}

extension SendbirdUI {
    /// This function checks if remote notifications are available.
    /// It returns true if the app is running on a device or on an iOS 16 (or later) simulator.
    /// Otherwise, it returns false.
    public static func isRemoteNotificationAvailable() -> Bool {
        #if targetEnvironment(simulator)
        // iOS 16 or later running in the simulator
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
        #else
        // running on a device
        return true
        #endif
    }
}
