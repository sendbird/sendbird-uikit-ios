//
//  CustomEmptyView.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/08.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class CustomEmptyView: SBUEmptyView {
    override func updateViews() {
        switch self.type {
        case .none:
            self.statusLabel.text = ""
            self.statusImageView.image = nil
        case .noChannels:
            self.statusLabel.text = "[Custom] No channels"
            self.statusImageView.image = UIImage(named: "logoSendbird")
        case .noMessages:
            self.statusLabel.text = "[Custom] No messages"
            self.statusImageView.image = UIImage(named: "logoSendbird")
        case .error:
            self.statusLabel.text = "[Custom] Something went wrong"
            self.statusImageView.image = UIImage(named: "logoSendbird")
        case .noMutedMembers:
            self.statusLabel.text = "[Custom] No muted members"
            self.statusImageView.image = UIImage(named: "logoSendbird")
        case .noBannedMembers:
            self.statusLabel.text = "[Custom] No banned members"
            self.statusImageView.image = UIImage(named: "logoSendbird")
        @unknown default:
            self.statusLabel.text = ""
            self.statusImageView.image = nil
        }
    }
    
    override func onClickRetry(_ sender: Any) {
        AlertManager.showCustomInfo(#function)
    }
}
