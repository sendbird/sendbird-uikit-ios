//
//  SBUMenuViewController.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/04/26.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBUMenuViewController: SBUBaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Emoji reaction bar (in Message menu)
    lazy var collectionView = UICollectionView(
        frame: .init(x: 0, y: 0, width: 0, height: 76),
        collectionViewLayout: layout
    )
    
    let layout: UICollectionViewFlowLayout = SBUCollectionViewFlowLayout()
    var tableView = UITableView()
    let message: SBDBaseMessage
    let itemTypes: [MessageMenuItem]
    let emojiList: [SBDEmoji] = SBUEmojiManager.getAllEmojis()
    var useReaction: Bool

    let maxEmojiOneLine = 6

    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme

    // MARK: - Action
    var tapHandlerToMenu: ((MessageMenuItem) -> Void)? = nil
    var emojiTapHandler: ((_ emojiKey: String, _ setSelect: Bool) -> Void)? = nil
    var moreEmojiTapHandler: (() -> Void)? = nil
    var dismissHandler: (() -> Void)? = nil

    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUMenuViewController.init()")
    required public init?(coder: NSCoder) {
        self.message = SBDBaseMessage()
        self.itemTypes = []
        self.useReaction = false
        super.init(coder: coder)
    }

    /// Use this function when initialize.
    /// - Parameter itemTypes: Menu item types
    init(message: SBDBaseMessage, itemTypes: [MessageMenuItem], useReaction: Bool) {
        self.message = message
        self.itemTypes = itemTypes
        self.useReaction = useReaction
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        // autolayout
        self.view.addSubview(self.tableView)

        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.register(
            SBUMenuCell.sbu_loadNib(),
            forCellReuseIdentifier: SBUMenuCell.sbu_className
        ) // for xib

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 56
        self.tableView.backgroundColor = .clear

        if useReaction, !emojiList.isEmpty {
            self.tableView.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 76))
            self.tableView.tableHeaderView?.addSubview(self.collectionView)

            // collectionView
            self.layout.scrollDirection = .horizontal
            self.layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
            self.layout.itemSize = SBUConstant.emojiListCollectionViewCellSize

            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            self.collectionView.register(
                SBUReactionCollectionViewCell.sbu_loadNib(),
                forCellWithReuseIdentifier: SBUReactionCollectionViewCell.sbu_className
            ) // for xib
            self.collectionView.bounces = false
            self.collectionView.showsHorizontalScrollIndicator = false
            self.collectionView.backgroundColor = .clear
        }

        // autolayout
        self.setupAutolayout()

        // Styles
        self.setupStyles()
    }


    /// This function handles the initialization of autolayouts.
    override func setupAutolayout() {
        self.tableView.setConstraint(from: self.view, left: 0, right: 0, top: 0, bottom: 0)
        self.tableView.layoutIfNeeded()

        if let tableHeaderView = self.tableView.tableHeaderView {
            self.collectionView.setConstraint(
                from: tableHeaderView,
                left: 0,
                right: 0,
                top: 0,
                bottom: 0
            )
        }
    }

    /// This function handles the initialization of styles.
    override func setupStyles() {
        self.view.backgroundColor = theme.backgroundColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let itemCount: CGFloat = CGFloat(
            emojiList.count < maxEmojiOneLine
            ? emojiList.count
            : maxEmojiOneLine
        )
        if itemCount > 2 {
            let space = (
                self.view.frame.width
                    - layout.sectionInset.left
                    - layout.sectionInset.right
                    - itemCount * layout.itemSize.width
                ) / (itemCount - 1)
            self.layout.minimumLineSpacing = space
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let bottomSheet = self.presentationController as? SBUBottomSheetController {

            bottomSheet.isEnableTop = false
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            bottomSheet.contentHeight = tableView.contentSize.height + bottomPadding
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissHandler?()
    }

    // MARK: - UITableView relations
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(
            withIdentifier: SBUMenuCell.sbu_className,
            for: indexPath
            ) as? SBUMenuCell else { return .init() }
        
        let item = self.itemTypes[indexPath.row]
        switch item {
        case .delete:
            cell.isEnabled = message.threadInfo.replyCount == 0
        case .reply:
            cell.isEnabled = message.parent == nil
        default: break
        }
        cell.configure(type: self.itemTypes[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SBUMenuCell {
            if cell.isEnabled == false {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        }
        self.dismiss(animated: true) {
            self.tapHandlerToMenu?(self.itemTypes[indexPath.row])
        }
    }

    // MARK: - UICollectionView relations
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiList.count < 6 ? emojiList.count : 6
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUReactionCollectionViewCell.sbu_className,
            for: indexPath) as? SBUReactionCollectionViewCell else { return .init() }

        if indexPath.row == 5, self.emojiList.count > 6 {
            let moreEmoji = SBUIconSetType.iconEmojiMore.image(
                with: theme.addReactionTintColor,
                to: SBUIconSetType.Metric.iconEmojiLarge
            )
            cell.configure(type: .messageMenu, url: nil)
            cell.emojiImageView.image = moreEmoji
            cell.isSelected = false
            return cell
        }

        let emoji = emojiList[indexPath.row]
        cell.configure(type: .messageMenu, url: emoji.url)

        guard let currentUesr = SBUGlobals.CurrentUser else { return cell }
        let didSelect = message.reactions
            .first { $0.key == emoji.key }?.userIds
            .contains(currentUesr.userId) ?? false
        cell.isSelected = didSelect

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 5, self.emojiList.count > 6 {
            self.moreEmojiTapHandler?()
            self.dismiss(animated: true)
            return
        }

        guard let currentUesr = SBUGlobals.CurrentUser else {
            self.dismiss(animated: true); return
        }

        let emoji = emojiList[indexPath.row]
        if let reaction = message.reactions.first(where: { $0.key == emoji.key }) {
            let shouldSelect = reaction.userIds.contains(currentUesr.userId) == false
            self.emojiTapHandler?(emoji.key, shouldSelect)
        } else {
            self.emojiTapHandler?(emoji.key, true)
        }
 
        self.dismiss(animated: true)
    }
}
