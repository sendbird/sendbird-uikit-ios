//
//  AlertManager.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/03.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import SendbirdUIKit

// This function handles alertController to be used in the sample app.
class AlertManager: NSObject {
    static func show(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(closeAction)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController  {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showCustomInfo(_ function: String) {
        self.show(title: "Custom", message: "\(function) function can be customized.")
    }
}

// This function handles channel object to be used in the sample app.
class ChannelManager: NSObject {
    static func getSampleChannel(completionHandler: @escaping (_ channel: GroupChannel) -> Void) {
        let params = GroupChannelListQueryParams()
        params.order = .latestLastMessage
        params.limit = 10
        params.includeEmptyChannel = true
        
        // Sendbird provides various access control options when using the Chat SDK. By default, the Allow retrieving user list attribute is turned on to facilitate creating sample apps. However, this may grant access to unwanted data or operations, leading to potential security concerns. To manage your access control settings, you can turn on or off each setting on Sendbird Dashboard.
        let channelListQuery = GroupChannel.createMyGroupChannelListQuery(params: params)
        channelListQuery.loadNextPage { channels, error in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            guard let channel = channels?.first else {
                AlertManager.show(title: "No channel", message: "Create a channel and proceed.")
                return
            }
            
            completionHandler(channel)
        }
    }
    
    static func getSampleOpenChannel(completionHandler: @escaping (_ channel: OpenChannel) -> Void) {
        let params = OpenChannelListQueryParams()
        params.limit = 10
        
        // Sendbird provides various access control options when using the Chat SDK. By default, the Allow retrieving user list attribute is turned on to facilitate creating sample apps. However, this may grant access to unwanted data or operations, leading to potential security concerns. To manage your access control settings, you can turn on or off each setting on Sendbird Dashboard.
        let channelListQuery = OpenChannel.createOpenChannelListQuery(params: params)
        channelListQuery.loadNextPage { openChannels, error in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            guard let openChannel = openChannels?.first else {
                AlertManager.show(title: "No channel", message: "Create at least one open channel to proceed.")
                return
            }
            
            completionHandler(openChannel)
        }
    }
}
