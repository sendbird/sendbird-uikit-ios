//
//  ChannelListVC_Overriding.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class ChannelListVC_Overriding: SBUGroupChannelListViewController {
    // MARK: - Show relations
    override func showChannel(channelURL: String, messageListParams: MessageListParams? = nil) {
        // If you want to use your own ChannelViewController, you can override and customize it here.
        AlertManager.showCustomInfo(#function)
    }
    
    override func showCreateChannelTypeSelector() {
        // If you want to use your own CreateChannelViewController, you can override and customize it here.
        AlertManager.showCustomInfo(#function)
    }
    
    
    // MARK: - Error handling
    override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        // If you override and customize this function, you can handle it when error received.
        print(message as Any);
    }
}
