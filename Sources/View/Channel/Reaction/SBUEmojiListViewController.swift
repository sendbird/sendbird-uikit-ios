//
//  SBUEmojiListViewController.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/26.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// A view controller that displays a list of emojis.
///
/// This class is responsible for managing and displaying a collection of emojis. It handles user interactions with the emojis and communicates with the bottom sheet controller.
///
/// - Since: 3.28.0
open class SBUEmojiListViewController: SBUBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SBUBottomSheetControllerDelegate, UIGestureRecognizerDelegate {

    public private(set) lazy var collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
    public let layout: UICollectionViewFlowLayout = SBUCollectionViewFlowLayout()
    public let emojiList: [Emoji]
    public let message: BaseMessage?
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme

    public var maxEmojiOneLine = 6

    lazy var bottomSheet: SBUBottomSheetController? = {
        self.presentationController as? SBUBottomSheetController
    }()

    var safeBottomPadding: CGFloat {
        let window = UIApplication.shared.currentWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    // MARK: - Action
    /// A handler that gets called when an emoji is tapped.
    ///
    /// - Parameters:
    ///   - emojiKey: The key of the tapped emoji.
    ///   - setSelect: A boolean indicating whether the emoji should be selected.
    /// - Since: 3.28.0
    public var emojiTapHandler: ((_ emojiKey: String, _ setSelect: Bool) -> Void)?
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUEmojiListViewController.init(message:)")
    required public init?(coder: NSCoder) {
        self.message = nil
        self.emojiList = SBUEmojiManager.getAllEmojis()
        super.init(coder: coder)
    }

    /// Use this function when initialize.
    /// - Parameter message: BaseMessage
    required public init(message: BaseMessage) {
        self.message = message
        
        // Filter emojis if custom `SBUGlobals.emojiCategoryFilter` is defined.
        emojiList = SBUEmojiManager.getAvailableEmojis(message: message)
        
        super.init(nibName: nil, bundle: nil)
    }

    open override func viewDidLayoutSubviews() {
        self.updateLayouts()
        
        super.viewDidLayoutSubviews()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if let bottomSheet = self.bottomSheet {
            self.collectionView.isScrollEnabled = bottomSheet.currentSnapPoint == .top

            let maxMiddleHeight = SBUConstant.bottomSheetMaxMiddleHeight + safeBottomPadding
            let calculatedHeieht = calculateCollectionViewContentHeight()
            let contentHeight = calculatedHeieht <= maxMiddleHeight
                ? calculatedHeieht
                : maxMiddleHeight

            let isEnableTop = calculatedHeieht > maxMiddleHeight
            bottomSheet.isEnableTop = isEnableTop
            bottomSheet.contentHeight = contentHeight
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard emojiList.count > 0 else { return }
        self.collectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // collectionView
        self.layout.itemSize = SBUConstant.emojiListCollectionViewCellSize
        self.layout.sectionInset = UIEdgeInsets(
            top: 12,
            left: 16,
            bottom: safeBottomPadding + 8,
            right: 16
        )
        self.layout.scrollDirection = .vertical
        self.layout.minimumLineSpacing = 16

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(
            SBUReactionCollectionViewCell.self,
            forCellWithReuseIdentifier: SBUReactionCollectionViewCell.sbu_className
        ) // for xib
        self.collectionView.bounces = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.isScrollEnabled = false
        self.collectionView.backgroundColor = .clear

        self.bottomSheet?.bottomSheetDelegate = self
        self.bottomSheet?.panGesture.delegate = self

        self.view.addSubview(self.collectionView)
    }

    open override func setupLayouts() {
        self.collectionView.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
        self.collectionView.layoutIfNeeded()
    }
    
    open override func updateLayouts() {
        let itemCount = CGFloat(
            emojiList.count < maxEmojiOneLine
            ? emojiList.count
            : maxEmojiOneLine
        )
        if itemCount > 2 {
            let space = (
                self.view.frame.width
                    - layout.sectionInset.left
                    - layout.sectionInset.right
                    - itemCount * layout.itemSize.width - 1
                ) / (itemCount - 1)
            self.layout.minimumInteritemSpacing = space
        }
        self.collectionView.layoutIfNeeded()
        self.collectionView.reloadData()

        self.collectionView.isScrollEnabled = self.bottomSheet?.currentSnapPoint == .top
    }

    open override func setupStyles() {
        self.view.backgroundColor = theme.backgroundColor
    }

    // MARK: - Common
    
    /// Calculates the height of the collection view content based on the number of emojis.
    ///
    /// - Returns: The total height required to display all emojis in the collection view.
    /// - Since: 3.28.0
    open func calculateCollectionViewContentHeight() -> CGFloat {
        let lineCount = CGFloat((emojiList.count + maxEmojiOneLine - 1) / maxEmojiOneLine)
        return lineCount * layout.itemSize.height
            + (lineCount - 1) * layout.minimumLineSpacing
            + layout.sectionInset.top
            + layout.sectionInset.bottom
    }

    // MARK: - UICollectionView relations
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return emojiList.count
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUReactionCollectionViewCell.sbu_className,
            for: indexPath
        ) as? SBUReactionCollectionViewCell else {
            return .init()
        }

        let emoji = emojiList[indexPath.row]
        cell.configure(type: .messageMenu, url: emoji.url)

        guard let currentUesr = SBUGlobals.currentUser else {
            return cell
        }
        let didSelect = self.message?.reactions
            .first { $0.key == emoji.key }?
            .userIds.contains(currentUesr.userId) ?? false
        cell.isSelected = didSelect
        
        return cell
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let currentUesr = SBUGlobals.currentUser else { self.dismiss(animated: true); return }

        let emoji = emojiList[indexPath.row]

        let wasSelected = message?.reactions
            .first { $0.key == emoji.key }?.userIds
            .contains(currentUesr.userId) ?? false

        self.emojiTapHandler?(emoji.key, !wasSelected)
        self.dismiss(animated: true)
    }

    // MARK: - UIGestureRecognizerDelegate
    open func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
            panGesture == bottomSheet?.panGesture {
            
            let velocity = panGesture.velocity(in: self.view).y
            if velocity >= 0, collectionView.contentOffset.y <= 0 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    // MARK: - SBUBottomSheetControllerDelegate
    
    /// This function is called when the bottom sheet moves to a specific position.
    /// - Since: 3.28.0
    open func bottomSheet(moveTo position: SBUBottomSheetSnapPoint) {
        switch position {
        case .top:
            collectionView.isScrollEnabled = true
            self.bottomSheet?.isEnableMiddle = false
        case .middle:
            collectionView.isScrollEnabled = false
        case .close:
            break
        }
    }
}
