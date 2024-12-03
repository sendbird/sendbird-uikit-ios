//
//  SBUOpenChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Photos
#if SWIFTUI
import SwiftUI
#endif

#if SWIFTUI
protocol OpenChannelViewEventDelegate: AnyObject {
    
}
#endif

@objcMembers
open class SBUOpenChannelViewController: SBUBaseChannelViewController, SBUOpenChannelViewModelDelegate, SBUOpenChannelModuleHeaderDelegate, SBUOpenChannelModuleListDelegate, SBUOpenChannelModuleInputDelegate, SBUOpenChannelModuleMediaDelegate, SBUOpenChannelModuleListDataSource, SBUOpenChannelModuleInputDataSource, SBUOpenChannelViewModelDataSource {
    
    // MARK: - UI properties (Public)
    public var headerComponent: SBUOpenChannelModule.Header? {
        get { self.baseHeaderComponent as? SBUOpenChannelModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUOpenChannelModule.List? {
        get { self.baseListComponent as? SBUOpenChannelModule.List }
        set { self.baseListComponent = newValue }
    }
    public var inputComponent: SBUOpenChannelModule.Input? {
        get { self.baseInputComponent as? SBUOpenChannelModule.Input }
        set { self.baseInputComponent = newValue }
    }
    public var mediaComponent: SBUOpenChannelModule.Media?
    
    // for channel info
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.channelTheme, setToDefault: true)
    public var overlayTheme: SBUChannelTheme
    
    public var prevOrientation: UIDeviceOrientation = .unknown
    public var currentOrientation: UIDeviceOrientation = .unknown
    
    public var weakHeaderComponentBottomConstraint: NSLayoutConstraint = .init()
    
    // swiftlint:disable identifier_name
    // MARK: - UI properties (Private)
    // for constraint
    private var mediaComponentLeadingConstraintForPortrait: NSLayoutConstraint?
    private var mediaComponentLeadingConstraintForLandscape: NSLayoutConstraint?
    private var mediaComponentTrailingConstraintForPortrait: NSLayoutConstraint?
    // swiftlint:enable identifier_name
    private var mediaComponentTopConstraintForPortrait: NSLayoutConstraint?
    private var mediaComponentTopConstraintForLandscape: NSLayoutConstraint?
    private var mediaComponentBottomConstraint: NSLayoutConstraint?
    
    private var mediaComponentWidthConstraint: NSLayoutConstraint?
    private var mediaComponentHeightConstraint: NSLayoutConstraint?
    
    private var listLeftMarginLeadingConstraint: NSLayoutConstraint?
    private var listLeftMarginTrailingConstraint: NSLayoutConstraint?
    private var listLeftMarginTopConstraint: NSLayoutConstraint?
    private var listLeftMarginBottomConstraint: NSLayoutConstraint?
    
    private var headerLeadingConstraintForPortrait: NSLayoutConstraint?
    private var headerLeadingConstraintForLandscape: NSLayoutConstraint?
    private var headerTrailingConstraint: NSLayoutConstraint?
    private var headerTopConstraintForPortrait: NSLayoutConstraint?
    private var headerTopConstraintForLandscape: NSLayoutConstraint?
    private var headerHeightConstraint: NSLayoutConstraint?
    
    // for top content area in portrait mode
    private var listTopMarginView = SBUMarginView()
    private var listTopMarginConstraints: [NSLayoutConstraint] = []
    
    // for right content area in landscape mode
    private var listLeftMarginView = SBUMarginView()
    private var listLeftMarginConstraints: [NSLayoutConstraint] = []
    
    // constant
    private let headerHeight: CGFloat = 56
    private var currentWidth: CGFloat = 0
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUOpenChannelViewModel? {
        get { self.baseViewModel as? SBUOpenChannelViewModel }
        set { self.baseViewModel = newValue }
    }
    
    public override var channel: OpenChannel? { self.viewModel?.channel as? OpenChannel }
    
    // Component
    /// If it's `true`, the navigation bar will be hidden.
    public var hideNavigationBar: Bool = false
    
    /// If it's `true`, the channel info view will be hidden.
    public var hideChannelInfoView: Bool = true
    
    /// Sets text in `channelInfoView.descriptionLabel`
    public var channelDescription: String?
    
    // Media
    
    /// A boolean value whether the media view is enabled or not. The default value is `false`.
    /// - Note: Use `enableMediaView(_:)` to set value.
    /// ```
    /// self.enableMediaView(true)
    /// self.print(isMediaViewEnabled) // true
    /// ```
    public private(set) var isMediaViewEnabled: Bool = false
    
    /// A relative ratio value of `mediaView`to entire screen. The default value is `0`.
    /// - Note: Use `updateMessageListRatio(to ratio:)` to set value.
    public private(set) var mediaViewRatio: CGFloat  = 0.0
    
    /// A relative ratio value of messaging view to entire screen. The default value is `1`
    /// - Note: Use `updateMessageListRatio(to ratio:)` to set value.
    public private(set) var messageListRatio: CGFloat = 1.0
    
    /// A boolean value whether `mediaView` is overlay or not. The default value is `false`.
    /// - Note: Use `overlayMediaView(_:messageListRatio:)` to set value.
    public private(set) var isMediaViewOverlaying: Bool = false
    
    /// If the media view area extends outside the screen’s safe areas, it's `true`. The default value is `true`.
    /// - Note: Use `mediaViewIgnoringSafeArea(_:)` to set value.
    public private(set) var isMediaViewIgnoringSafeArea: Bool = true
    
    // MARK: - Logic properties (Private)
    
    // MARK: - SwiftUI
    #if SWIFTUI
    var channelSettingsViewBuilder: OpenChannelSettingsViewBuilder?
    var participantListViewBuilder: OpenParticipantListViewBuilder?
    
    weak var swiftUIDelegate: (SBUOpenChannelViewModelDelegate & OpenChannelViewEventDelegate)? {
        didSet {
            self.viewModel?.baseDelegates.addDelegate(self.swiftUIDelegate, type: .swiftui)
        }
    }
    #endif
    
    // MARK: - Lifecycle
    
    /// If you have channel object, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = MessageListParams()
    ///     params.includeMetaArray = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `MessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channel: Channel object
    required public init(channel: OpenChannel, messageListParams: MessageListParams? = nil) {
        super.init(baseChannel: channel, messageListParams: messageListParams)
        
        self.headerComponent = SBUModuleSet.OpenChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.OpenChannelModule.ListComponent.init()
        self.inputComponent = SBUModuleSet.OpenChannelModule.InputComponent.init()
        self.mediaComponent = SBUModuleSet.OpenChannelModule.MediaComponent.init()
    }
    
    required public init(
        channelURL: String,
        startingPoint: Int64? = nil,
        messageListParams: MessageListParams? = nil
    ) {
        super.init(
            channelURL: channelURL,
            startingPoint: startingPoint,
            messageListParams: messageListParams
        )
        
        self.headerComponent = SBUModuleSet.OpenChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.OpenChannelModule.ListComponent.init()
        self.inputComponent = SBUModuleSet.OpenChannelModule.InputComponent.init()
        self.mediaComponent = SBUModuleSet.OpenChannelModule.MediaComponent.init()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerOrientationChangeNotification()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        /// - NOTE: Not called when the orientation was changed to `.portraitUpsideDown`
        self.currentWidth = size.width
        self.updateLayouts()
        self.updateStyles()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.configureOffset()
    }

    deinit {
        SBULog.info("")
    }
    
    // MARK: - ViewModel
    open override func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        showIndicator: Bool = true
    ) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        self.baseViewModel = SBUViewModelSet.OpenChannelViewModel.init(
            channel: channel,
            channelURL: channelURL,
            messageListParams: messageListParams,
            startingPoint: startingPoint,
            delegate: self,
            dataSource: self
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        listTopMarginView.tag = 1122
        listLeftMarginView.tag = 2233
        let theme = self.isMediaViewOverlaying ? self.overlayTheme : self.theme
        
        // media view (OpenChannel)
        self.navigationController?.isNavigationBarHidden = self.hideNavigationBar
        
        if let mediaComponent = self.mediaComponent {
            self.view.addSubview(mediaComponent)
            
            if let listComponent = listComponent {
                self.view.insertSubview(mediaComponent, belowSubview: listComponent)
            }
        }
        self.mediaComponent?.isHidden = !self.isMediaViewEnabled
        
        super.setupViews()
        
        headerComponent?
            .configure(delegate: self, theme: theme)
        listComponent?
            .configure(delegate: self, dataSource: self, theme: theme)
        inputComponent?
            .configure(delegate: self, dataSource: self, theme: theme)
        mediaComponent?
            .configure(delegate: self, theme: theme)
        
        // This view is above `mediaView`
        self.view.addSubview(self.listTopMarginView)
        self.view.addSubview(self.listLeftMarginView)
        
        // channel info view
        if let headerComponent = headerComponent {
            self.view.addSubview(headerComponent)
            headerComponent.hidesChannelInfoView = self.hideChannelInfoView
            headerComponent.overlaysChannelInfoView = self.isMediaViewOverlaying
        }
        
        if let inputComponent = inputComponent {
            (inputComponent.messageInputView as? SBUMessageInputView)?.isOverlay = self.isMediaViewOverlaying
        }
        
        // Orientation
        self.currentWidth = self.view.frame.width
        self.prevOrientation = UIDevice.current.orientation
        self.currentOrientation = UIDevice.current.orientation
        
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        // Media component layout
        self.mediaComponent?.translatesAutoresizingMaskIntoConstraints = false
        
        // for portrait
        self.mediaComponentLeadingConstraintForPortrait = self.mediaComponent?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        self.mediaComponentTrailingConstraintForPortrait = self.mediaComponent?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.mediaComponentTopConstraintForPortrait = self.mediaComponent?.topAnchor.constraint(
            equalTo: self.isMediaViewIgnoringSafeArea
            ? self.view.topAnchor
            : self.view.layoutMarginsGuide.topAnchor
            )
        self.mediaComponentHeightConstraint = self.isMediaViewEnabled
        ? self.mediaComponent?.heightAnchor.constraint(
            equalTo: self.view.heightAnchor,
            multiplier: self.mediaViewRatio
        )
        : self.mediaComponent?.heightAnchor.constraint(equalToConstant: 0)
        
        // for landscape
        self.mediaComponentLeadingConstraintForLandscape = self.mediaComponent?.leadingAnchor.constraint(
            equalTo: self.isMediaViewIgnoringSafeArea
            ? self.view.leadingAnchor
            : self.view.layoutMarginsGuide.leadingAnchor
        )
        self.mediaComponentTopConstraintForLandscape = self.mediaComponent?.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.mediaComponentBottomConstraint = self.mediaComponent?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.mediaComponentWidthConstraint = self.isMediaViewEnabled
        ? self.mediaComponent?.widthAnchor.constraint(
            equalTo: self.view.widthAnchor,
            multiplier: self.mediaViewRatio
        )
        : self.mediaComponent?.widthAnchor.constraint(equalToConstant: 0)
        
        switch self.currentOrientation {
        case .landscapeLeft, .landscapeRight:
            self.mediaComponentLeadingConstraintForLandscape?.isActive = true
            self.mediaComponentTopConstraintForLandscape?.isActive = true
            self.mediaComponentBottomConstraint?.isActive = true
            self.mediaComponentWidthConstraint?.isActive = true
            
        default:
            self.mediaComponentLeadingConstraintForPortrait?.isActive = true
            self.mediaComponentTrailingConstraintForPortrait?.isActive = true
            self.mediaComponentTopConstraintForPortrait?.isActive = true
            self.mediaComponentHeightConstraint?.isActive = true
        }
        
        // Header component layout
        self.headerComponent?.translatesAutoresizingMaskIntoConstraints = false
        
        // for Landscape
        self.headerLeadingConstraintForLandscape = headerComponent?.leadingAnchor.constraint(
            equalTo: self.listLeftMarginView.leadingAnchor,
            constant: 0
        )
        self.headerTopConstraintForLandscape = headerComponent?.topAnchor.constraint(equalTo: self.view.topAnchor)
        
        // for portrait
        self.headerLeadingConstraintForPortrait = headerComponent?.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor,
            constant: 0
        )
        self.headerTopConstraintForPortrait = headerComponent?.topAnchor.constraint(
            equalTo: self.isMediaViewOverlaying
            ? self.listTopMarginView.bottomAnchor
            : self.mediaComponent?.bottomAnchor ?? self.listTopMarginView.bottomAnchor,
            constant: 0
        )
        self.headerTopConstraintForPortrait?.priority = .defaultHigh - 50

