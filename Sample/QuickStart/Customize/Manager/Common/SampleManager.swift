//
//  AlertManager.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/03.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

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
        
        // In order to use the API, the option must be turned on in the dashboard.
        let channelListQuery = GroupChannel.createMyGroupChannelListQuery(params: params)
        channelListQuery.loadNextPage { channels, error in
            guard let channel = channels?.first else {
                AlertManager.show(title: "No channel", message: "Create a channel and proceed.")
                return
            }
            
            completionHandler(channel)
        }
    }
}
