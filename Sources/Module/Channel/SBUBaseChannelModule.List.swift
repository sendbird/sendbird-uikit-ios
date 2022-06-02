//
//  SBUBaseChannelModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


/// Event methods for the views updates and performing actions from the list component.
public protocol SBUBaseChannelModuleListDelegate: SBUCommonDelegate {
    /// Called when the `listComponent` is about to draw a cell for a particular row.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - cell: The table view cell that the list component going to use when drawing the row.
    ///    - indexPath: An index path locating the row in table view of `listComponent`
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the message cell was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - message: The message that was tapped.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didTapMessage message: SBDBaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the message cell was long tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - message: The message that was long tapped.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didLongTapMessage message: SBDBaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the user profile was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - user: The `SBUUser` of user profile that was tapped.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didTapUserProfile user: SBUUser
    )
    
    /// Called when the `scrollView` was scrolled.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - scrollView: The `scrollView`.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didScroll scrollView: UIScrollView
    )
    
    /// Called when the `scrollBottomView`was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - animated: if it's `true`, the list component will be scrolled while animating
    func baseChannelModuleDidTapScrollToButton(
        _ listComponent: SBUBaseChannelModule.List,
        animated: Bool
    )
    
    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUBaseChannelModule.List` object.
    func baseChannelModuleDidSelectRetry(_ listComponent: SBUBaseChannelModule.List)
}

/// Methods to get data source for the list component.
public protocol SBUBaseChannelModuleListDataSource: AnyObject {
    /// Ask the data source to return the `SBDBaseChannel` object.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `SBDBaseChannel` object.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, channelForTableView tableView: UITableView) -> SBDBaseChannel?
    
    /// Ask the data source to return the message list sent successfully.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `SBDBaseMessage` object that are sent successfully.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, sentMessagesInTableView tableView: UITableView) -> [SBDBaseMessage]
    
    /// Ask the data source to return the message list includes the sent, the failed and the pending.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `SBDBaseMessage` object including the sent, the failed and the pending.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, fullMessagesInTableView tableView: UITableView) -> [SBDBaseMessage]
    
    /// Ask the data source to return whether the `tableView` has next data.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: Whether the `tableView` has next data.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, hasNextInTableView tableView: UITableView) -> Bool
    
    /// Ask the data source to return the last seen index path
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The last seen `IndexPath`.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, lastSeenIndexPathIn tableView: UITableView) -> IndexPath?
    
    /// Ask the data source to return the starting point
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The starting point.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, startingPointIn tableView: UITableView) -> Int64?
}


extension SBUBaseChannelModule {
    /// A module component that represent the list of `SBUBaseChannelModule`.
    @objc(SBUBaseChannelModuleList)
    @objcMembers open class List: UIView, UITableViewDelegate, UITableViewDataSource {
        
        // MARK: - UI properties (Public)
        
        /// The table view to show messages in the channel
        public var tableView = UITableView()
        
        /// A view that shows when there is no message in the channel.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// A view that shows the state of the channel such as frozen state.
        public var channelStateBanner: UIView?
        
        /// A view that indicates a new received message.
        /// If you use a view that inherits `SBUNewMessageInfo`, you can change the button and their action.
        /// - NOTE: You can use the customized view and a view that inherits `SBUNewMessageInfo`.
        public var newMessageInfoView: UIView?
        
        /// A view that scrolls table view to the bottom.
        public var scrollBottomView: UIView?
        
        /// A view that shows profile of the user.
        /// If you do not want to use the user profile feature, please set this value to nil.
        /// - NOTE: To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`.
        public var userProfileView: UIView?
        
        /// The object that acts as the base delegate of the list component. The base delegate must adopt the `SBUBaseChannelModuleListDelegate`.
        public weak var baseDelegate: SBUBaseChannelModuleListDelegate?
        
        /// The object that acts as the base data source of the list component. The base data source must adopt the `SBUBaseChannelModuleListDataSource`.
        public weak var baseDataSource: SBUBaseChannelModuleListDataSource?
        
        /// The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class.
        public var theme: SBUChannelTheme? = nil
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        private lazy var defaultChannelStateBanner: UIView? = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = SBUStringSet.Channel_State_Banner_Frozen
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 5
            label.isHidden = true
            return label
        }()
        
        private lazy var defaultScrollBottomView: UIView? = {
            let view: UIView = UIView(frame: CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize))
            let theme = SBUTheme.componentTheme
            
            view.backgroundColor = .clear
            view.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 5)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 5
            view.layer.masksToBounds = false
            
            let scrollBottomButton = UIButton(frame: CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize))
            scrollBottomButton.layer.cornerRadius = scrollBottomButton.frame.height / 2
            scrollBottomButton.clipsToBounds = true
            
            scrollBottomButton.setImage(
                SBUIconSetType.iconChevronDown.image(
                    with: theme.scrollBottomButtonIconColor,
                    to: SBUIconSetType.Metric.iconChevronDown
                ),
                for: .normal
            )
            scrollBottomButton.backgroundColor = theme.scrollBottomButtonBackground
            scrollBottomButton.setBackgroundImage(UIImage.from(color: theme.scrollBottomButtonHighlighted), for: .highlighted)
            
            scrollBottomButton.addTarget(self, action: #selector(self.onTapScrollToBottom), for: .touchUpInside)
            view.addSubview(scrollBottomButton)
            
            scrollBottomButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollBottomButton.topAnchor.constraint(equalTo: view.topAnchor),
                scrollBottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollBottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollBottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            return view
        }()
        
        
        // MARK: - Logic properties (Public)
        
        /// The current channel object from `baseChannelModule(_:channelForTableView:)` data source method.
        public var baseChannel: SBDBaseChannel? {
            self.baseDataSource?.baseChannelModule(self, channelForTableView: self.tableView)
        }
        
        /// The array of sent messages in the channel. The value is returned by `baseChannelModule(_:sentMessagesInTableView:)` data source method.
        public var sentMessages: [SBDBaseMessage] {
            self.baseDataSource?.baseChannelModule(self, sentMessagesInTableView: self.tableView) ?? []
        }
        
        /// The array of all messages includes the sent, the failed and the pending. The value is returned by `baseChannelModule(_:fullMessagesInTableView:)` data source method.
        public var fullMessageList: [SBDBaseMessage] {
            self.baseDataSource?.baseChannelModule(self, fullMessagesInTableView: self.tableView) ?? []
        }
        
        
        // MARK: - Logic properties (Private)
        
        /// The object that is used as the cell animation debouncer.
        lazy var cellAnimationDebouncer: SBUDebouncer = SBUDebouncer()
        
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUBaseChannelModule.List()")
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        @available(*, unavailable, renamed: "SBUBaseChannelModule.List()")
        public override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        deinit {
            SBULog.info(#function)
        }
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            // empty view
            if self.emptyView == nil {
                self.emptyView = self.defaultEmptyView
            }
            
            // table view
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.tableView.separatorStyle = .none
            self.tableView.allowsSelection = false
            self.tableView.keyboardDismissMode = .interactive
            self.tableView.bounces = false
            self.tableView.alwaysBounceVertical = false
            
            self.emptyView?.transform = CGAffineTransform(scaleX: 1, y: -1)
            self.tableView.backgroundView = self.emptyView
            self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.addSubview(self.tableView)
            
            // channel state & common
            if self.channelStateBanner == nil {
                self.channelStateBanner = self.defaultChannelStateBanner
            }
            
            if let channelStateBanner = self.channelStateBanner {
                self.addSubview(channelStateBanner)
            }
            
            if self.newMessageInfoView == nil {
                self.newMessageInfoView = SBUNewMessageInfo()
            }
            
            if self.scrollBottomView == nil {
                self.scrollBottomView = self.defaultScrollBottomView
            }
            
            if self.userProfileView == nil {
                self.userProfileView = SBUUserProfileView(delegate: self)
            }
        }
        
        /// Sets layouts of the views in the list component.
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets styles of the views in the list component with the `theme`. If set theme parameter as `nil`, it uses the stored value.
        /// - Parameter theme: The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class.
        open func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            if let channelStateBanner = channelStateBanner as? UILabel {
                channelStateBanner.textColor = theme?.channelStateBannerTextColor
                channelStateBanner.font = theme?.channelStateBannerFont
                channelStateBanner.backgroundColor = theme?.channelStateBannerBackgroundColor
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
        }
        
        /// Updates styles of the views in the list component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class.
        ///   - componentTheme: The object that is used as the theme of some UI component in the list component such as `scrollBottomView`. The theme must adopt the `SBUComponentTheme` class. The default value is `SBUTheme.componentTheme`
        open func updateStyles(theme: SBUChannelTheme? = nil, componentTheme: SBUComponentTheme = SBUTheme.componentTheme) {
            self.setupStyles(theme: theme)
            
            if let userProfileView = self.userProfileView as? SBUUserProfileView {
                userProfileView.setupStyles()
            }
        }
        
        /// Sets the styles of `scrollBottomView`.
        /// - Parameters:
        ///   - scrollBottomView: The `scrollBottomView` object.
        ///   - theme: The object that is used as the theme of the `scrollBottomView`. The theme must adopt the `SBUComponentTheme` class. The default value is `SBUTheme.componentTheme`.
        public func setupScrollBottomViewStyle(
            scrollBottomView: UIView,
            theme: SBUComponentTheme = SBUTheme.componentTheme
        ) {
            self.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
            
            guard let scrollBottomButton = scrollBottomView.subviews.first as? UIButton else { return }
            
            scrollBottomButton.layer.cornerRadius = scrollBottomButton.frame.height / 2
            scrollBottomButton.clipsToBounds = true
            
            scrollBottomButton.setImage(
                SBUIconSetType.iconChevronDown.image(
                    with: theme.scrollBottomButtonIconColor,
                    to: SBUIconSetType.Metric.iconChevronDown
                ),
                for: .normal)
            scrollBottomButton.backgroundColor = theme.scrollBottomButtonBackground
            scrollBottomButton.setBackgroundImage(
                UIImage.from(color: theme.scrollBottomButtonHighlighted),
                for: .highlighted
            )
        }
        
        /// Updates hidden state of the `scrollBottomView`.
        open func setScrollBottomView(hidden: Bool) {
            self.scrollBottomView?.isHidden = hidden
        }
        
        // MARK: - TableView
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        // MARK: - EmptyView
        
        /// Update the `emptyView` according its type.
        /// - Parameter type: The value of `EmptyViewType`.
        public func updateEmptyView(type: EmptyViewType) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(type)
            }
        }
        
        // MARK: - Menu
        
        
        // MARK: - Actions
        
        /// Sets up the cell's tap gesture for handling the message.
        /// - Parameters:
        ///   - cell: Message cell object
        ///   - message: Message object
        ///   - indexPath: indexpath of cell
        open func setTapGesture(_ cell: UITableViewCell, message: SBDBaseMessage, indexPath: IndexPath) {
            self.baseDelegate?.baseChannelModule(self, didTapMessage: message, forRowAt: indexPath)
        }
        
        /// This function sets the cell's long tap gesture handling.
        /// - Parameters:
        ///   - cell: Message cell object
        ///   - message: Message object
        ///   - indexPath: indexpath of cell
        open func setLongTapGesture(_ cell: UITableViewCell, message: SBDBaseMessage, indexPath: IndexPath) {
            self.baseDelegate?.baseChannelModule(self, didLongTapMessage: message, forRowAt: indexPath)
        }
        
        /// This function sets the user profile tap gesture handling.
        ///
        /// If you do not want to use the user profile function, override this function and leave it empty.
        /// - Parameter user: `SBUUser` object used for user profile configuration
        open func setUserProfileTapGesture(_ user: SBUUser) {
            self.baseDelegate?.baseChannelModule(self, didTapUserProfile: user)
        }
        
        /// Moves scroll to bottom.
        @objc open func onTapScrollToBottom() {
            self.baseDelegate?.baseChannelModuleDidTapScrollToButton(self, animated: false)
        }
        
        
        // MARK: - UITableViewDelegate, UITableViewDataSource
        /// Called when the `scrollView` has been scrolled.
        open func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView == self.tableView else { return }
            self.baseDelegate?.baseChannelModule(self, didScroll: scrollView)
        }

        open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.fullMessageList.count
        }
        
        open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            preconditionFailure("Needs to implement this method")
        }
        
        open func tableView(
            _ tableView: UITableView,
            willDisplay cell: UITableViewCell,
            forRowAt indexPath: IndexPath
        ) {
            self.baseDelegate?.baseChannelModule(self, willDisplay: cell, forRowAt: indexPath)
        }
        
        open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        
        /// Sets images in file message cell.
        /// - Parameters:
        ///   - cell: File message cell
        ///   - fileMessage: File message object
        open func setFileMessageCellImage(_ cell: UITableViewCell, fileMessage: SBDFileMessage) {
            switch fileMessage.sendingStatus {
                case .canceled, .pending, .failed, .none:
                    guard let fileInfo = SBUPendingMessageManager.shared.getFileInfo(requestId: fileMessage.requestId),
                          let type = fileInfo.mimeType, let fileData = fileInfo.file,
                          SBUUtils.getFileType(by: type) == .image else { return }
                    
                    let image = UIImage.createImage(from: fileData)
                    let isAnimatedImage = image?.isAnimatedImage() == true
                    
                    if let cell = cell as? SBUFileMessageCell {
                        cell.setImage(
                            isAnimatedImage ? image?.images?.first : image,
                            size: SBUConstant.thumbnailSize
                        )
                    } else if let cell = cell as? SBUOpenChannelFileMessageCell {
                        cell.setImage(
                            isAnimatedImage ? image?.images?.first : image,
                            size: SBUConstant.openChannelThumbnailSize
                        )
                    }
                case .succeeded:
                    break
                @unknown default:
                    SBULog.error("unknown Type")
                    break
            }
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUBaseChannelModule.List: SBUEmptyViewDelegate {
    /// Reload data from the channel. This function invokes `SBUBaseChannelModuleListDelegate baseChannelModuleDidSelectRetry(_:)`
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noMessages)
        }
        
        SBULog.info("[Request] Retry load channel list")
        self.baseDelegate?.baseChannelModuleDidSelectRetry(self)
    }
}