        // common
        self.headerTrailingConstraint = headerComponent?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.headerTrailingConstraint?.priority = .defaultHigh
        
        let infoViewHeight: CGFloat = self.hideChannelInfoView ? 0 : headerHeight
        self.headerHeightConstraint = headerComponent?.heightAnchor.constraint(
            equalToConstant: infoViewHeight
        )
        
        switch self.currentOrientation {
        case .landscapeRight, .landscapeLeft:
            self.headerLeadingConstraintForLandscape?.isActive = true
            self.headerTopConstraintForLandscape?.isActive = true
        default:
            // Top (for portrait)
            self.headerLeadingConstraintForPortrait?.isActive = true
            self.headerTopConstraintForPortrait?.isActive = true
        }

        self.headerTrailingConstraint?.isActive = true
        self.headerHeightConstraint?.isActive = true
        
        // list left/top margin
        switch self.currentOrientation {
        case .landscapeRight, .landscapeLeft:
            self.listLeftMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.listLeftMarginConstraints = [
                self.listLeftMarginView.leadingAnchor.constraint(
                    equalTo: self.view.leadingAnchor,
                    constant: self.currentWidth*(1-self.messageListRatio)
                ),
                self.listLeftMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.listLeftMarginView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ]
            self.listLeftMarginConstraints.forEach { $0.isActive = true }

        default:
            // Top (for portrait)
            self.listTopMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.listTopMarginConstraints = [
                self.listTopMarginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.listTopMarginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.listTopMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.listTopMarginView.heightAnchor.constraint(
                    equalTo: self.view.heightAnchor,
                    multiplier: (1-self.messageListRatio)
                )
            ]
            self.listTopMarginConstraints.forEach { $0.isActive = true }
        }
        
