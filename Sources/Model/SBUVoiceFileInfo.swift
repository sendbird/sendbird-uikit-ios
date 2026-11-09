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
            return SBUVoiceFileInfo(
                fileName: SBUStringSet.VoiceMessage.fileName,
                playtime: playtime(of: message)
            )
        }
        
        return nil
    }
    
    /// 음성 메시지 metaArray의 재생 시간(ms)을 읽습니다.
    /// 값이 없거나 비었거나 숫자가 아니거나 NaN, 무한대, 음수, `Int` 밀리초로 바꿀 수 없을 만큼 큰 값이면 0입니다.
    /// (보낼 때 `sendVoiceMessage`가 이 값을 `Int` 밀리초로 바꿉니다.)
    static func playtime(of message: BaseMessage) -> Double {
        guard let value = message.metaArrays(keys: [SBUConstant.voiceMessageDurationKey]).first?.value.first else { return 0 }
        guard let playtime = Double(value),
              playtime.isFinite,
              playtime >= 0,
              playtime < Double(Int.max) else {
            // 값은 있는데 쓸 수 없어 0으로 보여 주는 경우입니다. 「00:00으로 보인다」는 문의에서 metadata 문제인지 알 수 있게 남깁니다.
            // 셀을 그릴 때마다 여러 번 읽히므로 같은 메시지는 한 번만 남깁니다.
            if markInvalidPlaytimeLogged(messageId: message.messageId) {
                logWarning("[SBUVoiceFileInfo] Invalid voice message duration \"\(value)\" in message \(message.messageId). Using 0.")
            }
            return 0
        }
        return playtime
    }
    
    /// 경고를 남기는 함수. 테스트가 남긴 횟수를 셀 수 있게 바꿔 끼웁니다.
    static var logWarning: (String) -> Void = { Log.warning($0) }
    
    /// 이미 경고를 남긴 메시지 ID. 잘못된 값이 든 메시지만 들어갑니다.
    static var loggedInvalidPlaytimes = Set<Int64>()
    /// 기록 개수 상한. 다 차면 비우고 다시 시작하므로, 그 뒤 같은 메시지가 한 번 더 남을 수 있습니다.
    static let loggedInvalidPlaytimesLimit = 1_000
    private static let loggedInvalidPlaytimesLock = NSLock()
    
    /// 처음 보는 메시지면 기록하고 `true`를 돌려줍니다.
    static func markInvalidPlaytimeLogged(messageId: Int64) -> Bool {
        loggedInvalidPlaytimesLock.lock()
        defer { loggedInvalidPlaytimesLock.unlock() }
        if loggedInvalidPlaytimes.count >= loggedInvalidPlaytimesLimit, !loggedInvalidPlaytimes.contains(messageId) {
            loggedInvalidPlaytimes.removeAll()
        }
        return loggedInvalidPlaytimes.insert(messageId).inserted
    }
}
