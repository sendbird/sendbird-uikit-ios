//
//  SendbirdUI.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@available(*, deprecated, renamed: "SendbirdUI") // 3.0.0
public typealias SBUMain = SendbirdUI

public class SendbirdUI {
    
    /// SendbirdUIKit configuration
    /// - Since: 3.6.0
    public static var config: SBUConfig = SBUConfig()
    
    /// Checks dashboard configuration load status
    static var isDashboardConfigLoaded: Bool = false
    
    // MARK: - Initialize
    /// This function is used to initializes SDK with applicationId.
    /// - Parameter applicationId: Application ID
    @available(*, unavailable, message: "Using the `initialize(applicationId:startHandler:migrationStartHandler:completionHandler:)` function, and in the CompletionHandler, please proceed with the following procedure.", renamed: "initialize(applicationId:startHandler:migrationStartHandler:completionHandler:)") // 2.2.0
    public static func initialize(applicationId: String) {
        SendbirdUI.initialize(applicationId: applicationId, startHandler: nil, migrationHandler: nil) { _ in
            
        }
    }
    
    /// This function is used to initializes SDK with applicationId.
    ///
    /// When the completion handler is called, please proceed with the next operation.
    ///
    /// - Parameters:
    ///   - applicationId: Application ID
    ///   - migrationStartHandler: Do something to display the progress of the DB migration.
    ///   - completionHandler: Do something to display the completion of the DB migration.
    ///
    /// - Since: 2.2.0
    @available(*, deprecated, renamed: "initialize(applicationId:startHandler:migrationHandler:completionHandler:)") // 3.0.0
    public static func initialize(applicationId: String,
                                  migrationStartHandler: @escaping (() -> Void),
                                  completionHandler: @escaping ((_ error: SBError?) -> Void)) {
        self.initialize(
            applicationId: applicationId,
            startHandler: nil,
            migrationHandler: migrationStartHandler,
            completionHandler: completionHandler
        )
    }
    
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
        SBUGlobals.applicationId = applicationId
        
