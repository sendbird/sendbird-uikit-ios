//
//  SBUVoicePlayer.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/01/09.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation

/// This is an enumeration for voice player error status.
public enum SBUVoicePlayerErrorStatus: Int {
    case none
    case playerInitialization
    case playerPreparation
    case play
    case pause
    case playerDecodeError
    case finishPlaying
}

public protocol SBUVoicePlayerDelegate: AnyObject {
    /// Called when the error was received.
    /// - Parameters:
    ///   - recorder: ``SBUVoicePlayer`` object.
    ///   - errorStatus: ``VoicePlayerErrorStatus``.
    func voicePlayerDidReceiveError(_ player: SBUVoicePlayer, errorStatus: SBUVoicePlayerErrorStatus)
    /// Called when the player was started to play.
    /// - Parameter recorder: ``SBUVoicePlayer`` object.
    func voicePlayerDidStart(_ player: SBUVoicePlayer)
    /// Called when the player was paused playing.
    /// - Parameters:
    ///   - recorder: ``SBUVoicePlayer`` object.
    ///   - voiceFileInfo: ``SBUVoiceFileInfo`` object.
    func voicePlayerDidPause(_ player: SBUVoicePlayer, voiceFileInfo: SBUVoiceFileInfo?)
    /// Called when the player was stop playing.
    /// - Parameter recorder: ``SBUVoicePlayer`` object.
    func voicePlayerDidStop(_ player: SBUVoicePlayer)
    /// Called when the player was reset.
    /// - Parameter recorder: ``SBUVoicePlayer`` object.
    func voicePlayerDidReset(_ player: SBUVoicePlayer)
    
    /// Called when the play time was updated.
    /// - Parameters:
    ///   - recorder: ``SBUVoicePlayer`` object.
    ///   - time: current play time.
    func voicePlayerDidUpdatePlayTime(_ player: SBUVoicePlayer, time: TimeInterval)
}

public class SBUVoicePlayer: NSObject, AVAudioPlayerDelegate {
    // MARK: Enums
    /// This is an enumeration for voice player status.
    public enum VoicePlayerStatus: Int {
        case none
        case prepared
        case playing
        case paused
        case stopped
    }
    
    // MARK: Properties
    /// (Read only) The ``VoicePlayerStatus`` value. The default is ``VoicePlayerStatus/none``
    public private(set) var status: VoicePlayerStatus = .none
    /// (Read only) The timer for voice player.
    public private(set) var progressTimer: Timer?
    
    lazy var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVAudioPlayer?
    
    var voiceFileInfo: SBUVoiceFileInfo?
    weak var delegate: SBUVoicePlayerDelegate?
    
    // MARK: - Initializer
    /// Initializes `SBUVoicePlayer` class with delegate and voiceFileInfo.
    /// - Parameters:
    ///   - delegate: `SBUVoicePlayerDelegate` instance.
    public init(delegate: SBUVoicePlayerDelegate?) {
        super.init()
        
        self.delegate = delegate
    }
    
    /// Configures player with voiceFileInfo.
    /// - Parameter voiceFileInfo: ``SBUVoiceFileInfo`` object.
    public func configure(voiceFileInfo: SBUVoiceFileInfo) {
        self.voiceFileInfo = voiceFileInfo
        
        if self.prepareToPlayer() == false {
            SBULog.error("[Failed] Player preparation")
            self.status = .none
        }
    }
    
    deinit {
        // Because it can affect other Player, Pause is only when `SBUVoicePlayer` is in use.
        guard self.status != .none else { return }
        
        self.audioPlayer?.stop()
        self.restoreCategory()
    }
    
    // MARK: - Player controls
    /// Plays voice from time. Default is `0`.
    /// - Parameter time: millisecond unit
    public func play(fromTime time: TimeInterval = 0) {
        if self.status != .prepared && self.status != .paused {
            if self.prepareToPlayer() == false {
                SBULog.error("[Failed] Player preparation")
                self.status = .none
            }
        }
        
        self.audioPlayer?.currentTime = time / 1000 // sec
        
        if self.audioPlayer?.play() == true {
            self.status = .playing
            self.startProgressTimer()
            self.delegate?.voicePlayerDidStart(self)
        } else {
            self.status = .none
            SBULog.error("[Failed] Play")
            self.delegate?.voicePlayerDidReceiveError(self, errorStatus: .play)
        }
    }
    
