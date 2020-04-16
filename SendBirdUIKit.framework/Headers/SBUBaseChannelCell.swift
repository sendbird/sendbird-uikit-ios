//
//  SBUBaseChannelCell.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/03/23.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

open class SBUBaseChannelCell: UITableViewCell {

    // MARK: - Public property
    var channel: SBDGroupChannel?

    // MARK: - View Lifecycle
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
 
    /// This function handles the initialization of views.
    open func setupViews() {

    }

    /// This function handles the initialization of actions.
    open func setupActions() {

    }

    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {

    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        
    }

    /// This function configure a cell using channel information.
    /// - Parameter channel: cell object
    open func configure(channel: SBDGroupChannel) {
        self.channel = channel
    }
}
