//
//  SBUMessageReactionView.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/05/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// A set of properties that are passed onto `SBUMessageReactionView` and its subclasses.
/// - Since: 3.27.0
public class SBUMessageReactionViewParams {
    let maxWidth: CGFloat
    let useReaction: Bool
    let reactions: [Reaction]
    let enableEmojiLongPress: Bool
    let message: BaseMessage?
    
    public init(
        maxWidth: CGFloat,
        useReaction: Bool,
        reactions: [Reaction],
        enableEmojiLongPress: Bool,
        message: BaseMessage? = nil
    ) {
        self.maxWidth = maxWidth
        self.useReaction = useReaction
        self.reactions = message?.reactions ?? reactions
        self.enableEmojiLongPress = enableEmojiLongPress
        self.message = message
    }
}

/// Emoji reaction box
open class SBUMessageReactionView: SBUView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    public let layout: UICollectionViewFlowLayout = SBUCollectionViewFlowLayout()

    public var message: BaseMessage?
    public var emojiList: [Emoji] = []
    public var reactions: [Reaction] = []
    public var maxWidth: CGFloat = SBUConstant.messageCellMaxWidth
    
    /// The boolean value that decides whether to enable a long press on an reaction emoji.
    /// If `true`, a member list for each reaction emoji is shown.
    /// - Since: 3.19.0
    public var enableEmojiLongPress: Bool = true

    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme

    var emojiTapHandler: ((_ emojiKey: String) -> Void)?
    var moreEmojiTapHandler: (() -> Void)?
    var emojiLongPressHandler: ((_ emojiKey: String) -> Void)?
    var errorHandler: ((_ error: SBError) -> Void)?

    public private(set) var collectionViewHeightConstraint: NSLayoutConstraint?
    public private(set) var collectionViewMinWidthContraint: NSLayoutConstraint?

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
            SBUReactionCollectionViewCell.self,
            forCellWithReuseIdentifier: SBUReactionCollectionViewCell.sbu_className
        ) // for xib

        self.collectionView.bounces = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.isScrollEnabled = false
        self.collectionView.backgroundColor = .clear
        
        if self.collectionView.currentLayoutDirection.isRTL {
            self.collectionView.transform = .init(scaleX: -1, y: 1)
        }

        self.addSubview(self.collectionView)
    }

    open override func setupLayouts() {
        super.setupLayouts()
        
        self.collectionView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)

        self.collectionViewHeightConstraint = self.collectionView
            .heightAnchor.constraint(equalToConstant: 0)

        self.collectionViewMinWidthContraint = self.collectionView
            .widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        
        NSLayoutConstraint.sbu_activate(baseView: self.collectionView, constraints: [
            self.collectionViewHeightConstraint,
            self.collectionViewMinWidthContraint
        ])
    }

    open override func setupStyles() {
        super.setupStyles()
        
        self.clipsToBounds = true
        self.backgroundColor = theme.reactionBoxBackgroundColor
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = theme.reactionBoxBorderLineColor.cgColor
    }

    public func hasMoreEmoji(at indexPath: IndexPath) -> Bool {
        return self.reactions.count < emojiList.count &&
            self.reactions.count == indexPath.row
    }
    
    open func configure(
        maxWidth: CGFloat,
        useReaction: Bool,
        reactions: [Reaction],
        enableEmojiLongPress: Bool
    ) {
        let params = SBUMessageReactionViewParams(
            maxWidth: maxWidth,
            useReaction: useReaction,
            reactions: reactions,
            enableEmojiLongPress: enableEmojiLongPress,
            message: nil
        )
        
        self.configure(configuration: params)
    }
    
    open func configure(configuration: SBUMessageReactionViewParams) {
        guard configuration.useReaction, !configuration.reactions.isEmpty else {
            self.collectionViewMinWidthContraint?.isActive = false
            self.isHidden = true
            return
        }
        
        self.collectionViewMinWidthContraint?.isActive = true
        self.isHidden = false
        self.maxWidth = configuration.maxWidth
        self.message = configuration.message
        self.reactions = configuration.message?.reactions ?? configuration.reactions
        self.emojiList = SBUEmojiManager.getAllEmojis()
        self.enableEmojiLongPress = configuration.enableEmojiLongPress
        
        let hasMoreEmoji = hasMoreEmoji()
        let cellSizes = reactions.reduce(0) {
            $0 + self.getCellSize(count: $1.userIds.count).width
        }
        
        var width: CGFloat = cellSizes
        + CGFloat(reactions.count - 1) * layout.minimumLineSpacing
        + layout.sectionInset.left + layout.sectionInset.right
        if hasMoreEmoji {
            width += self.getCellSize(count: 0).width + layout.minimumLineSpacing
        }
        self.collectionViewMinWidthContraint?.constant = width < maxWidth ? width : maxWidth
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        self.collectionViewHeightConstraint?.constant = self.collectionView
            .collectionViewLayout.collectionViewContentSize.height
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

    open func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard !reactions.isEmpty else { return 0 }

        if hasMoreEmoji() {
            return self.reactions.count + 1
        } else {
            return self.reactions.count
        }
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUReactionCollectionViewCell.sbu_className,
            for: indexPath) as? SBUReactionCollectionViewCell else { return .init() }
        
        cell.removeGestureRecognizer(moreEmojiTapRecognizer)
        
        if cell.currentLayoutDirection.isRTL {
            cell.contentView.transform = .init(scaleX: -1, y: 1)
        }
        
        if self.hasMoreEmoji(at: indexPath) {
            let moreEmoji = SBUIconSetType.iconEmojiMore.image(
                with: theme.addReactionTintColor,
                to: SBUIconSetType.Metric.iconEmojiSmall
            )
            cell.emojiImageViewRatioConstraint?.isActive = false
            cell.configure(
                type: .messageReaction,
                url: nil, 
                needsSideMargin: self.sameCellWidth
            )

            cell.emojiImageView.image = moreEmoji
            cell.emojiImageViewRatioConstraint?.isActive = true
            cell.isSelected = false
            cell.addGestureRecognizer(moreEmojiTapRecognizer)
            return cell
        }
        
        guard let reaction = reactions[safe: indexPath.row] else { return cell }
        let emojiKey = reaction.key
        
        let selectedEmoji = emojiList.first(where: { $0.key == reaction.key })
        cell.emojiImageViewRatioConstraint?.isActive = false
        cell.configure(
            type: .messageReaction,
            url: selectedEmoji?.url,
            count: reaction.userIds.count,
            needsSideMargin: self.sameCellWidth
        )
        cell.emojiImageViewRatioConstraint?.isActive = true
        cell.emojiLongPressHandler = { [weak self] in
            guard let self = self, self.enableEmojiLongPress else { return }
            self.emojiLongPressHandler?(emojiKey)
        }
        
        guard let currentUser = SBUGlobals.currentUser else { return cell }
        DispatchQueue.main.async {
            cell.isSelected = reaction.userIds.contains(currentUser.userId)
        }
        
        return cell
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard !self.hasMoreEmoji(at: indexPath) else { return }
        guard !reactions.isEmpty else { return }
        
        let reaction = reactions[indexPath.row]
        self.emojiTapHandler?(reaction.key)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let message = self.message else {
            return false
        }
        
        // Defense code for when different EmojiCategory had been applied in the past.
        // Block reaction add/delete if the selected emoji is no longer supported due to being filtered by EmojiCategory.
        let emojiKey = reactions[indexPath.row].key
        if !SBUEmojiManager.isEmojiAvailable(emojiKey: emojiKey, message: message) {
            let error = SBUError(code: .emojiUnsupported)
            SBULog.info(error.code.message)
            self.errorHandler?(error.asSBError())  // lets users handle the error.
            return false
        }

        return true
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        guard !self.hasMoreEmoji(at: indexPath) else { return self.getCellSize(count: 0) }
        guard !reactions.isEmpty else { return self.getCellSize(count: 0) }

        let count = reactions[indexPath.row].userIds.count
        return self.getCellSize(count: count)
    }
    
    /// Computes whether there are emojis left to react to a message with.
    /// - returns: `true` if there are more emojis, `false` if not.
    /// - Since: 3.27.0
    public func hasMoreEmoji() -> Bool {
        let availableEmojis = SBUEmojiManager.getAvailableEmojis(message: message)
        let reactedEmojiKeys = reactions.map { $0.key }
        let unreactedAvailableEmojis = availableEmojis.filter { !reactedEmojiKeys.contains($0.key) }
        let hasMoreEmoji = !unreactedAvailableEmojis.isEmpty
        return hasMoreEmoji
    }
}
