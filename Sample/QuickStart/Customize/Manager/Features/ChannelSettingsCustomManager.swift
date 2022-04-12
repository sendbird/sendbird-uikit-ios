//
//  ChannelSettingsCustomManager.swift
//  SendbirdUIKit-Sample
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
            let channelSettingsVC = SBUGroupChannelSettingsViewController(channel: channel)

            // This part changes the default titleView to a custom view.
            channelSettingsVC.headerComponent?.titleView = self.createHighlightedTitleLabel()
            
            // This part changes the default leftBarButton to a custom leftBarButton.
            // RightButton can also be changed in this way.
            channelSettingsVC.headerComponent?.leftBarButton = self.createHighlightedBackButton()
            
            // This part changes the default channelInfoView to a custom view.
            let channelInfoView = UILabel(frame: CGRect(
                x: 0,
                y: 0,
                width: self.navigationController?.view.bounds.width ?? 375,
                height:200)
            )
            channelInfoView.backgroundColor = SBUColorSet.secondary100
            channelInfoView.textAlignment = .center
            channelInfoView.text = "Custom UserInfo"
            channelInfoView.textColor = SBUColorSet.secondary500
            channelInfoView.highlight()
            channelSettingsVC.listComponent?.channelInfoView = channelInfoView
            
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
