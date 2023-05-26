//
//  SBUVoiceMessageInputView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/01/31.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

public protocol SBUVoiceMessageInputViewDelegate: AnyObject {
    /// Called when tapped cancel button on ``SBUVoiceMessageInputView``.
    /// - Parameter inputView: ``SBUVoiceMessageInputView`` instance
    func voiceMessageInputViewDidTapCacel(_ inputView: SBUVoiceMessageInputView)
    
    /// Called when the recorder is going to start to record
    /// - Parameters:
    ///   - inputView: ``SBUVoiceMessageInputView`` object
    ///   - voiceFileInfo: ``SBUVoiceFileInfo`` object
    func voiceMessageInputView(_ inputView: SBUVoiceMessageInputView, willStartToRecord voiceFileInfo: SBUVoiceFileInfo)
    
    /// Called when tapped send button on ``SBUVoiceMessageInputView``.
    /// - Parameters:
    ///   - inputView: ``SBUVoiceMessageInputView`` object
    ///   - voiceFileInfo: ``SBUVoiceFileInfo`` object
    func voiceMessageInputView(_ inputView: SBUVoiceMessageInputView, didTapSend voiceFileInfo: SBUVoiceFileInfo)
}

/// This class is used to record voice message
/// - Since: 3.4.0
public class SBUVoiceMessageInputView: NSObject, SBUViewLifeCycle {
    enum Status {
        case none // record icon
        case recording // stop icon
        case finishRecording // play icon
        case playing // pause icon
        case pause // play icon
        case finishPlaying // start icon
    }

    // MARK: - UI properties
    /// The theme object that is type of `SBUVoiceMessageInputTheme`. It's used in `SBUVoiceMessageInputView`.
    @SBUThemeWrapper(theme: SBUTheme.voiceMessageInputTheme)
    public var theme: SBUVoiceMessageInputTheme

    var canvasView = UIView()
    
    var baseView = UIView()
    var overlayView = UIButton()
    var contentView = UIView()
    
    var progressView = UIProgressView(progressViewStyle: .bar)
    var progressTimeLabel = UILabel()
    var progressRecordingIcon = UIImageView()
    
    var cancelButton = UIButton()
    var statusButton = UIButton()
    var sendButton = UIButton()
    
    // MARK: - Logic properties (Private)
    weak var delegate: SBUVoiceMessageInputViewDelegate?

    var isSendButtonEnabled = false
    var status: Status = .none
    
    var voiceRecorder: SBUVoiceRecorder?
    var voicePlayer: SBUVoicePlayer?
    var voiceFileInfo: SBUVoiceFileInfo?
    
    var recordingTime: TimeInterval = 0
    var currentPlayTime: TimeInterval = 0

    var prevOrientation: UIDeviceOrientation = .unknown
    
    var isShowing = false

    // MARK: - UIKit View Lifecycle
    public override init() {
        super.init()
    }
    
    deinit {
        self.dismiss()
    }
    
