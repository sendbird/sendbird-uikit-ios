//
//  BaseFileContentView.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

open class SBUBaseFileContentView: SBUView {
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    public var message: SBDFileMessage!
    public var position: MessagePosition = .center
    
    open func configure(message: SBDFileMessage, position: MessagePosition) {
        self.message = message
        self.position = position
    }
}
