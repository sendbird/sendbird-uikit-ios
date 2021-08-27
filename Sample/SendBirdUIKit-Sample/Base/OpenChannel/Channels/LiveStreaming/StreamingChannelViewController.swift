//
//  StreamingChannelViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/17.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
class StreamingChannelViewController: SBUOpenChannelViewController {
    // MARK: - UI Components
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(onClickClose),
            for: .touchUpInside
        )
        return button
    }()
    lazy var hideMessageListButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(onClickHideMessageList),
            for: .touchUpInside
        )
        return button
    }()
    lazy var translucentView = UIView()
    lazy var layoutGuideView = UIView()
    lazy var activeIndicator = UIView()
    lazy var liveLabel = UILabel()
    lazy var participantCountLabel = UILabel()
    lazy var liveInfoHStack: UIStackView = {
        let liveInfoHStack = UIStackView()
        liveInfoHStack.spacing = 8.0
        liveInfoHStack.axis = .horizontal
        return liveInfoHStack
    }()
    
    // MARK: - Properties
    var streamingData: StreamingChannel
    var isMessageListHidden: Bool = false {
        didSet { self.hideMessageList(hidden: isMessageListHidden) }
    }
    let activeIndicatorSize: CGFloat = 10
    var prevNewMessageInfoViewHidden: Bool = true
    
    init(channel: SBDOpenChannel, streamingData: StreamingChannel) {
        self.streamingData = streamingData
        super.init(channel: channel, messageListParams: nil)
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        /// `setupAutolayout` and `setupStyles` will be called in `super.loadView()
        /// Please add sub views before `super.loadView()`
        
        self.mediaView.contentMode = .scaleAspectFill
        self.mediaView.clipsToBounds = true
        
        self.activeIndicator.clipsToBounds = true
        
        self.liveInfoHStack.addArrangedSubview(self.liveLabel)
        self.liveInfoHStack.addArrangedSubview(self.participantCountLabel)
        
        self.mediaView.addSubview(self.translucentView)
        
        self.translucentView.addSubview(self.layoutGuideView)
        
        self.layoutGuideView.addSubview(self.activeIndicator)
        self.layoutGuideView.addSubview(self.liveInfoHStack)
        self.layoutGuideView.addSubview(self.closeButton)
        self.layoutGuideView.addSubview(self.hideMessageListButton)
        
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configure()
        self.translucentView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickMediaView(_:)))
        self.mediaView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        
        if self.currentOrientation != UIDevice.current.orientation {
            NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    // MARK: - SBUOpenChannelViewController
    
    // This method will be called inside of `super.loadView`
    override func setupAutolayout() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        self.overlayMediaView(isLandscape,
                              messageListRatio: isLandscape ? 0.4 : 0.7)
        super.setupAutolayout()
        
        self.setupLiveInfo()
    }
    
    // When it received event of the device orientation,
    // `updateAutolayout` and `updateStyles` methods will be called.
    override func updateAutolayout() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        if self.currentOrientation == .portrait {
            self.isMessageListHidden = false
        }
        
        if self.currentOrientation != .portraitUpsideDown {
            self.overlayMediaView(isLandscape,
                                  messageListRatio: isLandscape ? 0.4 : 0.7)
            super.updateAutolayout()
        }
        
        self.setupLiveInfo()
    }
    
    // This method will be called inside of `super.loadView`
    override func setupStyles() {
        super.setupStyles()
        
        self.mediaView.backgroundColor = .black
        
        self.closeButton.setImage(
            SBUIconSet.iconClose
                .sbu_with(tintColor: SBUColorSet.ondark01),
            for: .normal
        )
        
        let buttonIcon = self.isMessageListHidden
            ? UIImage(named: "iconChatShow")?
                .sbu_with(tintColor: SBUColorSet.ondark01)
            : UIImage(named: "iconChatHide")?
                .sbu_with(tintColor: SBUColorSet.ondark01)
        self.hideMessageListButton.setImage(
            buttonIcon,
            for: .normal
        )
        
        self.translucentView.backgroundColor = SBUColorSet.onlight03
        
        self.activeIndicator.backgroundColor = .red
        self.activeIndicator.layer.cornerRadius = self.activeIndicatorSize / 2
        
        self.liveLabel.font = SBUFontSet.body3
        self.liveLabel.textColor = SBUColorSet.ondark01
        
        self.participantCountLabel.font = SBUFontSet.body2
        self.participantCountLabel.textColor = SBUColorSet.ondark01
    }
    
    // MARK: - Methods
    func setupLiveInfo() {
        self.translucentView
            .sbu_constraint(equalTo: self.mediaView,
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0)
        
        self.layoutGuideView
            .sbu_constraint_equalTo(
                leadingAnchor: self.translucentView.layoutMarginsGuide.leadingAnchor,
                leading: 0
            )
            .sbu_constraint_equalTo(
                topAnchor: self.translucentView.layoutMarginsGuide.topAnchor,
                top: 0
            )
            .sbu_constraint_equalTo(
                trailingAnchor: self.translucentView.trailingAnchor,
                trailing: 30
            )
            .sbu_constraint_equalTo(
                bottomAnchor: self.translucentView.layoutMarginsGuide.bottomAnchor,
                bottom: 0
            )
        
        self.activeIndicator
            .sbu_constraint(equalTo: self.layoutGuideView, left: 0)
            .sbu_constraint(equalTo: self.liveInfoHStack, centerY: 0)
            .sbu_constraint(width: activeIndicatorSize,
                            height: activeIndicatorSize)
        
        // Top left corner
        self.closeButton
            .sbu_constraint(equalTo: self.layoutGuideView,
                            left: 0,
                            top: 2)
            .sbu_constraint(width: 24,
                            height: 24)
        
        // Bottom left corner
        self.liveInfoHStack
            .sbu_constraint(equalTo: self.layoutGuideView,
                            bottom: 10)
            .sbu_constraint_equalTo(leadingAnchor: self.activeIndicator.trailingAnchor,
                                    leading: 4)
            .sbu_constraint(height: 16)
        
        self.liveLabel
            .sbu_constraint(height: 16)
        
        self.participantCountLabel
            .sbu_constraint_equalTo(leadingAnchor: self.liveLabel.trailingAnchor,
                                    leading: 4)
            .sbu_constraint(height: 16)
        
        // Bottom right corner
        self.hideMessageListButton
            .sbu_constraint(equalTo: self.layoutGuideView,
                            bottom: 10)
            .sbu_constraint(equalTo: self.channelInfoView,
                            left: -44)
            .sbu_constraint(width: 24,
                            height: 24)
    }
    
    func configure() {
        guard let mediaView = mediaView as? UIImageView else { return }
        mediaView.updateImage(urlString: streamingData.liveChannelURL)
        
        self.liveLabel.text = "LIVE"
        
        guard let channel = self.channel else { return }
        switch channel.participantCount {
            case 1...: self.participantCountLabel.text = SBUStringSet.Open_Channel_Participants_Count(channel.participantCount)
            default: self.participantCountLabel.text = SBUStringSet.Open_Channel_Participants
        }
    }
    
    // MARK: - OpenChannelSettings
    override func showParticipantsList() {
        self.navigationController?.navigationBar.isHidden = false
        super.showParticipantsList()
    }
    
    // MARK: - Actions
    @objc
    func onClickClose() {
        if let channel = self.channel {
            self.exitChannel(channel)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func onClickHideMessageList() {
        self.isMessageListHidden.toggle()
    }
    
    // MARK: Gesture actions
    @objc
    func onClickMediaView(_ sender: UITapGestureRecognizer? = nil) {
        if self.messageInputView.textView?.isFirstResponder == false {
            self.showLiveInfo(shown: self.translucentView.isHidden)
        } else {
            self.dismissKeyboard()
        }
    }
    
    func hideMessageList(hidden: Bool) {
        guard self.isMediaViewEnabled else { return }
        guard self.isMediaViewOverlaying else { return }
        let offsetX = hidden ? self.tableView.frame.width : -self.tableView.frame.width
        
        self.channelInfoView.isHidden = hidden
        self.tableView.isHidden = hidden
        self.messageInputView.isHidden = hidden
        
        if hidden {
            self.prevNewMessageInfoViewHidden = self.newMessageInfoView?.isHidden ?? true
        }
        self.newMessageInfoView?.isHidden = hidden
            ? true :
            self.prevNewMessageInfoViewHidden
        
        self.hideMessageListButton.frame = self.hideMessageListButton
            .frame
            .offsetBy(dx: offsetX, dy: 0)
    }
    
    func showLiveInfo(shown: Bool) {
        self.translucentView.isHidden = !shown
    }
    
    /// Exits the channel.
    /// - Parameters:
    ///   - channel: Channel to exit
    ///   - completionHandler: Completion handler
    func exitChannel(_ channel: SBDOpenChannel,
                            completionHandler: ((Bool)-> Void)? = nil) {
        
        channel.exitChannel { error in
            guard error == nil else {
                completionHandler?(false)
                return
            }
            completionHandler?(true)
        }
    }
    
    override func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        super.channel(sender, userDidEnter: user)
        self.configure()
    }
    
    override func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        super.channel(sender, userDidExit: user)
        self.configure()
    }
}
