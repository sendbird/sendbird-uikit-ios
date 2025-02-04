//
//  LiveStreamChannelListViewModel.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2022/09/07.
//  Copyright © 2022 SendBird, Inc. All rights reserved.
//

import SendbirdChatSDK


/// This page shows how to customize a view model to use customized `OpenChannelListQuery` by overriding ``SBUOpenChannelListViewModel``.
/// - NOTE: To use a customized channel list query without overriding ``SBUOpenChannelListViewModel``, please refer to ``CommunityChannelListViewController``
class LiveStreamChannelListViewModel: SBUOpenChannelListViewModel {
    static let queryLimit: UInt = 20
    static let customType = "SB_LIVE_TYPE"
    
    required init(delegate: SBUOpenChannelListViewModelDelegate?, channelListQuery: OpenChannelListQuery?) {
        let params = OpenChannelListQueryParams {
            $0.limit = Self.queryLimit
            $0.customTypeFilter = Self.customType
        }
        let channelListQuery = OpenChannel.createOpenChannelListQuery(params: params)
        
        super.init(delegate: delegate, channelListQuery: channelListQuery)
    }
    
//    override func upsertChannels(_ channels: [OpenChannel]?, needReload: Bool) {
//        // Pass only the live stream channels
//        let channels = channels?.filter { $0.customType == Self.customType }
//        super.upsertChannels(channels, needReload: needReload)
//    }
}
