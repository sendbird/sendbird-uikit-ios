//
//  SBUBaseChannelSettingViewController.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos
import MobileCoreServices

@objcMembers
open class SBUBaseChannelSettingViewController: SBUBaseViewController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    // MARK: - Logic properties (Public)
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    public var theme: SBUChannelSettingsTheme
    
    public var channelName: String? = nil
    public internal(set) var channelUrl: String?
    
    public lazy var isOperator: Bool = {
        if let groupChannel = self.baseChannel as? SBDGroupChannel {
            return groupChannel.myRole == .operator
        } else if let openChannel = self.baseChannel as? SBDOpenChannel {
            guard let userId = SBUGlobals.CurrentUser?.userId else { return false }
            return openChannel.isOperator(withUserId: userId)
        }
        return false
    }()
    
    // MARK: - UI properties (Public)
    
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
            if let groupChannel = self.baseChannel as? SBDGroupChannel {
                if !groupChannel.isBroadcast || groupChannel.myRole == .operator {
                    self.navigationItem.rightBarButtonItem = self.rightBarButton
                }
            } else if let _ = self.baseChannel as? SBDOpenChannel {
                if self.isOperator {
                    self.navigationItem.rightBarButtonItem = self.rightBarButton
                }
            }
        }
    }
    
    public internal(set) lazy var tableView = UITableView()
    public lazy var userInfoView: UIView? = SBUChannelSettingsUserInfoView()
    
    // MARK: - Logic properties (Private)
    let actionSheetIdEdit = 1
    let actionSheetIdPicker = 2
    
    /// Exposed as group / open in inherited classes.
    var baseChannel: SBDBaseChannel?
    var channelActionViewModel: SBUChannelActionViewModel = SBUChannelActionViewModel() {
        willSet { self.disposeViewModel() }
        didSet { self.bindViewModel() }
    }
    
    
    // MARK: - UI properties (Private)
    
    lazy var defaultTitleView: SBUNavigationTitleView = {
        var titleView = SBUNavigationTitleView()
        titleView.text = self.channelName ?? SBUStringSet.ChannelSettings_Header_Title
        titleView.textAlignment = .left
        
        return titleView
    }()
    
    lazy var backButton: UIBarButtonItem = SBUCommonViews.backButton(
        vc: self,
        selector: #selector(onClickBack)
    )
    
    lazy var editButton: UIBarButtonItem = {
        let rightItem =  UIBarButtonItem(
            title: SBUStringSet.Edit,
            style: .plain,
            target: self,
            action: #selector(onClickEdit)
        )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let channelUrl = self.baseChannel?.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateStyles()
    }
    
    deinit {
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        self.disposeViewModel()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
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
            self.rightBarButton = self.editButton
        }
        
        // navigation bar
        self.navigationItem.titleView = self.titleView
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        if let groupChannel = self.baseChannel as? SBDGroupChannel {
            if !groupChannel.isBroadcast || groupChannel.myRole == .operator {
                self.navigationItem.rightBarButtonItem = self.rightBarButton
            }
        } else if let _ = self.baseChannel as? SBDOpenChannel {
            if self.isOperator {
                self.navigationItem.rightBarButtonItem = self.rightBarButton
            }
        }
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
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
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )
        
        // For iOS 15
        self.navigationController?.sbu_setupNavigationBarAppearance(tintColor: theme.navigationBarTintColor)
        
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
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
    
    
    // MARK: - ViewModel
    
    func bindViewModel() {
        self.channelActionViewModel.errorObservable.observe { [weak self] error in
            guard let self = self else { return }
            
            self.errorHandler(error)
        }
        
        self.channelActionViewModel.loadingObservable.observe { [weak self] isLoading in
            guard let self = self else { return }
            
            if isLoading {
                self.shouldShowLoadingIndicator()
            } else {
                self.shouldDismissLoadingIndicator()
            }
        }
        
        self.channelActionViewModel.channelLoadedObservable.observe { [weak self] channel in
            guard let self = self else { return }
            
            SBULog.info("Channel loaded: \(String(describing: channel))")
            self.baseChannel = channel
            
            if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
                userInfoView.configure(channel: self.baseChannel)
            }
            
            self.updateStyles()
        }
        
        self.channelActionViewModel.channelChangedObservable.observe { [weak self] channel, _ in
            guard let self = self else { return }
            
            SBULog.info("Channel changed: \(String(describing: channel))")
            self.baseChannel = channel
            
            if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
                userInfoView.configure(channel: self.baseChannel)
            }
            
            self.updateStyles()
        }
        
        self.channelActionViewModel.channelDeletedObservable.observe { [weak self] _ in
            guard let self = self else { return }
        
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
    
    private func disposeViewModel() {
        self.channelActionViewModel.dispose()
    }
    
    
    // MARK: - SDK relations
    
    public func loadChannel(channelUrl: String?) {}
    
    
    public func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) {}
    
    
    // MARK: - Custom viewController relations (Group Channel)
    
    /// If you want to use a custom memberListViewController, override it and implement it.
    open func showMemberList() {
        guard let channel = self.baseChannel as? SBDGroupChannel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        let memberListVC = SBUMemberListViewController(channel: channel)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    /// If you want to use a custom moderationsViewController, override it and implement it.
    /// - Since: 1.2.0
    open func showModerationList() {
        guard let channel = self.baseChannel as? SBDGroupChannel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        let moderationsVC = SBUModerationsViewController(channel: channel)
        self.navigationController?.pushViewController(moderationsVC, animated: true)
    }
    
    /// If you want to use a custom MessageSearchViewController, override it and implement it.
    ///
    /// - Since: 2.1.0
    open func showSearch() {
        guard let channel = self.baseChannel as? SBDGroupChannel else { return }
        let searchVc = SBUMessageSearchViewController(channel: channel)
        
        let nav = UINavigationController(rootViewController: searchVc)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    // MARK: - Custom viewController relations (Open Channel)
    
    /// If you want to use a custom memberListViewController, override it and implement it.
    open func showParticipantsList() {
        guard let channel = self.baseChannel as? SBDOpenChannel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        
        let memberListVC = SBUMemberListViewController(channel: channel, type: .participants)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    // MARK: - Actions
    
    /// This function used to when edit button click.
    /// - Since: 1.2.5 
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
    private func errorHandler(_ error: SBDError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    @available(*, deprecated, renamed: "errorHandler") // 2.1.12
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}


// MARK: - UITableView relations
extension SBUBaseChannelSettingViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

// MARK: - SBDChannelDelegate, SBDConnectionDelegate
extension SBUBaseChannelSettingViewController: SBDChannelDelegate {
    open func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        self.tableView.reloadData()
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        self.tableView.reloadData()
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        self.tableView.reloadData()
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        self.tableView.reloadData()
    }
}

// MARK: SBUActionSheetDelegate
extension SBUBaseChannelSettingViewController: SBUActionSheetDelegate {
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

// MARK: - UIImagePickerViewControllerDelegate
extension SBUBaseChannelSettingViewController: UIImagePickerControllerDelegate {
    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard let originalImage = info[.originalImage] as? UIImage,
                let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView else { return }
            
            userInfoView.coverImage.setImage(withImage: originalImage)
            
            self.updateChannel(coverImage: originalImage)
        }
    }
}

// MARK: - LoadingIndicatorDelegate
extension SBUBaseChannelSettingViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        SBULoading.start()
        return true
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}
