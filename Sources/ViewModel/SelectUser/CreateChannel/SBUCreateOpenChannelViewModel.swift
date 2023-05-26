//
//  SBUCreateOpenChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/25.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUCreateOpenChannelViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when it has created channel
    func createOpenChannelViewModel(
        _ viewModel: SBUCreateOpenChannelViewModel,
        didCreateChannel channel: BaseChannel?
    )
}

open class SBUCreateOpenChannelViewModel {
    
    // MARK: - Property (Private)
    weak var delegate: SBUCreateOpenChannelViewModelDelegate?
    @SBUAtomic private var isLoading = false
    
    // MARK: - Life Cycle
    public init(delegate: SBUCreateOpenChannelViewModelDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - Create Channel
    
    /// Creates the channel with channel name and cover image..
    /// - Parameters:
    ///   - channelName: Channel name
    ///   - coverImage: Cover image
    public func createChannel(channelName: String, coverImage: UIImage?) {
        let params = OpenChannelCreateParams()
        params.name = channelName
        params.coverImage = coverImage?.jpegData(compressionQuality: 0.5)
        if let currentUser = SBUGlobals.currentUser {
            params.operatorUserIds = [currentUser.userId]
        }

        SBUGlobalCustomParams.openChannelParamsCreateBuilder?(params)
        self.createChannel(params: params)
    }
    
    /// Creates the channel with params.
    ///
    /// You can create a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `OpenChannelCreateParams` class object
    public func createChannel(params: OpenChannelCreateParams) {
        SBULog.info("[Request] Create open channel")
        
        self.delegate?.shouldUpdateLoadingState(true)
        
        OpenChannel.createChannel(params: params) { [weak self] channel, error in
            defer { self?.delegate?.shouldUpdateLoadingState(false) }
            guard let self = self else { return }

            if let error = error {
                SBULog.error("""
                    [Failed] Create open channel request:
                    \(String(error.localizedDescription))
                    """)
                self.delegate?.didReceiveError(error)
                return
            }

            SBULog.info("[Succeed] Create open channel: \(channel?.description ?? "")")
            self.delegate?.createOpenChannelViewModel(self, didCreateChannel: channel)
        }
    }

    // MARK: - Common
//    open func updateChannelInfoView(coverImage: UIImage) {
//        self.coverImage = coverImage
//    }
}