        if let listComponent = listComponent {
            listComponent.translatesAutoresizingMaskIntoConstraints = false
            
            tableViewTopConstraint?.isActive = false
            tableViewLeftConstraint?.isActive = false
            tableViewRightConstraint?.isActive = false
            tableViewBottomConstraint?.isActive = false
            
            self.tableViewTopConstraint = listComponent.topAnchor.constraint(
                equalTo: self.headerComponent?.bottomAnchor ?? self.view.topAnchor,
                constant: 0
            )
            self.tableViewBottomConstraint = listComponent.bottomAnchor.constraint(
                equalTo: self.inputComponent?.topAnchor ?? self.view.bottomAnchor,
                constant: 0
            )
            self.tableViewLeftConstraint = listComponent.leftAnchor.constraint(
                equalTo: self.headerComponent?.leftAnchor ?? self.view.leftAnchor,
                constant: 0
            )
            self.tableViewRightConstraint = listComponent.rightAnchor.constraint(
                equalTo: self.headerComponent?.rightAnchor ?? self.view.rightAnchor,
                constant: 0
            )
            
            tableViewTopConstraint?.isActive = true
            tableViewLeftConstraint?.isActive = true
            tableViewRightConstraint?.isActive = true
            tableViewBottomConstraint?.isActive = true
        }
        
