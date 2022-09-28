//
//  OpenChannel+Ext.swift
//  SendbirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/22.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

extension OpenChannel {
    var liveStreamData: LiveStreamData? {
        guard let dataString = self.data else { return nil }
        guard let data = dataString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(LiveStreamData.self, from: data)
    }
}
