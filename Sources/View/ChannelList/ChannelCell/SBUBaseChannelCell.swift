//
//  SBUBaseChannelCell.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/03/23.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

open class SBUBaseChannelCell: SBUTableViewCell {

    // MARK: - Public property
    public private(set) var channel: SBDBaseChannel?
    
    @SBUThemeWrapper(theme: SBUTheme.channelCellTheme)
    public var theme: SBUChannelCellTheme


    // MARK: - View Lifecycle
 
    /// This function configure a cell using channel information.
    /// - Parameter channel: cell object
    open func configure(channel: SBDBaseChannel) {
        self.channel = channel
    }
}
