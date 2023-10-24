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
    
    public lazy var dateLabel: UILabel = UILabel()
    public var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    open override func setupViews() {
        self.dateLabel = SBUPaddingLabel(padding.top, padding.bottom, padding.left, padding.right)
        self.dateLabel.textAlignment = .center
        self.dateLabel.layer.cornerRadius = 10
        self.dateLabel.clipsToBounds = true
        self.addSubview(self.dateLabel)
    }
    
    open override func setupLayouts() {
        self.dateLabel
            .sbu_constraint(equalTo: self, centerX: 0, centerY: 0)
            .sbu_constraint(equalTo: self, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        self.backgroundColor = .clear
        
        self.dateLabel.font = theme.dateFont
        self.dateLabel.textColor = theme.dateTextColor
        self.dateLabel.backgroundColor = theme.dateBackgroundColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        let height = self.dateLabel.frame.height
        self.dateLabel.layer.cornerRadius = height / 2
    }
    
    open func configure(timestamp: Int64) {
        self.dateLabel.text = Date.dateSeparatedTime(baseTimestamp: timestamp)
    }
}
