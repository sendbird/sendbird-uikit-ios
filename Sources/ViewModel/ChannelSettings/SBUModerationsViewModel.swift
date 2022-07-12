//
//  SBUModerationsViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK


public protocol SBUModerationsViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the channel has been changed.
    func moderationsViewModel(
        _ viewModel: SBUModerationsViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    )
}


open class SBUModerationsViewModel {
    
    // MARK: - Property (Public)
    public private(set) var channel: GroupChannel?
    public private(set) var channelURL: String?
    
    
    // MARK: - Property (Private)
    weak var delegate: SBUModerationsViewModelDelegate?
    
    
    // MARK: - Lifecycle
    init(
        channel: GroupChannel? = nil,
        channelURL: String? = nil,
        delegate:SBUModerationsViewModelDelegate? = nil
    ) {
        
        self.delegate = delegate
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        
        guard let channelURL = channelURL else { return }
        self.loadChannel(channelURL: channelURL)
    }
    
    
    // MARK: - Channel related
    
    /// This function is used to load channel.
    /// - Parameters:
    ///   - channelURL: channel url
    public func loadChannel(channelURL: String) {
        self.delegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.shouldUpdateLoadingState(false)
                self.delegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((GroupChannel?, SBError?) -> Void) = {
                    [weak self] channel, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    } else if let channel = channel {
                        self.channel = channel
                        
                        let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                        self.delegate?.moderationsViewModel(
                            self,
                            didChangeChannel: channel,
                            withContext: context
                        )
                    }
                }
                
                GroupChannel.getChannel(url: channelURL, completionHandler: completionHandler)
            }
        }
    }
    
    
    // MARK: - Channel actions
    /// This function freezes the channel.
    /// - Parameter completionHandler: completion handler of freeze status change
    public func freezeChannel(_ completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        
        groupChannel.freeze { [weak self] error in
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            defer { self.delegate?.shouldUpdateLoadingState(false) }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            
            if let channel = self.channel {
                let context = MessageContext(source: .eventChannelFrozen, sendingStatus: .succeeded)
                self.delegate?.moderationsViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
            }
            completionHandler?(true)
        }
    }
    
    /// This function unfreezes the channel.
    /// - Parameter completionHandler: completion handler of freeze status change
    public func unfreezeChannel(_ completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        
        groupChannel.unfreeze { [weak self] error in
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            defer { self.delegate?.shouldUpdateLoadingState(false) }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            
            if let channel = self.channel {
                let context = MessageContext(source: .eventChannelUnfrozen, sendingStatus: .succeeded)
                self.delegate?.moderationsViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
            }
            completionHandler?(true)
        }
    }
}
