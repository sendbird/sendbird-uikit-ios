//
//  SBUChannelViewController.SBUQuotedMessageViewDelegate.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/08/12.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUChannelViewController: SBUQuotedMessageViewDelegate {
    open func didTapQuotedMessageView(_ quotedMessageView: SBUQuotedBaseMessageView) {
        guard let row = self.fullMessageList.firstIndex(
            where: { $0.messageId == quotedMessageView.messageId }
        ) else {
            // error
            //Couldn't find a linked message.
            return
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) as? SBUBaseMessageCell else { return }
        cell.messageContentView.animate(.shakeUpDown)
    }
}