// MARK: - SBUUserProfileViewDelegate
extension SBUBaseChannelModule.List: SBUUserProfileViewDelegate {
    open func didSelectClose() {
        // Implementation
        if let userProfileView = self.userProfileView as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
        }
    }
    
    open func didSelectMessage(userId: String?) {
        // Implementation
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
            if let userId = userId {
                SendbirdUI.createAndMoveToChannel(userIds: [userId])
            }
        }
    }
}

// MARK: - UITableViewCell
extension SBUBaseChannelModule.List {
    public var isScrollNearByBottom: Bool {
        return tableView.contentOffset.y < 10
    }
    
    /// To keep track of which scrolls tableview.
    func scrollTableView(
        to row: Int,
        at position: UITableView.ScrollPosition = .top,
        animated: Bool = false
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let isScrollable = !self.fullMessageList.isEmpty
                && row >= 0
                && row < self.fullMessageList.count
            
            if isScrollable {
                self.tableView.scrollToRow(
                    at: IndexPath(row: row, section: 0),
                    at: position,
                    animated: animated
                )
            } else {
                guard self.tableView.contentOffset != .zero else { return }
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    /// This function keeps the current scroll position with upserted messages.
    /// - Note: Only newly added messages are used for processing.
    /// - Parameter upsertedMessages: upserted messages
    func keepCurrentScroll(for upsertedMessages: [SBDBaseMessage]) -> IndexPath {
        let firstVisibleIndexPath = tableView
            .indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        var nextInsertedCount = 0
        if let newestMessage = sentMessages.first {
            // only filter out messages inserted at the bottom (newer) of current visible item
            nextInsertedCount = upsertedMessages
                .filter({ $0.createdAt > newestMessage.createdAt })
                .filter({ !SBUUtils.contains(messageId: $0.messageId, in: sentMessages) }).count
        }
        
        SBULog.info("New messages inserted : \(nextInsertedCount)")
        return IndexPath(
            row: firstVisibleIndexPath.row + nextInsertedCount,
            section: 0
        )
    }
    
    /// Scrolls tableview to initial position.
    /// If starting point is set, scroll to the starting point at `.middle`.
    func scrollToInitialPosition() {
        if let startingPoint = self.baseDataSource?.baseChannelModule(self, startingPointIn: self.tableView) {
            if let index = fullMessageList.firstIndex(where: { $0.createdAt <= startingPoint }) {
                self.scrollTableView(to: index, at: .middle)
            } else {
                self.scrollTableView(to: fullMessageList.count - 1, at: .top)
            }
        } else {
            self.scrollTableView(to: 0)
        }
    }
    
    /// This function checks if the current message and the next message date have the same day.
    /// - Parameters:
    ///   - currentIndex: Current message index
    ///   - fullMessageList: The full message list including failed/pending messages as well as sent messages
    /// - Returns: If `true`, the messages date is same day.
    public func checkSameDayAsNextMessage(currentIndex: Int, fullMessageList: [SBDBaseMessage]) -> Bool {
        guard currentIndex < fullMessageList.count-1 else { return false }
        
        let currentMessage = fullMessageList[currentIndex]
        let nextMessage = fullMessageList[currentIndex+1]
        
        let curCreatedAt = currentMessage.createdAt
        let prevCreatedAt = nextMessage.createdAt
        
        return Date.sbu_from(prevCreatedAt).isSameDay(as: Date.sbu_from(curCreatedAt))
    }
}
