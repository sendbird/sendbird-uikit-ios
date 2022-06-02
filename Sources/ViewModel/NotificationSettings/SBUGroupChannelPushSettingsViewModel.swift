//
//  SBUGroupChannelPushSettingsViewModel.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

public protocol SBUGroupChannelPushSettingsViewModelDelegate: SBUBaseChannelSettingsViewModelDelegate {
    /// Called when changed push notification option
    /// - Parameters:
    ///   - viewModel: `SBUGroupChannelPushSettingsViewModel` object.
    ///   - pushTriggerOption: `SBDGroupChannelPushTriggerOption` object to change.
    func groupChannelPushSettingsViewModel(
        _ viewModel: SBUGroupChannelPushSettingsViewModel,
        didChangeNotification pushTriggerOption: SBDGroupChannelPushTriggerOption
    )
}

open class SBUGroupChannelPushSettingsViewModel: SBUBaseChannelSettingsViewModel {
    public private(set) var currentTriggerOption: SBDGroupChannelPushTriggerOption = .off

    public weak var delegate: SBUGroupChannelPushSettingsViewModelDelegate? {
        get { self.baseDelegate as? SBUGroupChannelPushSettingsViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public init(
        channel: SBDBaseChannel? = nil,
        channelUrl: String? = nil,
        delegate: SBUGroupChannelPushSettingsViewModelDelegate? = nil
    ) {
        super.init()

        self.delegate = delegate

        if let channel = channel {
            self.channel = channel
            self.channelUrl = channel.channelUrl
        } else if let channelUrl = channelUrl {
            self.channelUrl = channelUrl
        }
        
        self.updateChannelPushTriggerOption()
    }
    
    
    open func changeNotification(_ pushTriggerOption: SBDGroupChannelPushTriggerOption) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        guard self.currentTriggerOption != pushTriggerOption else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        groupChannel.setMyPushTriggerOption(pushTriggerOption) { [weak self] error in
            guard let self = self else { return }
            self.delegate?.shouldUpdateLoadingState(false)
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            
            if let channel = self.channel {
                let context = SBDMessageContext()
                context.source = .eventChannelChanged
                self.delegate?.baseChannelSettingsViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
                self.updateChannelPushTriggerOption()
            }
        }
    }
    
    public func updateChannelPushTriggerOption() {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        if channel.myPushTriggerOption == .default {
            SBDMain.getPushTriggerOption { [weak self] pushTriggerOption, error in
                guard let self = self else { return }
                guard error == nil else {
                    SBULog.error(error?.description)
                    return
                }
                
                switch pushTriggerOption {
                case .all:
                    self.currentTriggerOption = .all
                case .mentionOnly:
                    self.currentTriggerOption = .mentionOnly
                case .off:
                    self.currentTriggerOption = .off
                default:
                    self.currentTriggerOption = .off
                }

                self.delegate?.groupChannelPushSettingsViewModel(
                    self,
                    didChangeNotification: self.currentTriggerOption
                )
            }
        } else {
            self.currentTriggerOption = channel.myPushTriggerOption
            self.delegate?.groupChannelPushSettingsViewModel(
                self,
                didChangeNotification: self.currentTriggerOption
            )
        }
    }
}

