//
//  SBUVoiceMessageConfiguration.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/02/27.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import AVFoundation

public class SBUVoiceMessageConfiguration {
    /// To turn on the voice message feature, set as `true`
    @available(*, deprecated, renamed: "SendbirdUI.config.groupChannel.channel.isVoiceMessageEnabled") // 3.6.0
    public var isVoiceMessageEnabled: Bool {
        get { SendbirdUI.config.groupChannel.channel.isVoiceMessageEnabled }
        set { SendbirdUI.config.groupChannel.channel.isVoiceMessageEnabled = newValue }
    }
    
    var storedAudioSessionConfig: AudioSessionConfiguration?
    
    public var player = Player()
    
    public class Player { }
    
    public var recorder = Recorder()
    
    public class Recorder {
        let minRecordingTime: Double = 1000 // ms
        let maxRecordingTime: Double = 600000 // ms
        
        public var settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 11025,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 12000
        ]
    }
    
    struct AudioSessionConfiguration {
        let category: AVAudioSession.Category
        let categoryOptions: AVAudioSession.CategoryOptions
        let mode: AVAudioSession.Mode
    }
}
