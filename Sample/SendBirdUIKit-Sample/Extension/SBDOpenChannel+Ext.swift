//
//  SBDOpenChannel+Ext.swift
//  SendBirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/22.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import SendBirdSDK

extension SBDOpenChannel {
    func toStreamChannel() -> StreamingChannel? {
        guard let dataString = self.data else { return nil }
        guard let data = dataString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(StreamingChannel.self, from: data)
    }
}
