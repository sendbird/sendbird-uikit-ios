//
//  SBUCreateOpenChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/24.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import PhotosUI
import MobileCoreServices

open class SBUCreateOpenChannelViewController: SBUBaseViewController, SBUActionSheetDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, SBUSelectablePhotoViewDelegate, SBUCreateOpenChannelModuleHeaderDelegate, SBUCreateOpenChannelModuleProfileInputDelegate, SBUCommonViewModelDelegate, SBUCreateOpenChannelViewModelDelegate, SBUAlertViewDelegate {

    // MARK: - UI properties (Public)
    public var headerComponent: SBUCreateOpenChannelModule.Header?
    public var profileInputComponent: SBUCreateOpenChannelModule.ProfileInput?
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.createOpenChannelTheme)
    public var theme: SBUCreateOpenChannelTheme
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUCreateOpenChannelViewModel?
    
    // MARK: - Constant
    private let actionSheetIdPicker = 2
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUCreateOpenChannelViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUCreateOpenChannelViewController(channel:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    required public init() {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel()
        self.headerComponent = SBUModuleSet.createOpenChannelModule.headerComponent
        self.profileInputComponent = SBUModuleSet.createOpenChannelModule.profileInputComponent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.viewModel = nil
        self.headerComponent = nil
        self.profileInputComponent = nil
    }
    
    // MARK: - ViewModel
    open func createViewModel() {
        self.viewModel = SBUCreateOpenChannelViewModel(delegate: self)
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(delegate: self, theme: self.theme)
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
        self.navigationItem.rightBarButtonItem = self.headerComponent?.rightBarButton
        
        // Body component
        self.profileInputComponent?.configure(
            delegate: self,
            theme: self.theme
        )
        
        if let profileInputComponent = self.profileInputComponent {
            self.view.addSubview(profileInputComponent)
        }
    }
    
    open override func setupLayouts() {
        self.profileInputComponent?.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationBarShadowColor
        )
        
        self.headerComponent?.setupStyles(theme: self.theme)
        self.profileInputComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
    }
    
    // MARK: - Actions
    
    /// This function creates open channel with profileInputComponent informations.
    public func createChannel() {
        let channelName = self.profileInputComponent?.getChannelName() ?? ""
        let coverImage: UIImage? = self.profileInputComponent?.getChannelCoverImage()
        
        self.createChannel(channelName: channelName, coverImage: coverImage)
    }
    
    /// This function creates open channel.
    /// - Parameters:
    ///   - channelName: Channel name
    ///   - coverImage: Channel cover image
    public func createChannel(channelName: String, coverImage: UIImage?) {
        self.viewModel?.createChannel(channelName: channelName, coverImage: coverImage)
    }
    
    /// This function shows the channel image selection menu.
    public func selectChannelImage(needRemoveItem: Bool) {
        let removeItem = SBUActionSheetItem(
            title: SBUStringSet.RemovePhoto,
            color: theme.actionSheetRemoveTextColor,
            tag: MediaResourceType.delete.rawValue,
            completionHandler: nil
        )
        let cameraItem = SBUActionSheetItem(
            title: SBUStringSet.Camera,
            color: theme.actionSheetTextColor,
            image: SBUIconSetType.iconCamera.image(
                with: theme.actionSheetItemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            ),
            tag: MediaResourceType.camera.rawValue,
            completionHandler: nil
        )
        let libraryItem = SBUActionSheetItem(
            title: SBUStringSet.PhotoVideoLibrary,
            color: theme.actionSheetTextColor,
            image: SBUIconSetType.iconPhoto.image(
                with: theme.actionSheetItemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            ),
            tag: MediaResourceType.library.rawValue,
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.actionSheetItemColor,
            completionHandler: nil
        )
        
        let items = needRemoveItem ? [removeItem, cameraItem, libraryItem] : [cameraItem, libraryItem]
        
        SBUActionSheet.show(
            items: items,
            cancelItem: cancelItem,
            identifier: actionSheetIdPicker,
            delegate: self
        )
    }
    
    /// This function shows image picker for changing channel image.
    /// - Parameter type: Media resource type (`MediaResourceType`)
    open func showChannelImagePicker(with type: MediaResourceType) {
        switch type {
        case .camera:
            SBUPermissionManager.shared.requestCameraAccess(for: .video) { [weak self] in
                guard let self = self else { return }
                self.showCamera()
            } onDenied: { [weak self] in
                guard let self = self else { return }
                self.showPermissionAlert(forType: .camera)
            }
        case .library:
            SBUPermissionManager.shared.requestPhotoAccessIfNeeded { status in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch status {
                    case .all:
                        self.showPhotoLibraryPicker()
                    case .limited:
                        self.showLimitedPhotoLibraryPicker()
                    default:
                        self.showPermissionAlert()
                    }
                }
            }
        case .delete:
            self.profileInputComponent?.updateChannelImage(nil)
        default: break
        }
    }
    
    /// Presents `UIImagePickerController` for using camera.
    open func showCamera() {
        let sourceType: UIImagePickerController.SourceType = .camera
        let mediaType: [String] = [
            String(kUTTypeImage)
        ]
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.mediaTypes = mediaType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    /// Presents `UIImagePickerController`. If `SBUGlobals.UsingPHPicker`is `true`, it presents `PHPickerViewController` in iOS 14 or later.
    /// - NOTE: If you want to use customized `PHPickerConfiguration`, please override this method.
    open func showPhotoLibraryPicker() {
        if #available(iOS 14, *), SBUGlobals.isPHPickerEnabled {
            var configuration = PHPickerConfiguration()
            configuration.filter = .any(of: [.images])
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
            return
        }
        
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        let mediaType: [String] = [
            String(kUTTypeImage),
        ]
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.mediaTypes = mediaType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    open func showLimitedPhotoLibraryPicker() {
        let selectablePhotoVC = SBUSelectablePhotoViewController(mediaType: .image)
        selectablePhotoVC.delegate = self
        let nav = UINavigationController(rootViewController: selectablePhotoVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    open func showPermissionAlert(forType permissionType: SBUPermissionManager.PermissionType = .photoLibrary) {
        SBUPermissionManager.shared.showPermissionAlert(
            forType: permissionType,
            alertViewDelegate: self
        )
    }
    
    // MARK: - Keyboard
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Common
    /// This function dismisses `ViewController` and moves to created channel.
    /// - Parameters:
    ///   - channel: Created channel
    ///   - messageListParams: messageListParams
    open func dismissAndMoveToChannel(_ channel: BaseChannel,
                                      messageListParams: MessageListParams?) {
        SendbirdUI.moveToChannel(
            channelURL: channel.channelURL,
            messageListParams: messageListParams
        )
    }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - SBUCreateOpenChannelModuleHeaderDelegate
    open func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header,
                                      didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header,
                                      didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header,
                                      didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header,
                                      didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header,
                                      didTapRightItem rightItem: UIBarButtonItem) {
        self.createChannel()
    }
    
    // MARK: - SBUCreateOpenChannelModuleProfileInputDelegate
    open func createOpenChannelModule(
        _ profileInputComponent: SBUCreateOpenChannelModule.ProfileInput,
        shouldChangeChannelName string: String
    ) {
        let trimmedText = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let needCreateButtonEnabled = !trimmedText.isEmpty
        self.headerComponent?.enableRightBarButton(needCreateButtonEnabled)
    }
    
    open func createOpenChannelModuleDidSelectChannelImage(
        _ profileInputComponent: SBUCreateOpenChannelModule.ProfileInput,
        needRemoveItem: Bool
    ) {
        self.selectChannelImage(needRemoveItem: needRemoveItem)
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.localizedDescription)
    }
    
    // MARK: - SBUCreateOpenChannelViewModelDelegate
    open func createOpenChannelViewModel(
        _ viewModel: SBUCreateOpenChannelViewModel,
        didCreateChannel channel: BaseChannel?
    ) {
        guard let channelURL = channel?.channelURL else {
            SBULog.error("[Failed] Create channel request: There is no channel url.")
            return
        }
        
        SendbirdUI.moveToChannel(channelURL: channelURL, channelType: .open)
    }
    
    // MARK: SBUActionSheetDelegate
    open func didSelectActionSheetItem(index: Int, identifier: Int) {
        if identifier == actionSheetIdPicker {
            let type = MediaResourceType.init(rawValue: index) ?? .unknown
            self.showChannelImagePicker(with: type)
        }
    }
    
    open func didDismissActionSheet() { }
    
    // MARK: - SBUAlertViewDelegate
    open func didDismissAlertView() { }
    
    // MARK: - SBUSelectablePhotoViewDelegate
    open func didTapSendImageData(_ data: Data, fileName: String? = nil, mimeType: String? = nil) {
        guard let image = UIImage(data: data) else { return }
        self.profileInputComponent?.updateChannelImage(image)
    }
    
    // MARK: - UIImagePickerViewControllerDelegate
    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            picker.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                guard let originalImage = info[.originalImage] as? UIImage else { return }
                
                self.profileInputComponent?.updateChannelImage(originalImage)
            }
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
            // image
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: [:]) { _, _ in
                    if itemProvider.canLoadObject(ofClass: UIImage.self) {
                        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] imageItem, _ in
                            guard let self = self else { return }
                            guard let originalImage = imageItem as? UIImage else { return }
                            self.profileInputComponent?.updateChannelImage(originalImage)
                        }
                    }
                }
            }
        }
    }
}
