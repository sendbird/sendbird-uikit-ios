//
//  SBUMain.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
public class SBUMain: NSObject {
    
    // MARK: - Initialize
    public static func initialize(applicationId: String) {
        SBUGlobals.ApplicationId = applicationId
        
        if let version = SBUMain.shortVersionString() {
            SBDMain.addExtension(SBUConstant.sbdExtensionKeyUIKit, version: version)
        }
        
        SBDMain.initWithApplicationId(applicationId)
        
        SBULog.info("[Init] UIKit initialized with id: \(applicationId)")
    }
    
    
    // MARK: - Connection
    public static func connect(completionHandler: @escaping (_ user: SBDUser?, _ error: SBDError?) -> Void) {
        SBULog.info("[Request] Connection to SendBird server")
        
        guard let currentUser = SBUGlobals.CurrentUser else {
            SBULog.error("[Failed] Connection to SendBird server: CurrentUser value is not set")
            completionHandler(SBDMain.getCurrentUser(), nil)
            return
        }
        
        let userId = currentUser.userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = currentUser.nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        SBDMain.connect(withUserId: userId, accessToken: SBUGlobals.AccessToken) { user, error in
            if let error = error {
                SBULog.error("[Failed] Connection to SendBird server: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            SBULog.info("[Succeed] Connection to SendBird server")
            
            SBUMain.updateUserInfo(
                nickname: nickname ?? userId,
                profileUrl: currentUser.profileUrl ?? user?.profileUrl
            ) { error in
                
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }
                
                #if !targetEnvironment(simulator)
                if let pendingPushToken = SBDMain.getPendingPushToken() {
                    SBULog.info("[Request] Register pending push token to SendBird server")
                    SBUMain.registerPush(deviceToken: pendingPushToken) { success in
                        if success == false {
                            SBULog.error("[Failed] Register pending push token to SendBird server")
                        }
                        SBULog.info("[Succeed] Register pending push token to SendBird server")
                    }
                }
                #endif
                
                SBUEmojiManager.loadAllEmojis { _, error in
                    completionHandler(user, error)
                }
                
            }
        }
    }
    
    public static func connectionCheck(completionHandler: @escaping (_ user: SBDUser?, _ error: SBDError?) -> Void) {
        SBULog.info("[Check] Connection status")
        
        if SBDMain.getConnectState() == .open {
            completionHandler(SBDMain.getCurrentUser(), nil)
        }
        else {
            SBUMain.connect(completionHandler: completionHandler)
        }
    }
    
    public static func disconnect(completionHandler: (() -> Void)?) {
        SBULog.info("[Request] Disconnection to SendBird server")
        
        SBDMain.disconnect(completionHandler: {
            SBULog.info("[Succeed] Disconnection to SendBird server")
            SBUGlobals.CurrentUser = nil
            completionHandler?()
        })
    }
    
    
    // MARK: - UserInfo
    public static func updateUserInfo(nickname: String?,
                                      profileUrl: String?,
                                      completionHandler: ((_ error: SBDError?) -> Void)?) {
        SBULog.info("[Request] Update user info")
        SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: profileUrl) { error in
            if let error = error {
                SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
                completionHandler?(error)
                return
            }
            
            SBULog.info("""
                [Succeed]
                Update user info: \(String(SBUGlobals.CurrentUser?.description ?? ""))
                """)
            completionHandler?(nil)
        }
    }
    
    
    // MARK: - Common
    @available(*, deprecated, renamed: "shortVersionString()")
    public static func getUIKitVersion() -> String {
        return SBUMain.shortVersionString() ?? ""
    }
    
    public static func versionString() -> String? {
        let bundle = Bundle(identifier: "com.sendbird.uikit")
        if let build = bundle?.infoDictionary?[kCFBundleVersionKey as String] {
            return "\(build)"
        }

        return nil
    }
    
    public static func shortVersionString() -> String? {
        let bundle = Bundle(identifier: "com.sendbird.uikit")
        if let shortVersion = bundle?.infoDictionary?["CFBundleShortVersionString"] {
            return "\(shortVersion)"
        }

        return nil
    }

    
    // MARK: - Push Notification
    public static func registerPush(deviceToken: Data,
                                    completionHandler: @escaping (_ success: Bool) -> Void) {
        SBULog.info("[Request] Register push token to SendBird server")
        
        #if !targetEnvironment(simulator)
        SBDMain.registerDevicePushToken(deviceToken, unique: true) { status, error in
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
    
    public static func unregisterPushToken(completionHandler: @escaping (_ success: Bool) -> Void) {
        SBUMain.connectionCheck { user, error in
        guard error == nil else { return }
            
            #if !targetEnvironment(simulator)
            guard let pendingPushToken = SBDMain.getPendingPushToken() else { return }
            SBULog.info("[Request] Unregister push token to SendBird server")
            SBDMain.unregisterPushToken(pendingPushToken) { resonse, error in
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
    
    public static func unregisterAllPushToken(completionHandler: @escaping (_ success: Bool) -> Void) {
        SBUMain.connectionCheck { user, error in
        guard error == nil else { return }
            
            SBULog.info("[Request] Unregister all push token to SendBird server")
            
            SBDMain.unregisterAllPushToken { resonse, error in
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
    
    public static func openChannel(channelUrl: String, basedOnChannelList: Bool = true) {
        guard SBUGlobals.CurrentUser != nil else { return }
        
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        var viewController: UIViewController? = nil
        
        if let tabbarController: UITabBarController = rootViewController as? UITabBarController {
            rootViewController = tabbarController.selectedViewController
        }
        
        if let navigationController: UINavigationController = rootViewController?
            .presentedViewController as? UINavigationController {
            
            for subViewController in navigationController.viewControllers {
                if let subViewController = subViewController as? SBUChannelListViewController {
                    navigationController.popToViewController(subViewController, animated: false)
                    viewController = subViewController
                    break
                } else if let subViewController = subViewController as? SBUChannelViewController {
                    viewController = subViewController
                }
            }
        } else if let navigationController: UINavigationController = rootViewController
            as? UINavigationController {
            
            for subViewController in navigationController.viewControllers {
                if let subViewController = subViewController as? SBUChannelListViewController {
                    navigationController.popToViewController(subViewController, animated: false)
                    viewController = subViewController
                    break
                } else if let subViewController = subViewController as? SBUChannelViewController {
                    viewController = subViewController
                }
            }
        }
        
        if let viewController = viewController as? SBUChannelListViewController {
            viewController.showChannel(channelUrl: channelUrl)
        } else if let viewController = viewController as? SBUChannelViewController {
            viewController.loadChannel(channelUrl: channelUrl)
        } else {
            if basedOnChannelList {
                // If based on channelList
                let vc = SBUChannelListViewController()
                let naviVC = UINavigationController(rootViewController: vc)
                rootViewController?.present(naviVC, animated: true, completion: {
                    vc.showChannel(channelUrl: channelUrl)
                })
            } else {
                // If based on channel
                let vc = SBUChannelViewController(channelUrl: channelUrl)
                let naviVC = UINavigationController(rootViewController: vc)
                rootViewController?.present(naviVC, animated: true)
            }
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
        let type = types.map {$0.rawValue}.reduce(0) {$0 + $1}
        SBULog.logType = type
    }
}
