//
//  SBUMessageReactionView.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/05/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Emoji reaction box
open class SBUMessageReactionView: SBUView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    public let layout: UICollectionViewFlowLayout = SBUCollectionViewFlowLayout()

    public var emojiList: [Emoji] = []
    public var reactions: [Reaction] = []
    public var maxWidth: CGFloat = SBUConstant.messageCellMaxWidth

    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme

    var emojiTapHandler: ((_ emojiKey: String) -> Void)?
    var moreEmojiTapHandler: (() -> Void)?
    var emojiLongPressHandler: ((_ emojiKey: String) -> Void)?

    public private(set) var collectionViewHeightConstraint: NSLayoutConstraint!
    public private(set) var collectionViewMinWidthContraint: NSLayoutConstraint!

    public let collectionViewInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    lazy var moreEmojiTapRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(self.onTapMoreEmoji(sender:))
    )
    
    var sameCellWidth = false
        
    public override init() {
        super.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable, renamed: "MessageReactionView()")
    public required init?(coder: NSCoder) {
        fatalError()
    }

    open override func setupViews() {
        super.setupViews()
        
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

    open override func setupLayouts() {
        super.setupLayouts()
        
        self.collectionView.setConstraint(from: self, left: 0, right: 0, top: 0, bottom: 0)

        self.collectionViewHeightConstraint = self.collectionView
            .heightAnchor.constraint(equalToConstant: 0)
        self.collectionViewHeightConstraint.isActive = true

        self.collectionViewMinWidthContraint = self.collectionView
            .widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        self.collectionViewMinWidthContraint.isActive = true
    }

    open override func setupStyles() {
        super.setupStyles()
        
        self.clipsToBounds = true
        self.backgroundColor = theme.reactionBoxBackgroundColor
        self.layer.cornerRadius = 16
        self.layer.borderWidth = 1
        self.layer.borderColor = theme.reactionBoxBorderLineColor.cgColor
    }

    public func hasMoreEmoji(at indexPath: IndexPath) -> Bool {
        return self.reactions.count < emojiList.count &&
            self.reactions.count == indexPath.row
    }
    
    open func configure(maxWidth: CGFloat, useReaction: Bool, reactions: [Reaction]) {
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

    /// The default value is `CGSize(width: 54, height: 30)`; if `count` is zero, the width is 36.
    open func getCellSize(count: Int) -> CGSize {
        return CGSize(width: count > 0 ? 54 : 36, height: 30)
    }

    // MARK: - Action

    @objc
    open func onTapMoreEmoji(sender: UITapGestureRecognizer) {
        let indexPath = IndexPath(row: reactions.count, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
        collectionView.deselectItem(at: indexPath, animated: true)
        self.moreEmojiTapHandler?()
    }

    // MARK: - UICollectionView relations
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard !reactions.isEmpty else { return 0 }

        if self.reactions.count < emojiList.count {
            return self.reactions.count + 1
        } else {
            return self.reactions.count
        }
    }

    open func collectionView(_ collectionView: UICollectionView,
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
            cell.configure(type: .messageReaction, url: nil, needsSideMargin: self.sameCellWidth)
            cell.emojiImageView.image = moreEmoji
            cell.isSelected = false
            cell.addGestureRecognizer(moreEmojiTapRecognizer)
            return cell
        }
        
        let reaction = reactions[indexPath.row]
        let emojiKey = reaction.key
        
        let selectedEmoji = emojiList.first(where: { $0.key == reaction.key })
        cell.configure(type: .messageReaction,
                       url: selectedEmoji?.url,
                       count: reaction.userIds.count, needsSideMargin: self.sameCellWidth)
        
        cell.emojiLongPressHandler = { [weak self] in
            guard let self = self else { return }
            self.emojiLongPressHandler?(emojiKey)
        }
        
        guard let currentUser = SBUGlobals.currentUser else { return cell }
        DispatchQueue.main.async {
            cell.isSelected = reaction.userIds.contains(currentUser.userId)
        }
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard !self.hasMoreEmoji(at: indexPath) else { return }

        let reaction = reactions[indexPath.row]
        self.emojiTapHandler?(reaction.key)
    }

    open func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.hasMoreEmoji(at: indexPath) {
            return self.getCellSize(count: 0)
        }

        let count = reactions[indexPath.row].userIds.count
        return self.getCellSize(count: count)
    }
}
