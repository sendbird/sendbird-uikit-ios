//
//  SBUBaseChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/11/17.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import MobileCoreServices
import AVKit
import SafariServices
import PhotosUI

@objcMembers
open class SBUBaseChannelViewController: SBUBaseViewController, SBUBaseChannelViewModelDelegate, SBUBaseChannelModuleHeaderDelegate, SBUBaseChannelModuleListDelegate, SBUBaseChannelModuleListDataSource, SBUBaseChannelModuleInputDelegate, SBUBaseChannelModuleInputDataSource, SBUBaseChannelViewModelDataSource, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, SBUSelectablePhotoViewDelegate, SBUFileViewControllerDelegate, SBUCommonViewModelDelegate, SBUAlertViewDelegate {
    
    // MARK: - UI Properties (Public)
    public var baseHeaderComponent: SBUBaseChannelModule.Header?
    public var baseListComponent: SBUBaseChannelModule.List?
    public var baseInputComponent: SBUBaseChannelModule.Input?
    
    /// To decide whether to use right bar button item or not
    public var useRightBarButtonItem: Bool = true {
        didSet { self.navigationItem.rightBarButtonItem = useRightBarButtonItem ? self.baseHeaderComponent?.rightBarButton : nil }
    }
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.channelTheme)
    public var theme: SBUChannelTheme
    
    // MARK: - Logic Properties (Public)
    public var baseViewModel: SBUBaseChannelViewModel?
    
    public var channelName: String?
    
    /// The state property to indicate whether it's showing the keyboard or not. It's `false` when ``keyboardWillHide(_:)`` is called and `true` when ``keyboardWillShow(_:)`` is called. The default value is `false`
    /// - Since: 3.2.3
    public var isKeyboardShowing: Bool = false

    var messageInputViewTopConstraint: NSLayoutConstraint?
    var messageInputViewLeftConstraint: NSLayoutConstraint?
    var messageInputViewRightConstraint: NSLayoutConstraint?
    /// The `NSLayoutConstraint` value used in ``baseInputComponent``'s bottom anchor constraint. The value is updated when either ``keyboardWillHide(_:)`` or ``keyboardWillShow(_:)`` is called.
    /// - Since: 3.2.3
    public var messageInputViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Logic Properties (Private)
    var initialMessageInputBottomConstraint: CGFloat = 0
    var initialMessageInputOrigin: CGPoint = .zero
    
    var tableViewTopConstraint: NSLayoutConstraint?
    var tableViewLeftConstraint: NSLayoutConstraint?
    var tableViewRightConstraint: NSLayoutConstraint?
    var tableViewBottomConstraint: NSLayoutConstraint?
    
    var lastSeenIndexPath: IndexPath?
    
    var scrollToInitialPositionHandler: (() -> Void)?
    
    var isTransformedList: Bool = true
    
    var isDisableChatInputState: Bool = false
    
    // MARK: - Lifecycle
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("Cannot use `init(coder:)`")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// If you have channel object, use this initializer. If you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = MessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeThreadInfo = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `MessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameters:
    ///   - baseChannel: Channel object
    ///   - messageListParams: `MessageListParams` object to be used when loading messages.
    ///   - displaysLocalCachedListFirst: (GroupChannel only) If this option is `true`, when a list is received through the local cache during initialization, it is displayed first.
    /// - Since: 1.0.11
    public init(baseChannel: BaseChannel, messageListParams: MessageListParams? = nil, displaysLocalCachedListFirst: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info(#function)
        
        if displaysLocalCachedListFirst {
            self.createViewModel(
                channel: baseChannel,
                messageListParams: messageListParams,
                displaysLocalCachedListFirst: displaysLocalCachedListFirst
            )
        } else {
            self.createViewModel(
                channel: baseChannel,
                messageListParams: messageListParams
            )
        }
    }
    
    /// Initiates view controller to enter a channel with its URL, message list params and a specific timestamp representing a starting potint.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = MessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeThreadInfo = true
    ///     ...
    /// ```
    ///
    /// - note: The `reverse` and the `previousResultSize` properties in the `MessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    ///
    /// - Parameters:
    ///   - channelURL: Channel's URL
    ///   - startingPoint: A starting point timestamp to start the message list from.
    ///   - messageListParams: `MessageListParams` object to be used when loading messages.
    /// - Since: 2.1.0
    required public init(
        channelURL: String,
        startingPoint: Int64? = nil,
        messageListParams: MessageListParams? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
        
        SBULog.info(#function)
        
        self.createViewModel(
            channelURL: channelURL,
            messageListParams: messageListParams,
            startingPoint: startingPoint
        )
    }
    
    /// Initiates view controller to enter a channel with its URL, message list params and a specific timestamp representing a starting potint.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = MessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeThreadInfo = true
    ///     ...
    /// ```
    ///
    /// - note: The `reverse` and the `previousResultSize` properties in the `MessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    ///
    /// - Parameters:
    ///   - channelURL: Channel's URL
    ///   - startingPoint: A starting point timestamp to start the message list from.
    ///   - messageListParams: `MessageListParams` object to be used when loading messages.
    ///   - displaysLocalCachedListFirst: (GroupChannel only) If this option is `true`, when a list is received through the local cache during initialization, it is displayed first.
    /// - Since: 3.3.5
    public init(
        channelURL: String,
        startingPoint: Int64? = nil,
        messageListParams: MessageListParams? = nil,
        displaysLocalCachedListFirst: Bool
    ) {
        super.init(nibName: nil, bundle: nil)
        
        SBULog.info(#function)
        
        if displaysLocalCachedListFirst {
            self.createViewModel(
                channelURL: channelURL,
                messageListParams: messageListParams,
                startingPoint: startingPoint,
                displaysLocalCachedListFirst: displaysLocalCachedListFirst
            )
        } else {
            self.createViewModel(
                channelURL: channelURL,
                messageListParams: messageListParams,
                startingPoint: startingPoint
            )
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        if #available(iOS 13.0, *) {
            self.navigationController?.isModalInPresentation = true
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerKeyboardNotifications()
        
        self.updateChannelStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActivity), name: UIApplication.willResignActiveNotification, object: nil)
        self.updateStyles(needsToLayout: false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addGestureHideKeyboard()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let userProfileView = self.baseListComponent?.userProfileView as? SBUUserProfileView {
            userProfileView.dismiss()
        }
        
        self.view.endEditing(true)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Called when the application will resign activity.
    open func applicationWillResignActivity() { }
    
    /// Called when the subview will present.
    open func willPresentSubview() {}
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        self.theme.statusBarStyle
    }
    
    deinit {
        self.baseViewModel = nil
        self.baseHeaderComponent = nil
        self.baseListComponent = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - ViewModel
    /// Creates the view model, loading initial messages from given starting point.
    /// - Note: If you want to customize the viewModel, override this function
    /// - Parameters:
    ///   - baseChannel: Channel object
    ///   - channelURL: Channel's URL
    ///   - messageListParams: `MessageListParams` object to be used when loading messages.
    ///   - startingPoint: The starting point timestamp of the messages. `nil` to start from the latest.
    ///   - showIndicator: Whether to show loading indicator on loading the initial messages.
    /// - Since: 3.0.0
    open func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        showIndicator: Bool = true
    ) { }
    
    /// Creates the view model, loading initial messages from given starting point.
    /// - Note: If you want to customize the viewModel, override this function
    /// - Parameters:
    ///   - baseChannel: Channel object
    ///   - channelURL: Channel's URL
    ///   - messageListParams: `MessageListParams` object to be used when loading messages.
    ///   - startingPoint: The starting point timestamp of the messages. `nil` to start from the latest.
    ///   - showIndicator: Whether to show loading indicator on loading the initial messages.
    ///   - displaysLocalCachedListFirst: (GroupChannel only) If this option is `true`, when a list is received through the local cache during initialization, it is displayed first.
    /// - Since: 3.3.5
    open func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        showIndicator: Bool = true,
        displaysLocalCachedListFirst: Bool
    ) { }
    
    // MARK: - Sendbird UIKit Life cycle
    
    // Please call me after the configuration of the component!
    /// Sets up views including module components.
    ///
    /// - Important: When you override this method, please call `super.setupViews` after `configure` method of the component. e.g.
    /// ```swift
    /// override func setupViews() {
    ///     self.baseHeaderComponent = SBUModuleSet.groupChannelModule.headerComponent()
    ///     self.baseHeaderComponent?.configure(delegate: self, theme: self.theme)
    ///
    ///     super.setupViews()
    /// }
    /// ```
    open override func setupViews() {
        // Header
        self.navigationItem.titleView = self.baseHeaderComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.baseHeaderComponent?.leftBarButton
        self.navigationItem.rightBarButtonItem = useRightBarButtonItem ? self.baseHeaderComponent?.rightBarButton : nil
        
        // List
        if let baseListComponent = baseListComponent {
            self.view.addSubview(baseListComponent)
        }
        
        // Input
        if let baseInputComponent = baseInputComponent {
            self.view.addSubview(baseInputComponent)
        }
        
        self.scrollToInitialPositionHandler = { [weak self] in
            if Thread.isMainThread {
                self?.baseListComponent?.tableView.layoutIfNeeded()
                self?.baseListComponent?.scrollToInitialPosition()
            } else {
                DispatchQueue.main.async {
                    self?.baseListComponent?.tableView.layoutIfNeeded()
                    self?.baseListComponent?.scrollToInitialPosition()
                }
            }
        }
    }
    
    open override func setupStyles() {
        self.setupStyles(theme: self.theme)
    }
    
    func setupStyles(theme: SBUChannelTheme) {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationBarShadowColor
        )
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    /// Setups scrollBottom view style.
    /// - Parameters:
    ///   - scrollBottomView: Scroll bottom view
    ///   - theme: theme for setup
    public func setupScrollBottomViewStyle(
        scrollBottomView: UIView,
        theme: SBUComponentTheme = SBUTheme.componentTheme
    ) {
        if let baseListComponent = baseListComponent {
            baseListComponent.setupScrollBottomViewStyle(
                scrollBottomView: scrollBottomView,
                theme: theme
            )
        }
    }
    
    // MARK: - Channel
    
    /// Updates channelTitle with channel and channelName
    /// - Since: 3.0.0
    public func updateChannelTitle() {
        if let titleView = self.baseHeaderComponent?.titleView as? SBUChannelTitleView {
            titleView.configure(
                channel: self.baseViewModel?.channel,
                title: self.channelName
            )
        }
    }
    
    // MARK: *
    /// Updates channelStatus with channel
    /// - Since: 3.0.0
    public func updateChannelStatus() {
        guard let channel = self.baseViewModel?.channel else { return }
        if let titleView = self.baseHeaderComponent?.titleView as? SBUChannelTitleView {
            titleView.updateChannelStatus(channel: channel)
        }
    }
    
    // MARK: - Message: Menu
    
    /// Shows channel settings view controller such as `SBUGroupChannelSettingsViewController`
    open func showChannelSettings() { }
    
    /// This function shows message thread view controller.
    /// - Parameters:
    ///   - channelURL: Channel url string
    ///   - parentMessageId: Parent message's Id
    ///   - parentMessageCreatedAt: Parent message's created time
    ///   - startingPoint: If not set this value, message thread list will be exposed from the first message. If you want to  expose the most recent messages first, use the `.max` value.
    /// - Since: 3.3.0
    open func showMessageThread(channelURL: String, parentMessageId: Int64, parentMessageCreatedAt: Int64? = 0, startingPoint: Int64? = 0) { }
    
    /// This function presents `SBUEmojiListViewController`
    /// - Parameter message: `BaseMessage` object
    /// - Since: 1.1.0
    open func showEmojiListModal(message: BaseMessage) {
        let emojiListVC = SBUEmojiListViewController(message: message)
        emojiListVC.modalPresentationStyle = .custom
        emojiListVC.transitioningDelegate = self
        
        emojiListVC.emojiTapHandler = { [weak self] emojiKey, setSelect in
            guard let self = self else { return }
            self.baseViewModel?.setReaction(
                message: message,
                emojiKey: emojiKey,
                didSelect: setSelect
            )
        }
        self.present(emojiListVC, animated: true)
    }
    
    // MARK: - TableView
    
    /// Scrolls to the message that is found by `id`. When it scrolls successfully, ``SBUBaseChannelModuleListDelegate/baseChannelModule(_:didScroll:)`` delegate method is called.
    /// - Parameters:
    ///    - messageId: The identifier of the message that is wanted to find
    ///    - enablesScrollAnimation: The boolean value whether scrolls to the message with animation or not. If `false`, it *jumps* to the message.
    ///    - enablesMessageAnimation: The boolean value whether animate the message after the scrolling. If `true`, the message is shaked up and down.
    ///    - position: Scroll position value.
    ///    - needToSearch: If `true`, reloads the collection based on the message information if not found by message ID.
    /// - SeeAlso: ``SBUBaseChannelModule/List/scrollToMessage(id:enablesScrollAnimation:enablesMessageAnimation:)``
    public func scrollToMessage(
        id messageId: Int64,
        enablesScrollAnimation: Bool = false,
        enablesMessageAnimation: Bool = false,
        position: SBUScrollPosition = .middle,
        needToSearch: Bool = true
    ) {
        self.baseListComponent?.scrollToMessage(
            id: messageId,
            enablesScrollAnimation: enablesScrollAnimation,
            enablesMessageAnimation: enablesMessageAnimation,
            position: position,
            needToSearch: needToSearch
        )
    }
    
    /// Scrolls to the message that is found by id of `message`. When it scrolls successfully, ``SBUBaseChannelModuleListDelegate/baseChannelModule(_:didScroll:)`` delegate method is called.
    /// - Parameters:
    ///    - message: The message that is wanted to find
    ///    - enablesScrollAnimation: The boolean value whether scrolls to the message with animation or not. If `false`, it *jumps* to the message.
    ///    - enablesMessageAnimation: The boolean value whether animate the message after the scrolling. If `true`, the message is shaked up and down.
    ///    - position: Scroll position value.
    ///    - needToSearch: If `true`, reloads the collection based on the message information if not found by message ID.
    /// - SeeAlso: ``SBUBaseChannelModule/List/scrollToMessage(id:enablesScrollAnimation:enablesMessageAnimation:)``
    public func scrollToMessage(
        message: BaseMessage,
        enablesScrollAnimation: Bool = false,
        enablesMessageAnimation: Bool = false,
        position: SBUScrollPosition = .middle,
        needToSearch: Bool = true
    ) {
        self.baseListComponent?.scrollToMessage(
            message: message,
            enablesScrollAnimation: enablesScrollAnimation,
            enablesMessageAnimation: enablesMessageAnimation,
            position: position,
            needToSearch: needToSearch
        )
    }
    
    // MARK: - New message info
    
    /// This function updates new message info view's hidden status.
    /// - Parameter hidden: hidden status
    /// - Since: 3.0.0
    public func updateNewMessageInfo(hidden: Bool) {
        guard let newMessageInfoView = self.baseListComponent?.newMessageInfoView else { return }
        guard hidden != newMessageInfoView.isHidden else { return }
        guard let viewModel = self.baseViewModel else { return }
        
        newMessageInfoView.isHidden = hidden && !viewModel.hasNext()
    }
    
    // MARK: - Common
    
    /// Opens a file that is type of `SBUFileData` according to its file type
    ///
    /// ```swift
    /// let fileData = SBUFileData(fileMessage: fileMessage)
    /// openFile(fileData)
    /// ```
    ///
    /// - Parameter fileData: ``SBUFileData`` object.
    /// - Since: 3.10.0
    open func openFile(_ fileData: SBUFileData) {
        self.willPresentSubview()
        
        SBULoading.start()
        
        switch fileData.fileType {
        case .image:
            let viewer = SBUCommonViewControllerSet.FileViewController.init(
                fileData: fileData,
                delegate: self
            )
            let naviVC = UINavigationController(rootViewController: viewer)
            SBULoading.stop()
            self.present(naviVC, animated: true)
            
        case .etc, .pdf, .video, .audio:
            SBUCacheManager.File.loadFile(urlString: fileData.urlString, fileName: fileData.name) { fileURL, _ in
                SBULoading.stop()
                
                guard let fileURL = fileURL else {
                    SBUToastView.show(type: .file(.openFailed))
                    return
                }
                
                switch fileData.fileType {
                case .audio, .video:
                    if SBUGlobals.isAVPlayerAlwaysEnabled {
                        let vc = AVPlayerViewController()
                        vc.player = AVPlayer(url: fileURL)
                        self.present(vc, animated: true) { vc.player?.play() }
                    } else {
                        let dc = UIDocumentInteractionController(url: fileURL)
                        dc.name = fileData.name
                        dc.delegate = self
                        dc.presentPreview(animated: true)
                    }
                default:
                    if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
                        if messageInputView.mode != .quoteReply {
                            self.setMessageInputViewMode(.none)
                        }
                    }
                    
                    if fileURL.scheme == "file" {
                        let dc = UIDocumentInteractionController(url: fileURL)
                        dc.name = fileData.name
                        dc.delegate = self
                        dc.presentPreview(animated: true)
                    } else {
                        let safariVC = SFSafariViewController(url: fileURL)
                        self.present(safariVC, animated: true, completion: nil)
                    }
                }
            }
        default:
            SBULoading.stop()
            return
        }
    }
    
    /// This function opens a file according to the file type.
    /// - Parameter fileMessage: fileMessage object
    /// - Note: Use `openFile(_:)` instead.
    /// - Since: 3.0.0
    open func openFile(fileMessage: FileMessage) {
        let fileData = SBUFileData(fileMessage: fileMessage)
        self.openFile(fileData)
    }
    
    /// This function increases the new message count.
    @discardableResult
    public func increaseNewMessageCount() -> Bool {
        guard let tableView = self.baseListComponent?.tableView,
              tableView.contentOffset != .zero,
              self.baseViewModel?.isLoadingNext == false
        else {
            self.lastSeenIndexPath = nil
            return false
        }
        
        let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first
        ?? IndexPath(row: 0, section: 0)
        self.lastSeenIndexPath = IndexPath(row: firstVisibleIndexPath.row + 1, section: 0)
        return true
    }
    
    /// Shows user profile view with user object
    /// - Parameter user: `SBUUser` object
    /// - Parameter isOpenChannel: Set the property to `true` if you're using it in an open channel.
    ///
    /// - Since: 3.11.0
    public func showUserProfile(user: SBUUser, isOpenChannel: Bool = false) {
        self.dismissKeyboard()
        
        guard let userProfileView = self.baseListComponent?.userProfileView as? SBUUserProfileView else { return }
        guard let baseView = self.navigationController?.view else { return }
        guard SendbirdUI.config.common.isUsingDefaultUserProfileEnabled else { return }
        
        let completionHandler: ((SBUUser, UIView) -> Void) = { user, baseView in
            userProfileView.show(
                baseView: baseView,
                user: user,
                isOpenChannel: isOpenChannel
            )
        }
        
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true) { [user, baseView] in
                    completionHandler(user, baseView)
                }
        } else {
            completionHandler(user, baseView)
        }
    }
    
    // MARK: - MessageInputView
    
    open func setMessageInputViewMode(_ mode: SBUMessageInputMode, message: BaseMessage? = nil) {
        self.baseInputComponent?.updateMessageInputMode(mode, message: message)
    }
    
    // MARK: - VoiceMessageInput
    open func showVoiceMessageInput() {}
    
    open func dismissVoiceMessageInput() {}
    
    open func resetVoiceMessageInput(for resignActivity: Bool = false) {}
    
    // MARK: - Error handling
    func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - SBUBaseChannelViewModelDelegate
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    ) { }
    
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didReceiveNewMessage message: BaseMessage,
        forChannel channel: BaseChannel
    ) {
        self.increaseNewMessageCount()
    }
    
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldFinishEditModeForChannel channel: BaseChannel
    ) {
        self.setMessageInputViewMode(.none)
    }
    
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldDismissForChannel channel: BaseChannel?
    ) {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeMessageList messages: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    ) {
        guard let baseListComponent = baseListComponent else { return }
        let emptyViewType: EmptyViewType = (!initialLoad && viewModel.fullMessageList.isEmpty) ? .noMessages : .none
        baseListComponent.updateEmptyView(type: emptyViewType)
        
        defer {
            if !initialLoad && !(self.baseViewModel?.isScrollToInitialPositionFinish ?? false) {
                self.scrollToInitialPositionHandler?()
                self.baseViewModel?.isScrollToInitialPositionFinish = true
            }
        }
        
        self.isDisableChatInputState =  messages.first?.asExtendedMessagePayload?.getDisabledChatInputState(hasNext: self.baseViewModel?.hasNext()) ?? false
        
        guard needsToReload else { return }
        
        // Verify that the UIViewController is currently visible on the screen
        let needsToLayout = self.isViewLoaded && (self.view.window != nil)
        baseListComponent.reloadTableView(needsToLayout: needsToLayout)
        
        guard let lastSeenIndexPath = self.lastSeenIndexPath else {
            let hidden = baseListComponent.isScrollNearByBottom
            baseListComponent.setScrollBottomView(hidden: hidden)
            
            if baseListComponent.isScrollNearByBottom,
                let fullMessageList = self.baseViewModel?.fullMessageList,
               !self.isTransformedList {
                self.baseListComponent?.scrollTableView(to: fullMessageList.count - 1)
            }
            
            return
        }
        
        baseListComponent.scrollTableView(to: lastSeenIndexPath.row)
        let hidden = baseListComponent.isScrollNearByBottom
        baseListComponent.setScrollBottomView(hidden: hidden)
    }
    
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        deletedMessages messages: [BaseMessage]
    ) { }
    
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldUpdateScrollInMessageList messages: [BaseMessage],
        forContext context: MessageContext?,
        keepsScroll: Bool
    ) {
        SBULog.info("Fetched : \(messages.count), keepScroll : \(keepsScroll)")
        guard let baseListComponent = baseListComponent else { return }
        
        guard !messages.isEmpty else {
            SBULog.info("Fetched empty messages.")
            return
        }
        
        if context?.source == .eventMessageSent {
            if !keepsScroll {
                self.baseChannelModuleDidTapScrollToButton(baseListComponent, animated: false)
            }
        } else if context?.source != .eventMessageReceived {
            // follow keepScroll flag if context is not `eventMessageReceived`.
            if keepsScroll, !baseChannelViewModel(viewModel, isScrollNearBottomInChannel: viewModel.channel) {
                self.lastSeenIndexPath = baseListComponent.keepCurrentScroll(for: messages)
            }
        } else {
            if !baseChannelViewModel(viewModel, isScrollNearBottomInChannel: viewModel.channel) {
                self.lastSeenIndexPath = baseListComponent.keepCurrentScroll(for: messages)
            }
        }
    }
    
    open func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didUpdateReaction reaction: ReactionEvent,
        forMessage message: BaseMessage
    ) {
        
    }
    
    // MARK: - SBUBaseChannelModuleHeaderDelegate
    open func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateTitleView titleView: UIView?) {
        var titleStackView = UIStackView()
        
        if let titleView = titleView {
            titleStackView = UIStackView(arrangedSubviews: [
                titleView,
                headerComponent.titleSpacer
            ])
            titleStackView.axis = .horizontal
        }
        
        self.navigationItem.titleView = titleStackView
    }
    
    open func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapTitleView titleView: UIView?) {
    }
    
    open func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?) {
        if useRightBarButtonItem {
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    open func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem) {
        
    }
    
    open func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        self.willPresentSubview()
    }
    
    // MARK: - SBUBaseChannelModuleListDelegate
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let baseViewModel = self.baseViewModel else { return }
        guard baseViewModel.fullMessageList.count > 0 else { return }
        
        let sentMessageList = baseViewModel.messageList
        let fullMessageList = baseViewModel.fullMessageList
        let messageListParams = baseViewModel.messageListParams
        
        if indexPath.row >= (fullMessageList.count - messageListParams.previousResultSize/2),
           baseViewModel.hasPrevious() {
            if let openChannelViewModel = baseViewModel as? SBUOpenChannelViewModel {
                openChannelViewModel.loadPrevMessages(timestamp: sentMessageList.last?.createdAt)
            } else if let messageThreadViewModel = baseViewModel as? SBUMessageThreadViewModel {
                messageThreadViewModel.loadPrevMessages(timestamp: sentMessageList.last?.createdAt)
            } else {
                baseViewModel.loadPrevMessages()
            }
        } else if indexPath.row < 5,
                  baseViewModel.hasNext() {
            baseViewModel.loadNextMessages()
        }
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapMessage message: BaseMessage, forRowAt indexPath: IndexPath) {
        self.dismissKeyboard()
        
        switch message {
            
        case let userMessage as UserMessage:
            // User message type, only fail case
            guard userMessage.sendingStatus == .failed,
                  userMessage.sender?.userId == SBUGlobals.currentUser?.userId  else { return }
            self.baseViewModel?.resendMessage(failedMessage: userMessage)
            self.baseChannelModuleDidTapScrollToButton(listComponent, animated: true)
            
        case let fileMessage as FileMessage:
            // File message type
            switch fileMessage.sendingStatus {
            case .pending:
                break
            case .failed:
                guard fileMessage.sender?.userId == SBUGlobals.currentUser?.userId else { return }
                self.baseViewModel?.resendMessage(failedMessage: fileMessage)
                self.baseChannelModuleDidTapScrollToButton(listComponent, animated: true)
            case .succeeded:
                self.openFile(fileMessage: fileMessage)
            default:
                break
            }
            
        case _ as AdminMessage:
            // Admin message type
            break
        default:
            break
        }
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didLongTapMessage message: BaseMessage, forRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        listComponent.showMessageMenu(on: message, forRowAt: indexPath)
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapVoiceMessage fileMessage: FileMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapSaveMessage message: BaseMessage) {
        guard let fileMessage = message as? FileMessage else { return }
        SBUDownloadManager.save(fileMessage: fileMessage, parent: self)
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapCopyMessage message: BaseMessage) {
        guard let userMessage = message as? UserMessage else { return }
        let pasteboard = UIPasteboard.general
        pasteboard.string = userMessage.message
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapEditMessage message: BaseMessage) {
        guard let channel = self.baseViewModel?.channel else { return }
        guard let userMessage = message as? UserMessage else { return }
        
        if channel.isFrozen == false ||
            self.baseViewModel?.isOperator == true {
            self.setMessageInputViewMode(.edit, message: userMessage)
        } else {
            SBULog.info("This channel is frozen")
        }
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapDeleteMessage message: BaseMessage) {
        guard message.threadInfo.replyCount == 0 else { return }
        self.baseViewModel?.deleteMessage(message: message)
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapReplyMessage message: BaseMessage) {
        guard message.parentMessage == nil else { return }
        
        switch SendbirdUI.config.groupChannel.channel.replyType {
        case .quoteReply:
            self.setMessageInputViewMode(.quoteReply, message: message)
        case .thread:
            if let channelURL = self.baseViewModel?.channelURL {
                // If it is the parent message itself, use `messageId` rather than `parentMessageId`.
                self.showMessageThread(
                    channelURL: channelURL,
                    parentMessageId: message.messageId,
                    parentMessageCreatedAt: message.createdAt,
                    startingPoint: .max
                )
            }
            break
        default:
            break
        }
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didDismissMenuForCell cell: UITableViewCell) {
        cell.isSelected = false
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapMoreEmojisOnMessage message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showEmojiListModal(message: message)
        }
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didFailScrollToMessageId messageId: Int64, needToSearch: Bool) {
        guard needToSearch == true else {
            self.errorHandler("Couldn't find the message with id: \(messageId)")
            return
        }
        
        self.baseViewModel?.channel?.getMessagesByMessageId(
            messageId,
            params: MessageListParams(previousResultSize: 1, nextResultSize: 1),
            completionHandler: { [weak self] messages, _ in
                guard let self = self, let message = messages?.first(where: { $0.messageId == messageId }) else {
                    self?.errorHandler("Couldn't find the message with id: \(messageId)")
                    return
                }
                
                self.baseViewModel?.loadInitialMessages(
                    startingPoint: message.createdAt,
                    showIndicator: true,
                    initialMessages: self.baseViewModel?.fullMessageList
                )
            })
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didFailScrollToMessage message: BaseMessage, needToSearch: Bool) {
        guard needToSearch == true else {
            self.errorHandler("Couldn't find the message with id: \(message.messageId)")
            return
        }
        
        baseViewModel?.loadInitialMessages(
            startingPoint: message.createdAt,
            showIndicator: true,
            initialMessages: self.baseViewModel?.fullMessageList
        )
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didReactToMessage message: BaseMessage, withEmoji key: String, selected: Bool) {
        self.baseViewModel?.setReaction(
            message: message,
            emojiKey: key,
            didSelect: selected
        )
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapRetryFailedMessage failedMessage: BaseMessage) {
        self.baseViewModel?.resendMessage(failedMessage: failedMessage)
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapDeleteFailedMessage failedMessage: BaseMessage) {
        self.baseViewModel?.deleteResendableMessage(failedMessage, needReload: true)
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapUserProfile user: SBUUser) {
        self.showUserProfile(user: user)
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didScroll scrollView: UIScrollView) {
        
    }
    
    open func baseChannelModuleDidTapScrollToButton(_ listComponent: SBUBaseChannelModule.List, animated: Bool) {
        let options = SBUScrollOptions(
            position: .bottom,
            isInverted: listComponent.tableView.isInverted
        )
        self.baseChannelModule(
            listComponent,
            didSelectScrollToBottonWithOptions: options,
            animated: true
        )
    }

    open func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didSelectScrollToBottonWithOptions options: SBUScrollOptions,
        animated: Bool
    ) {
        guard self.baseViewModel?.fullMessageList.isEmpty == false else { return }
        self.lastSeenIndexPath = nil
        
        DispatchQueue.main.async { [weak self, listComponent, animated] in
            guard let self = self else { return }
            
            if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView,
               messageInputView.mode != .quoteReply {
                self.setMessageInputViewMode(.none)
            }
            
            if self.baseViewModel?.hasNext() == true {
                listComponent.tableView.setContentOffset(listComponent.tableView.contentOffset, animated: false)
                self.baseViewModel?.reloadMessageList()
                self.baseListComponent?.scrollTableView(to: 0)
                return
            }
            
            var indexPath = IndexPath(row: 0, section: 0)
            
            if self.isTransformedList == false,
               let fullMessageCount = self.baseViewModel?.fullMessageList.count {
                indexPath = IndexPath(item: fullMessageCount - 1, section: 0)
                
                self.baseViewModel?.reloadMessageList()
            }
            
            self.baseListComponent?.scrollTableView(
                to: options.row(with: indexPath),
                at: options.at(),
                animated: animated
            )
            self.updateNewMessageInfo(hidden: true)
            self.baseListComponent?.setScrollBottomView(hidden: true)
        }
    }
    
    open func baseChannelModuleDidSelectRetry(_ listComponent: SBUBaseChannelModule.List) {
        if let channelURL = self.baseViewModel?.channelURL {
            self.baseViewModel?.loadChannel(channelURL: channelURL)
        }
    }
    
    // MARK: SBUBaseChannelModuleListDataSource
    open func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        channelForTableView tableView: UITableView
    ) -> BaseChannel? {
        self.baseViewModel?.channel
    }
    
    open func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        sentMessagesInTableView tableView: UITableView
    ) -> [BaseMessage] {
        self.baseViewModel?.messageList ?? []
    }
    
    open func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        fullMessagesInTableView tableView: UITableView
    ) -> [BaseMessage] {
        self.baseViewModel?.fullMessageList ?? []
    }
    
    open func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        hasNextInTableView tableView: UITableView
    ) -> Bool {
        self.baseViewModel?.hasNext() ?? false
    }
    
    open func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        lastSeenIndexPathIn tableView: UITableView
    ) -> IndexPath? {
        return self.lastSeenIndexPath
    }
    
    open func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        startingPointIn tableView: UITableView
    ) -> Int64? {
        return self.baseViewModel?.getStartingPoint()
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, parentViewControllerDisplayMenuItems menuItems: [SBUMenuItem]) -> UIViewController? {
        return self
    }
    
    open func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, pendingMessageManagerForCell cell: UITableViewCell) -> (SBUPendingMessageManager?, Bool?) {
        return (self.baseViewModel?.pendingMessageManager, self.baseViewModel?.isThreadMessageMode)
    }
    
    // MARK: - SBUBaseChannelModuleInputDelegate
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                didUpdateFrozenState isFrozen: Bool) { }
    
    open func baseChannelModuleDidStartTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        guard self.baseViewModel?.channel is GroupChannel else { return }
    }
    
    open func baseChannelModuleDidEndTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        guard self.baseViewModel?.channel is GroupChannel else { return }
    }
    
    open func baseChannelModuleDidTapAdd(_ inputComponent: SBUBaseChannelModule.Input) {
        self.willPresentSubview()
    }
    
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                didTapSend text: String,
                                parentMessage: BaseMessage?) {
        self.baseViewModel?.sendUserMessage(text: text, parentMessage: parentMessage)
    }
    
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                didTapResource type: MediaResourceType) {
        switch type {
        case .document: self.showDocumentPicker()
        case .library:
            switch SBUPermissionManager.shared.currentPhotoAccessStatus {
            case .all:
                self.showPhotoLibraryPicker()
            case .limited:
                self.showLimitedPhotoLibraryPicker()
            default:
                self.showPermissionAlert()
            }
        case .camera:
            switch SBUPermissionManager.shared.currentCameraAccessStatus {
            case .authorized:
                self.showCamera()
            default:
                self.showPermissionAlert(forType: .camera)
            }
        default:
            self.showPhotoLibraryPicker()
        }
    }
    
    /// Presents `UIDocumentPickerViewController`.
    /// - Since: 2.2.3
    open func showDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(
            documentTypes: ["public.content"],
            in: UIDocumentPickerMode.import
        )
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    open func showLimitedPhotoLibraryPicker() {
        let inputConfig: SBUConfig.BaseInput
        switch self.baseViewModel?.channel?.channelType {
        case .group:
            inputConfig = SendbirdUI.config.groupChannel.channel.input
        case .open:
            inputConfig = SendbirdUI.config.openChannel.channel.input
        default:
            return
        }
        let gallery = inputConfig.gallery
        
        var mediaType: PHAssetMediaType? // nil is all type support
        
        if gallery.isPhotoEnabled && gallery.isVideoEnabled { mediaType = nil } else if gallery.isPhotoEnabled { mediaType = .image } else if gallery.isVideoEnabled { mediaType = .video }
        
        let selectablePhotoVC = SBUSelectablePhotoViewController(mediaType: mediaType)
        selectablePhotoVC.delegate = self
        let nav = UINavigationController(rootViewController: selectablePhotoVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    /// Presents `UIImagePickerController`. If `SBUGlobals.UsingPHPicker`is `true`, it presents `PHPickerViewController` in iOS 14 or later.
    /// - NOTE: If you want to use customized `PHPickerConfiguration`, please override this method.
    /// - Since: 2.2.3
    open func showPhotoLibraryPicker() {
        let inputConfig: SBUConfig.BaseInput
        switch self.baseViewModel?.channel?.channelType {
        case .group:
            inputConfig = SendbirdUI.config.groupChannel.channel.input
        case .open:
            inputConfig = SendbirdUI.config.openChannel.channel.input
        default:
            return
        }
        
        if #available(iOS 14, *), SBUGlobals.isPHPickerEnabled {
            var pickerFilter: [PHPickerFilter] = []
            if inputConfig.gallery.isPhotoEnabled { pickerFilter += [.images] }
            if inputConfig.gallery.isVideoEnabled { pickerFilter += [.videos] }
            
            var configuration = PHPickerConfiguration()
            configuration.filter = .any(of: pickerFilter)
            
            // Multiple files message is allowed only for group channel.
            if !(self is SBUMessageThreadViewController),
             let _ = self.baseViewModel?.channel as? GroupChannel,
               SendbirdUI.config.groupChannel.channel.isMultipleFilesMessageEnabled {
                configuration.selectionLimit = SBUAvailable.multipleFilesMessageFileCountLimit

                if #available(iOS 15, *) {
                    configuration.selection = .ordered
                }
            }
 
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
            return
        }
        
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        var mediaType: [String] = []
        
        if inputConfig.gallery.isPhotoEnabled { mediaType += [String(kUTTypeImage), String(kUTTypeGIF)] }
        if inputConfig.gallery.isVideoEnabled { mediaType += [String(kUTTypeMovie)] }
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.mediaTypes = mediaType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    /// Presents `UIImagePickerController` for using camera.
    /// - Since: 2.2.3
    open func showCamera() {
        let sourceType: UIImagePickerController.SourceType = .camera
        var mediaType: [String] = []
        
        let inputConfig: SBUConfig.BaseInput
        switch self.baseViewModel?.channel?.channelType {
        case .group:
            inputConfig = SendbirdUI.config.groupChannel.channel.input
        case .open:
            inputConfig = SendbirdUI.config.openChannel.channel.input
        default:
            return
        }
        
        if inputConfig.camera.isPhotoEnabled {
            mediaType += [String(kUTTypeImage), String(kUTTypeGIF)]
        }
        
        if inputConfig.camera.isVideoEnabled {
            mediaType += [String(kUTTypeMovie)]
        }
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.mediaTypes = mediaType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // Shows permission request alert.
    /// - Since: 3.0.0
    open func showPermissionAlert(forType permissionType: SBUPermissionManager.PermissionType = .photoLibrary) {
        self.willPresentSubview()
        
        SBUPermissionManager.shared.showPermissionAlert(
            forType: permissionType,
            alertViewDelegate: self
        )
    }
    
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                didTapEdit text: String) {
        guard let message = self.baseViewModel?.inEditingMessage else { return }
        
        self.baseViewModel?.updateUserMessage(message: message, text: text)
    }
    
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                didChangeText text: String) {
        
    }
    
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                willChangeMode mode: SBUMessageInputMode, message: BaseMessage?) {
        
    }
    
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                didChangeMode mode: SBUMessageInputMode, message: BaseMessage?) {
        baseViewModel?.inEditingMessage = message as? UserMessage
    }
    
    open func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input,
                                  channelForInputView messageInputView: UIView?) -> BaseChannel? {
        baseViewModel?.channel
    }
    
    // MARK: - Input Keyboard events
    /// This function calls ``updateLayoutsWithKeyboard(isHidden:notification:)`` that changes the ``baseInputComponent`` bottom constraint using keyboard height.
    /// - Parameter notification: Notification object with keyboardFrame information
    /// - Important: When override this method, please refer to ``updateLayoutsWithKeyboard(isHidden:notification:)`` to update ``baseInputComponent`` bottom constraint with keyboard height.
    /// - Since: 1.2.5
    open func keyboardWillShow(_ notification: Notification) {
        self.updateLayoutsWithKeyboard(isHidden: false, notification: notification)
        
    }
    
    /// This function calls ``updateLayoutsWithKeyboard(isHidden:notification:)`` changes the ``baseInputComponent`` bottom constraint using keyboard height.
    /// - Parameter notification: Notification object with keyboardFrame information
    /// - Important: When override this method, please refer to ``updateLayoutsWithKeyboard(isHidden:notification:)`` to update ``baseInputComponent`` bottom constraint with keyboard height.
    /// - Since: 1.2.5
    open func keyboardWillHide(_ notification: Notification) {
        self.updateLayoutsWithKeyboard(isHidden: true, notification: notification)
    }
    
    // MARK: - SBUBaseChannelViewModelDataSource
    open func baseChannelViewModel(_ viewModel: SBUBaseChannelViewModel,
                                   isScrollNearBottomInChannel channel: BaseChannel?) -> Bool {
        return self.baseListComponent?.isScrollNearByBottom ?? true
    }
    
    // MARK: - UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        return true
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    open func presentationController(forPresented presented: UIViewController,
                                     presenting: UIViewController?,
                                     source: UIViewController) -> UIPresentationController? {
        return SBUBottomSheetController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    // MARK: - UIImagePickerControllerDelegate
    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                guard info[.mediaType] != nil else { return }
                let mediaType = info[.mediaType] as! CFString
                
                switch mediaType {
                case kUTTypeImage:
                    if let inputComponent = self.baseInputComponent {
                        inputComponent.pickImageFile(info: info)
                        return
                    }
                case kUTTypeMovie:
                    if let inputComponent = self.baseInputComponent {
                        inputComponent.pickVideoFile(info: info)
                        return
                    }
                default:
                    break
                }
            }
        }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - PHPickerViewControllerDelegate
    
    /// Override this method to handle the `results` from `PHPickerViewController`.
    /// As defaults, it doesn't support multi-selection and live photo.
    /// - Important: To use this method, please assign self as delegate to `PHPickerViewController` object.
    @available(iOS 14, *)
    open func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.forEach {
            let itemProvider = $0.itemProvider
            
            /// !! Warining !!
            /// Since the image identifier includes the gif identifier, the check of the gif type should take precedence over the image type comparison.
            
            // GIF
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                if let inputComponent = self.baseInputComponent {
                    inputComponent.pickGIFFile(itemProvider: itemProvider)
                    return
                }
            }
            
            // image
            else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                if let inputComponent = self.baseInputComponent {
                    inputComponent.pickImageFile(itemProvider: itemProvider)
                    return
                }
            }
            
            // video
            else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                if let inputComponent = self.baseInputComponent {
                    inputComponent.pickVideoFile(itemProvider: itemProvider)
                    return
                }
            }
        }
    }
    
    // MARK: - UIDocumentPickerDelegate
    open func documentPicker(_ controller: UIDocumentPickerViewController,
                             didPickDocumentsAt urls: [URL]) {
        if let inputComponent = self.baseInputComponent {
            inputComponent.pickDocumentFile(documentURLs: urls)
            return
        }
    }
    
    // MARK: - UIDocumentInteractionControllerDelegate
    open func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self// or use return self.navigationController for fetching app navigation bar colour
    }
    
    // MARK: - SBUSelectablePhotoViewDelegate
    /// Called when the image is picked from `SBUSelectablePhotoViewController`.
    /// - Parameter data: The image data.
    /// - Parameter fileName: The file name.
    open func didTapSendImageData(_ data: Data, fileName: String? = nil, mimeType: String? = nil) {
        if let inputComponent = self.baseInputComponent {
            inputComponent.pickImageData(data, fileName: fileName, mimeType: mimeType)
            return
        }
    }
    
    /// Called when the video is picked from `SBUSelectablePhotoViewController`
    /// - Parameter url: The URL of the video
    open func didTapSendVideoURL(_ url: URL) {
        if let inputComponent = self.baseInputComponent {
            inputComponent.pickVideoURL(url)
            return
        }
    }
    
    // MARK: - SBUFileViewControllerDelegate
    open func didSelectDeleteImage(message: FileMessage) {
        SBULog.info("[Request] Delete message: \(message.description)")
        
        self.baseViewModel?.deleteMessage(message: message)
    }
    
    // MARK: - SBUAlertViewDelegate
    open func didDismissAlertView() { }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        if self.baseViewModel?.fullMessageList.isEmpty == true, isBlocker {
            self.baseListComponent?.updateEmptyView(type: .error)
            self.baseListComponent?.tableView.reloadData()
        }
        
        self.errorHandler(error?.localizedDescription)
    }
    
    // MARK: - Deprecated, Unavailable
    
    /// This function creates message menu items with cell and message.
    /// - Parameters:
    ///   - cell: Sendbird's messageCell object
    ///   - message: `BaseMessage` object
    /// - Returns: message menu type array
    @available(*, unavailable, message: "Please use `SBUMenuItem` and  `createMessageMenuItems(for:)` in `SBUBaseChannelModule.List` instead.") // 3.1.2
    public func createMessageMenuTypes(_ cell: UITableViewCell,
                                       message: BaseMessage) -> [MessageMenuItem]? {
        return nil
    }
    
    // TODO: UItableViewCell -> SBUBaseMessageCell
    /// This function shows cell's menu.
    ///
    /// This is used when the reaction feature is activated.
    /// This function configures the menu items using the `message` object.
    ///
    /// - Parameters:
    ///   - cell: Message cell
    ///   - message: Message object
    /// - Since: 3.0.0
    @available(*, deprecated, message: "Please use `showMessageMenuSheet(for:cell:)` in `SBUBaseChannelModule.List` instead.") // 3.1.2
    public func showMenuViewController(_ cell: UITableViewCell, message: BaseMessage) {
        guard let listComponent = self.baseListComponent else { return }
        listComponent.showMessageMenuSheet(for: message, cell: cell)
    }
    
    // TODO: UItableViewCell -> SBUBaseMessageCell
    /// This function shows cell's menu. This is used when the reaction feature is activated.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - message: Message object
    ///   - types: Type array of menu items to use
    /// - Since: 1.2.5
    @available(*, unavailable, message: "Please use `showMessageMenuSheet(for:cell:)` and `createMessageMenuItems(for:)` in `SBUBaseChannelModule.List` instead.") // 3.1.2
    public func showMenuViewController(
        _ cell: UITableViewCell,
        message: BaseMessage,
        types: [MessageMenuItem]?
    ) {
        guard let listComponent = self.baseListComponent else { return }
        listComponent.showMessageMenuSheet(for: message, cell: cell)
    }
    
    // TODO: UItableViewCell -> SBUBaseMessageCell
    /// This function shows cell's menu.
    ///
    /// This is used when the reaction feature is inactivated.
    /// This function configures the menu items using the `message` object.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - indexPath: IndexPath
    ///   - message: Message object
    /// - Since: 3.0.0
    @available(*, deprecated, message: "Please use  `showMessageContextMenu(for:cell:forRowAt:)` in `SBUBaseChannelModule.List` instead.") // 3.1.2
    open func showMenuModal(
        _ cell: UITableViewCell,
        indexPath: IndexPath,
        message: BaseMessage
    ) {
        self.baseListComponent?.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath)
    }
    
    // TODO: UItableViewCell -> SBUBaseMessageCell
    /// This function shows cell's menu. This is used when the reaction feature is inactivated.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - indexPath: IndexPath
    ///   - message: Message object
    ///   - types: Type array of menu items to use
    /// - Since: 1.2.5
    @available(*, deprecated, message: "Please use  `showMessageContextMenu(for:cell:forRowAt:)` in `SBUBaseChannelModule.List` instead.") // 3.1.2
    public func showMenuModal(
        _ cell: UITableViewCell,
        indexPath: IndexPath,
        message: BaseMessage,
        types: [MessageMenuItem]?
    ) { self.baseListComponent?.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath) }
    
    /// This function shows cell's menu: retry, delete, cancel.
    ///
    /// This is used when selected failed message.
    /// - Parameter message: Message object
    /// - Since: 2.1.12
    @available(*, deprecated, message: "Please use `showFailedMessageMenu(on:)` in `SBUBaseChannelModule.List`") // 3.1.2
    public func showFailedMessageMenu(message: BaseMessage) {
        let retryItem = SBUActionSheetItem(
            title: SBUStringSet.Retry,
            color: self.theme.menuItemTintColor
        ) { [weak self] in
            self?.baseViewModel?.resendMessage(failedMessage: message)
            if let baseListComponent = self?.baseListComponent {
                self?.baseChannelModuleDidTapScrollToButton(baseListComponent, animated: true)
            }
        }
        let deleteItem = SBUActionSheetItem(
            title: SBUStringSet.Delete,
            color: self.theme.deleteItemColor
        ) { [weak self] in
            self?.baseViewModel?.deleteResendableMessage(message, needReload: true)
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
    
    /// This function shows delete message alert.
    /// - Parameters:
    ///   - message: message object to delete
    ///   - oneTimetheme: One-time theme
    /// - Since: 3.0.0
    @available(*, deprecated, message: "Please use `showDeleteMessageAlert(on:oneTimeTheme:)` in `SBUBaseChannelModule.List`") // 3.1.2
    public func showDeleteMessageMenu(message: BaseMessage,
                                      oneTimetheme: SBUComponentTheme? = nil) {
        self.baseListComponent?.showDeleteMessageAlert(on: message, oneTimeTheme: oneTimetheme)
    }
}
