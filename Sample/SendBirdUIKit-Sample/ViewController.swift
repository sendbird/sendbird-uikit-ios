//
//  ViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 11/03/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

enum ButtonType: Int {
    case signIn
    case startChatWithVC
    case startChatWithTC
    case startOpenChatWithTC
    case signOut
    case customSamples
}

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var logoStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var signInStackView: UIStackView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    
    @IBOutlet weak var homeStackView: UIStackView!
    @IBOutlet weak var startChatWithViewControllerButton: UIButton!
    @IBOutlet weak var startChatWithTabbarControllerButton: UIButton!
    @IBOutlet weak var startOpenChatWithTabbarControllerButton: UIButton!
    @IBOutlet weak var customSamplesButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var groupChannelShadowView: UIView!
    @IBOutlet weak var groupChannelBaseView: UIView!
    @IBOutlet weak var openChannelShadowView: UIView!
    @IBOutlet weak var openChannelBaseView: UIView!
    @IBOutlet weak var customSampleShadowView: UIView!
    @IBOutlet weak var customSamplesBaseView: UIView!
    
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
                self.signInStackView.isHidden = self.isSignedIn
                self.signInStackView.alpha = self.isSignedIn ? 0 : 1
                self.logoStackView.isHidden = self.isSignedIn
                self.logoStackView.alpha = self.isSignedIn ? 0 : 1
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
        
        startChatWithViewControllerButton.tag = ButtonType.startChatWithVC.rawValue
        startChatWithTabbarControllerButton.tag = ButtonType.startChatWithTC.rawValue
        startOpenChatWithTabbarControllerButton.tag = ButtonType.startOpenChatWithTC.rawValue
        customSamplesButton.tag = ButtonType.customSamples.rawValue
        
        homeStackView.alpha = 0
         
        [userIdTextField, nicknameTextField].forEach {
            guard let textField = $0 else { return }
            let paddingView = UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: 16,
                height: textField.frame.size.height)
            )
            textField.leftView = paddingView
            textField.delegate = self
            textField.leftViewMode = .always
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = CornerRadius.small.rawValue
            textField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            textField.tintColor = #colorLiteral(red: 0.4666666667, green: 0.337254902, blue: 0.8549019608, alpha: 1)
        }
        
        [signInButton,
         signOutButton].forEach {
            $0?.layer.cornerRadius = CornerRadius.small.rawValue
        }
        
        [groupChannelBaseView,
         openChannelBaseView,
         customSamplesBaseView]
            .forEach {
                $0?.layer.cornerRadius = CornerRadius.large.rawValue
            }
        
        [groupChannelShadowView,
         openChannelShadowView,
         customSampleShadowView].forEach {
            $0?.layer.cornerRadius = CornerRadius.large.rawValue
            $0?.layer.shadowRadius = CornerRadius.large.rawValue
            $0?.layer.shadowOffset.height = 8.0
            $0?.layer.shadowOpacity = 0.12
        }
        
        [signOutButton].forEach {
            $0?.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.88)
            $0?.layer.borderWidth = 1
        }
        
        unreadCountLabel.textColor = SBUColorSet.ondark01
        unreadCountLabel.font = SBUFontSet.caption1
        unreadCountLabel.backgroundColor = SBUColorSet.error300
        unreadCountLabel.layer.cornerRadius = unreadCountLabel.frame.height / 2
        unreadCountLabel.layer.masksToBounds = true
 
        UserDefaults.saveIsLightTheme(true)
        
        let coreVersion: String = SBDMain.getSDKVersion()
        var uikitVersion: String {
            if SBUMain.shortVersion == "[NEXT_VERSION]" {
                let bundle = Bundle(identifier: "com.sendbird.uikit.sample")
                return "\(bundle?.infoDictionary?["CFBundleShortVersionString"] ?? "")"
            } else {
                return SBUMain.shortVersion
            }
        }
        versionLabel.text = "UIKit v\(uikitVersion)\t|\tSDK v\(coreVersion)"
         
        userIdTextField.text = UserDefaults.loadUserID()
        nicknameTextField.text = UserDefaults.loadNickname()
        
        SBDMain.add(self as SBDUserEventDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
        
        guard userIdTextField.text != nil,
              nicknameTextField.text != nil else { return }
        signinAction()
    }
    
    deinit {
        SBDMain.removeUserEventDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    func updateUnreadCount() {
        SBDMain.getTotalUnreadMessageCount { [weak self] totalCount, error in
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
        
        SBUGlobals.CurrentUser = SBUUser(userId: userID, nickname: nickname)
        SBUMain.connect { [weak self] user, error in
            self?.loadingIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = true
            
            if let user = user {
                UserDefaults.saveUserID(userID)
                UserDefaults.saveNickname(nickname)
                
                print("SBUMain.connect: \(user)")
                self?.isSignedIn = true
                
                self?.updateUnreadCount()
            }
        }
    }
    
    func signOutAction() {
        SBUMain.unregisterPushToken { success in
            SBUMain.disconnect { [weak self] in
                print("SBUMain.disconnect")
                self?.isSignedIn = false
            }
        }
    }
    
    func startChatAction(type: ButtonType) {
        if type == .startChatWithVC {
            let mainVC = SBUChannelListViewController()
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
    
    func startOpenChatAction(type: ButtonType) {
        if type == .startOpenChatWithTC {
            let mainVC = MainOpenChannelTabbarController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
        }
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

extension ViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: SBDUserEventDelegate {
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32, totalCountByCustomType: [String : NSNumber]?) {
        self.setUnreadMessageCount(unreadCount: Int32(totalCount))
    }
}

extension ViewController: SBDConnectionDelegate {
    func didSucceedReconnection() {
        self.updateUnreadCount()
    }
}
