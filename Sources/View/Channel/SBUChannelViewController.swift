//
//  SBUChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos
import MobileCoreServices
import AVKit
import SafariServices

@objcMembers
open class SBUChannelViewController: SBUBaseChannelViewController {

    // MARK: - UI properties (Public)
    public var channelName: String? = nil
    
    /// You can use the customized view and a view that inherits `SBUNewMessageInfo`.
    /// If you use a view that inherits SBUNewMessageInfo, you can change the button and their action.
    public lazy var newMessageInfoView: UIView? = SBUNewMessageInfo()

    public var titleView: UIView? = nil {
        didSet {
            var stack = UIStackView()
            if let titleView = self.titleView {
                stack = UIStackView(arrangedSubviews: [titleView, self.spacer])
                stack.axis = .horizontal
            }
            
            self.navigationItem.titleView = stack
        }
    }
    public var leftBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        }
    }
    public var rightBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.rightBarButtonItem = self.useRightBarButtonItem ? self.rightBarButton : nil
        }
    }
    
    public lazy var channelStateBanner: UIView? = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = SBUStringSet.Channel_State_Banner_Frozen
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.isHidden = true
        return label
    }()
    
    public lazy var scrollBottomView: UIView? = {
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
        
        scrollBottomButton.setImage(SBUIconSetType.iconChevronDown.image(with: theme.scrollBottomButtonIconColor,
                                                                         to: SBUIconSetType.Metric.iconChevronDown),
                                    for: .normal)
        scrollBottomButton.backgroundColor = theme.scrollBottomButtonBackground
        scrollBottomButton.setBackgroundImage(UIImage.from(color: theme.scrollBottomButtonHighlighted), for: .highlighted)

        scrollBottomButton.addTarget(self, action: #selector(self.onClickScrollBottom(sender:)), for: .touchUpInside)
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

    // for cell
    public private(set) var adminMessageCell: SBUBaseMessageCell?
    public private(set) var userMessageCell: SBUBaseMessageCell?
    public private(set) var fileMessageCell: SBUBaseMessageCell?
    public private(set) var customMessageCell: SBUBaseMessageCell?
    public private(set) var unknownMessageCell: SBUBaseMessageCell?
    
    
    // MARK: - UI properties (Private)
    private lazy var defaultTitleView: SBUChannelTitleView = {
        var titleView: SBUChannelTitleView
        titleView = SBUChannelTitleView(
            frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        )

        return titleView
    }()
    
    private lazy var backButton: UIBarButtonItem = SBUCommonViews.backButton(
        vc: self,
        selector: #selector(onClickBack)
    )
    
    private lazy var infoButton: UIBarButtonItem = UIBarButtonItem(
        image: SBUIconSetType.iconInfo.image(
            to: SBUIconSetType.Metric.defaultIconSize
        ),
        style: .plain,
        target: self,
        action: #selector(onClickSetting)
    )
    
    let spacer = UIView()

    private var newMessagesCount: Int = 0
    
    // MARK: - Logic properties (Public)
    
    /// This object is used to import a list of messages, send messages, modify messages, and so on, and is created during initialization.
    public var channel: SBDGroupChannel? {
        return super.baseChannel as? SBDGroupChannel
    }
    public var highlightInfo: SBUHighlightMessageInfo? = nil
    
    /// To decide whether to use right bar button item or not
    public var useRightBarButtonItem: Bool = true {
        didSet {
            self.navigationItem.rightBarButtonItem = useRightBarButtonItem ? self.rightBarButton : nil
        }
    }

    /// This object is used before response from the server
    @available(*, deprecated, message: "Property value is always empty.") // 1.2.10
    public private(set) var preSendMessages: [String:SBDBaseMessage] = [:]
    /// This object that has resendable messages, including `pending messages` and `failed messages`.
    @available(*, deprecated, message: "Property value is always empty.") // 1.2.10
    public private(set) var resendableMessages: [String:SBDBaseMessage] = [:]
    @available(*, deprecated, message: "Property value is always empty.") // 1.2.10
    public private(set) var preSendFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    @available(*, deprecated, message: "Property value is always empty.") // 1.2.10
    public private(set) var resendableFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    @available(*, deprecated, message: "Property value is always empty.") // 1.2.10
    public private(set) var fileTransferProgress: [String:CGFloat] = [:] // Key: requestId, If have value, file message status is sending
    
    
    // MARK: - Logic properties (Private)
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUChannelViewController(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUChannelViewController(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }

    /// If you have channel object, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = SBDMessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeThreadInfo = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channel: Channel object
    /// - Since: 1.0.11
    public init(channel: SBDGroupChannel, messageListParams: SBDMessageListParams? = nil) {
        super.init(baseChannel: channel, messageListParams: messageListParams)
        SBULog.info("")
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = SBDMessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeThreadInfo = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channelUrl: Channel url string
    /// - Since: 1.0.11
    public override init(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        super.init(channelUrl: channelUrl, messageListParams: messageListParams)
        SBULog.info("")
    }
    
    /// Use this initializer to enter a channel to start from a specific timestamp..
    ///
    /// - Parameters:
    ///     - channelUrl: Channel's url
    ///     - startingPoint: A starting point timestamp to start the message list from
    ///     - messageListParams: `SBDMessageListParams` object to be used when loading messages.
    ///
    /// - Since: 2.1.0
    public override init(channelUrl: String, startingPoint: Int64, messageListParams: SBDMessageListParams? = nil) {
        super.init(channelUrl: channelUrl, startingPoint: startingPoint, messageListParams: messageListParams)
        SBULog.info("")
    }
    
    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        if self.titleView == nil {
            self.titleView = self.defaultTitleView
        }
        if self.leftBarButton == nil {
            self.leftBarButton = self.backButton
        }
        if self.rightBarButton == nil {
            self.rightBarButton = self.infoButton
        }
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        if self.useRightBarButtonItem {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        }

        var stack = UIStackView()
        if let titleView = self.titleView {
            stack = UIStackView(arrangedSubviews: [titleView, self.spacer])
            stack.axis = .horizontal
        }
        
        self.navigationItem.titleView = stack
        if #available(iOS 13.0, *) {
            self.navigationController?.isModalInPresentation = true
        }
        
        // Message Input View
        self.messageInputView.delegate = self
        
        if self.adminMessageCell == nil {
            self.register(adminMessageCell: SBUAdminMessageCell())
        }
        if self.userMessageCell == nil {
            self.register(userMessageCell: SBUUserMessageCell())
        }
        if self.fileMessageCell == nil {
            self.register(fileMessageCell: SBUFileMessageCell())
        }
        if self.unknownMessageCell == nil {
            self.register(unknownMessageCell: SBUUnknownMessageCell())
        }

        self.emptyView?.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.backgroundView = self.emptyView
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
        
        // message input view
        self.view.addSubview(self.messageInputView)
        
        // new message info view
        if let newMessageInfoView = self.newMessageInfoView {
            newMessageInfoView.isHidden = true
            self.view.addSubview(newMessageInfoView)
        }
        
        // channel state banner
        if let stateBanner = self.channelStateBanner {
            self.view.addSubview(stateBanner)
        }
        
        // scroll bottom view
        if let scrollBottomView = self.scrollBottomView {
            scrollBottomView.isHidden = true
            self.view.addSubview(scrollBottomView)
        }
        
        // autolayout
        self.setupAutolayout()

        // Styles
        self.setupStyles()
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
        
        self.spacer.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.spacer.widthAnchor.constraint(
            greaterThanOrEqualToConstant: self.view.bounds.width
        )
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewTopConstraint = self.tableView.topAnchor.constraint(
            equalTo: self.view.topAnchor,
            constant: 0
        )
        NSLayoutConstraint.activate([
            self.tableViewTopConstraint,
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(
                equalTo: self.messageInputView.topAnchor,
                constant: 0
            )
        ])
        
        self.channelStateBanner?
            .sbu_constraint(equalTo: self.view, leading: 8, trailing: -8, top: 8)
            .sbu_constraint(height: 24)
        
        self.messageInputView.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputViewBottomConstraint = self.messageInputView.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor,
            constant: 0
        )
        NSLayoutConstraint.activate([
            self.messageInputView.topAnchor.constraint(
                equalTo: self.tableView.bottomAnchor,
                constant: 0
            ),
            self.messageInputView.leftAnchor.constraint(
                equalTo: self.view.leftAnchor,
                constant: 0
            ),
            self.messageInputView.rightAnchor.constraint(
                equalTo: self.view.rightAnchor,
                constant: 0
            ),
            self.messageInputViewBottomConstraint
        ])
        
        if let newMessageInfoView = self.newMessageInfoView {
            newMessageInfoView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newMessageInfoView.bottomAnchor.constraint(
                    equalTo: self.messageInputView.topAnchor,
                    constant: -8
                ),
                newMessageInfoView.centerXAnchor.constraint(
                    equalTo: self.view.centerXAnchor,
                    constant: 0
                )
            ])
        }
        
        if let scrollBottomView = self.scrollBottomView {
            scrollBottomView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollBottomView.widthAnchor.constraint(equalToConstant: SBUConstant.scrollBottomButtonSize.width),
                scrollBottomView.heightAnchor.constraint(equalToConstant: SBUConstant.scrollBottomButtonSize.height),
                scrollBottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                scrollBottomView.bottomAnchor.constraint(equalTo: self.messageInputView.topAnchor, constant: -8)
            ])
        }
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationBarShadowColor
        )
        // For iOS 15
        self.navigationController?.sbu_setupNavigationBarAppearance(tintColor: theme.navigationBarTintColor)
        
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        if let channelStateBanner = self.channelStateBanner as? UILabel {
            channelStateBanner.textColor = self.theme.channelStateBannerTextColor
            channelStateBanner.font = self.theme.channelStateBannerFont
            channelStateBanner.backgroundColor = self.theme.channelStateBannerBackgroundColor
        }
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        super.updateStyles()
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUChannelTitleView {
            titleView.setupStyles()
        }
        self.messageInputView.setupStyles()
        
        if let newMessageInfoView = self.newMessageInfoView as? SBUNewMessageInfo {
            newMessageInfoView.setupStyles()
        }
        
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.setupStyles()
        }
        
        if let scrollBottomView = self.scrollBottomView {
            self.setupScrollBottomViewStyle(scrollBottomView: scrollBottomView)
        }
        
        self.reloadTableView()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupStyles()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)

        if let channelUrl = self.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }

        self.addGestureHideKeyboard()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let channel = self.channel {
            guard let titleView = titleView as? SBUChannelTitleView else { return }
            titleView.updateChannelStatus(channel: channel)
        }
        
        self.updateStyles()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        SBULog.info("")
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Binding
    
    override func createViewModel(startingPoint: Int64?, showIndicator: Bool = true) {
        super.createViewModel(startingPoint: startingPoint, showIndicator: showIndicator)
        
        self.messageInputView.setMode(.none)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let channelViewModel = self.channelViewModel else { return }
        
        channelViewModel.channelChangeObservable.observe { [weak self] messageContext, channel in
            guard let self = self else { return }
            
            guard channel != nil else {
                // channel deleted
                if self.navigationController?.viewControllers.last == self {
                    // If leave is called in the ChannelSettingsViewController, this logic needs to be prevented.
                    self.onClickBack()
                }
                return
            }
            
            // channel changed
            switch messageContext.source {
            case .eventReadReceiptUpdated, .eventDeliveryReceiptUpdated:
                if messageContext.source == .eventReadReceiptUpdated {
                    if let titleView = self.titleView as? SBUChannelTitleView {
                        titleView.updateChannelStatus(channel: channel)
                    }
                }
                self.reloadTableView()
            case .eventTypingStatusUpdated:
                if let titleView = self.titleView as? SBUChannelTitleView {
                    titleView.updateChannelStatus(channel: channel)
                }
            case .channelChangelog:
                if let titleView = self.titleView as? SBUChannelTitleView {
                    titleView.configure(channel: channel, title: self.channelName)
                }
                self.updateMessageInputModeState()
                self.reloadTableView()
            case .eventChannelChanged:
                if let titleView = self.titleView as? SBUChannelTitleView {
                    titleView.configure(channel: channel, title: self.channelName)
                }
                self.updateMessageInputModeState()
            case .eventChannelFrozen, .eventChannelUnfrozen,
                    .eventUserMuted, .eventUserUnmuted,
                    .eventOperatorUpdated,
                    .eventUserBanned: // Other User Banned
                self.updateMessageInputModeState()
            default: break
            }
        }
    }
    
    
    /// This function is used to load channel information.
    /// - Parameters:
    ///   - channelUrl: channel url
    ///   - messageListParams: (Optional) The parameter to be used when getting channel information. 
    public override func loadChannel(channelUrl: String?, messageListParams: SBDMessageListParams? = nil) {
        guard let channelUrl = channelUrl else { return }
        self.shouldShowLoadingIndicator()
        
        //NOTE: this load channel do too much work...
        if let messageListParams = messageListParams {
            self.customizedMessageListParams = messageListParams
        } else if self.customizedMessageListParams == nil {
            let messageListParams = SBDMessageListParams()
            SBUGlobalCustomParams.messageListParamsBuilder?(messageListParams)
            self.customizedMessageListParams = messageListParams
        }
        
        SBUMain.connectIfNeeded { user, error in
            if let error = error {
                self.errorHandler(error)
                // do not proceed to getChannel()
                return
            }

            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard let self = self else { return }
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    
                    if self.messageList.isEmpty {
                        if let emptyView = self.emptyView as? SBUEmptyView {
                            emptyView.reloadData(.error)
                        }
                    }
                    
                    self.errorHandler(error)
                    // don't return to allow failed UI
                }
                
                self.baseChannel = channel
                
                guard self.canProceed(with: self.channel, error: error) else { return }

                SBULog.info("""
                    [Succeed] Load channel request:
                    \(String(format: "%@", self.channel ?? ""))
                    """)
                
                // background refresh to check if user is banned or not.
                self.refreshChannel()
                
                if let titleView = self.titleView as? SBUChannelTitleView {
                    titleView.configure(channel: self.channel, title: self.channelName)
                }
                self.updateMessageInputModeState()
            }
        }
    }
    
    /// This function is used to add or delete reactions.
    /// - Parameters:
    ///   - message: `SBDBaseMessage` object to update
    ///   - emojiKey: set emoji key
    ///   - didSelect: set reaction state
    /// - Since: 1.1.0
    public func setReaction(message: SBDBaseMessage, emojiKey: String, didSelect: Bool) {
        switch didSelect {
        case true:
            SBULog.info("[Request] Add Reaction")
            self.channel?.addReaction(with: message, key: emojiKey) { reactionEvent, error in
                if let error = error {
                    SBULog.error("[Failed] Add reaction : \(error.localizedDescription)")
                    self.errorHandler(error)
                }
                SBULog.info("[Response] \(reactionEvent?.key ?? "") reaction")
            }
        case false:
            SBULog.info("[Request] Delete Reaction")
            self.channel?.deleteReaction(with: message, key: emojiKey) { reactionEvent, error in
                if let error = error {
                    SBULog.error("[Failed] Delete reaction : \(error.localizedDescription)")
                    self.errorHandler(error)
                }

                SBULog.info("[Response] \(reactionEvent?.key ?? "") reaction")
            }
        }
    }


    // MARK: - List managing
    
    /// This function updates the messages in the list.
    ///
    /// It is updated only if the messages already exist in the list, and if not, it is ignored.
    /// And, after updating the messages, a function to sort the message list is called.
    /// - Parameters:
    ///   - messages: Message array to update
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func updateMessagesInList(messages: [SBDBaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messageList) {
                self.messageList[index] = message
            }
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    /// This function increases the new message count.
    public override func increaseNewMessageCount() {
        guard !isScrollNearBottom() else { return }
        super.increaseNewMessageCount()
        
        self.setNewMessageInfoView(hidden: false)
        self.newMessagesCount += 1
        
        if let newMessageInfoView = self.newMessageInfoView as? SBUNewMessageInfo {
            newMessageInfoView.updateCount(count: self.newMessagesCount) { [weak self] in
                guard let self = self else { return }
                self.scrollToBottom(animated: false)
            }
        }
    }
    
    // MARK: - Channel related
    
    private func refreshChannel() {
        if let channel = channel {
            channel.refresh { [weak self] error in
                let _ = self?.canProceed(with: self?.channel, error: error)
                self?.updateMessageInputModeState()
            }
        } else if let channelUrl = self.channelUrl {
            // channel hasn't been loaded before.
            self.loadChannel(channelUrl: channelUrl)
        }
    }
    
    /// Check if viewcontroller should proceed with drawing UI with this channel object.
    /// VC will finish if user can't fetch the channel object (not a member), or allow it to draw failed UI.
    private func canProceed(with channel: SBDGroupChannel?, error: SBDError?) -> Bool {
        if let error = error {
            SBULog.info("canProceed error : \(error.localizedDescription)")
            self.errorHandler(error)
            if !self.belongsToChannel(error: error) {
                self.onClickBack()
                return false
            }
        }
        
        if let channel = channel {
            if channel.myMemberState == .none {
                self.onClickBack()
                return false
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        return true
    }
    
    private func belongsToChannel(error: SBDError) -> Bool {
        return error.code != SBDErrorCode.nonAuthorized.rawValue
    }
    

    // MARK: - Custom viewController relations
    
    /// If you want to use a custom channelSettingsViewController, override it and implement it.
    open func showChannelSettings() {
        guard let channel = self.channel else { return }
        
        let channelSettingsVC = SBUChannelSettingsViewController(channel: channel)
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
    /// This function presents `SBUEmojiListViewController`
    /// - Parameter message: `SBDBaseMessage` object
    /// - Since: 1.1.0
    open func showEmojiListModal(message: SBDBaseMessage) {
        let emojiListVC = SBUEmojiListViewController(message: message)
        emojiListVC.modalPresentationStyle = .custom
        emojiListVC.transitioningDelegate = self

        emojiListVC.emojiTapHandler = { [weak self] emojiKey, setSelect in
            guard let self = self else { return }
            self.setReaction(message: message, emojiKey: emojiKey, didSelect: setSelect)
        }
        self.present(emojiListVC, animated: true)
    }
    
    /// Used to register a custom cell as a admin message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized admin message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(adminMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.adminMessageCell = adminMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: adminMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: adminMessageCell),
                forCellReuseIdentifier: adminMessageCell.sbu_className
            )
        }
    }

    /// Used to register a custom cell as a user message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized user message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(userMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.userMessageCell = userMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: userMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: userMessageCell),
                forCellReuseIdentifier: userMessageCell.sbu_className
            )
        }
    }

    /// Used to register a custom cell as a file message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized file message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(fileMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.fileMessageCell = fileMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: fileMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: fileMessageCell),
                forCellReuseIdentifier: fileMessageCell.sbu_className
            )
        }
    }

    /// Used to register a custom cell as a additional message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(customMessageCell: SBUBaseMessageCell?, nib: UINib? = nil) {
        self.customMessageCell = customMessageCell
        guard let customMessageCell = customMessageCell else { return }
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: customMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: customMessageCell),
                forCellReuseIdentifier: customMessageCell.sbu_className
            )
        }
    }
    
    /// Used to register a custom cell as a unknown message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized unknown message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    private func register(unknownMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.unknownMessageCell = unknownMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: unknownMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: unknownMessageCell),
                forCellReuseIdentifier: unknownMessageCell.sbu_className
            )
        }
    }

    
    // MARK: - Cell TapHandler
    /// This function sets the cell's tap gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - message: Message object
    open func setTapGestureHandler(_ cell: SBUBaseMessageCell, message: SBDBaseMessage) {
        self.dismissKeyboard()
        
        switch message {
            
        case let userMessage as SBDUserMessage:
            // User message type, only fail case
            guard userMessage.sendingStatus == .failed,
                userMessage.sender?.userId == SBUGlobals.CurrentUser?.userId  else { return }
            self.resendMessage(failedMessage: userMessage)
           
        case let fileMessage as SBDFileMessage:
            // File message type
            switch fileMessage.sendingStatus {
            case .pending:
                break
            case .failed:
                guard fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId else { return }
                self.resendMessage(failedMessage: fileMessage)
            case .succeeded:
                self.openFile(fileMessage: fileMessage)
            default:
                break
            }

        case _ as SBDAdminMessage:
            // Admin message type
            break
        default:
            break
        }
    }
    
    func openFile(fileMessage: SBDFileMessage) {
        // File message type
        switch fileMessage.sendingStatus {
        case .pending:
            break
        case .failed:
            guard fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId else { return }
            self.resendMessage(failedMessage: fileMessage)
        case .succeeded:
            guard let url = URL(string: fileMessage.url),
               let fileURL = SBUCacheManager.saveAndLoadFileToLocal(url: url, fileName: fileMessage.name)  else {
                SBUToastManager.showToast(parentVC: self, type: .fileOpenFailed)
                return
            }
            
            switch SBUUtils.getFileType(by: fileMessage) {
            case .image:
                let viewer = SBUFileViewer(fileMessage: fileMessage, delegate: self)
                let naviVC = UINavigationController(rootViewController: viewer)
                self.present(naviVC, animated: true)
            case .etc, .pdf:
                if fileURL.scheme == "file" {
                    let dc = UIDocumentInteractionController(url: fileURL)
                    dc.name = fileMessage.name
                    dc.delegate = self
                    dc.presentPreview(animated: true)
                } else {
                    let safariVC = SFSafariViewController(url: fileURL)
                    self.present(safariVC, animated: true, completion: nil)
                }
            case .video, .audio:
                let vc = AVPlayerViewController()
                vc.player = AVPlayer(url: fileURL)
                self.present(vc, animated: true) { vc.player?.play() }
            default:
                break
            }
        default:
            break
        }
    }
    

    /// This function sets the cell's long tap gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - message: Message object
    ///   - indexPath: indexpath of cell
    open func setLongTapGestureHandler(_ cell: SBUBaseMessageCell,
                                       message: SBDBaseMessage,
                                       indexPath: IndexPath) {
        self.dismissKeyboard()
        switch message.sendingStatus {
        case .none, .canceled, .pending:
            break
        case .failed:
            self.showFailedMessageMenu(message: message)
        case .succeeded:
            switch message {
            case let userMessage as SBDUserMessage:
                let isCurrentUser = userMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
                var types: [MessageMenuItem] = []
                if isCurrentUser {
                    types = SBUGlobals.ReplyTypeToUse == .none
                        ? [.copy, .edit, .delete]
                        : [.copy, .edit, .delete, .reply]
                } else {
                    types = SBUGlobals.ReplyTypeToUse == .none
                        ? [.copy]
                        : [.copy, .reply]
                }
                    
                cell.isSelected = true
                
                if SBUEmojiManager.useReaction(channel: self.channel) {
                    self.showMenuViewController(cell, message: message, types: types)
                } else {
                    self.showMenuModal(cell, indexPath: indexPath,  message: userMessage, types: types)
                }
            case let fileMessage as SBDFileMessage:
                let isCurrentUser = fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
                var types: [MessageMenuItem] = []
                if isCurrentUser {
                    types = SBUGlobals.ReplyTypeToUse == .none
                        ? [.save, .delete]
                        : [.save, .delete, .reply]
                } else {
                    types = SBUGlobals.ReplyTypeToUse == .none
                        ? [.save]
                        : [.save, .reply]
                }
                cell.isSelected = true
                
                if SBUEmojiManager.useReaction(channel: self.channel) {
                    self.showMenuViewController(cell, message: message, types: types)
                } else {
                    self.showMenuModal(cell, indexPath: indexPath, message: fileMessage, types: types)
                }
            default:
                break
            }
        default:
            // Unknown Message
            guard message.sender?.userId == SBUGlobals.CurrentUser?.userId else { return }
            let types: [MessageMenuItem] = [.delete]
            self.showMenuModal(cell, indexPath: indexPath, message: message, types: types)
        }
    }

    /// This function sets the cell's tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.1.0
    @available(*, deprecated, renamed: "setEmojiTapGestureHandler(_:emojiKey:)") //  1.2.2
    open func setTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        self.setEmojiTapGestureHandler(cell, emojiKey: emojiKey)
    }
    
    /// This function sets the cell's tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.2.2
    open func setEmojiTapGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        guard let currentUser = SBUGlobals.CurrentUser else { return }
        let message = cell.message
        let shouldSelect = message.reactions.first { $0.key == emojiKey }?
            .userIds.contains(currentUser.userId) == false
        self.setReaction(message: message, emojiKey: emojiKey, didSelect: shouldSelect)
    }

    /// This function sets the cell's long tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.1.0
    @available(*, deprecated, renamed: "setEmojiLongTapGestureHandler(_:emojiKey:)") //  1.2.2
    open func setLongTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        self.setEmojiLongTapGestureHandler(cell, emojiKey: emojiKey)
    }
    
    /// This function sets the cell's long tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.2.2
    open func setEmojiLongTapGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        guard let channel = self.channel else { return }
        let message = cell.message
        let reaction = message.reactions.first { $0.key == emojiKey } ?? SBDReaction()
        let reactionsVC = SBUReactionsViewController(
            channel: channel,
            message: message,
            selectedReaction: reaction
        )
        reactionsVC.modalPresentationStyle = .custom
        reactionsVC.transitioningDelegate = self
        self.present(reactionsVC, animated: true)
    }

    
    // MARK: - Message input mode
    
    /// This is used to messageInputView state update.
    /// - Since: 1.2.0
    public func updateMessageInputModeState() {
        if let _ = self.channel {
            self.updateBroadcastModeState()
            self.updateFrozenModeState()
            self.updateMutedModeState()
        } else {
            self.messageInputView.setErrorState()
        }
    }
    
    func updateBroadcastModeState() {
        let isOperator = self.channel?.myRole == .operator
        let isBroadcast = self.channel?.isBroadcast ?? false
        self.messageInputView.isHidden = !isOperator && isBroadcast
    }
    
    func updateFrozenModeState() {
        let isOperator = self.channel?.myRole == .operator
        let isBroadcast = self.channel?.isBroadcast ?? false
        let isFrozen = self.channel?.isFrozen ?? false
        if !isBroadcast {
            self.messageInputView.setFrozenModeState(!isOperator && isFrozen)
            self.channelStateBanner?.isHidden = !isFrozen
        }
    }
    
    func updateMutedModeState() {
        let isOperator = self.channel?.myRole == .operator
        let isFrozen = self.channel?.isFrozen ?? false
        let isMuted = self.channel?.myMutedState == .muted
        if !isFrozen || (isFrozen && isOperator) {
            self.messageInputView.setMutedModeState(isMuted)
        }
    }

    // MARK: - Common
    
    /// This function checks if the current message and the next message date have the same day.
    /// - Parameter currentIndex: Current message index
    /// - Returns: If `true`, the messages date is same day.
    public func checkSameDayAsNextMessage(currentIndex: Int) -> Bool {
        guard currentIndex < self.fullMessageList.count-1 else { return false }
        
        let currentMessage = self.fullMessageList[currentIndex]
        let nextMessage = self.fullMessageList[currentIndex+1]
        
        let curCreatedAt = currentMessage.createdAt
        let prevCreatedAt = nextMessage.createdAt
        
        return Date.sbu_from(prevCreatedAt).isSameDay(as: Date.sbu_from(curCreatedAt))
    }
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public override func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        if let channelViewModel = self.channelViewModel {
            channelViewModel.setLoading(loadingState, showIndicator)
        } else {
            guard showIndicator else { return }
            
            if loadingState {
                SBULoading.start()
            } else {
                SBULoading.stop()
            }
        }
    }
    
    /// This is a function that gets the location of the message to be grouped.
    ///
    /// Only successful messages can be grouped.
    /// - Parameter currentIndex: Index of current message in the message list
    /// - Returns: Position of a message when grouped
    /// - Since: 1.2.1
    public func getMessageGroupingPosition(currentIndex: Int) -> MessageGroupPosition {
        guard currentIndex < self.fullMessageList.count else { return .none }
        
        let prevMessage = self.fullMessageList.count - 1 != currentIndex
            ? self.fullMessageList[currentIndex+1]
            : nil
        let currentMessage = self.fullMessageList[currentIndex]
        let nextMessage = currentIndex != 0
            ? self.fullMessageList[currentIndex-1]
            : nil
        
        let succeededPrevMsg = prevMessage?.sendingStatus != .failed
            ? prevMessage
            : nil
        let succeededCurrentMsg = currentMessage.sendingStatus != .failed
            ? currentMessage
            : nil
        let succeededNextMsg = nextMessage?.sendingStatus != .failed
            ? nextMessage
            : nil
        
        let prevSender = succeededPrevMsg?.sender?.userId ?? nil
        let currentSender = succeededCurrentMsg?.sender?.userId ?? nil
        let nextSender = succeededNextMsg?.sender?.userId ?? nil
        
        // Unit : milliseconds
        let prevTimestamp = Date.sbu_from(succeededPrevMsg?.createdAt ?? -1).sbu_toString(
            format: .yyyyMMddhhmm
        )
        let currentTimestamp = Date.sbu_from(succeededCurrentMsg?.createdAt ?? -1).sbu_toString(
            format: .yyyyMMddhhmm
        )
        let nextTimestamp = Date.sbu_from(succeededNextMsg?.createdAt ?? -1).sbu_toString(
            format: .yyyyMMddhhmm
        )
        
        if prevSender != currentSender && nextSender != currentSender {
            return .none
        }
        else if prevSender == currentSender && nextSender == currentSender {
            if prevTimestamp == nextTimestamp {
                return .middle
            }
            else if prevTimestamp == currentTimestamp {
                return .bottom
            }
            else if currentTimestamp == nextTimestamp {
                return .top
            }
        }
        else if prevSender == currentSender && nextSender != currentSender {
            return prevTimestamp == currentTimestamp ? .bottom : .none
        }
        else if prevSender != currentSender && nextSender == currentSender {
            return currentTimestamp == nextTimestamp ? .top : .none
        }
        
        return .none
    }
    
    
    // MARK: - Actions
    
    /// This function shows channel settings.
    public func onClickSetting() {
        self.showChannelSettings()
    }
    
    @objc open func onClickScrollBottom(sender: UIButton?) {
        self.scrollToBottom(animated: false)
    }
    
    
    // MARK: - ScrollView
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.tableView else { return }
        
        self.lastSeenIndexPath = nil
        
        if isScrollNearBottom() {
            self.newMessagesCount = 0
            self.setNewMessageInfoView(hidden: true)
        }
        self.setScrollBottomView(hidden: isScrollNearBottom())
    }
    
    // MARK: - Floating Buttons
    
    /// This shows new message view based on `hasNext`
    override func setNewMessageInfoView(hidden: Bool) {
        guard let newMessageInfoView = self.newMessageInfoView else { return }
        guard hidden != newMessageInfoView.isHidden else { return }
        guard let channelViewModel = self.channelViewModel else { return }
        
        newMessageInfoView.isHidden = hidden && !channelViewModel.hasNext()
    }
    
    /// Sets the scroll to bottom view.
    /// - Parameter hidden: whether to hide the view. `nil` to handle it automatically depending on the current scroll position.
    public override func setScrollBottomView(hidden: Bool?) {
        let hasNext = self.channelViewModel?.hasNext() ?? false
        let shouldHide = hidden ?? isScrollNearBottom()
        let hide = shouldHide && !hasNext
        
        guard hide != self.scrollBottomView?.isHidden else { return }
        self.scrollBottomView?.isHidden = hide
    }
    
    public override func scrollToBottom(animated: Bool) {
        self.newMessagesCount = 0
        super.scrollToBottom(animated: animated)
    }
    

    // MARK: - Cell generator
    
    /// This function sets gestures in user message cell.
    /// - Parameters:
    ///   - cell: User message cell
    ///   - userMessage: User message object
    ///   - indexPath: Cell's indexPath
    /// - Since: 1.2.5
    open func setUserMessageCellGestures(_ cell: SBUUserMessageCell,
                                         userMessage: SBDUserMessage,
                                         indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setTapGestureHandler(cell, message: userMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: userMessage, indexPath: indexPath)
        }
    }
    
    /// This function sets gestures in file message cell.
    /// - Parameters:
    ///   - cell: File message cell
    ///   - fileMessage: File message object
    ///   - indexPath: Cell's indexPath
    /// - Since: 1.2.5
    open func setFileMessageCellGestures(_ cell: SBUFileMessageCell,
                                         fileMessage: SBDFileMessage,
                                         indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setTapGestureHandler(cell, message: fileMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: fileMessage, indexPath: indexPath)
        }
    }
    
    /// This function sets gestures in unknown message cell.
    /// - Parameters:
    ///   - cell: Unknown message cell
    ///   - unknownMessage: message object
    ///   - indexPath: Cell's indexPath
    /// - Since: 1.2.5
    open func setUnkownMessageCellGestures(_ cell: SBUUnknownMessageCell,
                                           unknownMessage: SBDBaseMessage,
                                           indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setTapGestureHandler(cell, message: unknownMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: unknownMessage, indexPath: indexPath)
        }
    }
    
    /// This function sets images in file message cell.
    /// - Parameters:
    ///   - cell: File message cell
    ///   - fileMessage: File message object
    /// - Since: 1.2.5
    func setFileMessageCellImages(_ cell: SBUFileMessageCell,
                                  fileMessage: SBDFileMessage) {
        self.setCellImage(cell, fileMessage: fileMessage)
    }
    
    
    // MARK: - Cell's menu
    
    /// This function calculates the point at which to draw the menu.
    /// - Parameters:
    ///   - indexPath: IndexPath
    ///   - position: Message position
    /// - Returns: `CGPoint` value
    /// - Since: 1.2.5
    public func calculatorMenuPoint(indexPath: IndexPath,
                                    position: MessagePosition) -> CGPoint {
        let rowRect = self.tableView.rectForRow(at: indexPath)
        let rowRectInSuperview = self.tableView.convert(
            rowRect,
            to: UIApplication.shared.currentWindow
        )
        let originX = (position == .right) ? rowRectInSuperview.width : rowRectInSuperview.origin.x
        let menuPoint = CGPoint(x: originX, y: rowRectInSuperview.origin.y)
        
        return menuPoint
    }
    
    /// This function shows cell's menu. This is used when the reaction feature is activated.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - message: Message object
    ///   - types: Type array of menu items to use
    /// - Since: 1.2.5
    public func showMenuViewController(_ cell: UITableViewCell,
                                       message: SBDBaseMessage,
                                       types: [MessageMenuItem]) {
        let useReaction = SBUEmojiManager.useReaction(channel: self.channel)
        
        let menuVC = SBUMenuViewController(message: message, itemTypes: types, useReaction: useReaction)
        menuVC.modalPresentationStyle = .custom
        menuVC.transitioningDelegate = self
        self.present(menuVC, animated: true)

        menuVC.tapHandlerToMenu = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case .copy:
                guard let userMessage = message as? SBDUserMessage else { return }
                let pasteboard = UIPasteboard.general
                pasteboard.string = userMessage.message

            case .delete:
                self.deleteMessage(message: message)

            case .edit:
                guard let userMessage = message as? SBDUserMessage else { return }
                if self.channel?.isFrozen == false ||
                    self.channelViewModel?.isOperator == true {
                    self.messageInputView.setMode(.edit, message: userMessage)
                } else {
                    SBULog.info("This channel is frozen")
                }

            case .save:
                guard let fileMessage = message as? SBDFileMessage else { return }
                SBUDownloadManager.save(fileMessage: fileMessage, parent: self)
                
            case .reply:
                self.messageInputView.setMode(.quoteReply, message: message)
            }
        }

        menuVC.dismissHandler = {
            cell.isSelected = false
        }

        menuVC.emojiTapHandler = { [weak self] emojiKey, setSelect in
            guard let self = self else { return }
            self.setReaction(message: message, emojiKey: emojiKey, didSelect: setSelect)
        }

        menuVC.moreEmojiTapHandler = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showEmojiListModal(message: message)
            }
        }
    }

    /// This function shows cell's menu. This is used when the reaction feature is inactivated.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - indexPath: IndexPath
    ///   - message: Message object
    ///   - types: Type array of menu items to use
    /// - Since: 1.2.5
    public func showMenuModal(_ cell: UITableViewCell,
                              indexPath: IndexPath,
                              message: SBDBaseMessage,
                              types: [MessageMenuItem]) {
        guard let cell = cell as? SBUBaseMessageCell else { return }
        
        let menuItems = self.createMenuItems(
            cell: cell,
            message: message,
            types: types,
            isMediaViewOverlaying: false
        )

        let menuPoint = self.calculatorMenuPoint(indexPath: indexPath, position: cell.position)
        SBUMenuView.show(items: menuItems, point: menuPoint) {
            cell.isSelected = false
        }
    }
    
    
    /// This function shows cell's menu: retry, delete, cancel.
    ///
    /// This is used when selected failed message.
    /// - Parameter message: message object
    /// - Since: 2.1.12
    public func showFailedMessageMenu(message: SBDBaseMessage) {
        let retryItem = SBUActionSheetItem(
            title: SBUStringSet.Retry,
            color: self.theme.menuItemTintColor
        ) { [weak self] in
            self?.resendMessage(failedMessage: message)
        }
        let deleteItem = SBUActionSheetItem(
            title: SBUStringSet.Delete,
            color: self.theme.deleteItemColor
        ) { [weak self] in
            self?.deleteResendableMessage(message, needReload: true)
        }
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: self.theme.cancelItemColor,
            completionHandler: nil
        )

        SBUActionSheet.show(
            items: [retryItem, deleteItem],
            cancelItem: cancelItem
        )
    }


    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let channel = self.channel else {
            self.errorHandler("Channel must exist!", -1)
            return UITableViewCell()
        }
        
        guard indexPath.row < self.fullMessageList.count else {
            self.errorHandler("The index is out of range.", -1)
            return UITableViewCell()
        }
        
        let message = self.fullMessageList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: self.generateCellIdentifier(by: message)
            ) ?? UITableViewCell()
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.selectionStyle = .none
        
        guard let messageCell = cell as? SBUBaseMessageCell else {
            self.errorHandler("There are no message cells!", -1)
            return cell
        }
        
        //NOTE: to disable unwanted animation while configuring cells
        UIView.setAnimationsEnabled(false)
        
        let isSameDay = self.checkSameDayAsNextMessage(currentIndex: indexPath.row)
        let receiptState = SBUUtils.getReceiptState(of: message, in: channel)
        let useReaction = SBUEmojiManager.useReaction(channel: self.channel)
        
        switch (message, messageCell) {
            
        // Amdin Message
        case let (adminMessage, adminMessageCell) as (SBDAdminMessage, SBUAdminMessageCell):
            let configuration = SBUAdminMessageCellParams(
                message: adminMessage,
                hideDateView: isSameDay
            )
            adminMessageCell.configure(with: configuration)
        // Unknown Message
        case let (unknownMessage, unknownMessageCell) as (SBDBaseMessage, SBUUnknownMessageCell):
            let configuration = SBUUnknownMessageCellParams(
                message: unknownMessage,
                hideDateView: isSameDay,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                receiptState: receiptState,
                useReaction: useReaction
            )
            unknownMessageCell.configure(with: configuration)
                
            self.setUnkownMessageCellGestures(
                unknownMessageCell,
                unknownMessage: unknownMessage,
                indexPath: indexPath
            )
            
        // User Message
        case let (userMessage, userMessageCell) as (SBDUserMessage, SBUUserMessageCell):
            let configuration = SBUUserMessageCellParams(
                message: userMessage,
                hideDateView: isSameDay,
                useMessagePosition: true,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                receiptState: receiptState,
                useReaction: useReaction,
                withTextView: true
            )
            userMessageCell.configure(with: configuration)
                
            userMessageCell.configure(highlightInfo: self.highlightInfo)
            
            (userMessageCell.quotedMessageView as? SBUQuotedBaseMessageView)?.delegate = self
                
            self.setUserMessageCellGestures(
                userMessageCell,
                userMessage: userMessage,
                indexPath: indexPath
            )
            
        // File Message
        case let (fileMessage, fileMessageCell) as (SBDFileMessage, SBUFileMessageCell):
            let configuration = SBUFileMessageCellParams(
                message: fileMessage,
                hideDateView: isSameDay,
                useMessagePosition: true,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                receiptState: receiptState,
                useReaction: useReaction
            )
            fileMessageCell.configure(with: configuration)
            
            fileMessageCell.configure(highlightInfo: self.highlightInfo)
            
            (fileMessageCell.quotedMessageView as? SBUQuotedBaseMessageView)?.delegate = self
                
            self.setFileMessageCellGestures(
                fileMessageCell,
                fileMessage: fileMessage,
                indexPath: indexPath
            )
            
            self.setFileMessageCellImages(fileMessageCell, fileMessage: fileMessage)
            
        default:
            let configuration = SBUBaseMessageCellParams(
                message: message,
                hideDateView: isSameDay,
                messagePosition: .center,
                groupPosition: .none,
                receiptState: receiptState
            )
            messageCell.configure(with: configuration)
        }
        
        UIView.setAnimationsEnabled(true)
        
        // Tap profile action
        messageCell.userProfileTapHandler = { [weak messageCell, weak self] in
            guard let self = self else { return }
            guard let cell = messageCell else { return }
            guard let sender = cell.message.sender else { return }
            self.setUserProfileTapGestureHandler(SBUUser.init(sender: sender))
        }

        // Reaction action
        messageCell.emojiTapHandler = { [weak messageCell, weak self] emojiKey in
            guard let self = self else { return }
            guard let cell = messageCell else { return }
            self.setEmojiTapGestureHandler(cell, emojiKey: emojiKey)
        }

        messageCell.emojiLongPressHandler = { [weak messageCell, weak self] emojiKey in
            guard let self = self else { return }
            guard let cell = messageCell else { return }
            self.setEmojiLongTapGestureHandler(cell, emojiKey: emojiKey)
        }

        messageCell.moreEmojiTapHandler = { [weak self] in
            guard let self = self else { return }
            self.dismissKeyboard()
            self.showEmojiListModal(message: message)
        }

        return cell
    }
    /// This function generates cell's identifier.
    /// - Parameter message: Message object
    /// - Returns: Identifier
    open func generateCellIdentifier(by message: SBDBaseMessage) -> String {
        switch message {
        case is SBDFileMessage:
            return fileMessageCell?.sbu_className ?? SBUFileMessageCell.sbu_className
        case is SBDUserMessage:
            return userMessageCell?.sbu_className ?? SBUUserMessageCell.sbu_className
        case is SBDAdminMessage:
            return adminMessageCell?.sbu_className ?? SBUAdminMessageCell.sbu_className
        default:
            return unknownMessageCell?.sbu_className ?? SBUUnknownMessageCell.sbu_className
        }
    }
    
    
    // MARK: - SBUMessageInputViewDelegate
        
    open override func messageInputViewDidEndTyping() {
        SBULog.info("[Request] End typing")
        self.channel?.endTyping()
    }
}


