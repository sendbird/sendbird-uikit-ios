//
//  SBUChannelSettingsViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

@objcMembers
open class SBUChannelSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBUActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Public property
    public var channelName: String? = nil
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
    
    // MARK: - Private property
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme

    private lazy var titleView: SBUNavigationTitleView = _titleView
    private lazy var userInfoView: UIView = _userInfoView
    private lazy var tableView = UITableView()
    
    private lazy var _titleView: SBUNavigationTitleView = {
        let titleView = SBUNavigationTitleView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        titleView.text = self.channelName ?? SBUStringSet.ChannelSettings_Header_Title
        titleView.textAlignment = .left
        
        return titleView
    }()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        let backButton = UIBarButtonItem(image: SBUIconSet.iconBack, style: .plain, target: self, action: #selector(onClickBack))
        return backButton
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        let editButton = UIBarButtonItem(title: SBUStringSet.Edit, style: .plain, target: self, action: #selector(onClickEdit))
        return editButton
    }()
    
    private lazy var _userInfoView: UIView =  {
        return UserInfoView()
    }()
    
    private var updatedCoverImage: UIImage?
    
    private let actionSheetIdEdit = 1
    private let actionSheetIdPicker = 2
    
    /// One of two must be set.
    private var channel: SBDGroupChannel?
    private var channelUrl: String?

    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUChannelSettingsViewController.init(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    public init(channel: SBDGroupChannel?) {
        super.init(nibName: nil, bundle: nil)
        
        self.channel = channel
        
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameter channelUrl: Channel url string
    public init(channelUrl: String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.channelUrl = channelUrl
        
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        super.loadView()

        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.register(SBUChannelSettingCell.loadNib(), forCellReuseIdentifier: SBUChannelSettingCell.className)
        self.tableView.tableHeaderView = self.userInfoView
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
        
        // autolayout
        self.setupAutolayout()
        
        // styles
        self.setupStyles()
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.tableView.tableHeaderView?.frame.size = .init(width: tableView.bounds.width, height: 132)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
        ])
        
        self.userInfoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.userInfoView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.userInfoView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.userInfoView.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor, constant: 0),
        ])
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = theme.navigationBarTintColor
        self.navigationController?.navigationBar.shadowImage = .from(color: theme.navigationShadowColor)

        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
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
        
        if let channelUrl = self.channel?.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupStyles()
    }
    
    // MARK: - SDK relations
    public func updateChannelInfo(channelName: String? = nil) {
        guard let channel = self.channel else { return }
        
        let params = SBDGroupChannelParams()
        
        if channelName != nil {
            params.name = channelName
        }
        
        if let coverImage = self.updatedCoverImage {
            params.coverImage = coverImage.jpegData(compressionQuality: 0.5)
        } else {
            params.coverUrl = self.channel?.coverUrl
        }
        
        channel.update(with: params) { [weak self] channel, error in
            if let userInfoView = self?.userInfoView as? UserInfoView {
                userInfoView.configure(channel: self?.channel)
            }
        }
    }
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        SBUMain.connectionCheck { [weak self] user, error in

            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard error == nil else { return }
                
                self?.channel = channel
                
                if let userInfoView = self?.userInfoView as? UserInfoView {
                    userInfoView.configure(channel: self?.channel)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom memberListViewController, override it and implement it.
    open func showMemberList() {
        guard let channel = self.channel else { return }
        let memberListVC = SBUMemberListViewController(channel: channel)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    
    // MARK: - Actions
    func onClickBack() {
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func onClickEdit() {
        let changeNameItem = SBUActionSheetItem(title: SBUStringSet.ChannelSettings_Change_Name, color: theme.itemTextColor, image: nil)
        let changeImageItem = SBUActionSheetItem(title: SBUStringSet.ChannelSettings_Change_Image, color: theme.itemTextColor, image: nil)
        let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel, color: theme.itemColor)
        SBUActionSheet.show(items: [changeNameItem, changeImageItem], cancelItem: cancelItem, identifier: actionSheetIdEdit, delegate: self)
    }
    
    public func selectChannelImage() {
        let cameraItem = SBUActionSheetItem(title: SBUStringSet.Camera, image: SBUIconSet.iconCamera.with(tintColor: theme.itemColor))
        let libraryItem = SBUActionSheetItem(title: SBUStringSet.PhotoVideoLibrary, image: SBUIconSet.iconPhoto.with(tintColor: theme.itemColor))
        let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel, color: theme.itemColor)
        SBUActionSheet.show(items: [cameraItem, libraryItem], cancelItem: cancelItem, identifier: actionSheetIdPicker, delegate: self)
    }
    
    public func changeChannelName() {
        let okButton = SBUAlertButtonItem(title: SBUStringSet.OK) { [weak self] newChannelName in
            guard let newChannel = newChannelName as? String,
                newChannel.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else { return }
            self?.updateChannelInfo(channelName: newChannel.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }
        SBUAlertView.show(title: SBUStringSet.ChannelSettings_Change_Name, needInputField: true, placeHolder: SBUStringSet.ChannelSettings_Enter_New_Name, centerYRatio: 0.75, confirmButtonItem: okButton, cancelButtonItem: cancelButton)
    }
    
    
    // MARK: - Actions
    public func changeNotification(isOn: Bool) {
        let triggerOption: SBDGroupChannelPushTriggerOption = isOn ? .all : .off
        self.channel?.setMyPushTriggerOption(triggerOption, completionHandler: { error in
        })
    }
    
    public func leaveChannel() {
        self.channel?.leave(completionHandler: { [weak self] error in
            guard let self = self else { return }
            guard let navigationController = self.navigationController, navigationController.viewControllers.count > 1 else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            for vc in navigationController.viewControllers {
                if vc is SBUChannelListViewController {
                    navigationController.popToViewController(vc, animated: true)
                    return
                }
            }
            
            navigationController.popToRootViewController(animated: true)
        })
    }
    
    // MARK: - UITableView relations
    // CUSTOM:
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.userInfoView.endEditing(true)
        
        switch indexPath.row {
        case 0: // Notification
            break
            
        case 1: // Members
            self.showMemberList()
            
        case 2: // Leave Channel
            self.leaveChannel()
            
        default:
            break
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SBUChannelSettingCell.className) as? SBUChannelSettingCell else { fatalError() }
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0: // Notification
            cell.configure(type: .notification, channel: self.channel)
            cell.switchAction = { [weak self] isOn in
                self?.changeNotification(isOn: isOn)
            }
        case 1:
            cell.configure(type: .member, channel: self.channel)
            cell.rightButtonAction = { [weak self] in
                self?.showMemberList()
            }
        case 2:
            cell.configure(type: .leave, channel: nil)
            
        default: break
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    // MARK: SBUActionSheetDelegate
    func didSelectActionSheetItem(index: Int, identifier: Int) {
        if identifier == actionSheetIdEdit {
            let type = ChannelEditType.init(rawValue: index)
            switch type {
            case .name:
                self.changeChannelName()
            case .image:
                self.selectChannelImage()
            default:
                break
            }
        }
        else {
            let type = MediaResourceType.init(rawValue: index)
            var sourceType: UIImagePickerController.SourceType = .photoLibrary
            let mediaType: [String] = [String(kUTTypeImage)]
            
            switch type {
            case .camera:
                sourceType = .camera
            case .library:
                sourceType = .photoLibrary
            case .document:
                break
            default:
                break
            }
            
            if type != .document {
                if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = sourceType
                    imagePickerController.mediaTypes = mediaType
                    self.present(imagePickerController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: UIImagePickerViewControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let originalImage = info[.originalImage] as? UIImage, let userInfoView = self?.userInfoView as? UserInfoView else { return }
            self?.updatedCoverImage = originalImage
            userInfoView.coverImage.setImage(withImage: originalImage)
            
            self?.updateChannelInfo()
        }
    }
    
    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {
        
    }
}


// MARK: -
@objcMembers
fileprivate class UserInfoView: UIView {
    lazy var stackView = UIStackView()
    lazy var coverImage = SBUCoverImageView()
    lazy var channelNameField = UITextField()
    lazy var lineView = UIView()
    
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme
    
    var channel: SBDGroupChannel?
    
    let kCoverImageSize: CGFloat = 64.0
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "UserInfoView.init(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.channelNameField.textAlignment = .center
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.channelNameField.leftView = paddingView
        self.channelNameField.leftViewMode = .always
        self.channelNameField.rightView = paddingView
        self.channelNameField.rightViewMode = .always
        self.channelNameField.returnKeyType = .done
        self.channelNameField.isUserInteractionEnabled = false
        
        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(x: 0, y: 0, width: kCoverImageSize, height: kCoverImageSize)
        
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.spacing = 7
        self.stackView.alignment = .center
        self.stackView.addArrangedSubview(self.coverImage)
        self.stackView.addArrangedSubview(self.channelNameField)
        self.addSubview(stackView)
        self.addSubview(lineView)
    }
    
    func setupAutolayout() {
        self.coverImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.coverImage.widthAnchor.constraint(equalToConstant: kCoverImageSize),
            self.coverImage.heightAnchor.constraint(equalToConstant: kCoverImageSize),
        ])
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            self.stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
        ])
        
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.lineView.heightAnchor.constraint(equalToConstant: 0.5),
            self.lineView.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 20),
            self.lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            self.lineView.leftAnchor.constraint(equalTo: self.stackView.leftAnchor, constant: 16),
            self.lineView.rightAnchor.constraint(equalTo: self.stackView.rightAnchor, constant: -16),
        ])
    }
    
    func setupStyles() {
        self.backgroundColor = .clear
            
        self.lineView.backgroundColor = theme.cellSeparateColor

        self.channelNameField.font = theme.userNameFont
        self.channelNameField.textColor = theme.userNameTextColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImage.layer.cornerRadius = kCoverImageSize / 2
        self.coverImage.layer.borderColor = UIColor.clear.cgColor
        self.coverImage.layer.borderWidth = 1
        
        self.setupStyles()
    }
    
    func configure(channel: SBDGroupChannel?) {
        self.channel = channel
        
        if let url = channel?.coverUrl, SBUUtils.isValid(coverUrl: url) == true {
            self.coverImage.setImage(withCoverUrl: url)
        } else if let members = self.channel?.members as? [SBDUser] {
            self.coverImage.setImage(withUsers: members)
        } else {
            self.coverImage.setPlaceholderImage(iconSize: .init(width: 46, height: 46))
        }
        
        guard let channel = self.channel else { return }
        if SBUUtils.isValid(channelName: channel.name) == true {
            self.channelNameField.text = channel.name
        } else {
            self.channelNameField.text = SBUUtils.generateChannelName(channel: channel)
        }
    }
    
    
    // MARK: - Event
    var selectChannelImageAction: (() -> Void)? = nil
    func onClickChannelImageSelect(_ sender: Any) {
        self.endEditing(true)
        self.selectChannelImageAction?()
    }
    
    func updateChannelImage(image: UIImage) {
        self.coverImage.setImage(withImage: image)
    }
}
