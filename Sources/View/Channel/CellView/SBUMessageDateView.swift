//
//  SBUMessageDateView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This class used to display the date separator in the message list.
open class SBUMessageDateView: SBUView {
     
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    public lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    open override func setupViews() {
        self.dateLabel.textAlignment = .center
        self.addSubview(self.dateLabel)
    }
    
    open override func setupLayouts() {
        self.dateLabel
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 91, height: 20)
        
        self.setConstraint(height: 20, priority: .defaultLow)
    }
    
    open override func setupStyles() {
        self.backgroundColor = .clear
        
        self.dateLabel.font = theme.dateFont
        self.dateLabel.textColor = theme.dateTextColor
        self.dateLabel.backgroundColor = theme.dateBackgroundColor
    }
    
    open func configure(timestamp: Int64) {
        self.dateLabel.text = Date.dateSeparatedTime(baseTimestamp: timestamp)
    }
}
