//
//  SBUBaseChannelSettingsViewController.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import PhotosUI
import MobileCoreServices

open class SBUBaseChannelSettingsViewController: SBUBaseViewController, SBUActionSheetDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, SBUSelectablePhotoViewDelegate, SBUCommonViewModelDelegate, SBUBaseChannelSettingsViewModelDelegate, SBUAlertViewDelegate {
    
    // MARK: - UI Properties (Public)
    public var baseHeaderComponent: SBUBaseChannelSettingsModule.Header?
    public var baseListComponent: SBUBaseChannelSettingsModule.List?
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    public var theme: SBUChannelSettingsTheme
    
    // MARK: - Logic properties (Public)
    public var baseViewModel: SBUBaseChannelSettingsViewModel?
    
    public var channelName: String?
    
    public var channel: BaseChannel? { baseViewModel?.channel }
    public var channelURL: String? { baseViewModel?.channelURL }
    
    public var isOperator: Bool { baseViewModel?.isOperator ?? false }
    
    public let actionSheetIdEdit = 1
    public let actionSheetIdPicker = 2
    
    // MARK: - Lifecycle
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.baseViewModel = nil
        self.baseHeaderComponent = nil
        self.baseListComponent = nil
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupLayouts() {
        self.baseListComponent?.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationShadowColor// navigationBarShadowColor
        )
        