    // MARK: SBUViewLifeCycle
    public func setupViews() {
        self.voiceRecorder = SBUVoiceRecorder(delegate: self)
        self.voicePlayer = SBUVoicePlayer(delegate: self)
        
        // Orientation
        self.prevOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        // BaseView
        self.baseView.frame = self.canvasView.bounds
        self.baseView.addSubview(self.overlayView)
        self.baseView.addSubview(self.contentView)
        
        // Progress
        self.progressView.progress = 0.0
        self.progressTimeLabel.text = SBUUtils.convertToPlayTime(0)
        self.progressView.addSubview(self.progressTimeLabel)
        self.progressView.addSubview(self.progressRecordingIcon)
        self.contentView.addSubview(self.progressView)
        
        // Buttons
        self.cancelButton.addTarget(self, action: #selector(onTapCancel), for: .touchUpInside)
        self.statusButton.addTarget(self, action: #selector(onTapStatus), for: .touchUpInside)
        self.sendButton.addTarget(self, action: #selector(onTapSend), for: .touchUpInside)
        self.sendButton.isEnabled = self.isSendButtonEnabled
        
        self.contentView.addSubview(self.cancelButton)
        self.contentView.addSubview(self.statusButton)
        self.contentView.addSubview(self.sendButton)
        
        self.canvasView.addSubview(self.baseView)
    }
    
    public func setupLayouts() {
//        guard let window = UIApplication.shared.currentWindow else { return }
        
        self.baseView.frame = self.canvasView.bounds
        
        self.overlayView.sbu_constraint(
            equalTo: self.baseView,
            leading: 0,
            trailing: 0,
            top: 0,
            bottom: 0
        )
        
        // contentView
        self.contentView
            .sbu_constraint(equalTo: self.baseView, leading: 0, trailing: 0, bottom: 0)
            .sbu_constraint(height: 134)
        
        // progress
        self.progressView
            .sbu_constraint(equalTo: self.contentView, leading: 16, trailing: -16, top: 24)
            .sbu_constraint(height: 36)
        
        self.progressTimeLabel
            .sbu_constraint(equalTo: self.progressView, trailing: -16)
            .sbu_constraint(equalTo: self.progressView, centerY: 0)
        
        self.progressRecordingIcon
            .sbu_constraint(width: 12, height: 12)
            .sbu_constraint_equalTo(
                trailingAnchor: self.progressTimeLabel.leadingAnchor, trailing: -6,
                centerYAnchor: self.progressTimeLabel.centerYAnchor, centerY: 0
            )
        
        // Button
        self.cancelButton.sbu_constraint(equalTo: self.contentView, leading: 28, bottom: 24)
        
        self.statusButton
            .sbu_constraint(equalTo: self.contentView, bottom: 24, centerX: 0)
            .sbu_constraint(width: 34, height: 34)
        
        self.sendButton
            .sbu_constraint(equalTo: self.contentView, trailing: -16, bottom: 24)
            .sbu_constraint(width: 34, height: 34)
    }
    
    public func updateLayouts() {
        self.setupLayouts()
    }
    
    public func setupStyles() {
        self.overlayView.backgroundColor = self.theme.overlayColor
        
        self.contentView.backgroundColor = self.theme.backgroundColor
        self.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
        
        // Progress
        self.progressView.progressTintColor = self.theme.progressTintColor
        self.progressView.roundCorners(corners: .allCorners, radius: 36/2)
        self.progressTimeLabel.font = self.theme.progressTimeFont
        self.progressRecordingIcon.backgroundColor = self.theme.progressRecordingIconTintColor
        self.progressRecordingIcon.roundCorners(corners: .allCorners, radius: 12/2)
        self.updateProgress(with: self.status)
        
        // Buttons
        self.cancelButton.setTitle(SBUStringSet.VoiceMessage.Input.cancel, for: .normal)
        self.cancelButton.setTitleColor(self.theme.cancelTitleColor, for: .normal)
        self.cancelButton.titleLabel?.font = self.theme.cancelTitleFont
        
        self.statusButton.backgroundColor = self.theme.statusButtonBackgroundColor
        self.statusButton.roundCorners(corners: .allCorners, radius: 34/2)
        self.updateStatusButton(with: self.status)
        
        self.sendButton.roundCorners(corners: .allCorners, radius: 34/2)
        self.updateSendButton(with: self.status)
    }
    
    public func updateStyles() {
        self.setupStyles()
    }
    
    // MARK: Progress & Status
    func updateVoiceMessageInputStatus(_ status: Status, time: TimeInterval? = nil) {
        self.status = status
        
        self.updateProgress(with: status, time: time)
        self.updateStatusButton(with: status)
        self.updateSendButton(with: status)
    }
    
    func updateProgress(with status: Status, time: TimeInterval? = nil) {
        self.progressRecordingIcon.isHidden = true
        self.progressView.trackTintColor = self.theme.progressTrackTintColor
        self.progressTimeLabel.textColor = self.theme.progressTimeColor

        let time = time ?? 0
        self.progressTimeLabel.text = SBUUtils.convertToPlayTime(time)
        
        var progress: Float = 0
        
        switch self.status {
        case .none:
            self.progressView.trackTintColor = self.theme.progressTrackDeactivatedTintColor
            self.progressTimeLabel.textColor = self.theme.progressDeactivatedTimeColor

            break
        case .recording:
            if Float(Int(time) / 1000) > 0.1 {
                progress = Float(time / SBUGlobals.voiceMessageConfig.recorder.maxRecordingTime)
            }
            let isEvenSeconds = Int(time / 1000) % 2 == 1
            self.progressRecordingIcon.isHidden = isEvenSeconds
            break
        case .finishRecording:
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
    
    func updateStatusButton(with status: Status) {
        var statusImage = UIImage()
        
        switch status {
        case .none:
            statusImage = SBUIconSetType.iconRecording.image(
                with: self.theme.recordingButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            self.isSendButtonEnabled = false
            
        case .recording:
            statusImage = SBUIconSetType.iconStop.image(
                with: self.theme.stopButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .finishRecording:
            statusImage = SBUIconSetType.iconPlay.image(
                with: self.theme.playButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .playing:
            statusImage = SBUIconSetType.iconPause.image(
                with: self.theme.pauseButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .pause:
            statusImage = SBUIconSetType.iconPlay.image(
                with: self.theme.playButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
            
        case .finishPlaying:
            statusImage = SBUIconSetType.iconPlay.image(
                with: self.theme.playButtonTintColor,
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            )
        }
        
        self.statusButton.backgroundColor = self.theme.statusButtonBackgroundColor
        self.statusButton.setImage(statusImage, for: .normal)
    }
    
    func updateSendButton(with status: Status) {
        self.isSendButtonEnabled = true
        
        if (status == .none) || (self.recordingTime < 1000) {
            self.isSendButtonEnabled = false
        }
        
        let isEnabled = self.isSendButtonEnabled
        self.sendButton.isEnabled = isEnabled
        self.sendButton.backgroundColor = isEnabled
            ? self.theme.sendButtonBackgroundColor
            : self.theme.sendButtonDisabledBackgroundColor
        self.sendButton.setImage(
            SBUIconSetType.iconSend.image(
                with: (isEnabled ? self.theme.sendButtonTintColor : self.theme.sendButtonDisabledTintColor),
                to: SBUIconSetType.Metric.iconVoiceMessageSize
            ),
            for: .normal
        )
    }
    
    public func setupActions() {
        
    }
    
    // MARK: - Show/Dismiss
    
    func show(delegate: SBUVoiceMessageInputViewDelegate, canvasView: UIView?) {
        self.dismiss()
        
        self.delegate = delegate
        
        if let canvasView = canvasView {
            self.canvasView = canvasView
        } else if let window = UIApplication.shared.currentWindow {
            self.canvasView = window
        }
        
        self.setupViews()
        self.setupStyles()
        self.setupLayouts()
        self.setupActions()
        
        self.baseView.isHidden = false
        
        self.isShowing = true
    }
    
    func dismiss() {
        self.baseView.isHidden = true
        for subView in self.baseView.subviews {
            subView.removeFromSuperview()
        }
        self.baseView.removeFromSuperview()
        
        self.status = .none
        
        self.isShowing = false

        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    func reset(for resignActivity: Bool = false) {
        let lastStatus = self.status
        
        if !resignActivity {
            self.isSendButtonEnabled = false
            
            self.voiceFileInfo = nil
            
            self.recordingTime = 0
            self.currentPlayTime = 0
            
            self.status = .none
            
            self.voiceRecorder?.resetRecorder()
        
            switch lastStatus {
            case .none, .recording: break
            default: self.voicePlayer?.resetPlayer()
            }
            return
        }
        
        switch lastStatus {
        case .none, .recording:
            self.voiceRecorder?.resetRecorder()
            self.updateVoiceMessageInputStatus(.none)
        case .playing, .pause:
            self.voicePlayer?.pause()
            self.updateVoiceMessageInputStatus(.pause, time: self.currentPlayTime)
        default:
            self.voicePlayer?.resetPlayer()
        }
    }

    // MARK: - Actions
    
    @objc func onTapCancel() {
        self.reset()
        self.delegate?.voiceMessageInputViewDidTapCacel(self)
    }
    
    @objc func onTapStatus() {
        switch self.status {
        case .none:
            // Record
            if self.voiceRecorder?.record() ?? false {
                self.updateVoiceMessageInputStatus(.recording)
            }

        case .recording:
            // Stop; If the recording time is to short, resets
            if self.recordingTime < 1000 {
                self.voiceRecorder?.resetRecorder()
                self.updateVoiceMessageInputStatus(.none)
            } else {
                self.voiceRecorder?.stop()
                self.updateVoiceMessageInputStatus(.finishRecording)
            }
            
        case .finishRecording:
            // Play
            self.voicePlayer?.play()
//            self.updateVoiceContentStatus(.playing)
            
        case .playing:
            // Pause
            self.voicePlayer?.pause()
//            self.updateVoiceContentStatus(.pause, time: self.currentPlayTime)
            
        case .pause:
            // Play again
//            self.updateVoiceContentStatus(.playing, time: self.currentPlayTime)
            self.voicePlayer?.play(fromTime: self.currentPlayTime)
            
        case .finishPlaying:
            // Play
            self.voicePlayer?.play()
            self.updateVoiceMessageInputStatus(.playing)
        }
    }
    
    @objc func onTapSend() {
        if self.status == .none { return }
        
        if self.status == .recording {
            self.voiceRecorder?.stop()
        }
        if self.status == .playing || self.status == .pause {
            self.voicePlayer?.stop()
        }
        
        if self.voiceFileInfo?.playtime == nil {
            self.voiceFileInfo?.playtime = self.voiceRecorder?.currentRecordingTime
        }
        
        if let voiceFileInfo = self.voiceFileInfo {
            self.delegate?.voiceMessageInputView(self, didTapSend: voiceFileInfo)
        }
        self.reset()
    }
    
    // MARK: - Orientation
    @objc
    func orientationChanged(_ notification: NSNotification) {
        let currentOrientation = UIDevice.current.orientation
        
        if prevOrientation.isPortrait && currentOrientation.isLandscape ||
            prevOrientation.isLandscape && currentOrientation.isPortrait {
        }

        self.prevOrientation = currentOrientation
        
        self.updateLayouts()
    }
}

// MARK: - SBUVoiceRecorderDelegate
extension SBUVoiceMessageInputView: SBUVoiceRecorderDelegate {
    public func voiceRecorderDidReceiveError(_ recorder: SBUVoiceRecorder, errorStatus: VoiceRecorderErrorStatus) {
        self.updateVoiceMessageInputStatus(.none)
    }
    public func voiceRecorderDidUpdateRecordPermission(_ recorder: SBUVoiceRecorder, granted: Bool) {
        self.dismiss()
    }
    
    public func voiceRecorderDidPrepare(_ recorder: SBUVoiceRecorder, voiceFileInfo: SBUVoiceFileInfo) {
        self.voiceFileInfo = voiceFileInfo
        self.delegate?.voiceMessageInputView(self, willStartToRecord: voiceFileInfo)
    }
    
    public func voiceRecorderDidUpdateRecordTime(_ recorder: SBUVoiceRecorder, time: TimeInterval) {
        self.recordingTime = time
        self.updateVoiceMessageInputStatus(.recording, time: time)
    }
    
    public func voiceRecorderDidFinishRecord(_ recorder: SBUVoiceRecorder, voiceFileInfo: SBUVoiceFileInfo) {
        self.voiceFileInfo = voiceFileInfo
        let time = self.voiceFileInfo?.playtime
        
        self.voicePlayer?.configure(voiceFileInfo: voiceFileInfo)
        
        self.updateVoiceMessageInputStatus(.finishRecording, time: time)
    }
}

// MARK: - SBUVoicePlayerDelegate
extension SBUVoiceMessageInputView: SBUVoicePlayerDelegate {
    public func voicePlayerDidReceiveError(_ player: SBUVoicePlayer, errorStatus: SBUVoicePlayerErrorStatus) {}
    
    public func voicePlayerDidStart(_ player: SBUVoicePlayer) {
        self.updateVoiceMessageInputStatus(.playing, time: self.currentPlayTime)
    }
    
    public func voicePlayerDidPause(_ player: SBUVoicePlayer, voiceFileInfo: SBUVoiceFileInfo?) {
        self.updateVoiceMessageInputStatus(.pause, time: self.currentPlayTime)
    }
    
    public func voicePlayerDidStop(_ player: SBUVoicePlayer) {
        let time = self.voiceFileInfo?.playtime
        self.updateVoiceMessageInputStatus(.finishPlaying, time: time)
    }
    
    public func voicePlayerDidReset(_ player: SBUVoicePlayer) {}
    
    public func voicePlayerDidUpdatePlayTime(_ player: SBUVoicePlayer, time: TimeInterval) {
        self.currentPlayTime = time
        self.updateVoiceMessageInputStatus(.playing, time: time)
    }
}
