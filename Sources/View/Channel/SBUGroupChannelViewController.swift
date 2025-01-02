//
//  SBUGroupChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Photos
import AVKit
import SafariServices
import PhotosUI
import MobileCoreServices
#if SWIFTUI
import SwiftUI
#endif

#if SWIFTUI
protocol GroupChannelViewEventDelegate: AnyObject {
    func groupChannelViewDidUpdateNewMessagesCount(_ count: Int)
    func groupChannelViewDidChangeMessageText(_ text: String)
}
#endif

@objcMembers
open class SBUGroupChannelViewController: SBUBaseChannelViewController, SBUGroupChannelViewModelDelegate, SBUGroupChannelModuleHeaderDelegate, SBUGroupChannelModuleListDelegate, SBUGroupChannelModuleListDataSource, SBUGroupChannelModuleInputDelegate, SBUGroupChannelModuleInputDataSource, SBUGroupChannelViewModelDataSource, SBUMentionManagerDataSource, SBUMessageThreadViewControllerDelegate, SBUVoiceMessageInputViewDelegate, SBUReactionsViewControllerDelegate {

    // MARK: - UI properties (Public)
    public var headerComponent: SBUGroupChannelModule.Header? {
        get { self.baseHeaderComponent as? SBUGroupChannelModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUGroupChannelModule.List? {
        get { self.baseListComponent as? SBUGroupChannelModule.List }
        set { self.baseListComponent = newValue }
    }
    public var inputComponent: SBUGroupChannelModule.Input? {
        get { self.baseInputComponent as? SBUGroupChannelModule.Input }
        set { self.baseInputComponent = newValue }
    }
    /// The input view that is used to record voice message
    public var voiceMessageInputView = SBUGroupChannelModule.Input.VoiceMessageInputView.init()
    
    public var highlightInfo: SBUHighlightMessageInfo?
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUGroupChannelViewModel? {
        get { self.baseViewModel as? SBUGroupChannelViewModel }
        set { self.baseViewModel = newValue }
    }
    
    public override var channel: GroupChannel? { self.viewModel?.channel as? GroupChannel }
    
    public private(set) var newMessagesCount: Int = 0 {
        didSet {
            #if SWIFTUI
            self.swiftUIDelegate?.groupChannelViewDidUpdateNewMessagesCount(self.newMessagesCount)
            #endif
        }
    }
    
    override var isChatInputDisabled: Bool {
        didSet {
            (self.baseInputComponent?.messageInputView as? SBUMessageInputView)?.setDisableChatInputState(isChatInputDisabled)
        }
    }
    
    // MARK: - SwiftUI
    #if SWIFTUI
    var channelSettingsViewBuilder: GroupChannelSettingsViewBuilder?
    var messageThreadViewBuilder: MessageThreadViewBuilder?
    
    weak var swiftUIDelegate: (SBUGroupChannelViewModelDelegate & GroupChannelViewEventDelegate)? {
        didSet {
            self.viewModel?.baseDelegates.addDelegate(self.swiftUIDelegate, type: .swiftui)
        }
    }
    #endif
    
    /// An error handler that is called when any one of the files size in multiple files message exceeds the file size limit.
    /// If needed, override this handler to show your custom alert view.
    /// - Since: 3.10.0
    open func multipleFilesMessageFileSizeErrorHandler(_ message: String) {
        SBULog.error("Did receive error: \(message)")
        
        DispatchQueue.main.async {
            SBUAlertView.show(
                title: message,
                confirmButtonItem: SBUAlertButtonItem(
                    title: SBUStringSet.OK,
                    completionHandler: { _ in
                    }
                ), cancelButtonItem: nil
            )
        }
    }
    
    // MARK: - Logic properties (Private)
    
    // MARK: - Lifecycle
    
    /// If you have channel object, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
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
    /// - Parameter channel: Channel object
    /// - Since: 1.0.11
    required public init(channel: GroupChannel, messageListParams: MessageListParams? = nil) {
        super.init(baseChannel: channel, messageListParams: messageListParams)
        
        self.headerComponent = SBUModuleSet.GroupChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelModule.ListComponent.init()
        self.inputComponent = SBUModuleSet.GroupChannelModule.InputComponent.init()
    }
    
    public init(channel: GroupChannel, messageListParams: MessageListParams? = nil, displaysLocalCachedListFirst: Bool) {
        super.init(baseChannel: channel, messageListParams: messageListParams, displaysLocalCachedListFirst: displaysLocalCachedListFirst)
        
        self.headerComponent = SBUModuleSet.GroupChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelModule.ListComponent.init()
        self.inputComponent = SBUModuleSet.GroupChannelModule.InputComponent.init()
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
        
        self.headerComponent = SBUModuleSet.GroupChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelModule.ListComponent.init()
        self.inputComponent = SBUModuleSet.GroupChannelModule.InputComponent.init()
    }
    
    required public override init(
        channelURL: String,
        startingPoint: Int64? = nil,
        messageListParams: MessageListParams? = nil,
        displaysLocalCachedListFirst: Bool
    ) {
        super.init(
            channelURL: channelURL,
            startingPoint: startingPoint,
            messageListParams: messageListParams,
            displaysLocalCachedListFirst: displaysLocalCachedListFirst
        )
        
        self.headerComponent = SBUModuleSet.GroupChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelModule.ListComponent.init()
        self.inputComponent = SBUModuleSet.GroupChannelModule.InputComponent.init()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        theme.statusBarStyle
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.listComponent?.pauseAllVoicePlayer()
    }
    
    open override func applicationWillResignActivity() {
        self.resetVoiceMessageInput(for: true)
        self.listComponent?.pauseAllVoicePlayer()
    }
    
    open override func willPresentSubview() {
        // TODO: Voice Message - Unify policy
        self.listComponent?.pauseAllVoicePlayer()
    }
    
    deinit {
        SBULog.info("")
        
        // Clear typing message when exiting the channel.
        self.viewModel?.clearTypingMessage()
    }
    
    // MARK: - ViewModel
    open override func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        showIndicator: Bool = true
    ) {
        self.createViewModel(
            channel: channel,
            channelURL: channelURL,
            messageListParams: messageListParams,
            startingPoint: startingPoint,
            showIndicator: showIndicator,
            displaysLocalCachedListFirst: false
        )
    }

    open override func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        showIndicator: Bool = true,
        displaysLocalCachedListFirst: Bool = false
    ) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        self.baseViewModel = SBUViewModelSet.GroupChannelViewModel.init(
            channel: channel,
            channelURL: channelURL,
            messageListParams: messageListParams,
            startingPoint: startingPoint,
            delegate: self,
            dataSource: self,
            displaysLocalCachedListFirst: displaysLocalCachedListFirst
        )
        