// MARK: - SBDChannelDelegate
extension SBUChannelViewController: SBDChannelDelegate {
    // Received message
    open func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard self.messageListParams.belongs(to: message) else { return }

        switch message {
        case is SBDUserMessage:
            //// If need specific logic for user message, implement here
            SBULog.info("Did receive user message: \(message)")
            break
            
        case is SBDFileMessage:
            //// If need specific logic for file message, implement here
            SBULog.info("Did receive file message: \(message)")
            break
            
        case is SBDAdminMessage:
            //// If need specific logic for admin message, implement here
            SBULog.info("Did receive admin message: \(message)")
            break
            
        default:
            break
        }
        
        let hasNext = channelViewModel?.hasNext() ?? false
        if hasNext || !self.isScrollNearBottom() {
            if message is SBDUserMessage ||
                message is SBDFileMessage {
                // message is not added.
                // reset lastSeenIndexPath to not keep scroll in `increaseNewMessageCount`.
                self.lastSeenIndexPath = nil
                self.increaseNewMessageCount()
            }
        }
    }
 
    // Please do not use belows.
    open func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {}
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {}
    open func channel(_ sender: SBDBaseChannel, updatedReaction reactionEvent: SBDReactionEvent) {}
    open func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {}
    open func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {}
    open func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {}
    open func channelWasChanged(_ sender: SBDBaseChannel) {}
    open func channelWasFrozen(_ sender: SBDBaseChannel) {}
    open func channelWasUnfrozen(_ sender: SBDBaseChannel) {}
    open func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {}
    open func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {}
    open func channelDidUpdateOperators(_ sender: SBDBaseChannel) {}
    open func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {}
}


// MARK: - SBDConnectionDelegate
extension SBUChannelViewController: SBDConnectionDelegate {
    open func didSucceedReconnection() {
        SBUMain.updateUserInfo { error in
            if let error = error {
                SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        if self.channelViewModel?.hasNext() ?? false {
            self.channelViewModel?.messageCache?.loadNext()
        }
        
        if channelViewModel == nil {
            self.refreshChannel()
        }
        
        self.channelViewModel?.markAsRead()
    }
}


extension SBUChannelViewController: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
}
