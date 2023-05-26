//
//  SBUReactionsViewController.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/24.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Reacted user list
class SBUReactionsViewController: SBUBaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, SBUBottomSheetControllerDelegate {

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let layout: UICollectionViewFlowLayout = SBUCollectionViewFlowLayout()
    let stackView = UIStackView()
    let lineView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.5))
    let tableView = UITableView()
    let emojiList = SBUEmojiManager.getAllEmojis()

    var channel: GroupChannel!
    var selectedReaction: Reaction?
    var memberList: [Member] = []
    var reactionList: [Reaction] = []

    var collectionViewConstraintWidth: NSLayoutConstraint!
    var collectionViewConstraintMaxWidth: NSLayoutConstraint!

    var theme = SBUTheme.componentTheme

    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUReactionsViewController.init(channel:message:selectedReaction:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Use this function when initialize.
    /// - Parameter message: BaseMessage types
    init(channel: GroupChannel, message: BaseMessage, selectedReaction: Reaction?) {
        super.init(nibName: nil, bundle: nil)
        self.channel = channel
        self.reactionList = message.reactions
        self.selectedReaction = selectedReaction

        let members = self.channel?.members as? [Member] ?? []
        self.memberList = members
    }

    override func setupViews() {
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
        self.tableView.allowsSelection = false
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
            SBUReactionCollectionViewCell.sbu_loadNib(),
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
    override func setupLayouts() {
        self.stackView.setConstraint(from: self.view, left: 0, right: 0, top: 0, bottom: 0)
        self.tableView.setConstraint(from: self.stackView, left: 0)
        self.lineView .setConstraint(from: self.stackView, left: 0).setConstraint(height: 0.5)

        self.collectionView.setConstraint(height: 60).setConstraint(from: self.view, centerX: true)

        self.collectionViewConstraintWidth = self.collectionView.widthAnchor.constraint(
            equalToConstant: 0
        )
        self.collectionViewConstraintWidth.priority = .defaultLow

        self.collectionViewConstraintMaxWidth = self.collectionView.widthAnchor.constraint(
            lessThanOrEqualToConstant: self.view.frame.width
        )

        NSLayoutConstraint.activate([
            self.collectionViewConstraintWidth,
            self.collectionViewConstraintMaxWidth
        ])

        self.collectionView.layoutIfNeeded()
        self.view.setNeedsLayout()
    }
    
    override func updateLayouts() {
        self.collectionViewConstraintWidth.constant = self.collectionView.contentSize.width
        self.collectionViewConstraintMaxWidth.constant = self.view.bounds.width
        self.collectionView.layoutIfNeeded()

        if let bottomSheet = self.presentationController as? SBUBottomSheetController {
            self.tableView.isScrollEnabled = bottomSheet.currentSnapPoint == .top
        }
    }

    /// This function handles the initialization of styles.
    override func setupStyles() {
        self.view.backgroundColor = theme.backgroundColor
        self.lineView.backgroundColor = theme.reactionMenuLineColor
        self.tableView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let bottomSheet = self.presentationController as? SBUBottomSheetController {

            let window = UIApplication.shared.currentWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            bottomSheet.contentHeight = SBUConstant.bottomSheetMaxMiddleHeight + bottomPadding
        }
    }

    override func viewDidLayoutSubviews() {
        self.updateLayouts()
        
        super.viewDidLayoutSubviews()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let selectedReaction = self.selectedReaction,
              selectedReaction.userIds.count > 0 else { return }
        self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = getSelectedIndexPath() {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = getSelectedIndexPath() {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    // MARK: - Private func
    private func getSelectedIndexPath() -> IndexPath? {
        guard let selectedReaction = self.selectedReaction else { return nil }
        
        return self.reactionList.enumerated().compactMap {
            $0.element.key == selectedReaction.key
                ? IndexPath(item: $0.offset, section: 0)
                : nil
        }.first
    }

    private func getCellSize(count: Int) -> CGSize {
        switch count {
        case 0...9:
            return CGSize(width: 41, height: 44)
        case 10...99:
            return CGSize(width: 49, height: 44)
        default:
            return CGSize(width: 57, height: 44)
        }
    }

    // MARK: - UITableView relations
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedReaction = self.selectedReaction else { return 0 }
        
        return selectedReaction.userIds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(
            withIdentifier: SBUUserCell.sbu_className
            ) as? SBUUserCell else { return .init() }

        guard let selectedReaction = self.selectedReaction,
              indexPath.row < selectedReaction.userIds.count else { return .init() }

        let userId = selectedReaction.userIds[indexPath.row]
        let user = memberList.first { $0.userId == userId }.map { SBUUser(user: $0) }
            ?? SBUUser(
                userId: userId,
                nickname: SBUStringSet.User_No_Name,
                profileURL: nil)
        cell.configure(type: .reaction, user: user)
        return cell
    }

    // MARK: - UICollectionView relations
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reactionList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUReactionCollectionViewCell.sbu_className,
            for: indexPath) as? SBUReactionCollectionViewCell else { return .init() }

        guard reactionList.count > indexPath.row else { return .init() }
        
        let reaction = self.reactionList[indexPath.row]
        let emoji = self.emojiList.first(where: { $0.key == reaction.key })
        cell.configure(type: .reactions, url: emoji?.url, count: reaction.userIds.count)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.getCellSize(count: self.reactionList[indexPath.row].userIds.count)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    func bottomSheet(moveTo position: SBUBottomSheetSnapPoint) {

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
