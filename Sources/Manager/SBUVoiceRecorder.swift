//
//  SBUVoiceRecorder.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/12/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation

// TODO: Voice -> SBU prefix
/// This is an enumeration for voice recorder status.
public enum VoiceRecorderStatus: Int {
    case none
    case prepared
    case recording
    case completed
}

/// This is an enumeration for voice recorder error status.
public enum VoiceRecorderErrorStatus: Int {
    case none
    case fileCreation
    case audioSessionSetting
    case recorderPreparation
    case record
    case finishRecording
    case recorderEncodeError
}

public protocol SBUVoiceRecorderDelegate: AnyObject {
    /// Called when the error was received.
    /// - Parameters:
    ///   - recorder: `SBUVoiceRecorder` object.
    ///   - errorStatus: `VoiceRecorderErrorStatus`.
    func voiceRecorderDidReceiveError(_ recorder: SBUVoiceRecorder, errorStatus: VoiceRecorderErrorStatus)
    
    /// Called when the recorder was prepared
    /// - Parameters:
    ///   - recorder: `SBUVoiceRecorder` object.
    ///   - voiceFileInfo: Prepared voice file info object.
    func voiceRecorderDidPrepare(_ recorder: SBUVoiceRecorder, voiceFileInfo: SBUVoiceFileInfo)
    
    /// Called when the permission was updated.
    /// - Parameters:
    ///   - recorder: `SBUVoiceRecorder` object.
    ///   - granted: `true` when permission was granted.
    func voiceRecorderDidUpdateRecordPermission(_ recorder: SBUVoiceRecorder, granted: Bool)
    
    /// Called when the record time was updated.
    /// - Parameters:
    ///   - recorder: `SBUVoiceRecorder` object.
    ///   - time: current record time.
    func voiceRecorderDidUpdateRecordTime(_ recorder: SBUVoiceRecorder, time: TimeInterval)
    
    /// Called when the recorder was finished.
    /// - Parameters:
    ///   - recorder: `SBUVoiceRecorder` object.
    ///   - voiceFileInfo: Recorded voice file info object.
    func voiceRecorderDidFinishRecord(_ recorder: SBUVoiceRecorder, voiceFileInfo: SBUVoiceFileInfo)
}

public class SBUVoiceRecorder: NSObject, AVAudioRecorderDelegate {
    
    // MARK: Properties
    public private(set) var status: VoiceRecorderStatus = .none
    public private(set) var progressTimer: Timer?
    
    lazy var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder?
    
    var voiceFileInfo = SBUVoiceFileInfo()
    weak var delegate: SBUVoiceRecorderDelegate?
    
    var currentRecordingTime: Double = 0 // ms
    let minRecordingTime: Double = SBUGlobals.voiceMessageConfig.recorder.minRecordingTime // 1000 ms
    let maxRecordingTime: Double = SBUGlobals.voiceMessageConfig.recorder.maxRecordingTime // 60000 ms
    
    // MARK: - Initializer
    /// Initializes `SBUVoiceRecorder` class with delegate and checkPermission.
    /// - Parameters:
    ///   - delegate: `SBUVoiceRecorderDelegate` instance.
    public init(delegate: SBUVoiceRecorderDelegate?) {
        super.init()

        self.delegate = delegate

        SBUPermissionManager.shared.requestRecordAcess(onDenied: { [weak self] in
            guard let self = self else { return }
            SBULog.error("[Failed] Request record permission")
            self.showPermissionAlert()
        })
    }
    
    deinit {
        self.audioRecorder?.stop()
        self.restoreCategory()
        self.stopProgressTimer()
        self.delegate = nil
    }
    
    func showPermissionAlert() {
        let settingButton = SBUAlertButtonItem(title: SBUStringSet.Settings) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButton = SBUAlertButtonItem(
            title: SBUStringSet.Cancel,
            completionHandler: { [weak self] _ in
                guard let self = self else { return }
                self.resetRecorder()
                self.delegate?.voiceRecorderDidUpdateRecordPermission(self, granted: false)
            }
        )
        
        SBUAlertView.show(
            title: SBUStringSet.Alert_Allow_Microphone_Access,
            oneTimetheme: SBUTheme.componentTheme,
            confirmButtonItem: settingButton,
            cancelButtonItem: cancelButton) {
                self.resetRecorder()
                self.delegate?.voiceRecorderDidUpdateRecordPermission(self, granted: false)
            }
    }
    
    // MARK: - Recorder controls
    /// Starts audio recording.
    @discardableResult
    public func record() -> Bool {
        switch SBUPermissionManager.shared.currentRecordAccessStatus {
        case .granted:
            if self.status != .prepared {
                if self.prepareToRecord() == false {
                    SBULog.error("[Failed] Recorder preparation")
                    self.status = .none
                }
            }
             
            self.status = .recording
            
            if self.audioRecorder?.record() == true {
                self.startProgressTimer()
                return true
            } else {
                self.status = .none
                SBULog.error("[Failed] Record")
                self.delegate?.voiceRecorderDidReceiveError(self, errorStatus: .record)
                return false
            }
        default:
            SBUPermissionManager.shared.requestRecordAcess(onDenied: { [weak self] in
                guard let self = self else { return }
                SBULog.error("[Failed] Request record permission")
                self.showPermissionAlert()
            })
            self.status = .none
            self.delegate?.voiceRecorderDidReceiveError(self, errorStatus: .recorderPreparation)
            return false
        }
    }
    
