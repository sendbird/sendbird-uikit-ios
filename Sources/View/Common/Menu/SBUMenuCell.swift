//
//  SBUMenuself.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUMenuCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lineView: UIView!

    var isEnabled: Bool = true
    var tapHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
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
        
        self.tapHandler = item.completionHandler
    }
}
