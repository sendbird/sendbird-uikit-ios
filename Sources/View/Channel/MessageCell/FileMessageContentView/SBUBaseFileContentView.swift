//
//  SBUBaseFileContentView.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUBaseFileContentView: SBUView {
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    public var message: FileMessage!
    public var position: MessagePosition = .center
    
    open func configure(message: FileMessage, position: MessagePosition) {
        self.message = message
        self.position = position
    }
}
