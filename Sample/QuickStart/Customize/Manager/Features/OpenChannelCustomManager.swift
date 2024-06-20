//
//  OpenChannelCustomManager.swift
//  QuickStart
//
//  Created by Celine Moon on 5/23/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class OpenChannelCustomManager: BaseCustomManager {
    static var shared = OpenChannelCustomManager()
    
    func startSample(naviVC: UINavigationController, type: OpenChannelCustomType?) {
        self.navigationController = naviVC
        
        switch type {
        case .customMessageMenuItem:
            customMessageMenuItem()
        default:
            break
        }
    }
    
    func customMessageMenuItem() {
        SBUModuleSet.OpenChannelModule.ListComponent = CustomOpenChannelModuleList.self
        
        ChannelManager.getSampleOpenChannel { openChannel in
            let channelVC = OpenChannelVC_CustomMessageMenuItem(channel: openChannel)
            self.navigationController?.pushViewController(channelVC, animated: true)
        }
    }
}