    // Stops audio recording.
    public func stop() {
        self.currentRecordingTime = (self.audioRecorder?.currentTime ?? 0.0) * 1000
        self.audioRecorder?.stop()
    }
    
    func restoreCategory() {
        if let storedConfig = SBUGlobals.voiceMessageConfig.storedAudioSessionConfig {
            try? self.audioSession.setCategory(
                storedConfig.category,
                mode: storedConfig.mode,
                options: storedConfig.categoryOptions
            )
            SBUGlobals.voiceMessageConfig.storedAudioSessionConfig = nil
        }
        
        // If application is using audio playback in the past, maintain the session Active True status
        if self.audioSession.category == .playback {
            try? self.audioSession.setActive(true)
        } else {
            try? self.audioSession.setActive(false)
        }
    }
    
    /// Resets audio recorder
    public func resetRecorder() {
        self.stop()
        self.stopProgressTimer()
        self.voiceFileInfo = SBUVoiceFileInfo()
        self.status = .none
        self.currentRecordingTime = 0
        self.audioRecorder?.deleteRecording()
        self.audioRecorder = nil
    }
    
    // MARK: - Preparations
    /// Settings category and active option of `AVAudioSession` and prepares `AVAudioRecorder` settings.
    /// - Returns: `true` when preparation is successful.
    func prepareToRecord() -> Bool {
        // AVAudioSession
        do {
            if SBUGlobals.voiceMessageConfig.storedAudioSessionConfig == nil {
                SBUGlobals.voiceMessageConfig.storedAudioSessionConfig = .init(
                    category: audioSession.category,
                    categoryOptions: audioSession.categoryOptions,
                    mode: audioSession.mode
                )
            }
            try self.audioSession.setCategory(.playAndRecord)
            try self.audioSession.overrideOutputAudioPort(.speaker)
            try self.audioSession.setActive(true)
        } catch {
            SBULog.error("[Failed] Audio session preparation error: \(error.localizedDescription)")
            self.delegate?.voiceRecorderDidReceiveError(self, errorStatus: .audioSessionSetting)
            return false
        }
        
        // AVAudioPlayer
        let fileName = Date().sbu_toString(
            dateFormat: SBUDateFormatSet.VoiceMessage.fileNameFormat,
            localizedFormat: false
        )
        let fileExtension = "m4a"
        let fullFileName = "\(fileName).\(fileExtension)"
        
        guard let voiceFilePath = SBUCacheManager.File.diskCache.voiceTempPath(fileName: fullFileName) else {
            SBULog.error("[Failed] Create voice file")
            self.delegate?.voiceRecorderDidReceiveError(self, errorStatus: .recorderPreparation)
            return false
        }

        let settings = SBUGlobals.voiceMessageConfig.recorder.settings
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: voiceFilePath, settings: settings)
            self.audioRecorder?.delegate = self
            self.voiceFileInfo.fileName = fullFileName
            self.voiceFileInfo.filePath = voiceFilePath
        } catch {
            SBULog.error("[Failed] Audio recorder preparation error: \(error.localizedDescription)")
            self.delegate?.voiceRecorderDidReceiveError(self, errorStatus: .recorderPreparation)
            return false
        }
        
        if self.audioRecorder?.prepareToRecord() != true {
            return false
        }
        
        SBULog.info("[Succeeded] Audio recorder preparation")
        self.status = .prepared
        self.delegate?.voiceRecorderDidPrepare(self, voiceFileInfo: self.voiceFileInfo)
        return true
    }
    
    // MARK: - Timer
    func startProgressTimer() {
        self.stopProgressTimer()
        self.progressTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateRecordTime),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopProgressTimer() {
        self.progressTimer?.invalidate()
        self.progressTimer = nil
    }
    
    @objc func updateRecordTime() {
        guard let audioRecorder = self.audioRecorder else { return }

        if audioRecorder.isRecording {
            let currentTime = audioRecorder.currentTime * 1000
            self.delegate?.voiceRecorderDidUpdateRecordTime(self, time: currentTime)
            
            if currentTime >= self.maxRecordingTime {
                self.stop()
            }
        }
    }
    
    // MARK: - AVAudioRecorderDelegate
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully success: Bool) {
        self.stopProgressTimer()
        
        if self.currentRecordingTime < self.minRecordingTime {
            SBULog.info("Recorder will be canceled because it is less than the minimum recording time.")
            self.resetRecorder()
            return
        }
        
        if success {
            self.voiceFileInfo.playtime = self.currentRecordingTime
            self.status = .completed
            self.delegate?.voiceRecorderDidFinishRecord(self, voiceFileInfo: self.voiceFileInfo)
        } else {
            SBULog.error("[Failed] Finish recording")
            self.status = .none
            self.delegate?.voiceRecorderDidReceiveError(self, errorStatus: .finishRecording)
            self.resetRecorder()
        }
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        SBULog.error("[Failed] Recorder encode error: \(error.debugDescription)")
        
        self.resetRecorder()
        
        self.delegate?.voiceRecorderDidReceiveError(self, errorStatus: .recorderEncodeError)
    }
}
