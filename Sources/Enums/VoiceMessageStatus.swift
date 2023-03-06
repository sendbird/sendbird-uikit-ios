//
//  VoiceMessageStatus.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/02/27.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation

enum VoiceMessageStatus {
    case none // shows play icon
    case loading // loading
    case prepared // play
    case playing // pause icon
    case pause // shows play icon
    case finishPlaying // shows play icon
}
