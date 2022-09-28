//
//  LiveStreamChannelViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/17.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class LiveStreamChannelViewController: SBUOpenChannelViewController, LiveStreamChannelModuleMediaDelegate, LiveStreamChannelModuleMediaDataSource {
    // A relative ratio value of the message list with ratio to entire screen.
    static var defaultRatio = 0.7
    static var overlayRatio = 0.4
    
    // MARK: - UI Components
    lazy var hideChatButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(onTapHideChatButton),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - Properties
    var liveStreamData: LiveStreamData
    var isChatHidden: Bool = false {
        didSet { self.hideChat(hidden: isChatHidden) }
    }
    var prevNewMessageInfoViewHidden: Bool = true
    var hideChatButtonTrailingConstraint: NSLayoutConstraint!
    
    init(channel: OpenChannel, liveStreamData: LiveStreamData) {
        self.liveStreamData = liveStreamData
        super.init(channel: channel, messageListParams: nil)
    }
    
    required init(channel: OpenChannel, messageListParams: MessageListParams? = nil) {
        fatalError("init(channel:messageListParams:) has not been implemented")
    }
    
    required init(channelURL: String, startingPoint: Int64 = .max, messageListParams: MessageListParams? = nil) {
        // TODO: Use View model
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    required public init(channelURL: String, startingPoint: Int64? = nil, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    
    // MARK: - View Lifecycle
    
    /// Calls customized module component's `configure` method here.
    /// Please refer to ``LiveStreamChannelModule/Media/configure(delegate:dataSource:theme:)``  in `LiveStreamChannelModule.Media`
    override func loadView() {
        super.loadView()
        
        (self.mediaComponent as? LiveStreamChannelModule.Media)?
            .configure(delegate: self, dataSource: self, theme: self.theme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        
        if self.currentOrientation != UIDevice.current.orientation {
            NotificationCenter.default
                .post(name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Sendbird UIKit Life Cycle
    override func setupViews() {
        super.setupViews()
        
        self.hideChatButton.isHidden = true
        self.view.addSubview(self.hideChatButton)
    }
    
    /// This method will be called inside of ``SBUBaseViewController/loadView()``
    override func setupLayouts() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        self.overlayMediaView(
            isLandscape,
            messageListRatio: isLandscape ? Self.overlayRatio : Self.defaultRatio
        )
        super.setupLayouts()
        
        if let listComponent = self.listComponent {
            self.hideChatButton
                .sbu_constraint(width: 24, height: 24)
                .sbu_constraint_equalTo(bottomAnchor: self.view.layoutMarginsGuide.bottomAnchor, bottom: 8)
            self.hideChatButtonTrailingConstraint = hideChatButton.trailingAnchor
                .constraint(equalTo: listComponent.leadingAnchor, constant: -20)
            self.hideChatButtonTrailingConstraint.isActive = true
        }
    }
    
    /// This method will be called inside of ``SBUBaseViewController/loadView()``
    override func setupStyles() {
        super.setupStyles()
        
        let buttonIcon = UIImage(named: self.isChatHidden ? "iconChatShow" : "iconChatHide")?
            .sbu_with(tintColor: SBUColorSet.ondark01)
        
        self.hideChatButton.setImage(
            buttonIcon,
            for: .normal
        )
    }
    
    /// When it received event of the device orientation,
    /// ``SBUOpenChannelViewController/updateLayouts()`` and ``SBUOpenChannelViewController/updateStyles()`` methods will be called.
    override func updateLayouts() {
        let isLandscape = self.currentOrientation.isLandscape
        self.mediaViewIgnoringSafeArea(isLandscape)
        if self.currentOrientation == .portrait {
            self.isChatHidden = false
        }
        
        if self.currentOrientation != .portraitUpsideDown {
            self.overlayMediaView(
                isLandscape,
                messageListRatio: isLandscape ? Self.overlayRatio : Self.defaultRatio
            )
            
            super.updateLayouts()
        }
    }
    
    // MARK: - Actions
    
    @objc func onTapHideChatButton() {
        self.isChatHidden.toggle()
        
        let buttonIcon = UIImage(named: self.isChatHidden ? "iconChatShow" : "iconChatHide")?
            .sbu_with(tintColor: SBUColorSet.ondark01)
        
        self.hideChatButton.setImage(buttonIcon, for: .normal)
    }
    
    func hideChat(hidden: Bool) {
        guard self.isMediaViewEnabled else { return }
        guard self.isMediaViewOverlaying else { return }
        
        self.headerComponent?.isHidden = hidden
        self.listComponent?.isHidden = hidden
        self.inputComponent?.isHidden = hidden
        
        if let listComponent = self.listComponent {
            self.hideChatButtonTrailingConstraint.constant = self.isChatHidden ? listComponent.frame.width - 56 : -20
            self.hideChatButton.layoutIfNeeded()
        }
    }
    
    
    // MARK: (Customization) Module Components
    
    // MARK: - Header (OpenChannelSettings)
    override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        self.navigationController?.navigationBar.isHidden = false
        super.baseChannelModule(headerComponent, didTapRightItem: rightItem)
    }
    
    // MARK: - Media (LiveStreamChannelModuleMediaDelegate)
    
    override func openChannelModule(_ mediaComponent: SBUOpenChannelModule.Media, didTapMediaView mediaView: UIView) {
        if let messageInputView = self.inputComponent?.messageInputView as? SBUMessageInputView,
            messageInputView.textView?.isFirstResponder == false {
            let mediaComponent = self.mediaComponent as? LiveStreamChannelModule.Media
            mediaComponent?.hideLiveInfo()
            self.hideChatButton.isHidden = mediaComponent?.translucentView.isHidden == true
        } else {
            self.dismissKeyboard()
        }
    }
    
    func liveStreamChannelModule(_ mediaComponent: LiveStreamChannelModule.Media, didTapCloseButton button: UIButton) {
        self.onClickBack()
    }
    
    
    // MARK: - Media (LiveStreamChannelModuleMediaDataSource)
    
    func liveStreamChannelModule(_ mediaComponent: LiveStreamChannelModule.Media, channelForMediaView mediaView: UIView) -> OpenChannel? {
        self.channel
    }
}
