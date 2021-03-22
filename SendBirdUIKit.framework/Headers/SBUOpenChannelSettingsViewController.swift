//
//  SBUOpenChannelSettingsViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/11/09.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

@objcMembers
open class SBUOpenChannelSettingsViewController: SBUBaseViewController {
    
    // MARK: - UI properties (Public)
    public lazy var userInfoView: UIView? = _userInfoView
    public var titleView: UIView? = nil {
        didSet {
            self.navigationItem.titleView = self.titleView
        }
    }
    public var leftBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        }
    }
    public var rightBarButton: UIBarButtonItem? = nil {
        didSet {
            if self.isOperator {
                self.navigationItem.rightBarButtonItem = self.rightBarButton
            }
        }
    }
    public private(set) lazy var tableView = UITableView()
    
    public var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme

    
    // MARK: - UI properties (Private)
    private lazy var _titleView: SBUNavigationTitleView = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = self.channelName ?? SBUStringSet.ChannelSettings_Header_Title
        titleView.textAlignment = .left
        
        return titleView
    }()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        return SBUCommonViews.backButton(vc: self, selector: #selector(onClickBack))
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        let rightItem =  UIBarButtonItem(
            title: SBUStringSet.Edit,
            style: .plain,
            target: self,
            action: #selector(onClickEdit)
        )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    private lazy var _userInfoView: UIView =  {
        return SBUChannelSettingsUserInfoView()
    }()

    
    // MARK: - Logic properties (Public)
    public var channelName: String? = nil
    
    public private(set) var channel: SBDOpenChannel?
    public private(set) var channelUrl: String?

    public var isOperator: Bool {
        guard let userId = SBUGlobals.CurrentUser?.userId else { return false }
        return self.channel?.isOperator(withUserId: userId) ?? false
    }
    
    // MARK: - Logic properties (Private)
    private let actionSheetIdEdit = 1
    private let actionSheetIdPicker = 2
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUOpenChannelSettingsViewController(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUOpenChannelSettingsViewController(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }

    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    public init(channel: SBDOpenChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channel = channel
        self.channelUrl = channel.channelUrl
        
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameter channelUrl: Channel url string
    public init(channelUrl: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        if self.titleView == nil {
            self.titleView = _titleView
        }
        if self.leftBarButton == nil {
            self.leftBarButton = _leftBarButton
        }
        if self.rightBarButton == nil {
            self.rightBarButton = _rightBarButton
        }
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        if self.isOperator {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        }
        self.navigationItem.titleView = self.titleView
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.register(
            type(of: SBUOpenChannelSettingCell()),
            forCellReuseIdentifier: SBUOpenChannelSettingCell.sbu_className
        )
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
    open override func setupAutolayout() {
        if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
            userInfoView
                .sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0)
                .sbu_constraint(equalTo: self.tableView, centerX: 0)
        }

        self.tableView
            .sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )

        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
        
        if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
            userInfoView.setupStyles()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateStyles()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SBUActionSheet.dismiss()
        SBUAlertView.dismiss()
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            if let error = error { self.didReceiveError(error.localizedDescription) }
            
            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            SBDOpenChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard let self = self else { return }
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    self.didReceiveError(error.localizedDescription)
                    return
                }
                
                self.channel = channel
                
                SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                
                if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
                    userInfoView.configure(channel: self.channel)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    /// Used to update the channel name or cover image. `channelName` and` coverImage` are used for updating only the set values.
    /// - Parameters:
    ///   - channelName: Channel name to update
    ///   - coverImage: Cover image to update
    public func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) {
        let channelParams = SBDOpenChannelParams()
        
        channelParams.name = channelName
        
        if let coverImage = coverImage {
            channelParams.coverImage = coverImage.jpegData(compressionQuality: 0.5)
        } else {
            channelParams.coverUrl = self.channel?.coverUrl
        }
        
        SBUGlobalCustomParams.openChannelParamsUpdateBuilder?(channelParams)

        self.updateChannel(params: channelParams)
    }
    
    /// Updates the channel with channelParams.
    ///
    /// You can update a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `SBDOpenChannelParams` class object
    public func updateChannel(params: SBDOpenChannelParams) {
        guard let channel = self.channel else { return }
        guard let operators = channel.operators as? [SBDUser] else { return }
        let operatorUserIds = operators.map { $0.userId }
        
        SBULog.info("[Request] Channel update")
        
        channel.update(withName: params.name,
                       coverImage: params.coverImage,
                       coverImageName: "cover_image",
                       data: nil,
                       operatorUserIds: operatorUserIds,
                       customType: channel.customType,
                       progressHandler: nil) { [weak self] channel, error in
            guard let self = self else { return }
            if let error = error {
                SBULog.error("[Failed] Channel update request: \(String(error.localizedDescription))")
            }
            
            if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
                userInfoView.configure(channel: self.channel)
                SBULog.info("[Succeed] Channel update")
            }
        }
    }
    
    /// Deletes the channel.
    public func deleteChannel() {
        SBULog.info("""
            [Request] Delete channel,
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)
        
        guard let channel = self.channel else { return }
        channel.delete { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                SBULog.error("""
                    [Failed] Delete channel request:
                    \(String(error.localizedDescription))
                    """)
            }
            
            SBULog.info("""
                [Succeed] Delete channel request,
                ChannelUrl:\(self.channel?.channelUrl ?? "")
                """)
            
            guard let navigationController = self.navigationController,
                navigationController.viewControllers.count > 1 else {
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
        }
    }
    
    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom memberListViewController, override it and implement it.
    open func showParticipantsList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        
        let memberListVC = SBUMemberListViewController(channel: channel, type: .participants)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    
    // MARK: - Actions
    
    /// This function used to when edit button click.
    public func onClickEdit() {
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
            
            self.updateChannel(channelName: trimmedChannelName)
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        SBUAlertView.show(
            title: SBUStringSet.ChannelSettings_Change_Name,
            needInputField: true,
            placeHolder: SBUStringSet.ChannelSettings_Enter_New_Name,
            centerYRatio: 0.75,
            confirmButtonItem: okButton,
            cancelButtonItem: cancelButton
        )
    }
    
    
    // MARK: - Error handling
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameter message: error message
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
}


// MARK: - UITableView relations
extension SBUOpenChannelSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
            userInfoView.endEditing(true)
        }
        
        let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
        let type = OpenChannelSettingItemType(rawValue: rowValue)
        switch type {
        case .participants: self.showParticipantsList()
        case .delete: self.deleteChannel()
        default: return
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SBUOpenChannelSettingCell.sbu_className
            ) as? SBUOpenChannelSettingCell else { fatalError() }
        
        cell.selectionStyle = .none

        let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
        if let type = OpenChannelSettingItemType(rawValue: rowValue) {
            cell.configure(type: type, channel: self.channel)
        }

        return cell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OpenChannelSettingItemType.allTypes(isOperator: self.isOperator).count
    }
}


// MARK: SBUActionSheetDelegate
extension SBUOpenChannelSettingsViewController: SBUActionSheetDelegate {
    open func didSelectActionSheetItem(index: Int, identifier: Int) {
        if identifier == actionSheetIdEdit {
            let type = ChannelEditType.init(rawValue: index)
            switch type {
            case .name: self.changeChannelName()
            case .image: self.selectChannelImage()
            default: break
            }
        }
        else {
            let type = MediaResourceType.init(rawValue: index)
            var sourceType: UIImagePickerController.SourceType = .photoLibrary
            let mediaType: [String] = [String(kUTTypeImage)]
            
            switch type {
            case .camera: sourceType = .camera
            case .library: sourceType = .photoLibrary
            case .document: break
            default: break
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
}


// MARK: UIImagePickerViewControllerDelegate
extension SBUOpenChannelSettingsViewController: UIImagePickerControllerDelegate {
    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard let originalImage = info[.originalImage] as? UIImage else { return }
            guard let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView else { return }
            
            userInfoView.coverImage.setImage(withImage: originalImage)
            
            self.updateChannel(coverImage: originalImage)
        }
    }
}

// MARK: - SBDChannelDelegate, SBDConnectionDelegate
extension SBUOpenChannelSettingsViewController: SBDChannelDelegate {
    open func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        self.tableView.reloadData()
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        self.tableView.reloadData()
    }
    
}
