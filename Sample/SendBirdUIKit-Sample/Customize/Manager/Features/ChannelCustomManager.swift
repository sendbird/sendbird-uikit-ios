//
//  ChannelCustomManager.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class ChannelCustomManager: BaseCustomManager {
    static var shared = ChannelCustomManager()
    
    func startSample(naviVC: UINavigationController, type: ChannelCustomType?) {
        self.navigationController = naviVC
        
        switch type {
        case .uiComponent:
            uiComponentCustom()
        case .customCell:
            cellCustom()
        case .messageListParams:
            messageListParamsCustom()
        case .messageParams:
            messageParamsCustom()
        case .functionOverriding:
            functionOverridingCustom()
        default:
            break
        }
    }
}


extension ChannelCustomManager {
    func uiComponentCustom() {
        ChannelManager.getSampleChannel { channel in
            let channelVC = SBUChannelViewController(channel: channel)
            
            // This part changes the default titleView to a custom view.
            channelVC.titleView = self.createHighlightedTitleLabel()
            
            // This part changes the default leftBarButton to a custom leftBarButton.
            // RightButton can also be changed in this way.
            channelVC.leftBarButton = self.createHighlightedBackButton()
            
            // This part changes the messageInfoButton of newMessageInfoView.
            #if swift(>=5.2)
            let newMessageInfoView = CustomNewMessageInfo()
            #else
            let newMessageInfoView = CustomNewMessageInfo(frame: .zero)
            #endif
            channelVC.newMessageInfoView = newMessageInfoView
                        
            // This part changes the default emptyView to a custom emptyView.
            #if swift(>=5.2)
            let emptyView = CustomEmptyView()
            #else
            let emptyView = CustomEmptyView(frame: .zero)
            #endif
            emptyView.highlight()
            channelVC.emptyView = emptyView
            
            // Move to ChannelViewController using customized components
            self.navigationController?.pushViewController(channelVC, animated: true)
        }
    }
    
    func cellCustom() {
        // See the messageParamsCustom() function.
        self.messageParamsCustom()
    }
    
    func messageListParamsCustom() {
        ChannelManager.getSampleChannel { channel in
            // You can customize the message list using your own MessageListParams.
            // For all params options, refer to the `SBDMessageListParams` class.
            let params = SBDMessageListParams()
            params.includeMetaArray = true
            params.includeReactions = true
            params.includeThreadInfo = true
            params.includeParentMessageInfo = SBUGlobals.ReplyTypeToUse != .none
            params.replyType = SBUGlobals.ReplyTypeToUse.filterValue
            params.messageType = .user
            // ... You can set more query options
            
            // This part initialize the message list with your own MessageListParams.
            let channelVC = SBUChannelViewController(channel: channel, messageListParams: params)
            
            // Move to the ChannelViewController created using MessageListParams.
            self.navigationController?.pushViewController(channelVC, animated: true)
        }
    }

    // This is a sample displaying a highlight message using MessageParams.
    func messageParamsCustom() {
        ChannelManager.getSampleChannel { channel in
            let channelVC = ChannelVC_MessageParam(channel: channel)
            
            // This part changes the default user message cell to a custom cell.
            #if swift(>=5.2)
            channelVC.register(userMessageCell: CustomUserMessageCell())
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
    
    func functionOverridingCustom() {
        ChannelManager.getSampleChannel { channel in
            // If you inherit `SBUChannelViewController`, you can customize it by overriding some functions.
            let channelVC = ChannelVC_Overriding(channel: channel)
            self.navigationController?.pushViewController(channelVC, animated: true)
        }
    }
}
