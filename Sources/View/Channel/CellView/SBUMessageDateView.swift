//
//  SBUMessageDateView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUMessageDateView: SBUView {
     
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    var theme: SBUMessageCellTheme
    
    lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    override func setupViews() {
        self.dateLabel.textAlignment = .center
        self.addSubview(self.dateLabel)
    }
    
    override func setupAutolayout() {
        self.dateLabel
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 91, height: 20)
        
        self.setConstraint(height: 20, priority: .defaultLow)
    }
    
    override func setupStyles() {
        self.backgroundColor = .clear
        
        self.dateLabel.font = theme.dateFont
        self.dateLabel.textColor = theme.dateTextColor
        self.dateLabel.backgroundColor = theme.dateBackgroundColor
    }
    
    func configure(timestamp: Int64) {
        self.dateLabel.text = Date.sbu_from(timestamp).sbu_toString(format: .EMMMdd)
    }
}
