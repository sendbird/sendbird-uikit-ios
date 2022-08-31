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
        
        self.titleLabel.font = theme.menuTitleFont
        self.titleLabel.textColor = self.isEnabled
        ? theme.actionSheetTextColor
        : theme.actionSheetDisabledColor
        
        self.titleLabel.text = item.title
        self.iconImageView.image = item.image
        self.tapHandler = item.completionHandler
    }
}
