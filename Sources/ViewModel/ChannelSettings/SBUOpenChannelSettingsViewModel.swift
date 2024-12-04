//
//  SBUOpenChannelSettingsViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit
import SendbirdChatSDK

public protocol SBUOpenChannelSettingsViewModelDelegate: SBUBaseChannelSettingsViewModelDelegate {
    /// Called when the current user delete the channel.
    func openChannelSettingsViewModel(
        _ viewModel: SBUOpenChannelSettingsViewModel,
        didDeleteChannel channel: OpenChannel
    )
}

open class SBUOpenChannelSettingsViewModel: SBUBaseChannelSettingsViewModel {
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUOpenChannelSettingsViewModelDelegate? {
        get { self.baseDelegate as? SBUOpenChannelSettingsViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    // MARK: SwiftUI (Internal)
    var delegates: WeakDelegateStorage<SBUOpenChannelSettingsViewModelDelegate> {
        let computedDelegates = WeakDelegateStorage<SBUOpenChannelSettingsViewModelDelegate>()
        self.baseDelegates.allKeyValuePairs().forEach { key, value in
            if let delegate = value as? SBUOpenChannelSettingsViewModelDelegate {
                computedDelegates.addDelegate(delegate, type: key)
            }
        }
        return computedDelegates
    }
    
    // MARK: - LifeCycle
    required public init(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        delegate: SBUOpenChannelSettingsViewModelDelegate? = nil
    ) {
        super.init()
        
        self.delegate = delegate
        self.baseDelegates.addDelegate(delegate, type: .uikit)
        
        SendbirdChat.addChannelDelegate(
            self,
            identifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
        )
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }

        guard let channelURL = self.channelURL else { return }
        self.initializeAndLoad(channelURL: channelURL)
    }
    
    func initializeAndLoad(channelURL: String) {
        self.channelURL = channelURL
        self.loadChannel(channelURL: channelURL)
    }
    
    deinit {
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
        )
    }
    
    // MARK: - Channel related
    public override func loadChannel(channelURL: String?) {
        guard let channelURL = channelURL else { return }
        self.loadChannel(channelURL: channelURL, type: .open)
    }
    
    public override func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) {
        let channelParams = OpenChannelUpdateParams()
        
        channelParams.name = channelName
        
        if let coverImage = coverImage {
            channelParams.coverImage = coverImage.jpegData(compressionQuality: 0.5)
        } else {
            channelParams.coverURL = self.channel?.coverURL
        }
        
        SBUGlobalCustomParams.openChannelParamsUpdateBuilder?(channelParams)

        self.updateChannel(params: channelParams)
    }
    
    /// Updates the channel with channelParams.
    ///
    /// You can update a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `OpenChannelParams` class object
    public func updateChannel(params: OpenChannelUpdateParams) {
        guard let openChannel = self.channel as? OpenChannel else { return }
        
        SBULog.info("[Request] Channel update")
        self.delegates.forEach {
            $0.shouldUpdateLoadingState(true)
        }
        
        openChannel.update(params: params) { [weak self] channel, error in
            defer { self?.delegates.forEach { $0.shouldUpdateLoadingState(false) } }
            guard let self = self else { return }
            
            if let error = error {
                self.delegates.forEach {
                    $0.didReceiveError(error, isBlocker: false)
                }
                return
            } else if let channel = channel {
                self.channel = channel
                
                let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                self.delegates.forEach {
                    $0.baseChannelSettingsViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                }
            }
        }
    }
    
    /// Deletes the channel.
    public func deleteChannel() {
        guard let openChannel = self.channel as? OpenChannel else { return }
        
        self.delegates.forEach {
            $0.shouldUpdateLoadingState(true)
        }
        
        openChannel.delete { [weak self] error in
            guard let self = self else { return }
            
            self.delegates.forEach {
                $0.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegates.forEach {
                    $0.didReceiveError(error)
                }
                return
            }
            
            self.channel = nil
            
            self.delegates.forEach {
                $0.openChannelSettingsViewModel(self, didDeleteChannel: openChannel)
            }
        }
    }
}

// MARK: OpenChannelDelegate
extension SBUOpenChannelSettingsViewModel: OpenChannelDelegate {
    open func channel(_ channel: OpenChannel, userDidEnter user: User) {
        let context =  MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
        self.baseDelegates.forEach {
            $0.baseChannelSettingsViewModel(
                self,
                didChangeChannel: channel,
                withContext: context
            )
        }
    }
    
    open func channel(_ channel: OpenChannel, userDidExit user: User) {
        let context =  MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
        self.baseDelegates.forEach {
            $0.baseChannelSettingsViewModel(
                self,
                didChangeChannel: channel,
                withContext: context
            )
        }
    }
}
