//
//  SBUMenuself.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUMenuCell: SBUTableViewCell {
    lazy var containerView = { SBUStackView.init(axis: .horizontal, alignment: .fill, spacing: 30) }()
    lazy var titleLabel = { UILabel(frame: .zero) }()
    lazy var iconImageView = { UIImageView(frame: .zero) }()
    lazy var lineView = { UIView(frame: .zero) }()

    var isEnabled: Bool = true
    var tapHandler: ((@escaping (Bool) -> Void) -> Void)?
    
    func configure(with item: SBUMenuItem) {
        let theme = SBUTheme.componentTheme
        
        self.titleLabel.text = item.title
        self.titleLabel.font = item.font ?? theme.menuTitleFont
        self.titleLabel.textAlignment = item.textAlignment
        self.titleLabel.textColor = self.isEnabled
        ? item.color ?? theme.actionSheetTextColor
        : theme.actionSheetDisabledColor
        
        self.iconImageView.image = item.image
        self.iconImageView.tintColor = self.isEnabled
        ? item.tintColor ?? theme.actionSheetItemColor
        : theme.actionSheetDisabledColor
        
        if let tag = item.tag {
            self.tag = tag
        }
        
        self.tapHandler = { [weak item] completion in
            item?.completionHandler?()
            
            completion(item?.transitionsWhenSelected ?? false)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        self.containerView.setHStack([
            self.titleLabel,
            self.iconImageView
        ])
        
        self.contentView.addSubview(self.containerView)
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        
        self.containerView
            .sbu_constraint(equalTo: self.contentView, left: 17, right: 17, top: 0, bottom: 0, priority: .required)
            .sbu_constraint(height: 56, priority: .required)
        
        self.iconImageView
            .sbu_constraint(width: 25, priority: .required)
    }
    
    override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
        self.iconImageView.contentMode = .scaleAspectFit
    }
}
