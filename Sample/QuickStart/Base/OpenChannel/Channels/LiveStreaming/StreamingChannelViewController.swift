//
//  StreamingChannelViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/17.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

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
    
    init(channel: OpenChannel, streamingData: StreamingChannel) {
        self.streamingData = streamingData
        super.init(channel: channel, messageListParams: nil)
    }
    
    required init(channel: OpenChannel, messageListParams: MessageListParams? = nil) {
        fatalError("init(channel:messageListParams:) has not been implemented")
    }
    
    required init(channelURL: String, startingPoint: Int64 = .max, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    required public init(channelURL: String, startingPoint: Int64? = nil, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    
    // MARK: - View Lifecycle
    override func loadView() {
        /// `setupAutolayout` and `setupStyles` will be called in `super.loadView()
        /// Please add sub views before `super.loadView()`
        
        self.mediaComponent?.mediaView.contentMode = .scaleAspectFill
        self.mediaComponent?.mediaView.clipsToBounds = true
        
        self.activeIndicator.clipsToBounds = true
        
        self.liveInfoHStack.addArrangedSubview(self.liveLabel)
        self.liveInfoHStack.addArrangedSubview(self.participantCountLabel)
        
        self.mediaComponent?.mediaView.addSubview(self.translucentView)
        
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
        self.mediaComponent?.mediaView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        
        if self.currentOrientation != UIDevice.current.orientation {
            NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    // MARK: - Styles & Layout
    // This method will be called inside of `super.loadView`
    override func setupLayouts() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        self.overlayMediaView(isLandscape,
                              messageListRatio: isLandscape ? 0.4 : 0.7)
        super.setupLayouts()
        
        self.setupLiveInfo()
    }
    
    // When it received event of the device orientation,
    // `updateAutolayout` and `updateStyles` methods will be called.
    override func updateLayouts() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        if self.currentOrientation == .portrait {
            self.isMessageListHidden = false
        }
        
        if self.currentOrientation != .portraitUpsideDown {
            self.overlayMediaView(isLandscape,
                                  messageListRatio: isLandscape ? 0.4 : 0.7)
            super.updateLayouts()
        }
        
        self.setupLiveInfo()
    }
    
    // This method will be called inside of `super.loadView`
    override func setupStyles() {
        super.setupStyles()
        
        self.mediaComponent?.backgroundColor = .black
        self.mediaComponent?.mediaView.backgroundColor = .clear
        
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
        if let mediaView = self.mediaComponent?.mediaView {
            self.translucentView
                .sbu_constraint(
                    equalTo: mediaView,
                    leading: 0, trailing: 0, top: 0, bottom: 0
                )
        }
        
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
        if let channelInfoView = self.headerComponent?.channelInfoView {
            self.hideMessageListButton
                .sbu_constraint(equalTo: self.layoutGuideView,
                                bottom: 10)
                .sbu_constraint(equalTo: channelInfoView,
                                left: -44)
                .sbu_constraint(width: 24,
                                height: 24)
        }
    }
    
    func configure() {
        guard let mediaView = self.mediaComponent?.mediaView as? UIImageView else { return }
        mediaView.updateImage(urlString: streamingData.liveChannelURL)
        
        self.liveLabel.text = "LIVE"
        
        guard let channel = self.channel else { return }
        switch channel.participantCount {
            case 1...: self.participantCountLabel.text = SBUStringSet.Open_Channel_Participants_Count(channel.participantCount)
            default: self.participantCountLabel.text = SBUStringSet.Open_Channel_Participants
        }
    }
    
    // MARK: - OpenChannelSettings
    override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        self.navigationController?.navigationBar.isHidden = false
        super.baseChannelModule(headerComponent, didTapRightItem: rightItem)
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
        
        let buttonIcon = self.isMessageListHidden
        ? UIImage(named: "iconChatShow")?
            .sbu_with(tintColor: SBUColorSet.ondark01)
        : UIImage(named: "iconChatHide")?
            .sbu_with(tintColor: SBUColorSet.ondark01)
        self.hideMessageListButton.setImage(
            buttonIcon,
            for: .normal
        )
    }
    
    // MARK: Gesture actions
    @objc
    func onClickMediaView(_ sender: UITapGestureRecognizer? = nil) {
        if let messageInputView = self.inputComponent?.messageInputView as? SBUMessageInputView, messageInputView.textView?.isFirstResponder == false {
            self.showLiveInfo(shown: self.translucentView.isHidden)
        } else {
            self.dismissKeyboard()
        }
    }
    
    func hideMessageList(hidden: Bool) {
        guard self.isMediaViewEnabled else { return }
        guard self.isMediaViewOverlaying else { return }
        let offsetX = hidden ? self.listComponent!.frame.width : -self.listComponent!.frame.width
        
        self.headerComponent?.isHidden = hidden
        self.listComponent?.isHidden = hidden
        self.inputComponent?.isHidden = hidden
        
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
    func exitChannel(_ channel: OpenChannel,
                     completionHandler: ((Bool)-> Void)? = nil) {
        
        channel.exit(completionHandler: { error in
            guard error == nil else {
                completionHandler?(false)
                return
            }
            completionHandler?(true)
        })
    }
}
