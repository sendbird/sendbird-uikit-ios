//
//  SBUModerationsViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK


public protocol SBUModerationsViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the channel has been changed.
    func moderationsViewModel(
        _ viewModel: SBUModerationsViewModel,
        didChangeChannel channel: SBDBaseChannel?,
        withContext context: SBDMessageContext
    )
}


open class SBUModerationsViewModel {
    
    // MARK: - Property (Public)
    public private(set) var channel: SBDGroupChannel?
    public private(set) var channelUrl: String?
    
    
    // MARK: - Property (Private)
    weak var delegate: SBUModerationsViewModelDelegate?
    
    
    // MARK: - Lifecycle
    init(
        channel: SBDGroupChannel? = nil,
        channelUrl: String? = nil,
        delegate:SBUModerationsViewModelDelegate? = nil
    ) {
        
        self.delegate = delegate
        
        if let channel = channel {
            self.channel = channel
            self.channelUrl = channel.channelUrl
        } else if let channelUrl = channelUrl {
            self.channelUrl = channelUrl
        }
        
        guard let channelUrl = channelUrl else { return }
        self.loadChannel(channelUrl: channelUrl)
    }
    
    
    // MARK: - Channel related
    
    /// This function is used to load channel.
    /// - Parameters:
    ///   - channelUrl: channel url
    public func loadChannel(channelUrl: String) {
        self.delegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.shouldUpdateLoadingState(false)
                self.delegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((SBDGroupChannel?, SBDError?) -> Void) = {
                    [weak self] channel, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    } else if let channel = channel {
                        self.channel = channel
                        
                        let context = SBDMessageContext()
                        context.source = .eventChannelChanged
                        self.delegate?.moderationsViewModel(
                            self,
                            didChangeChannel: channel,
                            withContext: context
                        )
                    }
                }
                
                SBDGroupChannel.getWithUrl(channelUrl, completionHandler: completionHandler)
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
                let context = SBDMessageContext()
                context.source = .eventChannelFrozen
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
                let context = SBDMessageContext()
                context.source = .eventChannelUnfrozen
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
