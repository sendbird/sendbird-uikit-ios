//
//  ViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 11/03/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

enum ButtonType: Int {
    case signIn
    case startChatWithVC
    case startChatWithTC
    case startOpenChatWithTC
    case startChatBotWithVC
    case signOut
    case customSamples
}

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var connectView: ConnectView!
    
    var titleLabel: UILabel { connectView.titleLabel }
    var userIdTextField: UITextField { connectView.userIdTextField }
    var nicknameTextField: UITextField { connectView.nicknameTextField }
    var signInButton: UIButton { connectView.signInButton }
    
    @IBOutlet weak var mainView: MainView!
    
    var homeStackView: UIStackView { mainView.homeStackView }
    var unreadCountLabel: UILabel { mainView.groupChannelItemView.unreadCountLabel }
//    var startChatWithViewControllerButton: UIButton { mainView.groupChannelItemView.actionButton }
    var startChatWithTabbarControllerButton: UIButton { mainView.groupChannelItemView.actionButton }
    var startOpenChatWithTabbarControllerButton: UIButton { mainView.openChannelItemView.actionButton }
    var startChatBotWithViewControllerButton: UIButton { mainView.chatBotItemView.actionButton }
    var customSamplesButton: UIButton { mainView.customItemView.actionButton }
    var signOutButton: UIButton { mainView.signOutButton }
    
    @IBOutlet weak var versionLabel: UILabel!

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.stopAnimating()
        }
    }

    let duration: TimeInterval = 0.4
    var isSignedIn = false {
        didSet {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.connectView.isHidden = self.isSignedIn
                self.connectView.alpha = self.isSignedIn ? 0 : 1
                self.homeStackView.isHidden = !self.isSignedIn
                self.homeStackView.alpha = !self.isSignedIn ? 0 : 1
            })
            self.view.endEditing(true)
        }
    }
    
    enum CornerRadius: CGFloat {
        case small = 4.0
        case large = 8.0
    }
    
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SBUTheme.set(theme: .light)
        GlobalSetCustomManager.setDefault()
        
        nicknameTextField.text = UserDefaults.loadNickname()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.tag = ButtonType.signIn.rawValue
        signOutButton.tag = ButtonType.signOut.rawValue
        
//        startChatWithViewControllerButton.tag = ButtonType.startChatWithVC.rawValue
        startChatWithTabbarControllerButton.tag = ButtonType.startChatWithTC.rawValue
        startOpenChatWithTabbarControllerButton.tag = ButtonType.startOpenChatWithTC.rawValue
        startChatBotWithViewControllerButton.tag = ButtonType.startChatBotWithVC.rawValue
        customSamplesButton.tag = ButtonType.customSamples.rawValue
        
        signInButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
