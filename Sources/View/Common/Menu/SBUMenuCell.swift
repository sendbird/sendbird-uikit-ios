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
    var isEnabled: Bool = true

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

        self.titleLabel.font = theme.menuTitleFont
        self.titleLabel.textColor = self.isEnabled
            ? theme.actionSheetTextColor
            : theme.actionSheetDisabledColor
        let iconTintColor = self.isEnabled
            ? theme.actionSheetItemColor
            : theme.actionSheetDisabledColor

        switch type {
        case .save:
            self.titleLabel?.text = SBUStringSet.Save
            self.iconImageView.image = SBUIconSetType.iconDownload.image(
                with: iconTintColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        case .copy:
            self.titleLabel?.text = SBUStringSet.Copy
            self.iconImageView.image = SBUIconSetType.iconCopy.image(
                with: iconTintColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        case .edit:
            self.titleLabel?.text = SBUStringSet.Edit
            self.iconImageView.image = SBUIconSetType.iconEdit.image(
                with: iconTintColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        case .delete:
            self.titleLabel?.text = SBUStringSet.Delete
            self.iconImageView.image = SBUIconSetType.iconDelete.image(
                with: iconTintColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        case .reply:
            self.titleLabel?.text = SBUStringSet.Reply
            self.iconImageView.image = SBUIconSetType.iconReply.image(
                with: iconTintColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
        }
    }
}
