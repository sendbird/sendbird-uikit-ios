//
//  SBUReactionCollectionViewCell.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/28.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

enum SBUReactionCellType {
    case messageReaction
    case messageMenu
    case reactions
}

class SBUReactionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var emojiImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var rightMarginView: UIView!
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!

    var type: SBUReactionCellType = .messageMenu

    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    var needsSideMargin: Bool = false
    
    var count: Int?

    override var isSelected: Bool {
        didSet {
            self.setSelected()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupActions()
        self.setupStyles()
    }

    func setupViews() {
        switch type {
        case .messageReaction:
            self.setStackConstraints(top: -5, leading: 8, trailing: 8, height: 20)

            self.countLabel.textAlignment = .center
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 15
            self.lineView.isHidden = true

        case .messageMenu:
            self.setStackConstraints(top: -3, leading: 3, trailing: 3, height: 38)

            self.layer.cornerRadius = 8
            self.lineView.isHidden = true

        case .reactions:
            self.setStackConstraints(top: 0, leading: 0, trailing: 0, height: 28)

            self.layer.cornerRadius = 0
            self.lineView.isHidden = false
        }
    }
    
    func setupLayouts() {
        switch type {
        case .messageReaction:
            self.setStackConstraints(top: -5, leading: 8, trailing: 8, height: 20)
        case .messageMenu:
            self.setStackConstraints(top: -3, leading: 3, trailing: 3, height: 38)
        case .reactions:
            self.setStackConstraints(top: 0, leading: 0, trailing: 0, height: 28)
        }
    }

    func setupStyles() {
        switch type {
        case .messageReaction:
            self.countLabel.textColor = self.theme.reactionBoxEmojiCountColor
            self.countLabel.font = self.theme.reactionBoxEmojiCountFont
            self.backgroundColor = self.theme.reactionBoxEmojiBackgroundColor
            self.layer.borderColor = UIColor.clear.cgColor

        case .messageMenu:
            self.backgroundColor = .clear

        case .reactions:
            self.countLabel.textColor = self.theme.emojiCountColor
            self.countLabel.font = self.theme.emojiCountFont
            self.backgroundColor = .clear
            self.lineView.backgroundColor = self.theme.emojiSelectedUnderlineColor
        }
    }

    func setupActions() {
        let contentLongPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.onLongPressEmoji(sender:))
        )
        self.contentView.addGestureRecognizer(contentLongPressRecognizer)
    }

    // MARK: - Action
    var emojiLongPressHandler: (() -> Void)?

    @objc
    func onLongPressEmoji(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.emojiLongPressHandler?()
        }
    }

    func configure(type: SBUReactionCellType, url: String?, count: Int? = nil, needsSideMargin: Bool? = false) {
        self.type = type
        self.setCount(count)
        
        self.needsSideMargin = needsSideMargin ?? false

        if let urlString = url, !urlString.isEmpty {
            self.emojiImageView.loadImage(
                urlString: urlString,
                errorImage: SBUIconSetType.iconQuestion.image(to: SBUIconSetType.Metric.iconEmojiSmall),
                subPath: SBUCacheManager.PathType.reaction
            )
        } else {
            self.emojiImageView.image = SBUIconSetType.iconQuestion.image(to: SBUIconSetType.Metric.iconEmojiSmall)
        }
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        self.setSelected()
        self.setNeedsLayout()
    }

    func setCount(_ count: Int?) {
        self.count = count
        
        guard let count = count else {
            self.countLabel.isHidden = true
            if needsSideMargin {
                self.leftMarginView.isHidden = false
                self.rightMarginView.isHidden = false
            }
            return
        }
        
        self.countLabel.isHidden = false
        self.leftMarginView.isHidden = true
        self.rightMarginView.isHidden = true

        if type == .messageReaction {
            self.countLabel.text = count > 99 ? "99"  : String(count)
        } else {
            self.countLabel.text = count > 99 ? "99+" : String(count)
        }
    }

    private func setSelected() {
        switch type {
        case .messageReaction:
            self.backgroundColor = isSelected && (count != nil)
                ? theme.reactionBoxSelectedEmojiBackgroundColor
                : theme.reactionBoxEmojiBackgroundColor
        case .messageMenu:
            self.backgroundColor = isSelected
                ? theme.emojiListSelectedBackgroundColor
                : .clear
        case .reactions:
            self.countLabel.textColor = isSelected
                ? theme.emojiSelectedCountColor
                : theme.emojiCountColor
            self.lineView.alpha = isSelected ? 1 : 0
        }
    }

    func setStackConstraints(top: CGFloat, leading: CGFloat, trailing: CGFloat, height: CGFloat) {
        self.stackViewTopConstraint.constant = top
        self.stackViewLeadingConstraint.constant = leading
        self.stackViewTrailingConstraint.constant = trailing
        self.stackViewHeightConstraint.constant = height
    }

}
