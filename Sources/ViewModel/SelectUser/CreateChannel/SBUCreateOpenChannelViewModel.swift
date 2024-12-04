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

/// `SBUCreateOpenChannelViewModel` is a class that handles the creation of open channels.
open class SBUCreateOpenChannelViewModel {
    
    // MARK: - Property (Private)
    weak var delegate: SBUCreateOpenChannelViewModelDelegate?
    @SBUAtomic private var isLoading = false
    
    // MARK: SwiftUI (Internal)
    var delegates = WeakDelegateStorage<SBUCreateOpenChannelViewModelDelegate>()
        
    // MARK: - Life Cycle
    /// Initializes a new instance of `SBUCreateOpenChannelViewModel`.
    /// - Parameter delegate: An optional delegate that conforms to `SBUCreateOpenChannelViewModelDelegate`.
    required public init(delegate: SBUCreateOpenChannelViewModelDelegate?) {
        self.delegate = delegate
        self.delegates.addDelegate(delegate, type: .uikit)
    }
    
    // MARK: - Create Channel
    
    /// Creates the channel with channel name and cover image..
    /// - Parameters:
    ///   - channelName: Channel name
    ///   - coverImage: Cover image
    open func createChannel(channelName: String, coverImage: UIImage?) {
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
    open func createChannel(params: OpenChannelCreateParams) {
        SBULog.info("[Request] Create open channel")
        
        self.delegates.forEach {$0.shouldUpdateLoadingState(true) }
        
        OpenChannel.createChannel(params: params) { [weak self] channel, error in
            defer { self?.delegates.forEach {$0.shouldUpdateLoadingState(false) } }
            guard let self = self else { return }

            if let error = error {
                SBULog.error("""
                    [Failed] Create open channel request:
                    \(String(error.localizedDescription))
                    """)
                self.delegates.forEach {$0.didReceiveError(error) }
                return
            }

            SBULog.info("[Succeed] Create open channel: \(channel?.description ?? "")")
            self.delegates.forEach {$0.createOpenChannelViewModel(self, didCreateChannel: channel) }
        }
    }

    // MARK: - Common
//    open func updateChannelInfoView(coverImage: UIImage) {
//        self.coverImage = coverImage
//    }
}
