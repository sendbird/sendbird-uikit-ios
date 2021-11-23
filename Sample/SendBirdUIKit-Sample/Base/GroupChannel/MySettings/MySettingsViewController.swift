//
//  MySettingsViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/11.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos
import MobileCoreServices

enum MySettingsCellType: Int {
    case darkTheme, doNotDisturb, signOut
}

open class MySettingsViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Property
    lazy var rightBarButton: UIBarButtonItem = {
        let rightItem =  UIBarButtonItem(
            title: SBUStringSet.Edit,
            style: .plain,
            target: self,
            action: #selector(onClickEdit)
        )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    lazy var userInfoView = UserInfoTitleView()
    lazy var tableView = UITableView()
    
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme
    
    var isDoNotDisturbOn: Bool = false
    
    // MARK: - Constant
    private let actionSheetIdEdit = 1
    private let actionSheetIdPicker = 2
    
    // MARK: - Life cycle
    open override func loadView() {
        super.loadView()
        
        // navigation bar
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.register(
            type(of: MySettingsCell()),
            forCellReuseIdentifier: MySettingsCell.sbu_className
        )
        self.tableView.tableHeaderView = self.userInfoView
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
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
        self.userInfoView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        layoutConstraints.append(self.userInfoView.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.userInfoView.trailingAnchor.constraint(
            equalTo: self.view.trailingAnchor,
            constant: 0)
        )

        layoutConstraints.append(self.tableView.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.tableView.trailingAnchor.constraint(
            equalTo: self.view.trailingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.tableView.topAnchor.constraint(
            equalTo: self.view.topAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.tableView.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor,
            constant: 0)
        )
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )
        self.navigationController?.sbu_setupNavigationBarAppearance(
            tintColor: theme.navigationBarTintColor
        )
        
        self.rightBarButton.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let user = SBUGlobals.CurrentUser {
            self.userInfoView.configure(user: user)
        }
        
        self.loadDisturbSetting {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    
    // MARK: - SDK related
    func loadDisturbSetting(_ completionHandler: @escaping (() -> Void)) {
        SBDMain.getDoNotDisturb { [weak self] (isDoNotDisturbOn, _, _, _, _, _, error) in
            self?.isDoNotDisturbOn = error == nil ? isDoNotDisturbOn : false
            completionHandler()
        }
    }
    
    func changeDisturb(isOn: Bool, _ completionHandler: ((Bool) -> Void)? = nil) {
        SBDMain.setDoNotDisturbWithEnable(
            isOn,
            startHour: 0,
            startMin: 0,
            endHour: 23,
            endMin: 59,
            timezone: "UTC"
        ) { error in
            guard error == nil else {
                completionHandler?(false)
                return
            }
            
            completionHandler?(true)
        }
    }
    
    
    // MARK: - Actions
    /// Open the user edit action sheet.
    @objc func onClickEdit() {
        let changeNameItem = SBUActionSheetItem(
            title: "Change my nickname",
            color: theme.itemTextColor,
            image: nil
        ) {}
        let changeImageItem = SBUActionSheetItem(
            title: "Change my profile image",
            color: theme.itemTextColor,
            image: nil
        ) {}
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.itemColor
        ) {}
        SBUActionSheet.show(
            items: [changeNameItem, changeImageItem],
            cancelItem: cancelItem,
            identifier: actionSheetIdEdit,
            delegate: self
        )
    }
    
    /// Open the nickname change popup.
    public func changeNickname() {
        let okButton = SBUAlertButtonItem(title: SBUStringSet.OK) {[weak self] newNickname in
            guard let nickname = newNickname as? String,
                nickname.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
                else { return }
            
            SBUMain.updateUserInfo(nickname: nickname, profileUrl: nil) { (error) in
                guard error == nil, let user = SBUGlobals.CurrentUser else { return }
                UserDefaults.saveNickname(nickname)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.userInfoView.configure(user: user)
                }
            }
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        SBUAlertView.show(
            title: "Change my nickname",
            needInputField: true,
            placeHolder: "Enter nickname",
            centerYRatio: 0.75,
            confirmButtonItem: okButton,
            cancelButtonItem: cancelButton
        )
    }
    
    /// Open the user image selection menu.
    public func selectUserImage() {
        let cameraItem = SBUActionSheetItem(
            title: SBUStringSet.Camera,
            image: SBUIconSet.iconCamera.sbu_with(tintColor: SBUColorSet.primary300),
            completionHandler: nil
        )
        let libraryItem = SBUActionSheetItem(
            title: SBUStringSet.PhotoVideoLibrary,
            image: SBUIconSet.iconPhoto.sbu_with(tintColor: SBUColorSet.primary300),
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: SBUColorSet.primary300,
            completionHandler: nil
        )
        SBUActionSheet.show(
            items: [cameraItem, libraryItem],
            cancelItem: cancelItem,
            identifier: actionSheetIdPicker,
            delegate: self
        )
    }
    
    open func changeDarkThemeSwitch(isOn: Bool) {
        SBUTheme.set(theme: isOn ? .dark : .light)
        
        guard let tabbarController = self.tabBarController as? MainChannelTabbarController else { return }
        tabbarController.updateTheme(isDarkMode: isOn)
        self.userInfoView.setupStyles()
        self.tableView.reloadData()
    }
    
    func changeDisturbSwitch(isOn: Bool, _ completionHandler: ((Bool) -> Void)? = nil) {
        self.changeDisturb(isOn: isOn, completionHandler)
    }
    
    /// Sign out and dismiss tabbarController,
    func signOutAction() {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UITableView relations
extension MySettingsViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowValue = indexPath.row
        let type = MySettingsCellType(rawValue: rowValue)
        switch type {
        case .signOut:
            self.signOutAction()
        default:
            break
        }
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MySettingsCell.sbu_className
            ) as? MySettingsCell else { fatalError() }

        cell.selectionStyle = .none
        
        let isDarkMode = (self.tabBarController as? MainChannelTabbarController)?.isDarkMode ?? false

        let rowValue = indexPath.row
        if let type = MySettingsCellType(rawValue: rowValue) {
            cell.configure(type: type, isDarkMode: isDarkMode)

            switch type {
                case .darkTheme:
                    cell.switchAction = { [weak self] isOn in
                        self?.changeDarkThemeSwitch(isOn: isOn)
                    }
                case .doNotDisturb:
                    cell.changeSwitch(self.isDoNotDisturbOn)
                    cell.switchAction = { [weak self] isOn in
                        self?.changeDisturb(isOn: isOn, { success in
                            if !success {
                                cell.changeBackSwitch()
                            } else {
                                self?.isDoNotDisturbOn = isOn
                            }
                        })
                    }
                case .signOut: break
            }
        }

        return cell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}


// MARK: SBUActionSheetDelegate
extension MySettingsViewController: SBUActionSheetDelegate {
    public func didSelectActionSheetItem(index: Int, identifier: Int) {
        if identifier == actionSheetIdEdit {
            let type = ChannelEditType.init(rawValue: index)
            switch type {
            case .name:
                self.changeNickname()
            case .image:
                self.selectUserImage()
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
}


// MARK: UIImagePickerViewControllerDelegate
extension MySettingsViewController: UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let originalImage = info[.originalImage] as? UIImage else { return }
            
            self?.userInfoView.coverImage.image = originalImage
            
            SBUMain.updateUserInfo(
                nickname: nil,
                profileImage: originalImage.jpegData(compressionQuality: 0.5)
            ) { error in
                guard error == nil, let user = SBUGlobals.CurrentUser else { return }
                self?.userInfoView.configure(user: user)
            }
        }
    }
}
