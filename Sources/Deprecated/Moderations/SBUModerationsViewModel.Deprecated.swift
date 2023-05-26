//
//  SBUModerationsViewModel.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/07/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

extension SBUModerationsViewModel {
    // MARK: - 3.1.0
    @available(*, unavailable, message: "This function has been seperated. If you have channel object, use `init(channel:delegate:)` instead. or if you have channelUrl, use `init(channelURL:channelType:delegate:) instead.")
    convenience init(
        channel: GroupChannel? = nil,
        channelURL: String? = nil,
        delegate: SBUModerationsViewModelDelegate? = nil
    ) {
        self.init(channelURL: "", channelType: .group, delegate: delegate)
    }
}
