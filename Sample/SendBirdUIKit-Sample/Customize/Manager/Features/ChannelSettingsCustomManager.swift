//
//  ChannelSettingsCustomManager.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class ChannelSettingsCustomManager: BaseCustomManager {
    static var shared = ChannelSettingsCustomManager()
    
    func startSample(naviVC: UINavigationController, type: ChannelSettingsCustomType?) {
        self.navigationController = naviVC
        
        switch type {
        case .uiComponent:
            uiComponentCustom()
        case .functionOverriding:
            functionOverridingCustom()
        default:
            break
        }
    }
}


extension ChannelSettingsCustomManager {
    func uiComponentCustom() {
        ChannelManager.getSampleChannel { channel in
            let channelSettingsVC = SBUChannelSettingsViewController(channel: channel)

            // This part changes the default titleView to a custom view.
            channelSettingsVC.titleView = self.createHighlightedTitleLabel()
            
            // This part changes the default leftBarButton to a custom leftBarButton.
            // RightButton can also be changed in this way.
            channelSettingsVC.leftBarButton = self.createHighlightedBackButton()
            
            // This part changes the default userInfoView to a custom view.
            let userInfoView = UILabel(frame: CGRect(
                x: 0,
                y: 0,
                width: self.navigationController?.view.bounds.width ?? 375,
                height:200)
            )
            userInfoView.backgroundColor = SBUColorSet.secondary100
            userInfoView.textAlignment = .center
            userInfoView.text = "Custom UserInfo"
            userInfoView.textColor = SBUColorSet.secondary500
            userInfoView.highlight()
            channelSettingsVC.userInfoView = userInfoView
            
            // Move to ChannelSettingsViewController using customized components
            self.navigationController?.pushViewController(channelSettingsVC, animated: true)
        }
    }

    func functionOverridingCustom() {
        ChannelManager.getSampleChannel { channel in
            // If you inherit `SBUChannelSettingsViewController`, you can customize it by overriding some functions.
            let channelSettingsVC = ChannelSettingsVC_Overriding(channel: channel)
            self.navigationController?.pushViewController(channelSettingsVC, animated: true)
        }
    }
}
