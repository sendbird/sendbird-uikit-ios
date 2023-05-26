//
//  SBUVoiceContentView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/02/05.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// The ``SBUBaseFileContentView`` that displays the voice message
open class SBUVoiceContentView: SBUBaseFileContentView {
    /// The view that shows the progress of how long the voice message is being played for.
    /// - Since: 3.4.0
    public var progressView = UIProgressView(progressViewStyle: .bar)
    /// The `UILabel` displaying the current playing time of the voice message.
    /// - Since: 3.4.0
    public var progressTimeLabel = UILabel()
    /// The `UIButton` displaying either `iconPlay` or `iconPause` to show the playing status of the voice message.
    /// - Since: 3.4.0
    public var statusButton = UIButton()
    /// The essential information of a voice message such as file name, file path, play time and so on.
    /// - Since: 3.4.0
    public var voiceFileInfo: SBUVoiceFileInfo?
    
    var currentPlayTime: TimeInterval = 0
    var status: VoiceMessageStatus = .none
    
    var needSetBackgroundColor: Bool = false
    
    var rotationLayer: CAAnimation = {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.1
        rotation.repeatCount = Float.infinity
        return rotation
    }()
    
    // MARK: - Properties (Private)
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    open override func setupViews() {
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        // Progress
        self.progressView.progress = 0
        self.progressTimeLabel.text = SBUUtils.convertToPlayTime(0)
        self.progressView.addSubview(self.progressTimeLabel)
        
        self.statusButton.isUserInteractionEnabled = false
        
        self.progressView.addSubview(self.progressTimeLabel)
        self.progressView.addSubview(self.statusButton)
        
        self.addSubview(self.progressView)
    }
    
    open override func setupLayouts() {
        self.sbu_constraint(height: 44)
        self.sbu_constraint(width: 136, priority: .defaultLow)
        
        self.progressView.sbu_constraint(
            equalTo: self,
            leading: 0,
            trailing: 0,
            top: 0,
            bottom: 0
        )
        
        self.progressTimeLabel.sbu_constraint(
            equalTo: self.progressView,
            trailing: -12,
            centerY: 0
        )
        
        self.statusButton
            .sbu_constraint(equalTo: self.progressView, leading: 12, centerY: 0)
            .sbu_constraint(width: 28, height: 28)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        if self.needSetBackgroundColor {
            self.backgroundColor = self.theme.parentInfoProgressBackgroundColor
        }
        
        self.progressView.trackTintColor = .clear
        self.progressTimeLabel.font = self.theme.progressTimeFont
        
        self.statusButton.roundCorners(corners: .allCorners, radius: 28/2)
    }
    
    open func configure(message: FileMessage, position: MessagePosition, voiceFileInfo: SBUVoiceFileInfo?) {
        super.configure(message: message, position: position)
        
        self.voiceFileInfo = voiceFileInfo
        if self.voiceFileInfo == nil {
            self.reset()
        }
            
        if let currentPlayTime = self.voiceFileInfo?.currentPlayTime, currentPlayTime != 0 {
            if self.voiceFileInfo?.isPlaying == false {
                self.updateVoiceContentStatus(.pause, time: currentPlayTime)
            } else {
                self.updateVoiceContentStatus(.playing, time: currentPlayTime)
            }
        } else {
            self.reset()
        }
        
        self.layoutIfNeeded()
    }
    
    func reset() {
        let metaArrays = message.metaArrays(keys: [SBUConstant.voiceMessageDurationKey])
        if metaArrays.count > 0 {
            let value = metaArrays[0].value[0]
            self.updateVoiceContentStatus(.none, time: Double(value) ?? 0)
        } else {
            self.updateVoiceContentStatus(.none)
        }
        
        self.statusButton.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
    }
    
    func updateVoiceContentStatus(_ status: VoiceMessageStatus, time: TimeInterval? = nil) {
        self.status = status
        
        self.voiceFileInfo?.isPlaying = (self.status == .playing)
        
        self.updateProgress(with: status, time: time)
        self.updateStatusButton(with: status)
    }
    
    func updateProgress(with status: VoiceMessageStatus, time: TimeInterval? = nil) {
        self.progressView.progressTintColor = self.theme.progressTrackTintColor
        
        switch self.position {
        case .left, .center:
            self.progressTimeLabel.textColor =  self.theme.progressTimeLeftTextColor
        case .right:
            self.progressTimeLabel.textColor =  self.theme.progressTimeRightTextColor
        }
        
        let time = time ?? 0
        self.progressTimeLabel.text = SBUUtils.convertToPlayTime(time)
        
        var progress: Float = 0
        
        switch self.status {
        case .none:
            break
        case .loading:
            break
        case .prepared:
            break
        case .playing:
            let remainingTime = (self.voiceFileInfo?.playtime ?? 0) - time
            self.progressTimeLabel.text = SBUUtils.convertToPlayTime(remainingTime)
            let playtime = self.voiceFileInfo?.playtime ?? 1.0
            progress = Float(time / playtime)
            break
        case .pause:
            let remainingTime = (self.voiceFileInfo?.playtime ?? 0) - time
            self.progressTimeLabel.text = SBUUtils.convertToPlayTime(remainingTime)
            let playtime = self.voiceFileInfo?.playtime ?? 1.0
            progress = Float(time / playtime)
            break
        case .finishPlaying:
            break
        }
        
        self.progressView.progress = progress
    }
    
    func updateStatusButton(with status: VoiceMessageStatus) {
        var statusImage = UIImage()
        var needToSpin = false
        
        switch status {
        case .none:
            statusImage = SBUIconSetType.iconPlay.image(
                with: self.theme.playerPlayButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .loading:
            statusImage = SBUIconSetType.iconSpinner.image(
                with: self.theme.playerLoadingButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            needToSpin = true
            
        case .prepared:
            statusImage = SBUIconSetType.iconPlay.image(
                with: self.theme.playerPlayButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .playing:
            statusImage = SBUIconSetType.iconPause.image(
                with: self.theme.playerPauseButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .pause:
            statusImage = SBUIconSetType.iconPlay.image(
                with: self.theme.playerPlayButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .finishPlaying:
            statusImage = SBUIconSetType.iconPlay.image(
                with: self.theme.playerPlayButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
        }
        
        self.statusButton.backgroundColor = self.theme.playerStatusButtonBackgroundColor
        self.statusButton.setImage(statusImage, for: .normal)
        
        if needToSpin {
            self.statusButton.layer.add(self.rotationLayer, forKey: SBUAnimation.Key.spin.identifier)
        } else {
            self.statusButton.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
        }
    }
}
