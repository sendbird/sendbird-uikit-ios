//
//  SBUBaseChannelSettingsViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUBaseChannelSettingsViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the context of channel has been changed.
    func baseChannelSettingsViewModel(
        _ viewModel: SBUBaseChannelSettingsViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    )
    
    /// Called when the channel settings should dismiss
    /// - Parameters:
    ///   - viewModel: `SBUBaseChannelSettingsViewModel` object
    ///   - channel: channel object. If you want to move to the channel view, put the channel object or empty the channel object to go to the channel list.
    func baseChannelSettingsViewModel(
        _ viewModel: SBUBaseChannelSettingsViewModel,
        shouldDismissForChannelSettings channel: BaseChannel?
    )
}

open class SBUBaseChannelSettingsViewModel: NSObject {
    
    // MARK: - Logic properties (Public)
    public internal(set) var channel: BaseChannel?
    public internal(set) var channelURL: String?
    
    public var isOperator: Bool {
        if let groupChannel = self.channel as? GroupChannel {
            return groupChannel.myRole == .operator
        } else if let openChannel = self.channel as? OpenChannel {
            guard let userId = SBUGlobals.currentUser?.userId else { return false }
            return openChannel.isOperator(userId: userId)
        }
        return false
    }
    
    // MARK: - Logic properties (Private)
    weak var baseDelegate: SBUBaseChannelSettingsViewModelDelegate?
    
    // MARK: - LifeCycle
    public override init() {
        super.init()
    }
    
    deinit {
        self.baseDelegate = nil
    }
    
    // MARK: - Channel related
    
    /// This function loads channel information.
    /// - Parameter channelURL: channel url
    public func loadChannel(channelURL: String) { }
    
    /// This function loads channel information.
    /// - Parameters:
    ///   - channelURL: channel url
    ///   - type: channel type
    public func loadChannel(channelURL: String, type: ChannelType) {
        self.baseDelegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            guard let self = self else { return }
            defer { self.baseDelegate?.shouldUpdateLoadingState(false) }
            
            if let error = error {
                self.baseDelegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((BaseChannel?, SBError?) -> Void) = {
                    [weak self] channel, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.baseDelegate?.didReceiveError(error, isBlocker: false)
                    } else if let channel = channel {
                        self.channel = channel
                        
                        let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                        self.baseDelegate?.baseChannelSettingsViewModel(
                            self,
                            didChangeChannel: channel,
                            withContext: context
                        )
                    }
                }
                
                switch type {
                case .group:
                    GroupChannel.getChannel(url: channelURL, completionHandler: completionHandler)
                case .open:
                    OpenChannel.getChannel(url: channelURL, completionHandler: completionHandler)
                default:
                    break
                }
            }
        }
    }
    
    /// Used to update the channel name or cover image. `channelName` and` coverImage` are used for updating only the set values.
    /// - Parameters:
    ///   - channelName: Channel name to update
    ///   - coverImage: Cover image to update
    public func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) { }
}

// MARK: - BaseChannelDelegate
extension SBUBaseChannelSettingsViewModel: BaseChannelDelegate {
    public func channelWasChanged(_ channel: BaseChannel) {
        self.channel = channel
        
        let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
        self.baseDelegate?.baseChannelSettingsViewModel(
            self,
            didChangeChannel: channel,
            withContext: context
        )
    }
    open func channelDidUpdateOperators(_ channel: BaseChannel) {
        if let channel = self.channel as? GroupChannel {
            if channel.myRole != .operator {
                self.baseDelegate?.baseChannelSettingsViewModel(self, shouldDismissForChannelSettings: channel)
                return
            }
        } else if let channel = self.channel as? OpenChannel {
            let userId = SBUGlobals.currentUser?.userId ?? ""
            if !channel.isOperator(userId: userId) {
                self.baseDelegate?.baseChannelSettingsViewModel(self, shouldDismissForChannelSettings: channel)
                return
            }
        }
    }
    
    public func channel(_ channel: BaseChannel, userWasBanned user: RestrictedUser) {
        guard let userId = SBUGlobals.currentUser?.userId,
              user.userId == userId else { return }
        
        self.baseDelegate?.baseChannelSettingsViewModel(self, shouldDismissForChannelSettings: nil)
    }
    
    public func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {
        self.baseDelegate?.baseChannelSettingsViewModel(self, shouldDismissForChannelSettings: nil)
    }
}
