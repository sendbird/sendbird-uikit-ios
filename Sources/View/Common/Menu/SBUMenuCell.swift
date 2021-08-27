//
//  SBUMenuself.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/04/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUMenuCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lineView: UIView!

    var type: MessageMenuItem? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(type: MessageMenuItem) {

        self.type = type
        let theme = SBUTheme.componentTheme

        self.titleLabel.textColor = theme.actionSheetTextColor
        self.titleLabel.font = theme.menuTitleFont

        switch type {
        case .save:
            self.titleLabel?.text = SBUStringSet.Save
            self.iconImageView.image = SBUIconSetType.iconDownload.image(
                with: theme.actionSheetItemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        case .copy:
            self.titleLabel?.text = SBUStringSet.Copy
            self.iconImageView.image = SBUIconSetType.iconCopy.image(
                with: theme.actionSheetItemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        case .edit:
            self.titleLabel?.text = SBUStringSet.Edit
            self.iconImageView.image = SBUIconSetType.iconEdit.image(
                with: theme.actionSheetItemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        case .delete:
            self.titleLabel?.text = SBUStringSet.Delete
            self.iconImageView.image = SBUIconSetType.iconDelete.image(
                with: theme.actionSheetItemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        }
    }
}
