//
//  SBUMessageReactionView.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/05/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


/// Emoji reaction box
class SBUMessageReactionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let layout: UICollectionViewFlowLayout = SBUCollectionViewFlowLayout()

    var emojiList: [SBDEmoji] = []
    var reactions: [SBDReaction] = []
    var maxWidth: CGFloat = SBUConstant.messageCellMaxWidth

    var theme: SBUComponentTheme = SBUTheme.componentTheme

    var emojiTapHandler: ((_ emojiKey: String) -> Void)? = nil
    var moreEmojiTapHandler: (() -> Void)? = nil
    var emojiLongPressHandler: ((_ emojiKey: String) -> Void)? = nil

    private var collectionViewHeightConstraint: NSLayoutConstraint!
    private var collectionViewMinWidthContraint: NSLayoutConstraint!

    private let collectionViewInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    lazy var moreEmojiTapRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(self.onTapMoreEmoji(sender:))
    )
        
    init() {
        super.init(frame: .zero)
        self.setupViews()
        self.setupAutolayout()
        setupStyles()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
        setupStyles()
    }

    @available(*, unavailable, renamed: "MessageReactionView()")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 4)
        self.layout.minimumInteritemSpacing = 4
        self.layout.minimumLineSpacing = 4

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(
            SBUReactionCollectionViewCell.sbu_loadNib(),
            forCellWithReuseIdentifier: SBUReactionCollectionViewCell.sbu_className
        ) // for xib

        self.collectionView.bounces = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.isScrollEnabled = false
        self.collectionView.backgroundColor = .clear

        self.addSubview(self.collectionView)
    }

    func setupAutolayout() {
        self.collectionView.setConstraint(from: self, left: 0, right: 0, top: 0, bottom: 0)

        self.collectionViewHeightConstraint = self.collectionView
            .heightAnchor.constraint(equalToConstant: 0)
        self.collectionViewHeightConstraint.isActive = true

        self.collectionViewMinWidthContraint = self.collectionView
            .widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        self.collectionViewMinWidthContraint.isActive = true
    }

    func setupStyles() {
        self.theme = SBUTheme.componentTheme
        
        self.clipsToBounds = true
        self.backgroundColor = theme.reactionBoxBackgroundColor
        self.layer.cornerRadius = 16
        self.layer.borderWidth = 1
        self.layer.borderColor = theme.reactionBoxBorderLineColor.cgColor
    }

    func hasMoreEmoji(at indexPath: IndexPath) -> Bool {
        return self.reactions.count < emojiList.count &&
            self.reactions.count == indexPath.row
    }
    
    func configure(maxWidth: CGFloat, useReaction: Bool, reactions: [SBDReaction]) {
        guard useReaction, !reactions.isEmpty else {
            self.collectionViewMinWidthContraint.isActive = false
            self.isHidden = true
            return
        }

        self.collectionViewMinWidthContraint.isActive = true
        self.isHidden = false
        self.maxWidth = maxWidth
        self.reactions = reactions
        self.emojiList = SBUEmojiManager.getAllEmojis()

        let hasMoreEmoji = self.reactions.count < emojiList.count
        let cellSizes = reactions.reduce(0) {
            $0 + self.getCellSize(count: $1.userIds.count).width
        }

        var width: CGFloat = cellSizes
            + CGFloat(reactions.count - 1) * layout.minimumLineSpacing
            + layout.sectionInset.left + layout.sectionInset.right
        if hasMoreEmoji {
            width += self.getCellSize(count: 0).width + layout.minimumLineSpacing
        }
        self.collectionViewMinWidthContraint.constant = width < maxWidth ? width : maxWidth
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        self.collectionViewHeightConstraint.constant = self.collectionView
            .collectionViewLayout.collectionViewContentSize.height

        self.setNeedsLayout()
    }

    private func getCellSize(count: Int) -> CGSize {
        return CGSize(width: count > 0 ? 54 : 36, height: 30)
    }

    // MARK: - Action

    @objc func onTapMoreEmoji(sender: UITapGestureRecognizer) {
        let indexPath = IndexPath(row: reactions.count, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
        collectionView.deselectItem(at: indexPath, animated: true)
        self.moreEmojiTapHandler?()
    }


    // MARK: - UICollectionView relations
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard !reactions.isEmpty else { return 0 }

        if self.reactions.count < emojiList.count {
            return self.reactions.count + 1
        } else {
            return self.reactions.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUReactionCollectionViewCell.sbu_className,
            for: indexPath) as? SBUReactionCollectionViewCell else { return .init() }
        
        cell.removeGestureRecognizer(moreEmojiTapRecognizer)
        
        if self.hasMoreEmoji(at: indexPath) {
            let moreEmoji = SBUIconSetType.iconEmojiMore.image(
                with: theme.addReactionTintColor,
                to: SBUIconSetType.Metric.iconEmojiSmall
            )
            cell.configure(type: .messageReaction, url: nil)
            cell.emojiImageView.image = moreEmoji
            cell.isSelected = false
            cell.addGestureRecognizer(moreEmojiTapRecognizer)
            return cell
        }
        
        let reaction = reactions[indexPath.row]
        let emojiKey = reaction.key
        
        let selectedEmoji = emojiList.first (where: { $0.key == reaction.key })
        cell.configure(type: .messageReaction,
                       url: selectedEmoji?.url,
                       count: reaction.userIds.count)
        
        cell.emojiLongPressHandler = { [weak self] in
            guard let self = self else { return }
            self.emojiLongPressHandler?(emojiKey)
        }
        
        guard let currentUser = SBUGlobals.CurrentUser else { return cell }
        cell.isSelected = reaction.userIds.contains(currentUser.userId)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard !self.hasMoreEmoji(at: indexPath) else { return }

        let reaction = reactions[indexPath.row]
        self.emojiTapHandler?(reaction.key)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.hasMoreEmoji(at: indexPath) {
            return self.getCellSize(count: 0)
        }

        let count = reactions[indexPath.row].userIds.count
        return self.getCellSize(count:count)
    }
}
