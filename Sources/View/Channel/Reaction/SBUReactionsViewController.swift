//
//  SBUReactionsViewController.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/24.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.11.0
public protocol SBUReactionsViewControllerDelegate: SBUCommonDelegate {
    /// Called when the user cell was selected in the `tableView`.
    /// - Parameters:
    ///   - viewController: `SBUReactionsViewController` object
    ///   - tableView: `UITableView` object
    ///   - user: The `SBUUser` of user profile that was selected.
    ///   - indexPath: An index path locating the row in table view of `tableView`
    func reactionsViewController(
        _ viewController: SBUReactionsViewController,
        tableView: UITableView,
        didSelect user: SBUUser,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the user profile was tapped in the `tableView`.
    /// - Parameters:
    ///   - viewController: `SBUReactionsViewController` object
    ///   - user: The `SBUUser` of user profile that was tapped.
    func reactionsViewController(
        _ viewController: SBUReactionsViewController,
        didTapUserProfile user: SBUUser
    )
}

/// Reacted user list
/// - Since: 3.11.0
open class SBUReactionsViewController: SBUBaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, SBUBottomSheetControllerDelegate {

    public private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    public let layout: UICollectionViewFlowLayout = SBUCollectionViewFlowLayout()
    public let stackView = UIStackView()
    public let lineView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.5))
    public let tableView = UITableView()
    public let emojiList = SBUEmojiManager.getAllEmojis()

    public private(set) var channel: GroupChannel!
    public private(set) var selectedReaction: Reaction?
    public private(set) var memberList: [Member] = []
    public private(set) var reactionList: [Reaction] = []

    public weak var delegate: SBUReactionsViewControllerDelegate? // 3.11.0

    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme

    var collectionViewConstraintWidth: NSLayoutConstraint?
    var collectionViewConstraintMaxWidth: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUReactionsViewController.init(channel:message:selectedReaction:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Use this function when initialize.
    /// - Parameter message: BaseMessage types
    required public init(channel: GroupChannel, message: BaseMessage, selectedReaction: Reaction?) {
        super.init(nibName: nil, bundle: nil)
        self.channel = channel
        self.reactionList = message.reactions
        self.selectedReaction = selectedReaction

        let members = self.channel?.members as? [Member] ?? []
        self.memberList = members
    }

    open override func setupViews() {
        // stackView
        self.stackView.axis = .vertical
        self.stackView.alignment = .center

        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.isScrollEnabled = false
        self.tableView.register(
            type(of: SBUUserCell()),
            forCellReuseIdentifier: SBUUserCell.sbu_className
        )
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 56

        // collectionView
        self.layout.sectionInset = UIEdgeInsets(top: 16, left: 19, bottom: 0, right: 19)
        self.layout.scrollDirection = .horizontal
        self.layout.minimumLineSpacing = 16

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(
            SBUReactionCollectionViewCell.self,
            forCellWithReuseIdentifier: SBUReactionCollectionViewCell.sbu_className
        ) // for xib
        self.collectionView.bounces = false
        self.collectionView.showsHorizontalScrollIndicator = false

        if let bottomSheetVC = self.presentationController as? SBUBottomSheetController {
            bottomSheetVC.bottomSheetDelegate = self
        }

        self.view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.collectionView)
        self.stackView.addArrangedSubview(self.lineView)
        self.stackView.addArrangedSubview(self.tableView)
    }

    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        self.stackView.sbu_constraint(
            equalTo: self.view,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0
        )
        self.tableView.sbu_constraint(equalTo: self.stackView, left: 0)
        self.lineView
            .sbu_constraint(equalTo: self.stackView, left: 0)
            .sbu_constraint(height: 0.5)

        self.collectionView
            .sbu_constraint(height: 60)
            .sbu_constraint(equalTo: self.view, centerX: 0)
        
        self.collectionViewConstraintWidth?.isActive = false
        self.collectionViewConstraintMaxWidth?.isActive = false

        self.collectionViewConstraintWidth = self.collectionView.widthAnchor.constraint(
            equalToConstant: 0
        )
        self.collectionViewConstraintWidth?.priority = .defaultLow

        self.collectionViewConstraintMaxWidth = self.collectionView.widthAnchor.constraint(
            lessThanOrEqualToConstant: self.view.frame.width
        )

        self.collectionViewConstraintWidth?.isActive = true
        self.collectionViewConstraintMaxWidth?.isActive = true

        self.collectionView.layoutIfNeeded()
        self.view.setNeedsLayout()
    }
    
    open override func updateLayouts() {
        self.collectionViewConstraintWidth?.constant = self.collectionView.contentSize.width
        self.collectionViewConstraintMaxWidth?.constant = self.view.bounds.width
        self.collectionView.layoutIfNeeded()

        if let bottomSheet = self.presentationController as? SBUBottomSheetController {
            self.tableView.isScrollEnabled = bottomSheet.currentSnapPoint == .top
        }
    }

    /// This function handles the initialization of styles.
    open override func setupStyles() {
        self.view.backgroundColor = theme.backgroundColor
        self.lineView.backgroundColor = theme.reactionMenuLineColor
        self.tableView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if let bottomSheet = self.presentationController as? SBUBottomSheetController {

            let window = UIApplication.shared.currentWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            bottomSheet.contentHeight = SBUConstant.bottomSheetMaxMiddleHeight + bottomPadding
        }
    }

    open override func viewDidLayoutSubviews() {
        self.updateLayouts()
        
        super.viewDidLayoutSubviews()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let selectedReaction = self.selectedReaction,
              selectedReaction.userIds.count > 0 else { return }
        self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = getSelectedIndexPath() {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = getSelectedIndexPath() {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    // MARK: - Common
    
    /// Retrieves the index path for the currently selected reaction, if any.
    /// - Since: 3.28.0
    public func getSelectedIndexPath() -> IndexPath? {
        guard let selectedReaction = self.selectedReaction else { return nil }
        
        return self.reactionList.enumerated().compactMap {
            $0.element.key == selectedReaction.key
                ? IndexPath(item: $0.offset, section: 0)
                : nil
        }.first
    }

    /// This function retrieves the size of the cell based on the number of reactions.
    /// - Since: 3.28.0
    public func getCellSize(count: Int) -> CGSize {
        switch count {
        case 0...9:
            return CGSize(width: 41, height: 44)
        case 10...99:
            return CGSize(width: 49, height: 44)
        default:
            return CGSize(width: 57, height: 44)
        }
    }
    
    /// This function retrieves the user for the specified index path.
    /// - Since: 3.28.0
    public func getUser(with indexPath: IndexPath) -> SBUUser? {
        guard let selectedReaction = self.selectedReaction,
              indexPath.row < selectedReaction.userIds.count else { return nil }
        let userId = selectedReaction.userIds[indexPath.row]
        let user = memberList
            .first { $0.userId == userId }
            .map { SBUUser(user: $0) } ?? SBUUser(
                userId: userId,
                nickname: SBUStringSet.User_No_Name,
                profileURL: nil
            )
        return user
    }
    
    // MARK: - Actions
    
    /// This function sets the user profile tap gesture handling.
    ///
    /// If you do not want to use the user profile function, override this function and leave it empty.
    /// - Parameter user: `SBUUser` object used for user profile configuration
    /// - Since: 3.11.0
    public func setUserProfileTapGesture(_ user: SBUUser) {
        self.delegate?.reactionsViewController(self, didTapUserProfile: user)
    }
    
    // MARK: - UITableView relations
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedReaction = self.selectedReaction else { return 0 }
        
        return selectedReaction.userIds.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(
            withIdentifier: SBUUserCell.sbu_className
            ) as? SBUUserCell else { return .init() }

        cell.selectionStyle = .none

        guard let user = getUser(with: indexPath) else { return .init() }
        cell.configure(type: .reaction, user: user)
        cell.userProfileTapHandler = { [weak cell, weak self] in
            guard let self = self else { return }
            guard cell != nil else { return }
            
            self.setUserProfileTapGesture(user)
        }
        return cell
    }
    
    /// - Since: 3.11.0
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = getUser(with: indexPath) else { return }
        
        self.delegate?.reactionsViewController(
            self,
            tableView: tableView,
            didSelect: user,
            forRowAt: indexPath
        )
    }

    // MARK: - UICollectionView relations
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reactionList.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUReactionCollectionViewCell.sbu_className,
            for: indexPath) as? SBUReactionCollectionViewCell else { return .init() }

        guard reactionList.count > indexPath.row else { return .init() }
        
        let reaction = self.reactionList[indexPath.row]
        let emoji = self.emojiList.first(where: { $0.key == reaction.key })
        
        cell.configure(
            type: .reactions,
            url: emoji?.url,
            count: reaction.userIds.count
        )
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.getCellSize(count: self.reactionList[indexPath.row].userIds.count)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard reactionList.count > indexPath.row else { return }

        self.selectedReaction = self.reactionList[indexPath.row]
        self.tableView.reloadData()
        
        guard collectionView.numberOfSections > 0,
              collectionView.numberOfItems(inSection: 0) > indexPath.row,
              let cell = collectionView.cellForItem(at: indexPath)
                as? SBUReactionCollectionViewCell else { return }
        
        cell.setCount(self.reactionList[indexPath.row].userIds.count)
    }

    // MARK: - SBUBottomSheetControllerDelegate
    
    /// This function is called when the bottom sheet moves to a specific position.
    /// - Since: 3.28.0
    open func bottomSheet(moveTo position: SBUBottomSheetSnapPoint) {
        switch position {
        case .top:
            self.tableView.isScrollEnabled = true
            (self.presentationController as? SBUBottomSheetController)?.isEnableMiddle = false
        case .middle:
            self.tableView.isScrollEnabled = false
        default:
            break
        }
    }
}
