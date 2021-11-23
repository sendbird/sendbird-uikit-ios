//
//  SBUOpenChannelViewController.swift
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
open class SBUOpenChannelViewController: SBUBaseChannelViewController {

    private var openChannelViewModel: SBUOpenChannelViewModel? {
        self.channelViewModel as? SBUOpenChannelViewModel
    }
    
    // MARK: - UI properties (Public)
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.channelTheme, setToDefault: true)
    public var overlayTheme: SBUChannelTheme
    
    /// You can use the customized view and a view that inherits `SBUNewMessageInfo`.
    /// If you use a view that inherits SBUNewMessageInfo, you can change the button and their action.
    public lazy var newMessageInfoView: UIView? = {
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
            self.navigationItem.rightBarButtonItem = self.rightBarButton
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

    public lazy var channelInfoView = SBUChannelInfoHeaderView(delegate: self)

    // for cell
    public private(set) var adminMessageCell: SBUOpenChannelBaseMessageCell?
    public private(set) var userMessageCell: SBUOpenChannelBaseMessageCell?
    public private(set) var fileMessageCell: SBUOpenChannelBaseMessageCell?
    public private(set) var customMessageCell: SBUOpenChannelBaseMessageCell?
    public private(set) var unknownMessageCell: SBUOpenChannelBaseMessageCell?
    
    // for component
    
    /// If it's `true`, the navigation bar will be hidden.
    public var hideNavigationBar: Bool = false
    
    /// If it's `true`, the channel info view will be hidden.
    public var hideChannelInfoView: Bool = true
    
    /// Sets text in `channelInfoView.descriptionLabel`
    public var channelDescription: String?
    
    // MARK: - Media View
    /**
     The internal view provided for media such as photo or video. If you want to use `mediaView`, please call `enableMediaView(_:)` to enable and set its ratio through `updateMessageListRatio(to ratio:)`. If you want to overlay, use `overlayMediaView(_:messageListRatio:)` method.
     */
    public var mediaView = UIView()
    
    /**
     A boolean value whether the media view is enabled or not. The default value is `false`.
     
     - Note:
        Use `enableMediaView(_:)` to set value.
     
     ```
     self.enableMediaView(true)
     self.print(isMediaViewEnabled) // true
     ````
     */
    public private(set) var isMediaViewEnabled: Bool = false
    
    /**
     A relative ratio value of `mediaView`to entire screen. The default value is `0`.
     
     - Note:
     Use `updateMessageListRatio(to ratio:)` to set value.
     */
    public private(set) var mediaViewRatio: CGFloat  = 0.0
    
    /**
     A relative ratio value of messaging view to entire screen. The default value is `1`
     
     - Note:
     Use `updateMessageListRatio(to ratio:)` to set value.
     */
    public private(set) var messageListRatio: CGFloat = 1.0
    
    /**
     A boolean value whether `mediaView` is overlay or not. The default value is `false`.
     
     - Note:
        Use `overlayMediaView(_:messageListRatio:)` to set value.
     */
    public private(set) var isMediaViewOverlaying: Bool = false
    
    /**
     If the media view area extends outside the screen’s safe areas, it's `true`. The default value is `true`.
     
     - Note:
     Use `mediaViewIgnoringSafeArea(_:)` to set value.
     */
    public private(set) var isMediaViewIgnoringSafeArea: Bool = true
    
    /**
     Enable the internal media view.
     
     - Parameters:
        - enabled: If it's `true` It uses the media view.
     
     ```
     self.enableMediaView(true)
     self.updateMessageListRatio(to: 0.7)
     ````
     */
    public func enableMediaView(_ enabled: Bool = true) {
        self.isMediaViewEnabled = enabled
        if !enabled {
            updateMessageListRatio(to: 1)
        }
    }
    
    /**
     Updates a relative ratio value of `mediaView` and `messageList` to entire screen. After this method, You might need to call `setupStyles` or `updateComponentStyle`.
     
     - Parameters:
        - mediaView: A relative ratio value of `mediaView`to entire screen. If it's `nil`, the value won't be set.
        - messageList: A relative ratio value of `messageListRatio`to entire screen. If it's `nil`, the value won't be set.
     
     - Important:
        If the media view isn't overlaying mode, The sum of `mediaViewRatio` and `messageListRatio` must be `1.0`.
     
     ```
     self.updateRatio(mediaView: 0.3: messageList: 0.7)
     ````
     */
    @available(*, deprecated, renamed: "updateMessageListRatio(to:)") // 2.0.6
    public func updateRatio(mediaView: CGFloat? = nil, messageList: CGFloat? = nil) {
        if mediaView == nil, messageList == nil { return }
        if let mediaViewRatio = mediaView {
            self.mediaViewRatio = mediaViewRatio
        }
        if let messageListRatio = messageList {
            self.messageListRatio = messageListRatio
        }
    }
    
    /**
     Updates a relative ratio value of the message list with  `ratio` to entire screen.
     The mediaView will have it's ratio accordingly, meaning
        - normal mode : mediaView's ratio = (1 - message list's ratio). Media view & message list is side by side in landscape mode, top to bottom in portrait mode.
        - overlay mode : mediaView's ratio = 1 (fills the whole screen). Media view fills the whole screen & message list is above the media view with transparent background.
     After this method, You might need to call `setupStyles` or `updateComponentStyle`.
     
     - Parameters:
        - ratio: A relative ratio value of message list to entire screen. If it's `nil` or it's not in range from 0 to 1 inclusive, the value won't be set.
     
     - Important:
        The ratio must be in range of `0...1`.
     
     ```
     self.updateMessageListRatio(to: 0.7)
     ````
     */
    public func updateMessageListRatio(to ratio: CGFloat) {
        guard (0...1).contains(ratio) else {
            SBULog.warning("The ratio must be in range of 0...1")
            return
        }
        
        self.messageListRatio = ratio
        self.mediaViewRatio = self.isMediaViewOverlaying ? 1 : (1 - ratio)
    }
    
    /**
     Overlays the media view.
     
     - Parameters:
        - overlaying: If it's `true`, `mediaViewRatio` will be set to `1.0`. If it's `false`, `mediaViewRatio` will be set to `1 - messageListRatio`.
        - messageListRatio: A relative ratio value of  message list to entire screen.
     
     ```
     // Enable overlay mode
     self.overlayMediaView(true, messageListRatio: 0.4)
     
     // Disable overlay mode
     self.overlayMediaView(false, messageListRatio: 0.3)    // mediaViewRatio is 0.7
     ````
     */
    public func overlayMediaView(_ overlaying: Bool, messageListRatio: CGFloat) {
        self.isMediaViewOverlaying = overlaying
        self.updateMessageListRatio(to: messageListRatio)
    }
    
    /**
     Changes the media view area to extend outside the screen’s safe areas.
     
     - Parameters:
        - enabled: A boolean value whther the media view ignores safe area or not.
     
     - Note:
        - Ignores top edge when it's on portrait mode.
        - Ignores leading edge when it's on landscape mode.
     
     ```
     self.mediaViewIgnoringSafeArea(true)
     ````
     */
    public func mediaViewIgnoringSafeArea(_ enabled: Bool = true) {
        self.isMediaViewIgnoringSafeArea = enabled
    }
    
    // MARK: - Constraints
    // for constraint
    private var mediaViewConstraints: [NSLayoutConstraint] = []
    private var channelInfoViewAnchorConstraint: NSLayoutConstraint!
    private var channelInfoViewAnchorConstraints: [NSLayoutConstraint] = []
    private var channelInfoViewHeightConstraint: NSLayoutConstraint!

    
    // MARK: - UI properties (Private)
    
    private lazy var defaultTitleView: SBUChannelTitleView = {
        var titleView = SBUChannelTitleView()
        return titleView
    }()

    private lazy var backButton: UIBarButtonItem = {
        return SBUCommonViews.backButton(vc: self, selector: #selector(SBUOpenChannelViewController.onClickBack))
    }()

    private lazy var settingBarButton: UIBarButtonItem = {
        let theme = self.isMediaViewOverlaying ? self.overlayTheme : self.theme
        let barButton = UIBarButtonItem(
            image: SBUIconSetType.iconInfo.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onClickSetting)
        )
        barButton.tintColor = theme.rightBarButtonTintColor
        return barButton
    }()
    
    private lazy var participantListBarButton: UIBarButtonItem = {
        let theme = self.isMediaViewOverlaying ? self.overlayTheme : self.theme
        let barButton = UIBarButtonItem(
            image: SBUIconSetType.iconMembers.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onClickParticipantsList)
        )
        barButton.tintColor = theme.rightBarButtonTintColor
        return barButton
    }()
    
    var messageTopMarginView = UIView()
    var messageTopMarginConstraints: [NSLayoutConstraint] = []
    
    var messageLeftMarginView = UIView()
    var messageLeftMarginConstraints: [NSLayoutConstraint] = []
    
    let spacer = UIView()

    private let kInfoViewHeight: CGFloat = 56

    private lazy var currentWidth: CGFloat = 0
    private var prevOrientation: UIDeviceOrientation = .unknown
    public var currentOrientation: UIDeviceOrientation = .unknown
    
    // MARK: - Logic properties (Public)
    
    /// This object is used to import a list of messages, send messages, modify messages, and so on, and is created during initialization.
    public var channel: SBDOpenChannel? {
        return super.baseChannel as? SBDOpenChannel
    }
    public var channelName: String? = nil
    
    // MARK: - Logic properties (Private)
    
    var lastUpdatedTimestamp: Int64 = 0
    var firstLoad = true
    var hasPrevious = true
    var isLoading = false
    var limit: UInt = 20

    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUOpenChannelViewController(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUOpenChannelViewController(channelUrl:)")
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
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channel: Channel object
    public init(channel: SBDOpenChannel, messageListParams: SBDMessageListParams? = nil) {
        super.init(baseChannel: channel, messageListParams: messageListParams)
        SBULog.info("")
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = SBDMessageListParams()
    ///     params.includeMetaArray = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channelUrl: Channel url string
    public override init(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        super.init(channelUrl: channelUrl, messageListParams: messageListParams)
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
            self.rightBarButton = self.settingBarButton
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

        self.navigationController?.isNavigationBarHidden = self.hideNavigationBar
        
        self.view.addSubview(self.mediaView)
        self.mediaView.isHidden = !self.isMediaViewEnabled
        
        self.view.addSubview(self.messageTopMarginView)
        self.view.addSubview(self.messageLeftMarginView)
        
        self.view.addSubview(self.channelInfoView)
        self.channelInfoView.isHidden = self.hideChannelInfoView
        self.channelInfoView.isOverlay = self.isMediaViewOverlaying

        if self.adminMessageCell == nil {
            self.register(adminMessageCell: SBUOpenChannelAdminMessageCell())
        }
        if self.userMessageCell == nil {
            self.register(userMessageCell: SBUOpenChannelUserMessageCell())
        }
        if self.fileMessageCell == nil {
            self.register(fileMessageCell: SBUOpenChannelFileMessageCell())
        }
        if self.unknownMessageCell == nil {
            self.register(unknownMessageCell: SBUOpenChannelUnknownMessageCell())
        }

        self.emptyView?.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.backgroundView = self.emptyView
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
        
        // message input view
        self.messageInputView.delegate = self
        self.messageInputView.isOverlay = self.isMediaViewOverlaying
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

        // Orientation
        self.currentWidth = self.view.frame.width
        self.prevOrientation = UIDevice.current.orientation
        self.currentOrientation = UIDevice.current.orientation
        
        // autolayout
        self.setupAutolayout()

        // Styles
        self.setupStyles()
    }
    
    open override func setupAutolayout() {
        self.spacer.translatesAutoresizingMaskIntoConstraints = false
        let constraint = spacer.widthAnchor.constraint(
            greaterThanOrEqualToConstant: self.view.bounds.width
        )
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        self.mediaView.translatesAutoresizingMaskIntoConstraints = false
        if self.currentOrientation == .landscapeLeft || self.currentOrientation == .landscapeRight {
            self.mediaViewConstraints = [
                self.mediaView.leadingAnchor.constraint(equalTo: self.isMediaViewIgnoringSafeArea
                    ? self.view.leadingAnchor
                    : self.view.layoutMarginsGuide.leadingAnchor),
                self.mediaView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.mediaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                self.isMediaViewEnabled
                    ? self.mediaView.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                            multiplier: self.mediaViewRatio)
                    : self.mediaView.widthAnchor.constraint(equalToConstant: 0)
            ]
        }
        else {
            self.mediaViewConstraints = [
                self.mediaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.mediaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.mediaView.topAnchor.constraint(equalTo: self.isMediaViewIgnoringSafeArea
                    ? self.view.topAnchor
                    : self.view.layoutMarginsGuide.topAnchor),
                self.isMediaViewEnabled
                    ? self.mediaView.heightAnchor.constraint(equalTo: self.view.heightAnchor,
                                                             multiplier: self.mediaViewRatio)
                    : self.mediaView.heightAnchor.constraint(equalToConstant: 0)
            ]
        }
        self.mediaViewConstraints.forEach { $0.isActive = true }
        
        if self.currentOrientation == .landscapeLeft || self.currentOrientation == .landscapeRight {
            // Left (for landscape)
            self.messageLeftMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.messageLeftMarginConstraints = [
                self.messageLeftMarginView.leadingAnchor.constraint(
                    equalTo: self.view.leadingAnchor,
                    constant: self.currentWidth*(1-self.messageListRatio)
                ),
                self.messageLeftMarginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.messageLeftMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.messageLeftMarginView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ]
            self.messageLeftMarginConstraints.forEach { $0.isActive = true }
            
            self.channelInfoView.translatesAutoresizingMaskIntoConstraints = false
            self.channelInfoViewAnchorConstraints = [
                self.channelInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.channelInfoView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.channelInfoView.leadingAnchor.constraint(
                    equalTo: self.messageLeftMarginView.leadingAnchor,
                    constant: 0
                )
            ]
        }
        else {
            // Top (for portrait)
            self.messageTopMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.messageTopMarginConstraints = [
                self.messageTopMarginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.messageTopMarginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.messageTopMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.messageTopMarginView.heightAnchor.constraint(
                    equalTo: self.view.heightAnchor,
                    multiplier: (1-self.messageListRatio)
                )
            ]
            self.messageTopMarginConstraints.forEach { $0.isActive = true }
            
            // Channel info
            self.channelInfoView.translatesAutoresizingMaskIntoConstraints = false
            self.channelInfoViewAnchorConstraints = [
                self.channelInfoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.channelInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.channelInfoView.topAnchor.constraint(
                    equalTo: self.isMediaViewOverlaying
                        ? self.messageTopMarginView.bottomAnchor
                        : self.mediaView.bottomAnchor,
                    constant: 0
                )
            ]
        }
        self.channelInfoViewAnchorConstraints.forEach { $0.isActive = true }
        
        let infoViewHeight: CGFloat = self.hideChannelInfoView ? 0 : kInfoViewHeight
        self.channelInfoViewHeightConstraint = self.channelInfoView.heightAnchor.constraint(
            equalToConstant: infoViewHeight
        )
        self.channelInfoViewHeightConstraint.isActive = true
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewTopConstraint = self.tableView.topAnchor.constraint(
            equalTo: self.channelInfoView.bottomAnchor,
            constant: 0
        )
        NSLayoutConstraint.activate([
            self.tableViewTopConstraint,
            self.tableView.leftAnchor.constraint(equalTo: self.channelInfoView.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.channelInfoView.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(
                equalTo: self.messageInputView.topAnchor,
                constant: 0
            )
        ])
        
        self.channelStateBanner?
            .sbu_constraint(equalTo: self.tableView, leading: 8, trailing: -8, top: 8)
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
                equalTo: self.tableView.leftAnchor,
                constant: 0
            ),
            self.messageInputView.rightAnchor.constraint(
                equalTo: self.tableView.rightAnchor,
                constant: 0
            ),
            self.messageInputViewBottomConstraint
        ])
        
        if let scrollBottomView = self.newMessageInfoView {
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
        let theme = self.isMediaViewOverlaying ? self.overlayTheme : self.theme
        
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
            channelStateBanner.textColor = theme.channelStateBannerTextColor
            channelStateBanner.font = theme.channelStateBannerFont
            channelStateBanner.backgroundColor = theme.channelStateBannerBackgroundColor
        }
        
        self.view.backgroundColor = theme.backgroundColor
        
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUChannelTitleView {
            titleView.setupStyles()
        }
        
        self.messageInputView.isOverlay = self.isMediaViewOverlaying
        self.messageInputView.setupStyles()
        
        if let scrollBottomView = self.newMessageInfoView {
            self.setupScrollBottomViewStyle(
                scrollBottomView: scrollBottomView,
                theme: self.isMediaViewOverlaying ?
                    SBUTheme.overlayTheme.componentTheme :
                    SBUTheme.componentTheme
            )
        }
        
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.isOverlay = self.isMediaViewOverlaying
            emptyView.setupStyles()
        }
        
        self.channelInfoView.isOverlay = self.isMediaViewOverlaying
        self.channelInfoView.setupStyles()
        
        self.tableView.reloadData()
    }
    
    open func updateAutolayout() {
        self.mediaView.translatesAutoresizingMaskIntoConstraints = false
        self.mediaViewConstraints.forEach { $0.isActive = false }
        if self.currentOrientation == .landscapeLeft || self.currentOrientation == .landscapeRight {
            self.mediaViewConstraints = [
                self.mediaView.leadingAnchor.constraint(equalTo: self.isMediaViewIgnoringSafeArea
                    ? self.view.leadingAnchor
                    : self.view.layoutMarginsGuide.leadingAnchor),
                self.mediaView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.mediaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                self.isMediaViewEnabled
                    ? self.mediaView.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                            multiplier: self.mediaViewRatio)
                    : self.mediaView.widthAnchor.constraint(equalToConstant: 0)
            ]
        }
        else {
            self.mediaViewConstraints = [
                self.mediaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.mediaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.mediaView.topAnchor.constraint(equalTo: self.isMediaViewIgnoringSafeArea
                    ? self.view.topAnchor
                    : self.view.layoutMarginsGuide.topAnchor),
                self.isMediaViewEnabled
                    ? self.mediaView.heightAnchor.constraint(equalTo: self.view.heightAnchor,
                                                             multiplier: self.mediaViewRatio)
                    : self.mediaView.heightAnchor.constraint(equalToConstant: 0)
            ]
        }
        self.mediaViewConstraints.forEach { $0.isActive = true }
        
        
        self.channelInfoViewAnchorConstraints.forEach { $0.isActive = false }
        
        if self.currentOrientation == .landscapeLeft || self.currentOrientation == .landscapeRight {
            // Left (for landscape)
            self.messageLeftMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.messageLeftMarginConstraints.forEach { $0.isActive = false }
            self.messageLeftMarginConstraints = [
                self.messageLeftMarginView.leadingAnchor.constraint(
                    equalTo: self.view.leadingAnchor,
                    constant: self.currentWidth*(1-self.messageListRatio)
                ),
                self.messageLeftMarginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.messageLeftMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.messageLeftMarginView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ]
            self.messageLeftMarginConstraints.forEach { $0.isActive = true }
            
            self.channelInfoView.translatesAutoresizingMaskIntoConstraints = false
            self.channelInfoViewAnchorConstraints = [
                self.channelInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.channelInfoView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.channelInfoView.leadingAnchor.constraint(
                    equalTo: self.messageLeftMarginView.leadingAnchor,
                    constant: 0
                )
            ]
        }
        else {
            // Top (for portrait)
            self.messageTopMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.messageTopMarginConstraints.forEach { $0.isActive = false }
            self.messageTopMarginConstraints = [
                self.messageTopMarginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.messageTopMarginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.messageTopMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.messageTopMarginView.heightAnchor.constraint(
                    equalTo: self.view.heightAnchor,
                    multiplier: (1-self.messageListRatio)
                )
            ]
            self.messageTopMarginConstraints.forEach { $0.isActive = true }
            
            // Channel info
            self.channelInfoView.translatesAutoresizingMaskIntoConstraints = false
            self.channelInfoViewAnchorConstraints = [
                self.channelInfoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.channelInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.channelInfoView.topAnchor.constraint(
                    equalTo: self.isMediaViewOverlaying
                        ? self.messageTopMarginView.bottomAnchor
                        : self.mediaView.bottomAnchor,
                    constant: 0
                )
            ]
        }
        self.channelInfoViewAnchorConstraints.forEach { $0.isActive = true }
        
        let infoViewHeight: CGFloat = self.hideChannelInfoView ? 0 : kInfoViewHeight
        self.channelInfoViewHeightConstraint = self.channelInfoView.heightAnchor.constraint(
            equalToConstant: infoViewHeight
        )
        self.channelInfoViewHeightConstraint.isActive = true
        
        setScrollBottomView(hidden: nil)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.configureOffset()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // This view is above `mediaView`
        self.messageTopMarginView.isUserInteractionEnabled = false
        self.messageLeftMarginView.isUserInteractionEnabled = false
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)

        if let channelUrl = self.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(orientationChanged),
