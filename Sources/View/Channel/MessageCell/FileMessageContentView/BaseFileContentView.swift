//
//  BaseFileContentView.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class BaseFileContentView: UIView {
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var message: SBDFileMessage!
    var position: MessagePosition = .center

    func setupStyles() {
        self.theme = SBUTheme.messageCellTheme
    }
    
    func configure(message: SBDFileMessage, position: MessagePosition) {
        self.message = message
        self.position = position
    }
}
