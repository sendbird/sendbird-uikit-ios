//
//  AdditionalFeaturesManager.swift
//  QuickStart
//
//  Created by Celine Moon on 11/23/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class AdditionalFeaturesManager: BaseCustomManager {
    static var shared = AdditionalFeaturesManager()
    
    func startSample(naviVC: UINavigationController, type: AdditionalFeaturesType?) {
        self.navigationController = naviVC
        
        switch type {
        case .translationAndReport:
            translationReportMetadata()
//        case .channelMetadata:
//            channelMetaData()
        case .webviewChatBotWidget:
            webviewChatBotWidget()
        default:
            break
        }
        
    }
    
    func translationReportMetadata() {
        ChannelManager.getSampleChannel { channel in
            let channelVC = ChannelVC_AdditionalFeatures(channel: channel)
            
            // This part changes the default user message cell to a custom cell.
            #if swift(>=5.2)
            channelVC.listComponent?.register(userMessageCell: UserMessageCell_AdditionalFeatures())
            #else
            channelVC.register(userMessageCell: CustomUserMessageCell(
                style: .default,
                reuseIdentifier: CustomUserMessageCell.sbu_className)
            )
            #endif
            
            // Move to ChannelViewController using customized components
            self.navigationController?.pushViewController(channelVC, animated: true)
        }
    }
    
    func webviewChatBotWidget() {
        let webViewVc = CustomWebView_ChatBotWidgetController()
        self.navigationController?.pushViewController(webViewVc, animated: true)
    }
}