        self.baseHeaderComponent?.setupStyles(theme: self.theme)
        self.baseListComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.baseListComponent?.reloadChannelInfoView()
        self.baseListComponent?.reloadTableView()
    }
    
    // MARK: - ViewModel
    /// Creates the view model, loading initial messages from given starting point.
    /// - Note: If you want to customize the viewModel, override this function
    /// - Parameters:
    ///     - channel: (opt) channel object
    ///     - channelURL: (opt) channel url
    /// - Since: 3.0.0
    open func createViewModel(channel: BaseChannel? = nil,
                              channelURL: String? = nil) { }
    
    // MARK: - Common
    /// This function sets right bar button when enable to set.
    /// - Since: 3.0.0
    public func updateRightBarButton() {
        if let groupChannel = self.channel as? GroupChannel {
            if !groupChannel.isBroadcast || groupChannel.myRole == .operator {
                self.navigationItem.rightBarButtonItem = self.baseHeaderComponent?.rightBarButton
            }
        } else if let _ = self.channel as? OpenChannel {
            if self.isOperator {
                self.navigationItem.rightBarButtonItem = self.baseHeaderComponent?.rightBarButton
            }
        }
    }
    
    // MARK: - Actions
    /// This function used to when edit button click.
    /// - Since: 3.0.0
    public func showChannelEditActionSheet() {
        let changeNameItem = SBUActionSheetItem(
            title: SBUStringSet.ChannelSettings_Change_Name,
            color: theme.itemTextColor,
            image: nil,
            completionHandler: nil
        )
        let changeImageItem = SBUActionSheetItem(
            title: SBUStringSet.ChannelSettings_Change_Image,
            color: theme.itemTextColor,
            image: nil,
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.itemColor,
            completionHandler: nil
        )
        SBUActionSheet.show(
            items: [changeNameItem, changeImageItem],
            cancelItem: cancelItem,
            identifier: actionSheetIdEdit,
            delegate: self
        )
        
        self.updateStyles()
    }
    
    /// This function shows the channel image selection menu.
    public func selectChannelImage() {
        let cameraItem = SBUActionSheetItem(
            title: SBUStringSet.Camera,
            image: SBUIconSetType.iconCamera.image(
                with: theme.itemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            ),
            completionHandler: nil
        )
        let libraryItem = SBUActionSheetItem(
            title: SBUStringSet.PhotoVideoLibrary,
            image: SBUIconSetType.iconPhoto.image(
                with: theme.itemColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            ),
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.itemColor,
            completionHandler: nil
        )
        SBUActionSheet.show(
            items: [cameraItem, libraryItem],
            cancelItem: cancelItem,
            identifier: actionSheetIdPicker,
            delegate: self
        )
    }
    
    /// This function shows the channel name change popup.
    public func changeChannelName() {
        let okButton = SBUAlertButtonItem(title: SBUStringSet.OK) {[weak self] newChannelName in
            guard let self = self else { return }
            guard let newChannel = newChannelName as? String else { return }
            
            let trimmedChannelName = newChannel.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedChannelName.count > 0 else { return }
            
            self.baseViewModel?.updateChannel(channelName: trimmedChannelName)
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        
        SBUAlertView.show(
            title: SBUStringSet.ChannelSettings_Change_Name,
            needInputField: true,
            placeHolder: SBUStringSet.ChannelSettings_Enter_New_Name,
            centerYRatio: 0.75,
            confirmButtonItem: okButton,
            cancelButtonItem: cancelButton,
            delegate: self
        )
    }
    
    /// This function shows image picker for changing channel image.
    /// - Parameter type: Media resource type (`MediaResourceType`)
    /// - Since: 3.0.0
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
        default: break
        }
    }
    
    /// Presents `UIImagePickerController` for using camera.
    /// - Since: 3.0.0
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
    /// - Since: 3.0.0
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
    
    // MARK: - Actions
    
    open func showNotifications() {
        guard let channel = self.channel else { return }
        if channel is GroupChannel {
            let pushSettingsVC = SBUViewControllerSet.GroupChannelPushSettingsViewController.init(channel: channel)
            self.navigationController?.pushViewController(pushSettingsVC, animated: true)
        }
    }
    
    /// If you want to use a custom MessageSearchViewController, override it and implement it.
    /// - Since: 2.1.0
    open func showSearch() {
        guard let channel = self.channel else { return }
        
        let searchVC = SBUViewControllerSet.MessageSearchViewController.init(channel: channel)
        let nav = UINavigationController(rootViewController: searchVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    /// If you want to use a custom moderationsViewController, override it and implement it.
    /// - Since: 1.2.0
    open func showModerationList() { }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: SBUActionSheetDelegate
    open func didSelectActionSheetItem(index: Int, identifier: Int) {
        if identifier == actionSheetIdEdit {
            let type = ChannelEditType.init(rawValue: index)
            switch type {
            case .name: self.changeChannelName()
            case .image: self.selectChannelImage()
            default: break
            }
        } else if identifier == actionSheetIdPicker {
            let type = MediaResourceType.init(rawValue: index) ?? .unknown
            self.showChannelImagePicker(with: type)
        }
    }
    
    open func didDismissActionSheet() { }
    
    // MARK: - SBUAlertViewDelegate
    open func didDismissAlertView() { }
    
    // MARK: - UIImagePickerViewControllerDelegate
    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            picker.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                guard let originalImage = info[.originalImage] as? UIImage else { return }
                
                self.baseListComponent?.updateChannelInfoView(coverImage: originalImage)
                
                self.baseViewModel?.updateChannel(coverImage: originalImage)
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
                            self.baseListComponent?.updateChannelInfoView(coverImage: originalImage)
                            self.baseViewModel?.updateChannel(coverImage: originalImage)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - SBUSelectablePhotoViewDelegate
    open func didTapSendImageData(_ data: Data, fileName: String? = nil, mimeType: String? = nil) {
        guard let image = UIImage(data: data) else { return }
        self.baseListComponent?.updateChannelInfoView(coverImage: image)
        self.baseViewModel?.updateChannel(coverImage: image)
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
    }
    
    // MARK: - SBUBaseChannelSettingsViewModelDelegate
    open func baseChannelSettingsViewModel(
        _ viewModel: SBUBaseChannelSettingsViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    ) { }
    
    open func baseChannelSettingsViewModel(_ viewModel: SBUBaseChannelSettingsViewModel, shouldDismissForChannelSettings channel: BaseChannel?) {
        if channel != nil {
            guard let channelVC = SendbirdUI.findChannelViewController(
                rootViewController: self.navigationController
            ) else { return }
            
            self.navigationController?.popToViewController(channelVC, animated: false)
        } else {
            guard let channelListVC = SendbirdUI.findChannelListViewController(
                rootViewController: self.navigationController,
                channelType: (self.channel is OpenChannel) ? .open : .group
            ) else { return }
            
            if let openChannelListVC = channelListVC as? SBUOpenChannelListViewController {
                openChannelListVC.reloadChannelList()
            }
            
            self.navigationController?.popToViewController(channelListVC, animated: false)
        }
    }
}