//            name: UIDevice.orientationDidChangeNotification,
//            object: nil
//        )

        self.addGestureHideKeyboard()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        if let channel = self.channel {
            guard let titleView = titleView as? SBUChannelTitleView else { return }
            titleView.updateChannelStatus(channel: channel)
        }
        
        self.updateStyles()
        self.refreshChannel()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        /// - NOTE: Not called when the orientation was changed to `.portraitUpsideDown`
        self.currentWidth = size.width
        self.updateAutolayout()
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

        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - SDK relations
    
    /// Deletes a message with message object.
    /// - Parameter message: `SBDBaseMessage` based class object
    public override func deleteMessage(message: SBDBaseMessage) {
        super.deleteMessage(message: message,
                            oneTimetheme: isMediaViewOverlaying ? SBUComponentTheme.dark : nil)
    }
    
    /// This function is used to load channel information.
    /// - Parameters:
    ///   - channelUrl: channel url
    ///   - messageListParams: (Optional) The parameter to be used when getting channel information.
    public override func loadChannel(channelUrl: String?, messageListParams: SBDMessageListParams? = nil) {
        guard let channelUrl = channelUrl else { return }
        
        if let messageListParams = messageListParams {
            self.customizedMessageListParams = messageListParams
        } else {
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
            SBDOpenChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard let self = self else { return }
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    self.errorHandler(error)
                    self.onClickBack()
                    return
                }

                SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                
                channel?.enter { [weak self] (error) in
                    guard let self = self else { return }
                    if let error = error {
                        SBULog.error("[Failed] Enter channel request: \(error.localizedDescription)")
                        self.errorHandler(error)
                        self.onClickBack()
                        return
                    }
                    
                    self.baseChannel = channel
                    
                    self.channelInfoView.configure(channel: channel, description: self.channelDescription ?? nil)
                    
                    if let titleView = self.titleView as? SBUChannelTitleView {
                        titleView.configure(channel: self.channel, title: self.channelName)
                    }
                    
                    self.updateMessageInputModeState()
                    self.updateBarButton()
                }
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
    public func updateMessagesInList(messages: [SBDBaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messageList) {
                self.messageList[index] = message
            }
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    // MARK: - Channel related
    
    private func refreshChannel() {
        if let channel = channel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    SBULog.error("[Failed] Refresh channel request : \(error.localizedDescription)")
                    self.errorHandler(error)
                    if error.code != SBDErrorCode.networkError.rawValue {
                        self.onClickBack()
                    }
                    return
                }
                SBULog.info("[Succeed] Refresh channel request")
                
                self.openChannelViewModel?.loadMessageChangeLogs()
                self.updateMessageInputModeState()
            }
        } else if let channelUrl = self.channelUrl {
            // channel hasn't been loaded before.
            self.loadChannel(channelUrl: channelUrl)
        }
    }
    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom channelSettingsViewController, override it and implement it.
    open func showChannelSettings() {
        guard let channel = self.channel else { return }
        
        let channelSettingsVC = SBUOpenChannelSettingsViewController(channel: channel)
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
    open func showParticipantsList() {
        guard let channel = self.channel else { return }
        
        let memberListVC = SBUMemberListViewController(channel: channel, type: .participants)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
        /// Used to register a custom cell as a admin message cell based on `SBUOpenChannelBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized admin message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(adminMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
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

    /// Used to register a custom cell as a user message cell based on `SBUOpenChannelBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized user message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(userMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
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

    /// Used to register a custom cell as a file message cell based on `SBUOpenChannelBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized file message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(fileMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
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

    /// Used to register a custom cell as a additional message cell based on `SBUOpenChannelBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(customMessageCell: SBUOpenChannelBaseMessageCell?, nib: UINib? = nil) {
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
    
    /// Used to register a custom cell as a unknown message cell based on `SBUOpenChannelBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized unknown message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    private func register(unknownMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
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
    open func setTapGestureHandler(_ cell: SBUOpenChannelBaseMessageCell, message: SBDBaseMessage) {
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
            switch SBUUtils.getFileType(by: fileMessage) {
            case .image:
                let viewer = SBUFileViewer(fileMessage: fileMessage, delegate: self)
                let naviVC = UINavigationController(rootViewController: viewer)
                self.present(naviVC, animated: true)
            case .etc, .pdf:
                guard let url = URL(string: fileMessage.url),
                   let fileURL = SBUCacheManager.saveAndLoadFileToLocal(url: url, fileName: fileMessage.name)  else {
                    SBUToastManager.showToast(parentVC: self, type: .fileOpenFailed)
                    return
                }
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
                guard let url = URL(string: fileMessage.url),
                   let fileURL = SBUCacheManager.saveAndLoadFileToLocal(url: url, fileName: fileMessage.name)  else {
                    SBUToastManager.showToast(parentVC: self, type: .fileOpenFailed)
                    return
                }
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
    open func setLongTapGestureHandler(_ cell: SBUOpenChannelBaseMessageCell,
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
                let types: [MessageMenuItem] = isCurrentUser ? [.copy, .edit, .delete] : [.copy]
                cell.isSelected = true
                self.showMenuModal(cell, indexPath: indexPath,  message: userMessage, types: types)
            case let fileMessage as SBDFileMessage:
                let isCurrentUser = fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
                let types: [MessageMenuItem] = isCurrentUser ? [.save, .delete] : [.save]
                cell.isSelected = true
                self.showMenuModal(cell, indexPath: indexPath, message: fileMessage, types: types)
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
    
    /// This function sets the user profile tap gesture handling.
    ///
    /// If you do not want to use the user profile function, override this function and leave it empty.
    /// - Parameter user: `SBUUser` object used for user profile configuration
    open override func setUserProfileTapGestureHandler(_ user: SBUUser) {
        self.dismissKeyboard()
        if let userProfileView = self.userProfileView as? SBUUserProfileView,
            let baseView = self.navigationController?.view,
            SBUGlobals.UsingUserProfileInOpenChannel
        {
            userProfileView.show(
                baseView: baseView,
                user: user,
                isOpenChannel: true
            )
        }
    }
    
    public func updateBarButton() {
        if rightBarButton == nil {
            guard let userId = SBUGlobals.CurrentUser?.userId else { return }
            let isOperator = self.channel?.isOperator(withUserId: userId) ?? false
                self.rightBarButton = isOperator ? self.settingBarButton : self.participantListBarButton
        }
        self.navigationItem.rightBarButtonItem = self.rightBarButton
    }

    
    // MARK: - Message input mode
    
    /// This is used to messageInputView state update.
    public func updateMessageInputModeState() {
        if let _ = self.channel {
            self.updateFrozenModeState()
        } else {
            self.messageInputView.setErrorState()
        }
    }
    
    func updateFrozenModeState() {
        guard let userId = SBUGlobals.CurrentUser?.userId else { return }
        let isOperator = self.channel?.isOperator(withUserId: userId) ?? false
        let isFrozen = self.channel?.isFrozen ?? false
        self.messageInputView.setFrozenModeState(!isOperator && isFrozen)
        self.channelStateBanner?.isHidden = !isFrozen
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
    
    public func configureOffset() {
        guard self.tableView.contentOffset.y < 0,
            self.tableViewTopConstraint.constant <= 0 else { return }
      
        let tempOffset = self.tableView.contentOffset.y
        self.tableViewTopConstraint.constant -= tempOffset
    }
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public override func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        guard showIndicator else { return }
        
        if loadingState {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }
    
    /// This is a function that gets the location of the message to be grouped.
    ///
    /// Only successful messages can be grouped.
    /// - Parameter currentIndex: Index of current message in the message list
    /// - Returns: Position of a message when grouped
    public func getMessageGroupingPosition(currentIndex: Int) -> MessageGroupPosition {
        guard currentIndex < self.fullMessageList.count-1 else { return .none }
        
        let prevMessage = self.fullMessageList.count+2 > currentIndex
            ? self.fullMessageList[currentIndex+1]
            : nil
        let currentMessage = self.fullMessageList[currentIndex]
        let nextMessage = currentIndex != 0
            ? self.fullMessageList[currentIndex-1]
            : nil
        
        let succeededPrevMsg = prevMessage?.sendingStatus == .succeeded
            ? prevMessage
            : nil
        let succeededCurrentMsg = currentMessage.sendingStatus == .succeeded
            ? currentMessage
            : nil
        let succeededNextMsg = nextMessage?.sendingStatus == .succeeded
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
    
    // MARK: - Orientation
    func orientationChanged(_ notification: NSNotification) {
        if UIDevice.current.orientation == .faceUp || UIDevice.current.orientation == .faceDown { return }
        self.currentOrientation = UIDevice.current.orientation
        
        if prevOrientation != currentOrientation {
            /// - NOTE: Methods below are called in `viewWillTransition`. (`viewWillTransition` is called first except for `.portraitUpsideDown`)
            self.updateAutolayout()
            self.updateStyles()
        }

        self.prevOrientation = currentOrientation
    }
    
    
    // MARK: - Actions
    
    /// This function actions to pop or dismiss.
    public override func onClickBack() {
        self.channel?.exitChannel(completionHandler: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                SBULog.error("[Failed] Exit channel request: \(error.localizedDescription)")
                self.errorHandler(error)
            }
            
            if let navigationController = self.navigationController,
                navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    /// This function shows channel settings.
    public func onClickSetting() {
        self.showChannelSettings()
    }
    
    public func onClickParticipantsList() {
        self.showParticipantsList()
    }
    
    @objc open func onClickScrollBottom(sender: UIButton?) {
        self.scrollToBottom(animated: false)
    }
    
    
    // MARK: - ScrollView
    
    /// Sets the scroll to bottom view.
    /// - Parameter hidden: whether to hide the view. `nil` to handle it automatically depending on the current scroll position.
    public override func setScrollBottomView(hidden: Bool?) {
        let shouldHide = hidden ?? isScrollNearBottom()
        
        guard shouldHide != self.newMessageInfoView?.isHidden else { return }
        self.newMessageInfoView?.isHidden = shouldHide
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.tableView else { return }
        
        self.lastSeenIndexPath = nil
        
        if isScrollNearBottom() {
            self.lastSeenIndexPath = nil
            setScrollBottomView(hidden: true)
        } else {
            if let newMessageInfoView = self.newMessageInfoView {
                /// - NOTE:  If messageListView(`tableView`) is hidden, `newMessageInfoView` must be hidden also.
                newMessageInfoView.isHidden = self.tableView.isHidden
            }
        }
    }
    /// This shows new message view based on `hasNext`
    override func setNewMessageInfoView(hidden: Bool) {
        guard let newMessageInfoView = self.newMessageInfoView else { return }
        guard hidden != newMessageInfoView.isHidden else { return }
        guard let openChannelViewModel = self.openChannelViewModel else { return }
        
        newMessageInfoView.isHidden = hidden && !openChannelViewModel.hasNext()
    }
    

    // MARK: - Cell generator
    
    /// This function sets gestures in user message cell.
    /// - Parameters:
    ///   - cell: User message cell
    ///   - userMessage: User message object
    ///   - indexPath: Cell's indexPath
    open func setUserMessageCellGestures(_ cell: SBUOpenChannelUserMessageCell,
                                         userMessage: SBDUserMessage,
                                         indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }
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
    open func setFileMessageCellGestures(_ cell: SBUOpenChannelFileMessageCell,
                                         fileMessage: SBDFileMessage,
                                         indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }
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
    open func setUnkownMessageCellGestures(_ cell: SBUOpenChannelUnknownMessageCell,
                                           unknownMessage: SBDBaseMessage,
                                           indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }
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
    func setFileMessageCellImages(_ cell: SBUOpenChannelFileMessageCell,
                                  fileMessage: SBDFileMessage) {
        self.setCellImage(cell, fileMessage: fileMessage)
    }
    
    
    // MARK: - Cell's menu
    
    /// This function calculates the point at which to draw the menu.
    /// - Parameters:
    ///   - indexPath: IndexPath
    ///   - position: Message position
    /// - Returns: `CGPoint` value
    public func calculatorMenuPoint(indexPath: IndexPath) -> CGPoint {
        
        // Jaesung's Opinion: What about `open`, not `public`?
        let rowRect = self.tableView.rectForRow(at: indexPath)
        let rowRectInSuperview = self.tableView.convert(
            rowRect,
            to: self.tableView.superview?.superview
        )
        
        let y = rowRectInSuperview.origin.y < self.tableView.frame.minY
            ? self.tableView.frame.origin.y
            : rowRectInSuperview.origin.y

        let menuPoint = CGPoint(x: self.messageInputView.frame.minX, y: y)
        
        return menuPoint
    }
    
    /// This function shows cell's menu.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - indexPath: IndexPath
    ///   - message: Message object
    ///   - types: Type array of menu items to use
    public func showMenuModal(_ cell: UITableViewCell,
                              indexPath: IndexPath,
                              message: SBDBaseMessage,
                              types: [MessageMenuItem]) {
        guard let cell = cell as? SBUOpenChannelBaseMessageCell else { return }
        
        let menuItems = self.createMenuItems(
            message: message,
            types: types,
            isMediaViewOverlaying: isMediaViewOverlaying
        )

        let menuPoint = self.calculatorMenuPoint(indexPath: indexPath)
        SBUMenuView.show(
            items: menuItems,
            point: menuPoint,
            oneTimetheme: isMediaViewOverlaying ? SBUComponentTheme.dark : nil
        ) {
            cell.isSelected = false
        }
    }
    
    /// This function shows cell's menu: retry, delete, cancel.
    ///
    /// This is used when selected failed message.
    /// - Parameter message: message object
    /// - Since: 2.1.12
    public func showFailedMessageMenu(message: SBDBaseMessage) {
        let theme = self.isMediaViewOverlaying ? self.overlayTheme : self.theme
        
        let retryItem = SBUActionSheetItem(
            title: SBUStringSet.Retry,
            color: theme.menuItemTintColor
        ) { [weak self] in
            self?.resendMessage(failedMessage: message)
        }
        let deleteItem = SBUActionSheetItem(
            title: SBUStringSet.Delete,
            color: theme.deleteItemColor
        ) { [weak self] in
            self?.deleteResendableMessages(
                requestIds: [message.requestId],
                needReload: true
            )
        }
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.cancelItemColor,
            completionHandler: nil
        )

        SBUActionSheet.show(
            items: [retryItem, deleteItem],
            cancelItem: cancelItem
        )
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.channel != nil else {
            self.errorHandler("Channel must exist!", -1)
            return UITableViewCell()
        }
        
        let message = self.fullMessageList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: self.generateCellIdentifier(by: message)
            ) ?? UITableViewCell()
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.selectionStyle = .none
        
        guard let messageCell = cell as? SBUOpenChannelBaseMessageCell else {
            self.errorHandler("There are no message cells!", -1)
            return cell
        }
        
        //NOTE: to disable unwanted animation while configuring cells
        UIView.setAnimationsEnabled(false)
        
        let isSameDay = self.checkSameDayAsNextMessage(currentIndex: indexPath.row)
        switch (message, messageCell) {
            
        // Amdin Message
        case let (adminMessage, adminMessageCell) as (SBDAdminMessage, SBUOpenChannelAdminMessageCell):
            adminMessageCell.configure(
                adminMessage,
                hideDateView: isSameDay,
                isOverlay: isMediaViewOverlaying
            )
        // Unknown Message
        case let (unknownMessage, unknownMessageCell) as (SBDBaseMessage, SBUOpenChannelUnknownMessageCell):
            unknownMessageCell.configure(
                unknownMessage,
                hideDateView: isSameDay,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                withTextView: true,
                isOverlay: isMediaViewOverlaying
            )
            self.setUnkownMessageCellGestures(
                unknownMessageCell,
                unknownMessage: unknownMessage,
                indexPath: indexPath
            )
            
        // User Message
        case let (userMessage, userMessageCell) as (SBDUserMessage, SBUOpenChannelUserMessageCell):
            userMessageCell.configure(
                userMessage,
                hideDateView: isSameDay,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                withTextView: true,
                isOverlay: isMediaViewOverlaying
            )
            self.setUserMessageCellGestures(
                userMessageCell,
                userMessage: userMessage,
                indexPath: indexPath
            )
            
        // File Message
        case let (fileMessage, fileMessageCell) as (SBDFileMessage, SBUOpenChannelFileMessageCell):
            fileMessageCell.configure(
                fileMessage,
                hideDateView: isSameDay,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                fileType: SBUUtils.getFileType(by: fileMessage),
                isOverlay: isMediaViewOverlaying
            )
            
            self.setFileMessageCellGestures(
                fileMessageCell,
                fileMessage: fileMessage,
                indexPath: indexPath
            )
            
            self.setFileMessageCellImages(fileMessageCell, fileMessage: fileMessage)
            
        default:
            messageCell.configure(
                message: message,
                hideDateView: isSameDay,
                isOverlay: isMediaViewOverlaying
            )
        }
        
        UIView.setAnimationsEnabled(true)
        
        // Tap profile action
        messageCell.userProfileTapHandler = { [weak messageCell, weak self] in
            guard let self = self else { return }
            guard let cell = messageCell, let sender = cell.message.sender else { return }
            self.setUserProfileTapGestureHandler(SBUUser.init(sender: sender))
        }

        return cell
    }
    
    /// This function generates cell's identifier.
    /// - Parameter message: Message object
    /// - Returns: Identifier
    open func generateCellIdentifier(by message: SBDBaseMessage) -> String {
        switch message {
        case is SBDFileMessage:
            return fileMessageCell?.sbu_className ?? SBUOpenChannelFileMessageCell.sbu_className
        case is SBDUserMessage:
            return userMessageCell?.sbu_className ?? SBUOpenChannelUserMessageCell.sbu_className
        case is SBDAdminMessage:
            return adminMessageCell?.sbu_className ?? SBUOpenChannelAdminMessageCell.sbu_className
        default:
            return unknownMessageCell?.sbu_className ?? SBUOpenChannelUnknownMessageCell.sbu_className
        }
    }
}

// MARK: - SBUChannelInfoHeaderViewDelegate
extension SBUOpenChannelViewController: SBUChannelInfoHeaderViewDelegate {
    open func didSelectChannelInfo() {
        SBULog.info("didSelectChannelInfo")
        self.showChannelSettings()
    }

    open func didSelectChannelParticipants() {
        SBULog.info("didSelectChannelParticipants")
        self.showParticipantsList()
    }
}

// MARK: - SBDChannelDelegate, SBDConnectionDelegate
extension SBUOpenChannelViewController: SBDChannelDelegate, SBDConnectionDelegate {
    // MARK: SBDChannelDelegate
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
            self.channelViewModel?.messageCache?.add(messages: [message])
            
            if message is SBDUserMessage ||
                message is SBDFileMessage {
                // message is not added.
                // reset lastSeenIndexPath to not keep scroll in `increaseNewMessageCount`.
                self.lastSeenIndexPath = nil
                self.increaseNewMessageCount()
            }
        }
        
        if !hasNext {
            self.upsertMessagesInList(messages: [message], needUpdateNewMessage: true, needReload: true)
        }
    }
    
    // Updated message
    open func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard self.messageListParams.belongs(to: message) else {
            self.deleteMessagesInList(messageIds: [message.messageId], needReload: true)
            return
        }
        
        SBULog.info("Did update message: \(message)")
        
        self.updateMessagesInList(messages: [message], needReload: true)
    }
    
    // Deleted message
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Message was deleted: \(messageId)")
        
        self.deleteMessagesInList(messageIds: [messageId], needReload: true)
    }
      
    open func channelWasChanged(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDOpenChannel else { return }
        SBULog.info("Channel was changed, ChannelUrl:\(channel.channelUrl)")

        if let titleView = titleView as? SBUChannelTitleView {
            titleView.configure(channel: channel, title: self.channelName)
        }
    }
    
    open func channelWasFrozen(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDOpenChannel else { return }
        SBULog.info("Channel was frozen, ChannelUrl:\(channel.channelUrl)")
        
        self.updateMessageInputModeState()
    }
    
    open func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDOpenChannel else { return }
        SBULog.info("Channel was unfrozen, ChannelUrl:\(channel.channelUrl)")
        
        self.updateMessageInputModeState()
    }
    
    open func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are muted.")
            self.updateMessageInputModeState()
        }
    }
    
    open func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are unmuted.")
            self.updateMessageInputModeState()
        }
    }
    
    open func channelDidUpdateOperators(_ sender: SBDBaseChannel) {
        self.updateMessageInputModeState()
    }

    open func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are banned.")
            self.onClickBack()
        }
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        guard let titleView = self.titleView as? SBUChannelTitleView else { return }
        titleView.updateChannelStatus(channel: sender)
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        guard let titleView = self.titleView as? SBUChannelTitleView else { return }
        titleView.updateChannelStatus(channel: sender)
    }
    
    open func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - SBDConnectionDelegate
    open func didSucceedReconnection() {
        SBULog.info("Did succeed reconnection")
        SBUMain.updateUserInfo { error in
            if let error = error {
                SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        refreshChannel()
    }
}

extension SBUOpenChannelViewController: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
}