        if let inputComponent = inputComponent {
            inputComponent
                .sbu_constraint(equalTo: self.listComponent ?? self.view, left: 0, right: 0)
            
            self.messageInputViewTopConstraint?.isActive = false
            self.messageInputViewBottomConstraint?.isActive = false
            
            self.messageInputViewTopConstraint = inputComponent.topAnchor.constraint(
                equalTo: self.listComponent?.bottomAnchor ?? self.view.bottomAnchor,
                constant: 0
            )
            self.messageInputViewBottomConstraint = self.inputComponent?.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor,
                constant: 0
            )
            
            self.messageInputViewTopConstraint?.isActive = true
            self.messageInputViewBottomConstraint?.isActive = true
        }
    }
    
    open override func updateLayouts() {
        super.updateLayouts()
        
        self.mediaComponentLeadingConstraintForPortrait?.isActive = false
        self.mediaComponentTopConstraintForPortrait?.isActive = false
        self.mediaComponentTrailingConstraintForPortrait?.isActive = false
        self.mediaComponentLeadingConstraintForLandscape?.isActive = false
        self.mediaComponentTopConstraintForLandscape?.isActive = false
        self.mediaComponentBottomConstraint?.isActive = false
        self.mediaComponentWidthConstraint?.isActive = false
        self.mediaComponentHeightConstraint?.isActive = false
        
        switch self.currentOrientation {
        case .landscapeLeft, .landscapeRight:
            self.mediaComponentWidthConstraint = self.isMediaViewEnabled
            ? self.mediaComponent?.widthAnchor.constraint(
                equalTo: self.view.widthAnchor,
                multiplier: self.mediaViewRatio
            )
            : self.mediaComponent?.widthAnchor.constraint(equalToConstant: 0)
            
            self.mediaComponentLeadingConstraintForLandscape?.isActive = true
            self.mediaComponentTopConstraintForLandscape?.isActive = true
            self.mediaComponentBottomConstraint?.isActive = true
            self.mediaComponentWidthConstraint?.isActive = true
            
        default:
            self.mediaComponentHeightConstraint = self.isMediaViewEnabled
            ? self.mediaComponent?.heightAnchor.constraint(
                equalTo: self.view.heightAnchor,
                multiplier: self.mediaViewRatio
            )
            : self.mediaComponent?.heightAnchor.constraint(equalToConstant: 0)
            
            self.mediaComponentLeadingConstraintForPortrait?.isActive = true
            self.mediaComponentTrailingConstraintForPortrait?.isActive = true
            self.mediaComponentTopConstraintForPortrait?.isActive = true
            self.mediaComponentHeightConstraint?.isActive = true
        }

        self.headerLeadingConstraintForPortrait?.isActive = false
        self.headerLeadingConstraintForLandscape?.isActive = false
        self.headerTopConstraintForPortrait?.isActive = false
        self.headerTopConstraintForLandscape?.isActive = false
        self.headerHeightConstraint?.isActive = false
        
        switch self.currentOrientation {
        case .landscapeRight, .landscapeLeft:
            self.headerLeadingConstraintForLandscape?.isActive = true
            self.headerTopConstraintForLandscape?.isActive = true

        default:
            // Top (for portrait)
            self.headerLeadingConstraintForPortrait?.isActive = true
            self.headerTopConstraintForPortrait?.isActive = true
        }
        self.headerHeightConstraint?.isActive = true
        
        // list left/top margin
        self.listLeftMarginConstraints.forEach { $0.isActive = false }
        self.listTopMarginConstraints.forEach { $0.isActive = false }
    
        switch self.currentOrientation {
        case .landscapeRight, .landscapeLeft:
            self.listLeftMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.listLeftMarginConstraints = [
                self.listLeftMarginView.leadingAnchor.constraint(
                    equalTo: self.view.leadingAnchor,
                    constant: self.currentWidth*(1-self.messageListRatio)
                ),
                self.listLeftMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.listLeftMarginView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ]
            self.listLeftMarginConstraints.forEach { $0.isActive = true }

        default:
            // Top (for portrait)
            self.listTopMarginView.translatesAutoresizingMaskIntoConstraints = false
            self.listTopMarginConstraints = [
                self.listTopMarginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.listTopMarginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.listTopMarginView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.listTopMarginView.heightAnchor.constraint(
                    equalTo: self.view.heightAnchor,
                    multiplier: (1-self.messageListRatio)
                )
            ]
            self.listTopMarginConstraints.forEach { $0.isActive = true }
        }
        
        if let listComponent = listComponent {
            let hidden = listComponent.isScrollNearByBottom
            listComponent.setScrollBottomView(hidden: hidden)
        }
    }
    
    open override func setupStyles() {
        let theme = self.isMediaViewOverlaying ? self.overlayTheme : self.theme
        self.setupStyles(theme: theme)
    }
    
    open override func updateStyles(needsToLayout: Bool) {
        self.setupStyles()
        super.updateStyles()
        
        self.headerComponent?.updateStyles(overlaid: self.isMediaViewOverlaying)
        self.inputComponent?.updateStyles(overlaid: self.isMediaViewOverlaying)
        
        // Invokes `updateStyles(overlaid:)` instead of `updateStyles(theme:componentTheme:)`
        self.listComponent?
            .updateStyles(
                theme: self.isMediaViewOverlaying
                ? self.overlayTheme
                : self.theme,
                componentTheme: self.isMediaViewOverlaying
                ? SBUTheme.overlayTheme.componentTheme
                : SBUTheme.componentTheme
            )
        
        self.listComponent?.reloadTableView(needsToLayout: needsToLayout)
    }
    
    open override func updateStyles() {
        self.updateStyles(needsToLayout: true)
    }
    
    // MARK: - Channel
    
    /// This function updates channel info view. If `channelDescription` is set, this value is used for channel info view configuring.
    public func updateChannelInfoView() {
        if let headerComponent = headerComponent {
            (headerComponent.channelInfoView as? SBUChannelInfoHeaderView)?
                .configure(channel: channel, description: self.channelDescription ?? nil)
        }
    }
    
    // MARK: - Message: Menu
    
    /// This function calculates the point at which to draw the menu.
    /// - Parameters:
    ///   - indexPath: IndexPath
    /// - Returns: `CGPoint` value
    @available(*, deprecated, message: "Please use `calculateMessageMenuCGPoint(indexPath:)` in `SBUOpenChannelModule.List`") // 3.1.2
    public func calculatorMenuPoint(indexPath: IndexPath) -> CGPoint {
        guard let listComponent = listComponent else {
            SBULog.error("listComponent is not set up.")
            return .zero
        }
        return listComponent.calculateMessageMenuCGPoint(indexPath: indexPath)
    }
    
    @available(*, deprecated, message: "Please use `showMessageContextMenu(for:cell:forRowAt:)` in `SBUOpenChannelModule.List`") // 3.1.2
    public override func showMenuModal(_ cell: UITableViewCell,
                                       indexPath: IndexPath,
                                       message: BaseMessage,
                                       types: [MessageMenuItem]?) {
        self.listComponent?.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath)
    }
    
    @available(*, deprecated, message: "Please use `showDeleteMessageAlert(on:oneTimeTheme:)` in `SBUOpenChannelModule.List` instead.") // 3.1.2
    public override func showDeleteMessageMenu(message: BaseMessage,
                                               oneTimetheme: SBUComponentTheme? = nil) {
        self.listComponent?.showDeleteMessageAlert(
            on: message,
            oneTimeTheme: isMediaViewOverlaying ? SBUComponentTheme.dark : nil
        )
    }
    
    // MARK: - Media View
    
    /// Enable the internal media view.
    /// - Parameters:
    /// - enabled: If it's `true` It uses the media view.
    /// ```
    /// self.enableMediaView(true)
    /// self.updateMessageListRatio(to: 0.7)
    /// ```
    public func enableMediaView(_ enabled: Bool = true) {
        self.isMediaViewEnabled = enabled
        if !enabled {
            updateMessageListRatio(to: 1)
        }
    }
    
    /// Updates a relative ratio value of the message list with  `ratio` to entire screen.
    ///
    /// The mediaView will have it's ratio accordingly, meaning
    /// - normal mode : mediaView's ratio = (1 - message list's ratio). Media view & message list is side by side in landscape mode, top to bottom in portrait mode.
    /// - overlay mode : mediaView's ratio = 1 (fills the whole screen). Media view fills the whole screen & message list is above the media view with transparent background.
    ///
    /// After this method, You might need to call `setupStyles` or `updateComponentStyle`.
    ///
    /// - Parameters:
    ///   - ratio: A relative ratio value of message list to entire screen. If it's `nil` or it's not in range from 0 to 1 inclusive, the value won't be set.
    ///
    /// - Important: The ratio must be in range of `0...1`.
    /// ```
    /// self.updateMessageListRatio(to: 0.7)
    /// ```
    public func updateMessageListRatio(to ratio: CGFloat) {
        guard (0...1).contains(ratio) else {
            SBULog.warning("The ratio must be in range of 0...1")
            return
        }
        
        self.messageListRatio = ratio
        self.mediaViewRatio = self.isMediaViewOverlaying ? 1 : (1 - ratio)
    }
    
    /// Overlays the media view.
    ///
    /// - Parameters:
    ///   - overlaying: If it's `true`, `mediaViewRatio` will be set to `1.0`. If it's `false`, `mediaViewRatio` will be set to `1 - messageListRatio`.
    ///   - messageListRatio: A relative ratio value of  message list to entire screen.
    ///
    /// ```
    /// // Enable overlay mode
    /// self.overlayMediaView(true, messageListRatio: 0.4)
    ///
    /// // Disable overlay mode
    /// self.overlayMediaView(false, messageListRatio: 0.3)    // mediaViewRatio is 0.7
    /// ```
    public func overlayMediaView(_ overlaying: Bool, messageListRatio: CGFloat) {
        self.isMediaViewOverlaying = overlaying
        self.updateMessageListRatio(to: messageListRatio)
    }
    
    /// Changes the media view area to extend outside the screen’s safe areas.
    ///
    /// - Parameters:
    ///   - enabled: A boolean value whther the media view ignores safe area or not.
    ///
    /// - Note:
    ///   - Ignores top edge when it's on portrait mode.
    ///   - Ignores leading edge when it's on landscape mode.
    ///
    /// ```
    /// self.mediaViewIgnoringSafeArea(true)
    /// ```
    public func mediaViewIgnoringSafeArea(_ enabled: Bool = true) {
        self.isMediaViewIgnoringSafeArea = enabled
    }
    
    // MARK: - ScrollView
    public func configureOffset() {
        guard let tableView = self.listComponent?.tableView else { return }
        guard tableView.contentOffset.y < 0,
              let tableViewTopConstraint = self.tableViewTopConstraint,
              tableViewTopConstraint.constant <= 0 else { return }
        
        let tempOffset = tableView.contentOffset.y
        self.tableViewTopConstraint?.constant -= tempOffset
    }
    
    // MARK: - Navigation
    public func updateBarButton() {
        guard let userId = SBUGlobals.currentUser?.userId else { return }
        let isOperator = self.channel?.isOperator(userId: userId) ?? false
        self.headerComponent?.updateBarButton(isOperator: isOperator)
    }
    
    // MARK: - Actions
    
    /// This function actions to pop or dismiss.
    public override func onClickBack() {
        guard let channel = channel else {
            super.onClickBack()
            return
        }
        channel.exit(completionHandler: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                SBULog.error("[Failed] Exit channel request: \(error.localizedDescription)")
                self.errorHandler(error.localizedDescription)
            }
            
            if dismissAction != nil {
                dismissAction?()
            } else {
                if let navigationController = self.navigationController,
                   navigationController.viewControllers.count > 1 {
                    navigationController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    open override func showChannelSettings() {
        guard let channel = self.channel else { return }
        
        #if SWIFTUI
        if let channelSettingsViewBuilder = self.channelSettingsViewBuilder {
            let view = channelSettingsViewBuilder(
                channel.channelURL
            )
            let channelSettingsVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(channelSettingsVC, animated: true)
            return
        }
        #endif
        
        let channelSettingsVC = SBUViewControllerSet.OpenChannelSettingsViewController.init(channel: channel)
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
    /// If you want to use a custom participants list, override it and implement it.
    open func showParticipantsList() {
        guard let channel = self.channel else { return }
        
        #if SWIFTUI
        if let participantListViewBuilder = self.participantListViewBuilder {
            let view = participantListViewBuilder(
                channel.channelURL
            )
            let participantListVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(participantListVC, animated: true)
            return
        }
        #endif
        
        let participantListVC = SBUViewControllerSet.OpenUserListViewController.init(channel: channel, userListType: .participants)
        self.navigationController?.pushViewController(participantListVC, animated: true)
    }
    
    // MARK: - Orientation
    public func registerOrientationChangeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    func orientationChanged(_ notification: NSNotification) {
        if UIDevice.current.orientation == .faceUp || UIDevice.current.orientation == .faceDown { return }
        self.currentOrientation = UIDevice.current.orientation
        
        if prevOrientation != currentOrientation {
            /// - NOTE: Methods below are called in `viewWillTransition`. (`viewWillTransition` is called first except for `.portraitUpsideDown`)
            self.updateLayouts()
            self.updateStyles()
        }
        
        self.prevOrientation = currentOrientation
    }
    
    // MARK: - SBUOpenChannelModuleHeaderDelegate
    open override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem) {
        onClickBack()
    }
    
    open override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        
        guard let channel = self.channel else { return }
        guard let userId = SBUGlobals.currentUser?.userId else { return }
        let isOperator = channel.isOperator(userId: userId)
        
        if isOperator {
            // Channel settings
            self.showChannelSettings()
        } else {
            // ParticipantList
            self.showParticipantsList()
        }
    }
    
    open override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateTitleView titleView: UIView?) {
        #if SWIFTUI
        if self.headerComponent?.viewConverter.leftView.entireContent != nil || self.headerComponent?.viewConverter.rightView.entireContent != nil {
            self.navigationItem.titleView = titleView
            return
        }
        #endif
        super.baseChannelModule(headerComponent, didUpdateTitleView: titleView)
    }
    
    // MARK: - SBUOpenChannelModuleListDelegate
    open override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapUserProfile user: SBUUser) {
        self.showUserProfile(user: user, isOpenChannel: true)
    }
    
    // MARK: - SBUOpenChannelModuleListDataSource
    open func openChannelModuleIsOverlaid(_ listComponent: SBUOpenChannelModule.List) -> Bool {
        self.isMediaViewOverlaying
    }
    
    // MARK: - SBUOpenChannelModuleInputDelegate
    open override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didUpdateFrozenState isFrozen: Bool) {
        self.listComponent?.channelStateBanner?.isHidden = !isFrozen
    }
    
    open func openChannelModule(_ inputComponent: SBUOpenChannelModule.Input, didPickFileData fileData: Data?, fileName: String, mimeType: String) {
        self.viewModel?.sendFileMessage(
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType
        )
    }
    
    open override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didScroll scrollView: UIScrollView) {
        super.baseChannelModule(listComponent, didScroll: scrollView)
        
        self.lastSeenIndexPath = nil
        
        if listComponent.isScrollNearByBottom {
            self.updateNewMessageInfo(hidden: true)
        }
    }
    
    // MARK: - SBUOpenChannelModuleMediaDelegate
    open func openChannelModule(_ mediaComponent: SBUOpenChannelModule.Media, didTapMediaView mediaView: UIView) {
        
    }
    
    // MARK: - SBUOpenChannelViewModelDelegate
    open override func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    ) {
        guard channel != nil else {
            if self.isLastInNavigationStack() {
                // If leave is called in the ChannelSettingsViewController, this logic needs to be prevented.
                self.onClickBack()
            }
            return
        }
        
        #if SWIFTUI
        if self.listComponent?.viewConverter.tableView.entireContent != nil {
            self.listComponent?.applyViewConverter(.entireContent)
        }
        #endif
        
        // channel changed
        switch context.source {
        case .channelChangelog:
            self.updateChannelTitle()
            self.updateChannelStatus()
            self.updateChannelInfoView()
            self.updateBarButton()
            self.inputComponent?.updateMessageInputModeState()
            self.listComponent?.reloadTableView()
            
        case .eventChannelChanged:
            self.updateChannelTitle()
            self.updateChannelStatus()
            self.updateChannelInfoView()
            self.updateBarButton()
            self.inputComponent?.updateMessageInputModeState()
            
        case .eventChannelFrozen, .eventChannelUnfrozen,
                .eventUserMuted, .eventUserUnmuted,
                .eventOperatorUpdated,
                .eventUserBanned: // Other User Banned
            self.updateChannelTitle()
            self.updateBarButton()
            self.inputComponent?.updateMessageInputModeState()
            
        case .eventChannelMemberCountChanged:
            self.updateChannelTitle()
            self.listComponent?.reloadTableView()
            
        default: break
        }
    }
}
