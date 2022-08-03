//
//  ChannelVC_CustomHeader.swift
//  QuickStart
//
//  Created by Tez Park on 2022/07/19.
//  Copyright © 2022 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol CustomChannelModuleHeaderDelegate: SBUBaseChannelModuleHeaderDelegate {
    func customChannelModule(_ headerComponent: CustomChannelHeaderComponent, didTapTitleView titleView: UIView)
}

class CustomChannelHeaderComponent: SBUGroupChannelModule.Header {
    override func setupViews() {
        super.setupViews()

        // Add the gesture recognizer to a view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTitleView(sender:)))
        self.titleView?.addGestureRecognizer(tapGesture)
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        
        // This logic will be removed after modifying it inside
        self.titleView?.sbu_constraint(height: 40)
    }
    
    open func onTapTitleView(sender: UITapGestureRecognizer){
        if let titleView = self.titleView {
            (self.delegate as? CustomChannelModuleHeaderDelegate)?.customChannelModule(self, didTapTitleView: titleView)
        }
    }
}


class ChannelVC_CustomHeader: SBUGroupChannelViewController { }

extension ChannelVC_CustomHeader: CustomChannelModuleHeaderDelegate {
    func customChannelModule(_ headerComponent: CustomChannelHeaderComponent, didTapTitleView titleView: UIView) {
        if let channel = self.viewModel?.channel as? GroupChannel {
            let members = channel.members
            print(members)
        }
    }
}
