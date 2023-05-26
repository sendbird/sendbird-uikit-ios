//
//  SBUVoiceFileInfo.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/02/08.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This is a structure that has the essential information of a voice message such as file name, file path, play time and so on.
public class SBUVoiceFileInfo: NSObject {
    // for send message
    var fileName: String?
    var filePath: URL?
    
    // for play
    var playtime: Double?
    var currentPlayTime: Double = 0 // ms
    var isPlaying: Bool = false
    
    init(fileName: String? = nil,
         filePath: URL? = nil,
         playtime: Double? = nil,
         currentPlayTime: Double = 0) {
        super.init()
        
        self.fileName = fileName
        self.filePath = filePath
        self.playtime = playtime
        self.currentPlayTime = currentPlayTime
    }
    
    /// Creates voice file info with `FileMessage` object
    /// - Parameter message: `FileMessage` object
    /// - Returns: ``SBUVoiceFileInfo`` obejct; If the `message` is not the *voice* message, it returns `nil`
    public static func createVoiceFileInfo(with message: FileMessage) -> SBUVoiceFileInfo? {
        if SBUUtils.getFileType(by: message) == .voice {
            var playtime: Double = 0
            let metaArrays = message.metaArrays(keys: [SBUConstant.voiceMessageDurationKey])
            if metaArrays.count > 0 {
                let value = metaArrays[0].value[0]
                playtime = Double(value) ?? 0
            }
            
            return SBUVoiceFileInfo(
                fileName: SBUStringSet.VoiceMessage.fileName,
                playtime: playtime
            )
        }
        
        return nil
    }
}
