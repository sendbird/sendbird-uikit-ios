//
//  SBUOpenChannelSettingsViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit
import SendBirdSDK

public protocol SBUOpenChannelSettingsViewModelDelegate: SBUBaseChannelSettingsViewModelDelegate {
    /// Called when the current user delete the channel.
    func openChannelSettingsViewModel(
        _ viewModel: SBUOpenChannelSettingsViewModel,
        didDeleteChannel channel: SBDOpenChannel
    )
}



open class SBUOpenChannelSettingsViewModel: SBUBaseChannelSettingsViewModel {
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUOpenChannelSettingsViewModelDelegate? {
        get { self.baseDelegate as? SBUOpenChannelSettingsViewModelDelegate }
        set { self.baseDelegate = newValue }
    }

    
    // MARK: - LifeCycle
    public init(channel: SBDBaseChannel? = nil,
         channelUrl: String? = nil,
         delegate: SBUOpenChannelSettingsViewModelDelegate? = nil) {
        super.init()
        
        self.delegate = delegate
        
        if let channel = channel {
            self.channel = channel
            self.channelUrl = channel.channelUrl
        } else if let channelUrl = channelUrl {
            self.channelUrl = channelUrl
        }

        self.loadChannel(channelUrl: self.channelUrl)
    }

    
    // MARK: - Channel related
    public override func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        self.loadChannel(channelUrl: channelUrl, type: .open)
    }
    
    public override func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) {
        let channelParams = SBDOpenChannelParams()
        
        channelParams.name = channelName
        
        if let coverImage = coverImage {
            channelParams.coverImage = coverImage.jpegData(compressionQuality: 0.5)
        } else {
            channelParams.coverUrl = self.channel?.coverUrl
        }
        
        SBUGlobalCustomParams.openChannelParamsUpdateBuilder?(channelParams)

        self.updateChannel(params: channelParams)
    }
    
    /// Updates the channel with channelParams.
    ///
    /// You can update a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `SBDOpenChannelParams` class object
    public func updateChannel(params: SBDOpenChannelParams) {
        guard let openChannel = self.channel as? SBDOpenChannel else { return }
        
        SBULog.info("[Request] Channel update")
        self.delegate?.shouldUpdateLoadingState(true)
        
        openChannel.update(with: params) { [weak self] channel, error in
            defer { self?.delegate?.shouldUpdateLoadingState(false) }
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            } else if let channel = channel {
                self.channel = channel
                
                let context = SBDMessageContext()
                context.source = .eventChannelChanged
                self.delegate?.baseChannelSettingsViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
            }
        }
    }
    
    /// Deletes the channel.
    public func deleteChannel() {
        guard let openChannel = self.channel as? SBDOpenChannel else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        
        openChannel.delete { [weak self] error in
            guard let self = self else { return }
            
            self.delegate?.shouldUpdateLoadingState(false)
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            
            self.channel = nil
            
            self.delegate?.openChannelSettingsViewModel(self, didDeleteChannel: openChannel)
        }
    }
}
