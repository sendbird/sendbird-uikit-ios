//
//  CreateCommunityChannelViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/12/04.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import SendBirdSDK

open class CreateCommunityChannelViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - UI properties (Public)
    public lazy var titleView: SBUNavigationTitleView = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = SBUStringSet.CreateChannel_Header_Title_Profile
        titleView.textAlignment = .center
        return titleView
    }()
    public lazy var leftBarButton: UIBarButtonItem = {
        let barButtinItem =  UIBarButtonItem(
            title: SBUStringSet.Cancel,
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
        barButtinItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return barButtinItem
    }()
    public lazy var rightBarButton: UIBarButtonItem = {
        let barButtinItem =  UIBarButtonItem(
            title: SBUStringSet.CreateChannel_Create(0),
            style: .plain,
            target: self,
            action: #selector(onClickCreate)
        )
        barButtinItem.isEnabled = false
        barButtinItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return barButtinItem
    }()
    public lazy var coverImageButton: UIButton = {
        let button = UIButton()
        button.setImage(
            SBUIconSet.iconCamera
                .sbu_with(tintColor: self.theme.coverImageTintColor)
                .resize(with: .init(width: self.coverImageSize, height: self.coverImageSize))
                .withBackground(
                    color: self.theme.coverImageBackgroundColor,
                    margin: 24,
                    circle: true
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(selectChannelImage), for: .touchUpInside)
        button.layer.cornerRadius = coverImageSize / 2
        button.layer.masksToBounds = true
        return button
    }()
    public lazy var channelNameField = UITextField()
    
    public var theme: SBUUserListTheme = SBUTheme.userListTheme
    public var customType: String = "SB_COMMUNITY_TYPE"
    
    let coverImageSize: CGFloat = 80
    
    // MARK: - Logic properties (Private)
    var hasCoverImage = false
    
    
    // MARK: - Lifecycle
    
    open override func loadView() {
        super.loadView()
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        // components
        self.channelNameField.addTarget(self, action: #selector(onEditingChangeTextField(_:)), for: .editingChanged)
        self.channelNameField.clearButtonMode = .whileEditing
        self.view.addSubview(self.coverImageButton)
        self.view.addSubview(self.channelNameField)
        
        // autolayout
        self.setupAutolayout()
        
        // Styles
        self.setupStyles()
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.coverImageButton.sbu_constraint(
            equalTo: self.view,
            left: 15,
            top: 15
        )
        
        self.coverImageButton.sbu_constraint(
            width: coverImageSize,
            height: coverImageSize
        )
        
        self.channelNameField.sbu_constraint(
            equalTo: self.coverImageButton,
            top: 0,
            bottom: 0
        )
        
        self.channelNameField.sbu_constraint_equalTo(
            leadingAnchor: self.coverImageButton.trailingAnchor,
            leading: 15,
            trailingAnchor: self.view.trailingAnchor,
            trailing: -15
        )
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.theme = SBUTheme.userListTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )
        
        self.leftBarButton.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton.tintColor = theme.barButtonDisabledTintColor
        
        self.channelNameField.attributedPlaceholder = NSAttributedString(
            string: SBUStringSet.ChannelSettings_Enter_New_Channel_Name,
            attributes: [
                NSAttributedString.Key.foregroundColor: theme.placeholderTintColor
            ]
        )
        self.channelNameField.textColor = theme.textfieldTextColor
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open func updateStyles() {
        self.theme = SBUTheme.userListTheme
        
        self.setupStyles()
        
        self.titleView.setupStyles()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapBackground(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.updateStyles()
    }
    
    // MARK: - SDK relations
    
    /// Creates the channel.
    public func createChannel() {
        if SBDMain.getConnectState() == .closed {
            self.showError("The Internet connection appears to be offline.")
            return
        }
        
        let channelName = self.channelNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let coverImage: Data = (
            self.hasCoverImage
                ? self.coverImageButton
                    .imageView?
                    .image?
                    .jpegData(compressionQuality: 1.0)
                : Data()
            ) ?? Data()
        
        self.rightBarButton.isEnabled = false
        SBULoading.start()
        
        SBDOpenChannel.createChannel(
            withName: channelName,
            channelUrl: nil,
            coverImage: coverImage,
            coverImageName: "cover_image",
            data: nil,
            operatorUserIds: [SBUGlobals.CurrentUser?.userId ?? ""],
            customType: customType,
            progressHandler: nil) { [weak self] (channel, error) in
                guard let self = self else { return }
                self.rightBarButton.isEnabled = true
                SBULoading.stop()
                
                if let error = error { self.showError(error.localizedDescription) }
                
                guard let channel = channel else { return }
                SBUMain.moveToChannel(
                    channelUrl: channel.channelUrl,
                    basedOnChannelList: false,
                    channelType: .open
                )
        }
    }
    
    // MARK: - Actions
    
    @objc public func onClickCreate() {
        self.createChannel()
    }
    
    @objc func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    ///  Refer to `didSelectActionSheetItem`
    @objc public func selectChannelImage() {
        let removeItem = SBUActionSheetItem(
            title: SBUStringSet.RemovePhoto,
            color: theme.removeColor,
            textAlignment: .center,
            completionHandler: nil
        )
        let cameraItem = SBUActionSheetItem(
            title: SBUStringSet.TakePhoto,
            textAlignment: .center,
            completionHandler: nil
        )
        let libraryItem = SBUActionSheetItem(
            title: SBUStringSet.ChoosePhoto,
            textAlignment: .center,
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.itemColor,
            completionHandler: nil
        )
        
        self.view.endEditing(true)
        
        SBUActionSheet.show(
            items: self.hasCoverImage
                ? [removeItem, cameraItem, libraryItem]
                : [cameraItem, libraryItem],
            cancelItem: cancelItem,
            delegate: self
        )
    }
    
    @objc func onEditingChangeTextField(_ sender: UITextField) {
        self.rightBarButton.isEnabled = !(sender.text?.isEmpty == true)
        self.rightBarButton.tintColor = sender.text?.isEmpty == true
            ? theme.barButtonDisabledTintColor
            : theme.barButtonTintColor
    }
    
    
    // MARK: - Error handling
    func showError(_ message: String) {
        let okButton = SBUAlertButtonItem(title: SBUStringSet.OK) { _ in }
        
        SBUAlertView.show(
            title: message,
            confirmButtonItem: okButton,
            cancelButtonItem: nil
        )
    }
    
    @objc
    func onTapBackground(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
}


// MARK: SBUActionSheetDelegate
extension CreateCommunityChannelViewController: SBUActionSheetDelegate {
    public func didSelectActionSheetItem(index: Int, identifier: Int) {
        var sourceType: UIImagePickerController.SourceType = .photoLibrary
        let mediaType: [String] = [String(kUTTypeImage)]
        
        let type = self.hasCoverImage ? index : index + 1
        
        switch type {
        case 1: sourceType = .camera
        case 2: sourceType = .photoLibrary
        default: break
        }
        
        if type != 0 {
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = sourceType
                imagePickerController.mediaTypes = mediaType
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        else {
            self.coverImageButton.setImage(
                SBUIconSet.iconCamera
                    .sbu_with(tintColor: self.theme.coverImageTintColor)
                    .resize(with: .init(width: coverImageSize,
                                        height: coverImageSize))
                    .withBackground(color: self.theme.coverImageBackgroundColor,
                                    margin: 24,
                                    circle: true),
                for: .normal
            )
            self.hasCoverImage = false
        }
    }
}


// MARK: UIImagePickerViewControllerDelegate
extension CreateCommunityChannelViewController: UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let originalImage = info[.originalImage] as? UIImage, let `self` = self else { return }
        
            self.coverImageButton.setImage(
                originalImage
                    .resize(with: .init(width: self.coverImageSize,
                                        height: self.coverImageSize))
                    .withBackground(color: .green,
                                    margin: 0,
                                    circle: true),
                for: .normal
            )
            
            self.hasCoverImage = true
        }
    }
}