        if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
            messageInputView.setMode(.none)
        }
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        super.setupViews()
        
        self.headerComponent?
            .configure(delegate: self, theme: self.theme)
        self.listComponent?
            .configure(delegate: self, dataSource: self, theme: self.theme)
        self.inputComponent?
            .configure(delegate: self, dataSource: self, mentionManagerDataSource: self, theme: self.theme)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()

        if let listComponent = listComponent {
            listComponent.translatesAutoresizingMaskIntoConstraints = false
            
            tableViewTopConstraint?.isActive = false
            tableViewBottomConstraint?.isActive = false
            tableViewLeftConstraint?.isActive = false
            tableViewRightConstraint?.isActive = false
            
            self.tableViewTopConstraint = listComponent.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                constant: 0
            )
            self.tableViewBottomConstraint = listComponent.bottomAnchor.constraint(
                equalTo: self.inputComponent?.topAnchor ?? self.view.bottomAnchor,
                constant: 0
            )
            self.tableViewLeftConstraint = listComponent.leftAnchor.constraint(
                equalTo: self.view.leftAnchor, constant: 0
            )
            self.tableViewRightConstraint = listComponent.rightAnchor.constraint(
                equalTo: self.view.rightAnchor, constant: 0
            )
            
            tableViewTopConstraint?.isActive = true
            tableViewBottomConstraint?.isActive = true
            tableViewLeftConstraint?.isActive = true
            tableViewRightConstraint?.isActive = true
        }
        
        if let inputComponent = self.inputComponent {
            inputComponent.translatesAutoresizingMaskIntoConstraints = false
            
            messageInputViewTopConstraint?.isActive = false
            messageInputViewBottomConstraint?.isActive = false
            messageInputViewLeftConstraint?.isActive = false
            messageInputViewRightConstraint?.isActive = false
            
            self.messageInputViewTopConstraint = inputComponent.topAnchor.constraint(
                equalTo: self.listComponent?.bottomAnchor ?? self.view.bottomAnchor,
                constant: 0
            )
            self.messageInputViewBottomConstraint = inputComponent.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor,
                constant: 0
            )
            self.messageInputViewLeftConstraint = inputComponent.leftAnchor.constraint(
                equalTo: self.view.leftAnchor,
                constant: 0
            )
            self.messageInputViewRightConstraint = inputComponent.rightAnchor.constraint(
                equalTo: self.view.rightAnchor,
                constant: 0
            )
            
            messageInputViewTopConstraint?.isActive = true
            messageInputViewBottomConstraint?.isActive = true
            messageInputViewLeftConstraint?.isActive = true
            messageInputViewRightConstraint?.isActive = true
        }
    }
    
    open override func setupStyles() {
        super.setupStyles()
    }
    
    open override func updateStyles(needsToLayout: Bool) {
        self.setupStyles()
        super.updateStyles()
        
        self.headerComponent?.updateStyles(theme: self.theme)
        self.listComponent?.updateStyles(theme: self.theme)
        
        self.listComponent?.reloadTableView(needsToLayout: needsToLayout)
    }
    
    open override func updateStyles() {
        self.updateStyles(needsToLayout: true)
    }

    // MARK: - New message count

    /// This function increases the new message count.
    @discardableResult
    public override func increaseNewMessageCount() -> Bool {
        guard let viewModel = viewModel else { return false }
        guard !baseChannelViewModel(viewModel, isScrollNearBottomInChannel: viewModel.channel) else { return false }
        
        guard super.increaseNewMessageCount() else { return false }
        
        self.updateNewMessageInfo(hidden: false)
        self.newMessagesCount += 1
        
        if let newMessageInfoView = self.listComponent?.newMessageInfoView as? SBUNewMessageInfo {
            newMessageInfoView.updateCount(count: self.newMessagesCount) { [weak self] in
                guard let self = self else { return }
                guard let listComponent = self.listComponent else { return }
                
                let position = SBUGlobals.scrollPostionConfiguration.groupChannel.scrollToNewMessage
                let options = SBUScrollOptions(
                    count: self.newMessagesCount,
                    position: position,
                    isInverted: listComponent.tableView.isInverted
                )
                
                self.baseChannelModule(
                    listComponent,
                    didSelectScrollToBottonWithOptions: options,
                    animated: true
                )
            }
        }
        return true
    }
    
    // MARK: - Message: Menu
    
    /// Calculates the `CGPoint` value that indicates where to draw the message menu in the group channel screen.
    /// - Parameters:
    ///   - indexPath: IndexPath
    ///   - position: Message position
    /// - Returns: `CGPoint` value
    /// - Since: 1.2.5
    @available(*, deprecated, message: "Please use `calculateMessageMenuCGPoint(indexPath:position:)` in `SBUGroupChannelModule.List`") // 3.1.2
    public func calculatorMenuPoint(
        indexPath: IndexPath,
        position: MessagePosition
    ) -> CGPoint {
        guard let listComponent = listComponent else {
            SBULog.error("listComponent is not set up.")
            return .zero
        }
        
        return listComponent.calculateMessageMenuCGPoint(indexPath: indexPath, position: position)
    }
    
    @available(*, deprecated, message: "Please use `showMessageContextMenu(message:cell:forRowAt:)` in `SBUGroupChannelModule.List`") // 3.1.2
    open override func showMenuModal(_ cell: UITableViewCell, indexPath: IndexPath, message: BaseMessage) {
        self.listComponent?.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath)
    }
    
    @available(*, deprecated, message: "Please use `showMessageContextMenu(message:cell:forRowAt:)` in `SBUGroupChannelModule.List`") // 3.1.2
    public override func showMenuModal(_ cell: UITableViewCell,
                                       indexPath: IndexPath,
                                       message: BaseMessage,
                                       types: [MessageMenuItem]?) {
        self.listComponent?.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath)
    }
    
    open override func showChannelSettings() {
        guard let channel = self.channel else { return }
        
        #if SWIFTUI
        if let channelSettingsViewBuilder = self.channelSettingsViewBuilder {
            let view = channelSettingsViewBuilder(channel.channelURL)
            let channelSettingsVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(channelSettingsVC, animated: true)
            return
        }
        #endif
        
        let channelSettingsVC = SBUViewControllerSet.GroupChannelSettingsViewController.init(channel: channel)
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
    open override func showMessageThread(
        channelURL: String,
        parentMessageId: Int64,
        parentMessageCreatedAt: Int64? = 0,
        startingPoint: Int64? = 0
    ) {
        if (parentMessageCreatedAt ?? 0) < (self.channel?.messageOffsetTimestamp ?? 0) {
            SBULog.warning(SBUStringSet.Message_Reply_Cannot_Found_Original)
            return
        }
        
        var parentMessage: BaseMessage?
        if let fullMessageList = self.viewModel?.fullMessageList {
            parentMessage = fullMessageList.first(where: { $0.messageId == parentMessageId })
        }
        
        #if SWIFTUI
        if let messageThreadViewBuilder = self.messageThreadViewBuilder {
            let view = messageThreadViewBuilder(
                channelURL,
                parentMessageId
            )
            let messageThreadVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(
                messageThreadVC,
                animated: true
            )
            return
        }
        #endif
        
        let messageThreadVC = SBUViewControllerSet.MessageThreadViewController.init(
            channelURL: channelURL,
            parentMessage: parentMessage,
            parentMessageId: parentMessageId,
            delegate: self,
            startingPoint: startingPoint,
            voiceFileInfos: self.listComponent?.voiceFileInfos
        )
        self.navigationController?.pushViewController(messageThreadVC, animated: true)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    
    open override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        super.imagePickerControllerDidCancel(picker)
        
        if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
            messageInputView.setMode(.none)
        }
    }
    
    @available(iOS 14, *)
    override open func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard results.count <= SBUAvailable.multipleFilesMessageFileCountLimit else {
            self.errorHandler("Up to \(SBUAvailable.multipleFilesMessageFileCountLimit) can be attached.")
            return
        }
        
        // Picked multiple files
        if results.count > 1 {
            checkAllFileSizes(results) { [weak self] isValid in
                if isValid {
                    self?.handleMultipleFiles(results)
                } else {
                    self?.multipleFilesMessageFileSizeErrorHandler(SBUStringSet.FileUpload.Error.exceededSizeLimit)
                }
            }
            return
        }
        
        // Picked a single file
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
    
    @available(iOS 14, *)
    private func handleMultipleFiles(_ results: [PHPickerResult]) {
        guard let inputComponent = self.baseInputComponent as? SBUGroupChannelModule.Input else {
            return
        }
        
        // Group picked files depending on file type.
        let (imageAndGIFs, videos) = self.groupFilesByMimeType(results)
        
        // Handle images+GIFs.
        if imageAndGIFs.count > 0 {
            
            // multiple (image + gif) -> send a multipleFilesMessage
            if imageAndGIFs.count > 1 {
                inputComponent.pickMultipleImageFiles(itemProviders: imageAndGIFs)
            }
            
            // single image / gif -> send a fileMessage
            else if imageAndGIFs.count == 1 {
                let itemProvider = imageAndGIFs.first!
                
                // GIF
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                    if let inputComponent = self.baseInputComponent {
                        inputComponent.pickGIFFile(itemProvider: itemProvider)
                    }
                }
                
                // image
                else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    if let inputComponent = self.baseInputComponent {
                        inputComponent.pickImageFile(itemProvider: itemProvider)
                    }
                }
            }
        }
        
        // Handle videos.
        if videos.count > 0 {
            // video(s) selected -> send N fileMessages
            videos.forEach { itemProvider in
                inputComponent.pickVideoFile(itemProvider: itemProvider)
            }
        }
    }
    
    // MARK: PHPicker Util Methods.
    /// Presents `UIImagePickerController`. If `SBUGlobals.UsingPHPicker`is `true`, it presents `PHPickerViewController` in iOS 14 or later.
    /// - NOTE: If you want to use customized `PHPickerConfiguration`, please override this method.
    /// - Since: 3.10.0
    open override func showPhotoLibraryPicker() {
        let inputConfig = SendbirdUI.config.groupChannel.channel.input
        
        if #available(iOS 14, *), SBUGlobals.isPHPickerEnabled {
            var pickerFilter: [PHPickerFilter] = []
            if inputConfig.gallery.isPhotoEnabled { pickerFilter += [.images] }
            if inputConfig.gallery.isVideoEnabled { pickerFilter += [.videos] }
            
            var configuration = PHPickerConfiguration()
            configuration.filter = .any(of: pickerFilter)
            
            if let groupChannel = self.viewModel?.channel as? GroupChannel,
               !groupChannel.isSuper && !groupChannel.isBroadcast,
               inputComponent?.currentQuotedMessage == nil,
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

    @available(iOS 14, *)
    private func checkAllFileSizes(_ results: [PHPickerResult], completion: @escaping (Bool) -> Void) {
        var areAllFileSizesValid = true
        
        let group = DispatchGroup()
        for result in results {
            if !areAllFileSizesValid {
                group.leave()
                completion(false)
                return
            }
            
            group.enter()
            
            let itemProvider = result.itemProvider
            
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                self.checkGifSize(itemProvider: itemProvider) { isValid in
                    if !isValid { areAllFileSizesValid = false }
                    group.leave()
                }
                
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                self.checkImageSize(itemProvider: itemProvider) { isValid in
                    if !isValid { areAllFileSizesValid = false }
                    group.leave()
                }
                
            } else {
                self.checkVideoSize(itemProvider: itemProvider) { isValid in
                    if !isValid { areAllFileSizesValid = false }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(areAllFileSizesValid)
        }
    }
    
    @available(iOS 14, *)
    private func checkImageSize(itemProvider: NSItemProvider, completion: @escaping (Bool) -> Void) {
        itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: [:]) { (item, _) in
            if let url = item as? URL {
                completion(url.isFileSizeUploadable)
            } else {
                completion(false)
            }
        }
    }
    
    @available(iOS 14, *)
    private func checkGifSize(itemProvider: NSItemProvider, completion: @escaping (Bool) -> Void) {
        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.gif.identifier) { item, _ in
            if let gifURL = item {
                completion(gifURL.isFileSizeUploadable)
            } else {
                completion(false)
            }
        }
    }

    @available(iOS 14, *)
    private func checkVideoSize(itemProvider: NSItemProvider, completion: @escaping (Bool) -> Void) {
        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { item, error in
            if let videoURL = item {
                completion(videoURL.isFileSizeUploadable)
            } else {
                if let error = error {
                    SBULog.error("Failed to read video file. \(error)")
                }
                completion(false)
            }
        }
    }
    
    /// Groups picked files by file type.
    /// - Returns a tuple - (an array of images + GIFs, an array of videos)
    @available(iOS 14, *)
    private func groupFilesByMimeType(_ results: [PHPickerResult]) -> ([NSItemProvider], [NSItemProvider]) {
        var imageAndGIFs = [NSItemProvider]()
        var videos = [NSItemProvider]()
        
        results.forEach {
            let itemProvider = $0.itemProvider
                
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) ||
                itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                imageAndGIFs.append(itemProvider)
            }
            
            // Group videos
            else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                videos.append(itemProvider)
            }
        }
        
        return (imageAndGIFs, videos)
    }
    
    // MARK: - VoiceMessageInput
    open override func showVoiceMessageInput() {
        super.showVoiceMessageInput()
        
        let canvasView = self.navigationController?.view ?? self.view
        
        self.voiceMessageInputView.show(delegate: self, canvasView: canvasView)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    open override func dismissVoiceMessageInput() {
        super.dismissVoiceMessageInput()
        
        self.voiceMessageInputView.dismiss()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func updateVoiceMessageInputMode() {
        let showAlertCompletionHandler: ((String) -> Void) = { title in
            self.resetVoiceMessageInput()
            
            SBUAlertView.show(
                title: title,
                confirmButtonItem: SBUAlertButtonItem(
                    title: SBUStringSet.OK,
                    completionHandler: { _ in
                        self.dismissVoiceMessageInput()
                    }
                ), cancelButtonItem: nil
            ) {
                self.dismissVoiceMessageInput()
            }
        }
        
        var title = ""
        
        // Frozen
        let isOperator = self.channel?.myRole == .operator
        let isBroadcast = self.channel?.isBroadcast ?? false
        let isFrozen = self.channel?.isFrozen ?? false
        if !isBroadcast, !isOperator && isFrozen, self.voiceMessageInputView.isShowing {
            title = SBUStringSet.VoiceMessage.Alert.frozen
        }
        
        let isMuted = self.channel?.myMutedState == .muted
        if (!isFrozen || (isFrozen && isOperator)), isMuted, self.voiceMessageInputView.isShowing {
            title = SBUStringSet.VoiceMessage.Alert.muted
        }

        if title.count > 0 {
            showAlertCompletionHandler(title)
        }
    }
    
    open override func resetVoiceMessageInput(for resignActivity: Bool = false) {
        super.resetVoiceMessageInput(for: resignActivity)
        
        self.voiceMessageInputView.reset(for: resignActivity)
    }
    
    // MARK: - SBUGroupChannelViewModelDelegate
    open override func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    ) {
        guard channel != nil else {
            // channel deleted
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
        case .eventReadStatusUpdated, .eventDeliveryStatusUpdated:
            if context.source == .eventReadStatusUpdated {
                self.updateChannelStatus()
            }
            self.listComponent?.reloadTableView()
            
        case .eventTypingStatusUpdated:
            self.updateChannelStatus()
            self.listComponent?.reloadTableView()
            
        case .channelChangelog:
            self.updateChannelTitle()
            self.inputComponent?.updateMessageInputModeState()
            self.listComponent?.reloadTableView()
            self.updateVoiceMessageInputMode()
            
        case .eventChannelChanged:
            self.updateChannelTitle()
            self.inputComponent?.updateMessageInputModeState()
            self.updateVoiceMessageInputMode()
            
        case .eventChannelFrozen, .eventChannelUnfrozen,
                .eventUserMuted, .eventUserUnmuted,
                .eventOperatorUpdated,
                .eventUserBanned: // Other User Banned
            self.inputComponent?.updateMessageInputModeState()
            self.updateVoiceMessageInputMode()
            
        default: break
        }
    }
    
    open override func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        deletedMessages messages: [BaseMessage]
    ) {
        for message in messages {
            self.listComponent?.pauseVoicePlayer(cacheKey: message.cacheKey)
        }
    }
    
    open func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        didReceiveSuggestedMentions members: [SBUUser]?) {
        let members = members ?? []
        self.inputComponent?.handlePendingMentionSuggestion(with: members)
    }
    
    public func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        didFinishUploadingFileAt index: Int,
        multipleFilesMessageRequestId requestId: String
    ) {
        self.baseListComponent?.reloadMultipleFilesMessageCollectionViewCell(
            requestId: requestId,
            index: index
        )
    }
    
    open func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        didReceiveStreamMessage message: BaseMessage,
        forChannel channel: GroupChannel
    ) {
        self.listComponent?.updateStreamMessage(message)
    }
    
    // MARK: - SBUGroupChannelModuleHeaderDelegate
    open override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        super.baseChannelModule(headerComponent, didTapRightItem: rightItem)
        
        self.showChannelSettings()
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
    
    // MARK: - SBUGroupChannelModuleListDelegate
    open func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        didSelectFileAt index: Int,
        multipleFilesMessageCell: SBUMultipleFilesMessageCell,
        forRowAt cellIndexPath: IndexPath
    ) {
        guard let multipleFilesMessage = multipleFilesMessageCell.multipleFilesMessage else {
            SBUToastView.show(type: .file(.openFailed))
            return
        }
        guard index < multipleFilesMessage.files.count else { return }
        let fileInfo = multipleFilesMessage.files[index]
        
        // show file view controller
        let fileType: SBUMessageFileType
        if let mimeType = fileInfo.mimeType {
            fileType = SBUUtils.getFileType(by: mimeType)
        } else {
            fileType = .etc
        }
        let file = SBUFileData(
            urlString: fileInfo.url,
            message: multipleFilesMessage,
            cacheKey: multipleFilesMessage.cacheKey + "_\(index)",
            fileType: fileType,
            name: fileInfo.fileName ?? ""
        )
        self.openFile(file)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell) {
        guard let currentUser = SBUGlobals.currentUser,
              let message = messageCell.message else { return }
        
        let shouldSelect = message.reactions.first { $0.key == emojiKey }?
            .userIds.contains(currentUser.userId) == false
        self.viewModel?.setReaction(message: message, emojiKey: emojiKey, didSelect: shouldSelect)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didLongTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell) {
        guard let channel = self.channel,
              let message = messageCell.message else { return }
        
        let reaction = message.reactions.first { $0.key == emojiKey }
        let reactionsVC = SBUCommonViewControllerSet.ReactionsViewController.init(
            channel: channel,
            message: message,
            selectedReaction: reaction
        )
        reactionsVC.delegate = self
        reactionsVC.modalPresentationStyle = UIModalPresentationStyle.custom
        reactionsVC.transitioningDelegate = self
        self.present(reactionsVC, animated: true)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapMoreEmojiForCell messageCell: SBUBaseMessageCell) {
        self.dismissKeyboard()
        
        guard let message = messageCell.message else { return }
        self.showEmojiListModal(message: message)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapQuotedMessageView quotedMessageView: SBUQuotedBaseMessageView) {
        if SendbirdUI.config.groupChannel.channel.replyType == .thread &&  SendbirdUI.config.groupChannel.channel.threadReplySelectType == .thread {
            if let channelURL = self.baseViewModel?.channelURL {
                self.showMessageThread(
                    channelURL: channelURL,
                    parentMessageId: quotedMessageView.messageId,
                    parentMessageCreatedAt: quotedMessageView.params?.quotedMessageCreatedAt,
                    startingPoint: quotedMessageView.params?.messageCreatedAt
                )
            }
            return
        }
        
        if (quotedMessageView.params?.quotedMessageCreatedAt ?? 0) < (self.channel?.messageOffsetTimestamp ?? 0) {
            SBULog.warning(SBUStringSet.Message_Reply_Cannot_Found_Original)
            return
        }
        
        guard let row = self.baseViewModel?.fullMessageList.firstIndex(
            where: { $0.messageId == quotedMessageView.messageId }
        ) else {
            SBULog.info("There is no cached linked message. Reloads messages based on linked messages.")
            self.viewModel?.loadInitialMessages(
                startingPoint: quotedMessageView.params?.quotedMessageCreatedAt,
                showIndicator: true,
                initialMessages: nil
            )
            return
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        
        self.listComponent?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        guard let cell = self.listComponent?.tableView.cellForRow(at: indexPath) as? SBUBaseMessageCell else {
            SBULog.error("The cell for row at \(indexPath) is not `SBUBaseMessageCell`")
            return
        }
        cell.messageContentView.animate(.shakeUpDown)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapMentionUser user: SBUUser) {
        self.showUserProfile(user: user)
    }
    
    open func groupChannelModuleDidTapThreadInfoView(_ threadInfoView: SBUThreadInfoView) {
        guard let message = threadInfoView.message,
              let channelURL = self.channel?.channelURL else { return }
        
        // If it is the parent message itself, use `messageId` rather than `parentMessageId`.
        self.showMessageThread(
            channelURL: channelURL,
            parentMessageId: message.messageId,
            parentMessageCreatedAt: message.createdAt
        )
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSelect suggestedReplyOptionView: SBUSuggestedReplyOptionView) {
        guard let text = suggestedReplyOptionView.text else { return }
        
        let messageParams = UserMessageCreateParams(message: text)
        SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)
        self.viewModel?.sendUserMessage(messageParams: messageParams)
    }

    @available(*, deprecated, message: "This method is deprecated in 3.27.0.")
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSubmit form: SendbirdChatSDK.Form, messageCell: SBUBaseMessageCell) {
        guard let message = messageCell.message else { return }
        
        self.viewModel?.submitForm(message: message, form: form)
    }
   
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSubmitMessageForm form: SendbirdChatSDK.MessageForm, messageCell: SBUBaseMessageCell) {
        guard let message = messageCell.message else { return }
        
        self.viewModel?.submitMessageForm(message: message)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didUpdate feedbackAnswer: SBUFeedbackAnswer, messageCell: SBUBaseMessageCell) {
        
        guard let message = messageCell.message else { return }

        switch feedbackAnswer.action {
        case .rating:
            self.viewModel?.submitFeedback(
                message: message,
                answer: feedbackAnswer
            ) { [weak self, weak message, weak messageCell] _ in
                self?.listComponent?.reloadCell(messageCell)
                
                SBUFeedbackAnswer.showCommentPopup(
                    answer: feedbackAnswer
                ) { [weak self, weak message] answer in
                    guard let message = message else { return }
                    self?.viewModel?.updateFeedback(message: message, answer: answer) { _ in
                        self?.listComponent?.reloadTableView()
                    }
                }
            }
            // end case .rating
            
        case .modify:
            SBUFeedbackAnswer.showModifications(
                theme: listComponent.theme,
                answer: feedbackAnswer,
                updateHandler: { [weak self, weak message] answer in
                    guard let message = message else { return }
                    self?.viewModel?.updateFeedback(message: message, answer: answer) { _ in
                        self?.listComponent?.reloadTableView()
                        SBUToastView.show(type: .feedback)
                    }
                },
                deleteHandler: { [weak self, weak message] _ in
                    guard let message = message else { return }
                    self?.viewModel?.deleteFeedback(message: message) {
                        self?.listComponent?.reloadTableView()
                    }
                }
            )
            // end case .modify
        }
        // end switch
    }
    
    open func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleTemplateAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        self.handleWebAction(action, message: message, forRowAt: indexPath)
    }
    
    open func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleTemplateCustomAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        self.handleCustomAction(action, message: message, forRowAt: indexPath)
    }
    
    open func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleTemplatePreDefinedAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        // do nothing.. (need to override this method)
    }
    
    open func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleUncachedTemplateKeys templateKeys: [String],
        messageCell: SBUBaseMessageCell
    ) {
        self.viewModel?.loadUncachedTemplate(
            keys: templateKeys
        ) { [weak self] _ in
            self?.baseListComponent?.reloadTableView()
        }
    }
    
    open func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleUncachedTemplateImages cacheData: [String: String],
        messageCell: SBUBaseMessageCell
    ) {
        self.viewModel?.loadUncachedTemplateImages(
            data: cacheData
        ) { [weak self] _ in
            self?.baseListComponent?.reloadCell(messageCell)
        }
    }
    
    open override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapVoiceMessage fileMessage: FileMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.baseChannelModule(listComponent, didTapVoiceMessage: fileMessage, cell: cell, forRowAt: indexPath)
        
        if let cell = cell as? SBUBaseMessageCell {
            self.listComponent?.updateVoiceMessage(cell, message: fileMessage, indexPath: indexPath)
        }
    }
    
    open override func baseChannelModuleDidTapScrollToButton(_ listComponent: SBUBaseChannelModule.List, animated: Bool) {
        guard self.baseViewModel?.fullMessageList.isEmpty == false else { return }
        self.newMessagesCount = 0
        
        super.baseChannelModuleDidTapScrollToButton(listComponent, animated: animated)
    }
    
    open override func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didSelectScrollToBottonWithOptions options: SBUScrollOptions,
        animated: Bool
    ) {
        guard self.baseViewModel?.fullMessageList.isEmpty == false else { return }
        self.newMessagesCount = 0
        
        super.baseChannelModule(
            listComponent,
            didSelectScrollToBottonWithOptions: options,
            animated: animated
        )
    }
    
    open override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didScroll scrollView: UIScrollView) {
        super.baseChannelModule(listComponent, didScroll: scrollView)
        
        self.lastSeenIndexPath = nil
        
        if listComponent.isScrollNearByBottom {
            self.newMessagesCount = 0
            self.updateNewMessageInfo(hidden: true)
        }
    }
    
    // MARK: - SBUGroupChannelModuleListDataSource
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, highlightInfoInTableView tableView: UITableView) -> SBUHighlightMessageInfo? {

        guard self.viewModel?.isInitialLoading == false else { return nil }
        
        return self.highlightInfo
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didHandleUncachedTemplateKeys templateKeys: [String]) -> Bool? {
        let cache = self.viewModel?.templateLoadCache ?? [:]
        var result = true
        for templateKey in templateKeys {
            switch cache[templateKey] {
            case .success: continue
            case .failure, .loading: result = false
            default: return nil
            }
        }
        return result
    }

    // MARK: - SBUGroupChannelModuleInputDelegate
    open override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didUpdateFrozenState isFrozen: Bool) {
        self.listComponent?.channelStateBanner?.isHidden = !isFrozen
    }
    
    open func groupChannelModule(_ inputComponent: SBUGroupChannelModule.Input, didPickFileData fileData: Data?, fileName: String, mimeType: String, parentMessage: BaseMessage?) {
        
        if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
            messageInputView.setMode(.none)
        }
        
        self.viewModel?.sendFileMessage(
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parentMessage: parentMessage
        )
    }
    
    open func groupChannelModule(_ inputComponent: SBUGroupChannelModule.Input, didPickMultipleFiles fileInfoList: [UploadableFileInfo]?, parentMessage: BaseMessage?) {
        if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
            messageInputView.setMode(.none)
        }
        
        self.viewModel?.sendMultipleFilesMessage(
            fileInfoList: fileInfoList!
        )
    }
    
    open func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didTapSend text: String,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String],
        parentMessage: BaseMessage?
    ) {
        self.viewModel?.sendUserMessage(
            text: text,
            mentionedMessageTemplate: mentionedMessageTemplate,
            mentionedUserIds: mentionedUserIds,
            parentMessage: parentMessage
        )
    }
    
    open func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didTapEdit text: String,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String]
    ) {
        guard let message = self.baseViewModel?.inEditingMessage else { return }
        self.viewModel?.updateUserMessage(
            message: message,
            text: text,
            mentionedMessageTemplate: mentionedMessageTemplate,
            mentionedUserIds: mentionedUserIds
        )
    }
    
    open func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        willChangeMode mode: SBUMessageInputMode,
        message: BaseMessage?,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String]
    ) { }
    
    open func groupChannelModule(_ inputComponent: SBUGroupChannelModule.Input, shouldLoadSuggestedMentions filterText: String) {
        self.viewModel?.loadSuggestedMentions(with: filterText)
    }
    
    open func groupChannelModuleShouldStopSuggestingMention(_ inputComponent: SBUGroupChannelModule.Input) {
        self.viewModel?.cancelLoadingSuggestedMentions()
    }
    
    open func groupChannelModuleDidTapVoiceMessage(_ inputComponent: SBUGroupChannelModule.Input) {
        SBUPermissionManager.shared.requestRecordAcess { [weak self] in
            guard let self = self else { return }
            self.showVoiceMessageInput()
        } onDenied: {
            SBULog.info("Record permission was denied")
            self.showPermissionAlert(forType: .record)
            return
        }
    }
    
    open override func baseChannelModuleDidStartTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        self.viewModel?.startTypingMessage()
    }
    
    open override func baseChannelModuleDidEndTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        self.viewModel?.endTypingMessage()
        self.inputComponent?.dismissSuggestedMentionList()
    }
    
    open override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didChangeText text: String) {
        super.baseChannelModule(inputComponent, didChangeText: text)
        
        #if SWIFTUI
        self.swiftUIDelegate?.groupChannelViewDidChangeMessageText(text)
        #endif
    }
    
    // MARK: - SBUGroupChannelViewModelDataSource
    open func groupChannelViewModel(_ viewModel: SBUGroupChannelViewModel,
                                    startingPointIndexPathsForChannel channel: GroupChannel?) -> [IndexPath]? {
        return self.listComponent?.tableView.indexPathsForVisibleRows
    }
    
    // MARK: - SBUMentionManagerDataSource
    open func mentionManager(_ manager: SBUMentionManager, suggestedMentionUsersWith filterText: String) -> [SBUUser] {
        return self.viewModel?.suggestedMemberList ?? []
    }
    
    // MARK: - SBUMessageThreadViewControllerDelegate
    open func messageThreadViewController(
        _ viewController: SBUMessageThreadViewController,
        shouldMoveToParentMessage parentMessage: BaseMessage
    ) {
        
        guard let row = self.baseViewModel?.fullMessageList.firstIndex(
            where: { $0.messageId == parentMessage.messageId }
        ) else {
            SBULog.info("There is no cached linked message. Reloads messages based on linked messages.")
            self.viewModel?.loadInitialMessages(
                startingPoint: parentMessage.createdAt,
                showIndicator: true,
                initialMessages: self.viewModel?.fullMessageList
            )
            return
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        self.listComponent?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        self.listComponent?.tableView.layoutIfNeeded()
    }
    
    open func messageThreadViewController(_ viewController: SBUMessageThreadViewController, shouldSyncVoiceFileInfos voiceFileInfos: [String: SBUVoiceFileInfo]?) {
        if let voiceFileInfos = voiceFileInfos {
            self.listComponent?.voiceFileInfos = voiceFileInfos
        }
    }
    
    // MARK: - SBUVoiceMessageInputViewDelegate
    open func voiceMessageInputViewDidTapCacel(_ inputView: SBUVoiceMessageInputView) {
        self.dismissVoiceMessageInput()
    }
    
    open func voiceMessageInputView(
        _ inputView: SBUVoiceMessageInputView,
        willStartToRecord voiceFileInfo: SBUVoiceFileInfo
    ) {
        self.willPresentSubview()
    }
    
    open func voiceMessageInputView(
        _ inputView: SBUVoiceMessageInputView,
        didTapSend voiceFileInfo: SBUVoiceFileInfo
    ) {
        var parentMessage: BaseMessage?
        if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
            switch messageInputView.option {
            case .quoteReply(let message):
                parentMessage = message
            default:
                break
            }
            messageInputView.setMode(.none)
        }
        
        self.dismissVoiceMessageInput()
        self.viewModel?.sendVoiceMessage(voiceFileInfo: voiceFileInfo, parentMessage: parentMessage)
    }
    
    // MARK: - SBUReactionsViewControllerDelegate
    
    /// - Since: 3.11.0
    open func reactionsViewController(
        _ viewController: SBUReactionsViewController,
        didTapUserProfile user: SBUUser
    ) {
        self.showUserProfile(user: user)
    }
    
    /// - Since: 3.11.0
    open func reactionsViewController(
        _ viewController: SBUReactionsViewController,
        tableView: UITableView,
        didSelect user: SBUUser,
        forRowAt indexPath: IndexPath
    ) {
        
    }
    
    // MARK: - Action handling
    /// Called when there’s a tap gesture on a message template that includes a web URL. e.g., `"https://www.sendbird.com"`
    /// ```swift
    /// print(action.urlFromActionDatas) // "https://www.sendbird.com"
    /// ```
    /// - Since: 3.21.0
    open func handleWebAction(
        _ action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        guard let url = action.urlFromActionDatas else { return }
        url.open()
    }
    
    /// Called when there’s a tap gesture on a message template that includes a custom URL scheme. e.g., `"myapp://someaction"`
    /// ```swift
    /// print(action.urlFromActionDatas) // "myapp://someaction"
    /// ```
    /// - Since: 3.21.0
    open func handleCustomAction(
        _ action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        guard let url = action.urlFromActionDatas else { return }
        url.open(needSanitise: false)
    }
}
