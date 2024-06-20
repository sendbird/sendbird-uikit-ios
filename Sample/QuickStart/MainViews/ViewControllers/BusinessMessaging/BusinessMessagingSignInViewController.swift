//
//  BusinessMessagingSignInViewController.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/24/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

final class BusinessMessagingSignInViewController: UIViewController {
    @IBOutlet weak var applicationIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var feedOnlySwitch: UISwitch!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.nicknameTextField.text = UserDefaults.loadNickname(type: .businessMessagingSample)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let signedApp = UserDefaults.loadSignedInSampleApp()
        if signedApp != .none {
            self.signIn()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = ViewController.CornerRadius.small.rawValue
        [applicationIdTextField, userIdTextField, nicknameTextField].forEach {
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
            textField.layer.cornerRadius = 4
            textField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            textField.tintColor = #colorLiteral(red: 0.4666666667, green: 0.337254902, blue: 0.8549019608, alpha: 1)
        }
        
        self.applicationIdTextField.text = UserDefaults.loadAppId(type: .businessMessagingSample)
        self.userIdTextField.text = UserDefaults.loadUserId(type: .businessMessagingSample)
        self.nicknameTextField.text = UserDefaults.loadNickname(type: .businessMessagingSample)
        
        self.feedOnlySwitch.isOn = UserDefaults.loadAuthType() == .authFeed
    }
    
    @IBAction func clickSelectSampleAppsButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickSignInButton(_ sender: Any) {
        self.signIn()
    }
    
    func signIn() {
        self.view.isUserInteractionEnabled = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        
        let appId = applicationIdTextField.text ?? ""
        let userId = userIdTextField.text ?? ""
        let nickname = nicknameTextField.text ?? ""

        guard !appId.isEmpty else {
            applicationIdTextField.shake()
            applicationIdTextField.becomeFirstResponder()
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
            return
        }
        
        guard !userId.isEmpty else {
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
        
        SBUGlobals.currentUser = SBUUser(
            userId: userId,
            nickname: nickname
        )
        SBUGlobals.apiHost = UserDefaults.loadAPIHost(type: .businessMessagingSample)
        SBUGlobals.wsHost = UserDefaults.loadWebsocketHost(type: .businessMessagingSample)

        SendbirdUI.initialize(
            applicationId: appId,
            initParamsBuilder: { params in
            params?.isLocalCachingEnabled = true
        },
            migrationHandler: {

        },
            completionHandler: { error in
                if self.feedOnlySwitch.isOn {
                    SendbirdUI.authenticateFeed { [weak self] user, error in
                        guard let self = self else { return }
                        
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        
                        if let user = user {
                            self.saveSignInfo(
                                appId: appId,
                                userId: userId,
                                nickname: nickname
                            )
                            UserDefaults.saveSignedSampleApp(type: .businessMessagingSample)
                            UserDefaults.saveAuthType(type: .authFeed)
                            print("SendbirdUIKit.authenticate: \(user)")

                            self.openViewController(authType: .authFeed)
                        }
                    }
                } else {
                    SendbirdUI.connect { [weak self] user, error in
                        guard let self = self else { return }
                        
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        
                        if let user = user {
                            self.saveSignInfo(
                                appId: appId,
                                userId: userId,
                                nickname: nickname
                            )

                            UserDefaults.saveSignedSampleApp(type: .businessMessagingSample)
                            UserDefaults.saveAuthType(type: .websocket)
                            print("SendbirdUIKit.connect: \(user)")

                            self.openViewController(authType: .websocket)
                        }
                    }
                }
        })
    }
    
    func saveSignInfo(appId: String, userId: String, nickname: String) {
        UserDefaults.saveAppId(type: .businessMessagingSample, appId: appId)
        UserDefaults.saveUserId(type: .businessMessagingSample, userId: userId)
        UserDefaults.saveNickname(type: .businessMessagingSample, nickname: nickname)
    }
    
    func openViewController(authType: AuthType) {
        let vc = BusinessMessagingSelectionViewController()
        vc.authType = authType
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BusinessMessagingSignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
