//
//  ChannelVC_MessageParam.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/04.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class ChannelVC_MessageParam: SBUGroupChannelViewController {
    override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didTapSend text: String, parentMessage: SBDBaseMessage?) {
        guard text.count > 0 else { return }
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let messageParam = SBDUserMessageParams(message: text) else { return }
        
        let alert = UIAlertController(title: "Highlight message", message: "Would you like to send it as a Highlight message?", preferredStyle: .alert)
        let sendAction = UIAlertAction(title: "No", style: .default) { [weak self] action in
            self?.viewModel?.sendUserMessage(messageParams: messageParam)
        }
        let highlightAction = UIAlertAction(title: "YES", style: .default) { [weak self] action in
            messageParam.customType = "highlight"
            self?.viewModel?.sendUserMessage(messageParams: messageParam)
        }
        alert.addAction(sendAction)
        alert.addAction(highlightAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