//        startChatWithViewControllerButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
        startChatWithTabbarControllerButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
        startChatBotWithViewControllerButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
        startOpenChatWithTabbarControllerButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
        customSamplesButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
 
        UserDefaults.saveIsLightTheme(true)
        
        let coreVersion: String = SendbirdChat.getSDKVersion()
        var uikitVersion: String {
            if SendbirdUI.shortVersion == "[NEXT_VERSION]" {
                let bundle = Bundle(identifier: "com.sendbird.uikit.sample")
                return "\(bundle?.infoDictionary?["CFBundleShortVersionString"] ?? "")"
            } else if SendbirdUI.shortVersion == "0.0.0" {
                guard let dictionary = Bundle.main.infoDictionary,
                      let appVersion = dictionary["CFBundleShortVersionString"] as? String,
                      let build = dictionary["CFBundleVersion"] as? String else {return ""}
                return "\(appVersion)(\(build))"
            } else {
                return SendbirdUI.shortVersion
            }
        }
        versionLabel.text = "UIKit v\(uikitVersion)\tSDK v\(coreVersion)"
         
        userIdTextField.text = UserDefaults.loadUserID()
        nicknameTextField.text = UserDefaults.loadNickname()
        
        SendbirdChat.addUserEventDelegate(self, identifier: self.description)
        SendbirdChat.addConnectionDelegate(self, identifier: self.description)
        
        guard userIdTextField.text != nil,
              nicknameTextField.text != nil else { return }
        signinAction()
    }
    
    deinit {
        SendbirdChat.removeUserEventDelegate(forIdentifier: self.description)
        SendbirdChat.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    func updateUnreadCount() {
        SendbirdChat.getTotalUnreadMessageCount { [weak self] totalCount, error in
            guard let self = self else { return }
            self.setUnreadMessageCount(unreadCount: Int32(totalCount))
        }
    }
    
    func setUnreadMessageCount(unreadCount: Int32) {
        guard self.isSignedIn else { return }
        
        var badgeValue: String?
        if unreadCount == 0 {
            badgeValue = nil
        } else if unreadCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(unreadCount)"
        }
        
        self.unreadCountLabel.text = badgeValue
        self.unreadCountLabel.isHidden = badgeValue == nil
    }
    
    // MARK: - Actions
    @IBAction func onEditingChangeTextField(_ sender: UITextField) {
        let color = sender.text?.isEmpty ?? true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0) : #colorLiteral(red: 0.4823529412, green: 0.3254901961, blue: 0.937254902, alpha: 1)
        sender.animateBorderColor(toColor: color, duration: 0.1)
    }
  
    @IBAction func onTapButton(_ sender: UIButton) {
        let type = ButtonType(rawValue: sender.tag)

        switch type {
        case .signIn:
            self.signinAction()
        case .startChatWithVC, .startChatWithTC:
            self.startChatAction(type: type ?? .startChatWithVC)
        case .startOpenChatWithTC:
            self.startOpenChatAction(type: .startOpenChatWithTC)
        case .startChatBotWithVC:
            self.startChatBotAction(type: .startChatBotWithVC)
        case .signOut:
            self.signOutAction()
        case .customSamples:
            self.moveToCustomSamples()
        default:
            break
        }
    }

    func signinAction() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        let userID = userIdTextField.text ?? ""
        let nickname = nicknameTextField.text ?? ""
        
        guard !userID.isEmpty else {
            userIdTextField.shake()
            userIdTextField.becomeFirstResponder()
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            return
        }
        guard !nickname.isEmpty else {
            nicknameTextField.shake()
            nicknameTextField.becomeFirstResponder()
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            return
        }
        
        SBUGlobals.currentUser = SBUUser(userId: userID, nickname: nickname)
        SendbirdUI.connect { [weak self] user, error in
            self?.loadingIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = true
            
            if let user = user {
                UserDefaults.saveUserID(userID)
                UserDefaults.saveNickname(nickname)
                
                print("SendbirdUIKit.connect: \(user)")
                self?.isSignedIn = true
                self?.updateUnreadCount()
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                    let payload = appDelegate.pendingNotificationPayload {
                    self?.startChatAction(with: payload)
                    appDelegate.pendingNotificationPayload = nil
                }
            }
        }
    }
    
    func signOutAction() {
        SendbirdUI.unregisterPushToken { success in
            SendbirdUI.disconnect { [weak self] in
                print("SendbirdUIKit.disconnect")
                self?.isSignedIn = false
            }
        }
    }
    
    func startChatAction(type: ButtonType) {
        if type == .startChatWithVC {
            let mainVC = SBUGroupChannelListViewController()
            let naviVC = UINavigationController(rootViewController: mainVC)
            naviVC.modalPresentationStyle = .fullScreen
            present(naviVC, animated: true)
        }
        else if type == .startChatWithTC {
            let mainVC = MainChannelTabbarController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
        }
    }
    
    func startChatAction(with payload: NSDictionary) {
        guard let channel: NSDictionary = payload["channel"] as? NSDictionary,
              let channelURL: String = channel["channel_url"] as? String else { return }
        
        let mainVC = SBUGroupChannelListViewController()
        let naviVC = UINavigationController(rootViewController: mainVC)
        naviVC.modalPresentationStyle = .fullScreen
        self.present(naviVC, animated: true) {
            SendbirdUI.moveToChannel(channelURL: channelURL)
        }
    }
    
    func startOpenChatAction(type: ButtonType) {
        guard type == .startOpenChatWithTC else { return }
        
        let mainVC = MainOpenChannelTabbarController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
    }
    
    func startChatBotAction(type: ButtonType) {
        guard type == .startChatBotWithVC else { return }
        
        SendbirdUI.startChatWithAIBot(botId: "client_bot", isDistinct: true)
    }
    
    func moveToCustomSamples() {
        SBUTheme.set(theme: .light)
        let mainVC = CustomBaseViewController(style: .grouped)
        let naviVC = UINavigationController(rootViewController: mainVC)
        naviVC.modalPresentationStyle = .fullScreen
        present(naviVC, animated: true)
    }
}


extension ViewController: UINavigationControllerDelegate {
     public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ViewController: UserEventDelegate {
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32, totalCountByCustomType: [String : Int]?) {
        self.setUnreadMessageCount(unreadCount: Int32(totalCount))
    }
}

extension ViewController: ConnectionDelegate {
    func didSucceedReconnection() {
        self.updateUnreadCount()
    }
}
