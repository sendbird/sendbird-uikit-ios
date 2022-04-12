//
//  Data+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 5/5/21.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import AVFoundation

extension Data {
    func getAVAsset() -> AVAsset? {
        let directory = NSTemporaryDirectory()
        let fileName = "\(NSUUID().uuidString).mov"
        if let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName]) {
            try? self.write(to: fullURL)
            let asset = AVAsset(url: fullURL)
            return asset
        }
        return nil
    }
}
