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
        SBDMain.initWithApplicationId(applicationId)
    }
    
    
    // MARK: - Connection
    public static func connect(completionHandler: @escaping (_ user: SBDUser?, _ error: SBDError?) -> Void) {
        guard let currentUser = SBUGlobals.CurrentUser else {
            completionHandler(SBDMain.getCurrentUser(), nil)
            return
        }
        
        let userId = currentUser.userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = currentUser.nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        SBDMain.connect(withUserId: userId, accessToken: SBUGlobals.AccessToken) { user, error in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            SBDMain.updateCurrentUserInfo(withNickname: nickname ?? userId, profileUrl: currentUser.profileUrl ?? user?.profileUrl) { error in
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }
            
                #if !targetEnvironment(simulator)
                if let pendingPushToken = SBDMain.getPendingPushToken() {
                    SBUMain.registerPush(deviceToken: pendingPushToken) { success in
                        
                    }
                }
                #endif
                
                completionHandler(user, nil)
            }
        }
    }
    
    public static func connectionCheck(completionHandler: @escaping (_ user: SBDUser?, _ error: SBDError?) -> Void) {
        if SBDMain.getConnectState() == .open {
            completionHandler(SBDMain.getCurrentUser(), nil)
        }
        else {
            SBUMain.connect(completionHandler: completionHandler)
        }
    }
    
    public static func disconnect(completionHandler: (() -> Void)?) {
        SBDMain.disconnect(completionHandler: {
            SBUGlobals.CurrentUser = nil
            completionHandler?()
        })
    }
    
    
    // MARK: - UserInfo
    public static func updateUserInfo(nickname: String?, profileUrl: String?, completionHandler: ((_ error: SBDError?) -> Void)?) {
        SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: profileUrl, completionHandler: completionHandler)
    }
    
    
    // MARK: - Common
    public static func getUIKitVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    
    // MARK: - Push Notification
    public static func registerPush(deviceToken: Data, completionHandler: @escaping (_ success: Bool) -> Void) {
        #if !targetEnvironment(simulator)
        SBDMain.registerDevicePushToken(deviceToken, unique: true) { status, error in
            switch status {
            case .success:
                print("APNS Token is registered.")
                completionHandler(true)
            case .pending:
                print("Push registration is pending.")
                completionHandler(false)
            case .error:
                print("APNS registration failed with error: \(String(describing: error ?? nil))")
                completionHandler(false)
            @unknown default:
                print("Push registration: unknown default")
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
            SBDMain.unregisterPushToken(pendingPushToken, completionHandler: { resonse, error in
                guard error == nil else {
                    print("Push unregistration is fail.")
                    completionHandler(false)
                    return
                }
                
                print("Push unregistration is success.")
                completionHandler(true)
            })
            #else
            completionHandler(false)
            #endif
        }
    }
    
    public static func unregisterAllPushToken(completionHandler: @escaping (_ success: Bool) -> Void) {
        SBUMain.connectionCheck { user, error in
        guard error == nil else { return }
            
            SBDMain.unregisterAllPushToken { resonse, error in
                guard error == nil else {
                    print("Push unregistration is fail.")
                    completionHandler(false)
                    return
                }
                
                print("Push unregistration is success.")
                completionHandler(true)
            }
        }
    }
    
    public static func openChannel(channelUrl: String, basedOnChannelList: Bool = true) {
        guard SBUGlobals.CurrentUser != nil else { return }
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        var viewController: UIViewController? = nil
        
        if let navigationController: UINavigationController = rootViewController?.presentedViewController as? UINavigationController {
            for subViewController in navigationController.viewControllers {
                if subViewController is SBUChannelListViewController {
                    navigationController.popToViewController(subViewController, animated: false)
                    viewController = subViewController as! SBUChannelListViewController
                    break
                } else if subViewController is SBUChannelViewController {
                    viewController = subViewController as! SBUChannelViewController
                }
            }
        }
        
        if viewController is SBUChannelListViewController {
            (viewController as! SBUChannelListViewController).showChannel(channelUrl: channelUrl)
        } else if viewController is SBUChannelViewController {
            (viewController as! SBUChannelViewController).loadChannel(channelUrl: channelUrl)
        } else {
            if basedOnChannelList == true {
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
}
