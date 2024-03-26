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

/// `SBUModerationsViewModel` is an open class that manages the channel data for the moderation view.
open class SBUModerationsViewModel {
    
    // MARK: - Property (Public)
    /// The `BaseChannel` object that represents the channel.
    public private(set) var channel: BaseChannel?
    
    /// The URL of the channel as a `String`.
    public private(set) var channelURL: String?
    
    /// The type of the channel, represented as a `ChannelType`.
    public private(set) var channelType: ChannelType = .group
    
    // MARK: - Property (Private)
    weak var delegate: SBUModerationsViewModelDelegate?
    
    // MARK: - Lifecycle
    /// Initializes a new `SBUModerationsViewModel` instance.
    ///
    /// This initializer takes a `BaseChannel` and an optional `SBUModerationsViewModelDelegate`.
    ///
    /// - Parameters:
    ///   - channel: The `BaseChannel` to be managed by the view model.
    ///   - delegate: An optional `SBUModerationsViewModelDelegate` to handle events. Default is `nil`.
    public init(channel: BaseChannel, delegate: SBUModerationsViewModelDelegate? = nil) {
        self.delegate = delegate
        
        self.channelType = (channel is GroupChannel) ? .group : .open
        self.channel = channel
        self.channelURL = channel.channelURL
        
        guard let channelURL = self.channelURL else { return }
        self.loadChannel(channelURL: channelURL)
    }
    
    /// Initializes a new `SBUModerationsViewModel` instance with a channel URL and type.
    ///
    /// - Parameters:
    ///   - channelURL: The URL of the channel to be managed by the view model.
    ///   - channelType: The type of the channel, represented as a `ChannelType`.
    ///   - delegate: An optional `SBUModerationsViewModelDelegate` to handle events. Default is `nil`.
    public init(
        channelURL: String,
        channelType: ChannelType, 
        delegate: SBUModerationsViewModelDelegate? = nil
    ) {
        self.delegate = delegate
        
        self.channelType = channelType
        self.channelURL = channelURL
        
        self.loadChannel(channelURL: channelURL)
    }
    
    // MARK: - Channel related
    
    /// This function is used to load channel.
    /// - Parameters:
    ///   - channelURL: channel url
    public func loadChannel(channelURL: String) {
        self.delegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.shouldUpdateLoadingState(false)
                self.delegate?.didReceiveError(error, isBlocker: false)
            } else {
                if self.channelType == .group {
                    self.loadGroupChannel(channelURL: channelURL)
                } else if self.channelType == .open {
                    self.loadOpenChannel(channelURL: channelURL)
                }
            }
        }
    }
    
    private func loadGroupChannel(channelURL: String) {
        let completionHandler: ((GroupChannel?, SBError?) -> Void) = { [weak self] channel, error in
            guard let self = self else { return }
            
            defer { self.delegate?.shouldUpdateLoadingState(false) }
            
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
    
    private func loadOpenChannel(channelURL: String) {
        let completionHandler: ((OpenChannel?, SBError?) -> Void) = { [weak self] channel, error in
            guard let self = self else { return }
            
            defer { self.delegate?.shouldUpdateLoadingState(false) }
            
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
        
        OpenChannel.getChannel(url: channelURL, completionHandler: completionHandler)
    }
    
    // MARK: - Channel actions
    /// This function freezes the channel. (Group channel)
    /// - Parameter completionHandler: completion handler of freeze status change
    public func freezeChannel(_ completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel as? GroupChannel else { return }
        
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
    
    /// This function unfreezes the channel. (Group channel)
    /// - Parameter completionHandler: completion handler of freeze status change
    public func unfreezeChannel(_ completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel as? GroupChannel else { return }
        
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
