//
//  MultipleFilesMessage+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/10/20.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

extension MultipleFilesMessage {
    /// Indicates the number of files of a multiple files message.
    /// - Since: 3.10.0
    public var filesCount: Int {
        if self.sendingStatus == .succeeded {
            return self.files.count
        } else {
            if let messageParam = self.messageParams as? MultipleFilesMessageCreateParams {
                return messageParam.uploadableFileInfoList.count
            } else {
                return 0
            }
        }
    }
}