        startHandler?()
        migrationHandler?()
        
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
            logLevel: chatLogLevel
        )
        
        if let error = SendbirdChat.initializeSynchronously(params: params) {
            SBULog.error("[Failed] SendbirdChat initialize failed.: \(error.debugDescription)")
            completionHandler(error)
        } else {
            completionHandler(nil)

            // Call after initialization
            let sdkInfo = __SendbirdSDKInfo(product: .uikitChat, platform: .ios, version: SendbirdUI.shortVersion)
            _ = SendbirdChat.__addSendbirdExtensions(extensions: [sdkInfo], customData: nil)
            SendbirdChat.__addExtension(SBUConstant.extensionKeyUIKit, version: SendbirdUI.shortVersion)

            SendbirdChatOptions.setMemberInfoInMessage(true)
        }
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
    
    @available(*, deprecated, renamed: "connectIfNeeded(completionHandler:)") // 2.2.0
    public static func connectionCheck(
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        self.connectIfNeeded(completionHandler: completionHandler)
    }
    
    /// This function is used to check the connection state.
    ///  if connected, returns the User object, otherwise, call the connect function from the inside.
    ///  If local caching is enabled, the currentUser object is delivered and the connect operation is performed.
    ///
    /// - Parameter completionHandler: The handler block to execute.
    public static func connectIfNeeded(
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        SBULog.info("[Check] Connection status : \(SendbirdChat.getConnectState().rawValue)")
        
        if SendbirdChat.getConnectState() == .open {
            completionHandler(SendbirdChat.getCurrentUser(), nil)
        } else {
            SBULog.info("currentUser: \(String(describing: SendbirdChat.getCurrentUser()?.userId))")
            if SendbirdChat.isLocalCachingEnabled,
               let _ = SendbirdChat.getCurrentUser() {
                completionHandler(SendbirdChat.getCurrentUser(), nil)
                SendbirdUI.connectAndUpdates { _, _ in }
            } else {
                SendbirdUI.connectAndUpdates(completionHandler: completionHandler)
            }
        }
    }
    
    /// This function is used to check connection state and connect to the Sendbird server or local caching database.
    /// - Parameter completionHandler: The handler block to execute.
    static func connectAndUpdates(
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
        
        // TODO: Reset when the test server is no longer needed
        SendbirdChat.connect(
            userId: userId,
            authToken: SBUGlobals.accessToken
        ) { [userId, nickname] user, error in
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
            
            SendbirdUI.updateUserInfo(
                nickname: updatedNickname,
                profileURL: currentUser.profileURL ?? user.profileURL
            ) { error in
                
                #if !targetEnvironment(simulator)
                if let pendingPushToken = SendbirdChat.getPendingPushToken() {
                    SBULog.info("[Request] Register pending push token to Sendbird server")
                    SendbirdUI.registerPush(deviceToken: pendingPushToken) { success in
                        if !success {
                            SBULog.error("[Failed] Register pending push token to Sendbird server")
                        }
                        SBULog.info("[Succeed] Register pending push token to Sendbird server")
                    }
                }
                #endif
                
                self.config.loadDashboardConfig { _ in
                    self.loadNotificationChannelSettings { _ in
                        completionHandler(user, error)
                    }
                }
            }
        }
    }
    
    static func loadNotificationChannelSettings(
        completionHandler: @escaping (_ succeeded: Bool) -> Void
    ) {
        guard SBUAvailable.isNotificationChannelEnabled else {
            completionHandler(false)
            return
        }

        SBUNotificationChannelManager.loadGlobalNotificationChannelSettings { success in
            if !success { SBULog.error("[Failed] Load global notification channel settings") }
            
            self.loadTemplateList(completionHandler: completionHandler)
        }
    }
    
    static func loadTemplateList(completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        SBUNotificationChannelManager.loadTemplateList { success in
            if !success { SBULog.error("[Failed] Load template list") }
            completionHandler(success)
        }
    }
    
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
            
            #if !targetEnvironment(simulator)
            if let pendingPushToken = SendbirdChat.getPendingPushToken() {
                SBULog.info("[Request] Register pending push token to Sendbird server")
                SendbirdUI.registerPush(deviceToken: pendingPushToken) { success in
                    if !success {
                        SBULog.error("[Failed] Register pending push token to Sendbird server")
                    }
                    SBULog.info("[Succeed] Register pending push token to Sendbird server")
                }
            }
            #endif
            
            completionHandler(error)
        }
    }
    
    /// This function is used to disconnect
    /// - Parameter completionHandler: The handler block to execute.
    public static func disconnect(completionHandler: (() -> Void)?) {
        SBULog.info("[Request] Disconnection to Sendbird")
        
        SendbirdChat.disconnect(completionHandler: {
            SBULog.info("[Succeed] Disconnection to Sendbird")
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
    /// - Since: 2.2.0
    public static var shortVersion: String {
        
        if let bundle = Bundle(identifier: SBUConstant.bundleIdentifier),
            let build = bundle.infoDictionary?[SBUConstant.sbuAppVersion] {
            return "\(build)"
        } else {
            let bundle = Bundle(for: SendbirdUI.self)
            if let build = bundle.infoDictionary?["CFBundleShortVersionString"] {
                return "\(build)"
            }
        }
        
        return "0.0.0"
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
        
        #if !targetEnvironment(simulator)
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
        #else
        completionHandler(false)
        #endif
    }
    
    /// This function is used to unregister push token on the Sendbird server.
    /// - Parameter completionHandler: The handler block to execute.
    public static func unregisterPushToken(completionHandler: @escaping (_ success: Bool) -> Void) {
        SendbirdUI.connectIfNeeded { _, error in
        guard error == nil else {
            completionHandler(false)
            return
        }
            
            #if !targetEnvironment(simulator)
            guard let pendingPushToken = SendbirdChat.getPendingPushToken() else {
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
            #else
            completionHandler(false)
            #endif
        }
    }
    
    /// This function is used to unregister all push token on the Sendbird server.
    /// - Parameter completionHandler: The handler block to execute.
    public static func unregisterAllPushToken(completionHandler: @escaping (_ success: Bool) -> Void) {
        SendbirdUI.connectIfNeeded { _, error in
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
    }
    
    @available(*, deprecated, renamed: "moveToChannel(channelURL:basedOnChannelList:messageListParams:)") // 1.2.2
    public static func openChannel(channelUrl: String,
                                   basedOnChannelList: Bool = true,
                                   messageListParams: MessageListParams? = nil) {
        moveToChannel(
            channelURL: channelUrl,
            basedOnChannelList: basedOnChannelList,
            messageListParams: messageListParams
        )
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
                switch channelType {
                case .open:
                    // shouldn't be instance of SBUGroupChannelListViewController since this is for group channel.
                    return !($0 is SBUGroupChannelListViewController) && $0 is SBUBaseChannelListViewController
                case .group:
                    return $0 is SBUGroupChannelListViewController
                case .feed:
                    return $0 is SBUGroupChannelListViewController // Not used now
                @unknown default:
                    return false
                }
            }) {
            return channelListVc
        } else {
            return navigationController
                .viewControllers
                .last(where: {
                    switch channelType {
                    case .open:
                        return $0 is SBUOpenChannelViewController
                    case .group:
                        return $0 is SBUGroupChannelViewController
                    case .feed:
                        return $0 is SBUFeedNotificationChannelViewController
                    @unknown default:
                        return false
                    }
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
