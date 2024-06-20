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
    case signOut
    case basicUsage
    case chatBot
    case customSample
    case businessMessagingSample
    case selectSampeApps
}

enum MainViewState: Int {
    case productList
    case basicUsage
    case chatBot
    case customSample
    case businessMessagingSample
}

enum SampleAppType: Int {
    case none = 0
    case basicUsage
    case businessMessagingSample
    case chatBot
    case customSample
}

enum AuthType: Int {
    case authFeed = 0
    case websocket
}

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var basicUsagesView: MainItemView!
    @IBOutlet weak var talkToAnAIChatbotView: MainItemView!
    @IBOutlet weak var customizationSamplesView: MainItemView!
    @IBOutlet weak var businessMessagingSampleView: MainItemView!

    @IBOutlet weak var versionLabel: UILabel!

    let duration: TimeInterval = 0.4
    
    enum CornerRadius: CGFloat {
        case small = 4.0
        case large = 8.0
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SBUTheme.set(theme: .light)
        GlobalSetCustomManager.setDefault()
        
        let signedApp = UserDefaults.loadSignedInSampleApp()
        switch signedApp {
        case .none:
            break
        case .basicUsage:
            self.openBasicUsage()
        case .businessMessagingSample:
            self.openBusinessMessagingSample()
        case .chatBot:
            self.openAIChatBot()
        case .customSample:
            self.openCustomizationSample()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.setDefaultInformation()
        self.setupButtons()
 
        UserDefaults.saveIsLightTheme(true)
        
        self.setupVersion()
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
    
    // MARK: - Actions
    @IBAction func onEditingChangeTextField(_ sender: UITextField) {
        let color = sender.text?.isEmpty ?? true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0) : #colorLiteral(red: 0.4823529412, green: 0.3254901961, blue: 0.937254902, alpha: 1)
        sender.animateBorderColor(toColor: color, duration: 0.1)
    }
    
    @IBAction func onBasicUsagesViewButton(_ sender: UIButton) {
        self.openBasicUsage()
    }
    
    @IBAction func onTalkToAnAIChatbotTapButton(_ sender: UIButton) {
        self.openAIChatBot()
    }
    
    @IBAction func onCustomizationSamplesTapButton(_ sender: UIButton) {
        self.openCustomizationSample()
    }
    
    @IBAction func onBusinessMessagingSampleTapButton(_ sender: UIButton) {
        self.openBusinessMessagingSample()
    }
    
    func openBasicUsage(with payload: NSDictionary? = nil) {
        let vc = GeneralSignInViewController()
        vc.sampleAppType = .basicUsage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openAIChatBot() {
        let vc = AIChatBotSignInViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openCustomizationSample() {
        let vc = GeneralSignInViewController()
        vc.sampleAppType = .customSample
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openBusinessMessagingSample() {
        let vc = BusinessMessagingSignInViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func moveToCustomSamples() {
        SBUTheme.set(theme: .light)
        let mainVC = CustomBaseViewController(style: .grouped)
        let naviVC = UINavigationController(rootViewController: mainVC)
        naviVC.modalPresentationStyle = .fullScreen
        present(naviVC, animated: true)
    }
    
    func setupButtons() {
        self.basicUsagesView.titleLabel.text = "Basic Usages"
        self.basicUsagesView.unreadCountLabel.isHidden = true
        self.basicUsagesView.descriptionLabel.isHidden = true
        
        self.talkToAnAIChatbotView.titleLabel.text = "Talk to an AI Chatbot"
        self.talkToAnAIChatbotView.unreadCountLabel.isHidden = true
        self.talkToAnAIChatbotView.descriptionLabel.isHidden = true
        
        self.customizationSamplesView.titleLabel.text = "Customization samples"
        self.customizationSamplesView.unreadCountLabel.isHidden = true
        self.customizationSamplesView.descriptionLabel.isHidden = true
        
        self.businessMessagingSampleView.titleLabel.text = "Business Messaging sample"
        self.businessMessagingSampleView.unreadCountLabel.isHidden = true
        self.businessMessagingSampleView.descriptionLabel.isHidden = true
        
        self.basicUsagesView.actionButton.addTarget(self, action: #selector(onBasicUsagesViewButton(_:)), for: .touchUpInside)
        self.talkToAnAIChatbotView.actionButton.addTarget(self, action: #selector(onTalkToAnAIChatbotTapButton(_:)), for: .touchUpInside)
        self.customizationSamplesView.actionButton.addTarget(self, action: #selector(onCustomizationSamplesTapButton(_:)), for: .touchUpInside)
        self.businessMessagingSampleView.actionButton.addTarget(self, action: #selector(onBusinessMessagingSampleTapButton(_:)), for: .touchUpInside)
    }
    
    func setupVersion() {
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
    }
}

extension ViewController {
    /// Sets default information for all sample types.
    func setDefaultInformation() {
        self.setDefaultBasicUsageInfo()
        self.setDefaultChatbotInfo()
        self.setDefaultCustomSampleInfo()
        self.setDefaultBusinessMessagingSampleInfo()
    }
    
    /// Sets default information for basic usage sample.
    func setDefaultBasicUsageInfo() {
        let appId = UserDefaults.loadAppId(type: .basicUsage)
        if appId == nil || appId?.count == 0 {
            UserDefaults.saveAppId(type: .basicUsage, appId: "FEA2129A-EA73-4EB9-9E0B-EC738E7EB768")
        }

//        let userId = UserDefaults.loadUserId(type: .basicUsage)
//        if userId == nil || userId?.count == 0 {
//            UserDefaults.saveUserId(type: .basicUsage, userId: "USER_ID")
//        }
//        
//        let nickname = UserDefaults.loadNickname(type: .basicUsage)
//        if nickname == nil || nickname?.count == 0 {
//            UserDefaults.saveNickname(type: .basicUsage, nickname: "NICKNAME")
//        }
//        
//        let wsHost = UserDefaults.loadWebsocketHost(type: .basicUsage)
//        if wsHost == nil || wsHost?.count == 0 {
//            UserDefaults.saveWebsocketHost(type: .basicUsage, host: "wss://ws-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
//        
//        let apiHost = UserDefaults.loadAPIHost(type: .basicUsage)
//        if apiHost == nil || apiHost?.count == 0 {
//            UserDefaults.saveAPIHost(type: .basicUsage, host: "https://api-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
    }
    
    /// Sets default information for chatbot sample.
    func setDefaultChatbotInfo() {
        let appId = UserDefaults.loadAppId(type: .chatBot)
        if appId == nil || appId?.count == 0 {
            UserDefaults.saveAppId(type: .chatBot, appId: "FEA2129A-EA73-4EB9-9E0B-EC738E7EB768")
        }
        
//        let botId = UserDefaults.loadBotId()
//        if botId == nil || botId?.count == 0 {
//            UserDefaults.saveBotId(botId: "onboarding_bot")
//        }
//
//        let userId = UserDefaults.loadUserId(type: .chatBot)
//        if userId == nil || userId?.count == 0 {
//            UserDefaults.saveUserId(type: .chatBot, userId: "USER_ID")
//        }
//        
//        let nickname = UserDefaults.loadNickname(type: .chatBot)
//        if nickname == nil || nickname?.count == 0 {
//            UserDefaults.saveNickname(type: .chatBot, nickname: "NICKNAME")
//        }
//        
//        let wsHost = UserDefaults.loadWebsocketHost(type: .chatBot)
//        if wsHost == nil || wsHost?.count == 0 {
//            UserDefaults.saveWebsocketHost(type: .chatBot, host: "wss://ws-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
//        
//        let apiHost = UserDefaults.loadAPIHost(type: .chatBot)
//        if apiHost == nil || apiHost?.count == 0 {
//            UserDefaults.saveAPIHost(type: .chatBot, host: "https://api-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
    }
    
    /// Sets default information for custom sample.
    func setDefaultCustomSampleInfo() {
        let appId = UserDefaults.loadAppId(type: .customSample)
        if appId == nil || appId?.count == 0 {
            UserDefaults.saveAppId(type: .customSample, appId: "FEA2129A-EA73-4EB9-9E0B-EC738E7EB768")
        }

//        let userId = UserDefaults.loadUserId(type: .customSample)
//        if userId == nil || userId?.count == 0 {
//            UserDefaults.saveUserId(type: .customSample, userId: "USER_ID")
//        }
//        
//        let nickname = UserDefaults.loadNickname(type: .customSample)
//        if nickname == nil || nickname?.count == 0 {
//            UserDefaults.saveNickname(type: .customSample, nickname: "NICKNAME")
//        }
//        
//        let wsHost = UserDefaults.loadWebsocketHost(type: .customSample)
//        if wsHost == nil || wsHost?.count == 0 {
//            UserDefaults.saveWebsocketHost(type: .customSample, host: "wss://ws-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
//        
//        let apiHost = UserDefaults.loadAPIHost(type: .customSample)
//        if apiHost == nil || apiHost?.count == 0 {
//            UserDefaults.saveAPIHost(type: .customSample, host: "https://api-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
    }
    
    /// Sets default information for business messaging sample.
    func setDefaultBusinessMessagingSampleInfo() {
        let appId = UserDefaults.loadAppId(type: .businessMessagingSample)
        if appId == nil || appId?.count == 0 {
            UserDefaults.saveAppId(type: .businessMessagingSample, appId: "FEA2129A-EA73-4EB9-9E0B-EC738E7EB768")
        }

//        let userId = UserDefaults.loadUserId(type: .businessMessagingSample)
//        if userId == nil || userId?.count == 0 {
//            UserDefaults.saveUserId(type: .businessMessagingSample, userId: "USER_ID")
//        }
//        
//        let nickname = UserDefaults.loadNickname(type: .businessMessagingSample)
//        if nickname == nil || nickname?.count == 0 {
//            UserDefaults.saveNickname(type: .businessMessagingSample, nickname: "NICKNAME")
//        }
//        
//        let wsHost = UserDefaults.loadWebsocketHost(type: .businessMessagingSample)
//        if wsHost == nil || wsHost?.count == 0 {
//            UserDefaults.saveWebsocketHost(type: .businessMessagingSample, host: "wss://ws-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
//        
//        let apiHost = UserDefaults.loadAPIHost(type: .businessMessagingSample)
//        if apiHost == nil || apiHost?.count == 0 {
//            UserDefaults.saveAPIHost(type: .businessMessagingSample, host: "https://api-FEA2129A-EA73-4EB9-9E0B-EC738E7EB768.sendbird.com")
//        }
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