    /// Pauses voice
    public func pause() {
        // Because it can affect other Player, Pause is only when `SBUVoicePlayer` is in use.
        guard self.status != .none else { return }
        
        self.audioPlayer?.pause()
        self.stopProgressTimer()
        self.status = .paused
        
        self.delegate?.voicePlayerDidPause(self, voiceFileInfo: self.voiceFileInfo)
    }
    
    /// Stops voice
    public func stop() {
        self.audioPlayer?.stop()
        self.status = .stopped
        self.delegate?.voicePlayerDidStop(self)
    }
    
    /// Resets player
    public func resetPlayer() {
        self.stop()
        self.stopProgressTimer()
        self.status = .prepared
        self.voiceFileInfo?.currentPlayTime = 0
        self.delegate?.voicePlayerDidReset(self)
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
    
    // MARK: - Preparations
    func prepareToPlayer() -> Bool {
        guard let url = self.voiceFileInfo?.filePath else { return false }
        
        do {
            if SBUGlobals.voiceMessageConfig.storedAudioSessionConfig == nil {
                SBUGlobals.voiceMessageConfig.storedAudioSessionConfig = .init(
                    category: audioSession.category,
                    categoryOptions: audioSession.categoryOptions,
                    mode: audioSession.mode
                )
            }
            try self.audioSession.setCategory(.playback)
            try self.audioSession.overrideOutputAudioPort(.speaker)
            SBULog.info("AVAudioSession Category Playback OK")
            do {
                try self.audioSession.setActive(true)
                
                SBULog.info("AVAudioSession is Active")
                
            } catch let error as NSError {
                SBULog.error(error.localizedDescription)
            }
        } catch let error as NSError {
            SBULog.error(error.localizedDescription)
        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            self.status = .none
            SBULog.error("[Failed] Audio player preparation: \(error.localizedDescription)")
            self.delegate?.voicePlayerDidReceiveError(self, errorStatus: .playerPreparation)
        }
        
        self.audioPlayer?.delegate = self
        
        if self.audioPlayer?.prepareToPlay() != true {
            self.status = .none
            return false
        }
        
        SBULog.info("[Succeeded] Audio player preparation")
        self.status = .prepared
        return true
    }
    
    // MARK: - Timer
    func startProgressTimer() {
        self.stopProgressTimer()
        self.progressTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updatePlayTime),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopProgressTimer() {
        self.progressTimer?.invalidate()
        self.progressTimer = nil
    }
    
    @objc func updatePlayTime() {
        guard let audioPlayer = self.audioPlayer else { return }

        if audioPlayer.isPlaying {
            let currentTime = audioPlayer.currentTime * 1000
            if currentTime >= self.voiceFileInfo?.currentPlayTime ?? 0 {
                self.voiceFileInfo?.currentPlayTime = currentTime
                
                self.delegate?.voicePlayerDidUpdatePlayTime(self, time: self.voiceFileInfo?.currentPlayTime ?? 0)
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully success: Bool) {
        self.stopProgressTimer()
        
        if success {
            self.status = .prepared
            self.voiceFileInfo?.currentPlayTime = 0
            self.delegate?.voicePlayerDidStop(self)
        } else {
            SBULog.error("[Failed] Finish playing")
            self.status = .none
            self.delegate?.voicePlayerDidReceiveError(self, errorStatus: .finishPlaying)
            self.resetPlayer()
        }
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        SBULog.error("[Failed] Player decode error: \(error.debugDescription)")
        
        self.delegate?.voicePlayerDidReceiveError(self, errorStatus: .playerDecodeError)
        self.status = .none
        self.resetPlayer()
    }
}
