//
//  SBUMessageCellConfiguration.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/27.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The class for configuring message cell feature.
/// - Since: 3.2.2
public class SBUMessageCellConfiguration {
    public var groupChannel = GroupChannel()
    public var openChannel = OpenChannel()
    
    public class BaseChannel {
        /// The max width of the message cell.
        public var messageCellMaxWidth: CGFloat = SBUConstant.messageCellMaxWidth
    }
    
    public class GroupChannel: BaseChannel {
        /// The thumbnail size for the file message.
        public var thumbnailSize: CGSize = SBUConstant.thumbnailSize
        public var voiceMessageSize: CGSize = SBUConstant.voiceMessageBaseSize
    }
    
    public class OpenChannel: BaseChannel {
        /// The thumbnail size for the file message.
        public var thumbnailSize: CGSize = SBUConstant.openChannelThumbnailSize
    }
}
