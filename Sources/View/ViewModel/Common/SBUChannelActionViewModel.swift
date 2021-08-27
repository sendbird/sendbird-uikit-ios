//
//  SBUChannelLoadViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK


enum ChannelChangedType : Int {
    case promote, dismiss, freeze, unfreeze, ban, unban, mute, unmute, invite, update, notification
}

typealias ChannelRequestCompletion = (SBDError?, ChannelChangedType) -> Void
typealias ChannelUpdateCompletion = (SBDBaseChannel?, SBDError?) -> Void

class SBUChannelActionViewModel: SBULoadableViewModel  {
    
    // MARK: - Properties
    private(set) var channel: SBDBaseChannel? = nil
    var channelUrl: String? {
        get { return channel?.channelUrl }
    }
    let channelLoadedObservable = SBUObservable<SBDBaseChannel>()
    let channelChangedObservable = SBUObservable<(SBDBaseChannel, ChannelChangedType)>()
    let channelDeletedObservable = SBUObservable<Void>()
    
    private lazy var channelRequestCompletion: ChannelRequestCompletion = {
        return { [weak self] error, type in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("[Failed] request: \(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.set(value: (channel, type))
            }
        }
    }()
    
    private lazy var channelUpdateCompletion: ChannelUpdateCompletion = {
        return { [weak self] channel, error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("[Failed] Channel update request:\(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
                return
            } else if let channel = channel {
                self.channel = channel
                self.channelChangedObservable.set(value: (channel, .update))
            }
        }
    }()
    
    
    // MARK: - Base Channel
    func promoteToOperator(member: SBUUser) {
        self.promoteToOperators(memberIds: [member.userId])
    }
    
    func promoteToOperators(memberIds: [String]) {
        guard let channel = self.channel else { return }
        self.loadingObservable.set(value: true)
        SBULog.info("[Request] Promote members: \(memberIds)")
        channel.addOperators(withUserIds: memberIds) { [weak self] error in
            self?.channelRequestCompletion(error, .promote)
        }
    }
    
    func dismissOperator(member: SBUUser) {
        self.dismissOperator(memberIds: [member.userId])
    }
    
    func dismissOperator(memberIds: [String]) {
        guard let channel = self.channel else { return }
        self.loadingObservable.set(value: true)
        SBULog.info("[Request] Dismiss operators: \(memberIds)")
        channel.removeOperators(withUserIds: memberIds) { [weak self] error in
            self?.channelRequestCompletion(error, .dismiss)
        }
    }
    
    func ban(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.loadingObservable.set(value: true)
            groupChannel.banUser(
                withUserId: member.userId,
                seconds: -1,
                description: nil) { [weak self] error in
                self?.channelRequestCompletion(error, .ban)
            }
        } else if let openChannel = self.channel as? SBDOpenChannel {
            openChannel.banUser(
                withUserId: member.userId,
                seconds: -1) { [weak self] error in
                self?.channelRequestCompletion(error, .ban)
            }
        }
    }
    
    func unban(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.loadingObservable.set(value: true)
            groupChannel.unbanUser(
                withUserId: member.userId) { [weak self] error in
                self?.channelRequestCompletion(error, .unban)
            }
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.loadingObservable.set(value: true)
            openChannel.unbanUser(
                withUserId: member.userId) { [weak self] error in
                self?.channelRequestCompletion(error, .unban)
            }
        }
    }
    
    func mute(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.loadingObservable.set(value: true)
            groupChannel.muteUser(withUserId: member.userId) { [weak self] error in
                self?.channelRequestCompletion(error, .mute)
            }
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.loadingObservable.set(value: true)
            openChannel.muteUser(withUserId: member.userId) { [weak self] error in
                self?.channelRequestCompletion(error, .mute)
            }
        }
    }
    
    func unmute(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.loadingObservable.set(value: true)
            groupChannel.unmuteUser(withUserId: member.userId) { [weak self] error in
                self?.channelRequestCompletion(error, .unmute)
            }
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.loadingObservable.set(value: true)
            openChannel.unmuteUser(withUserId: member.userId) { [weak self] error in
                self?.channelRequestCompletion(error, .unmute)
            }

        }
    }
    
    
    // MARK: - Group Channel
    func loadGroupChannel(with channelUrl: String) {
        self.loadingObservable.set(value: true)
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.loadingObservable.set(value: false)
                self.errorObservable.set(value: error)
            } else {
                SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                    guard let self = self else { return }
                    
                    self.loadingObservable.set(value: false)
                    if let error = error {
                        self.errorObservable.set(value: error)
                    } else if let channel = channel {
                        self.channel = channel
                        self.channelLoadedObservable.set(value: channel)
                    }
                }
            }
        }
    }
    
    func updateChannel(params: SBDGroupChannelParams) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        SBULog.info("[Request] Channel update")
        self.loadingObservable.set(value: true)
        
        groupChannel.update(
            with: params,
            completionHandler: channelUpdateCompletion
        )
    }
    
    func leaveChannel() {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        groupChannel.leave { [weak self] error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("[Failed] Leave channel request:\(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
                return
            }
            
            self.channel = nil
            self.channelDeletedObservable.set(value: ())
        }
    }
    
    func freezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)

        groupChannel.freeze { [weak self] error in
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            defer { self.loadingObservable.set(value: false) }
            
            if let error = error {
                SBULog.error("[Failed] Freeze channel request:\(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
                completionHandler?(false)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.set(value: (channel, .freeze))
            }
            completionHandler?(true)
        }
    }
    
    func unfreezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        groupChannel.unfreeze { [weak self] error in
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            defer { self.loadingObservable.set(value: false) }
            
            if let error = error {
                SBULog.error("[Failed] Unfreeze channel request:\(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
                completionHandler?(false)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.set(value: (channel, .unfreeze))
            }
            completionHandler?(true)
        }
    }
    
    func changeNotification(triggerOption: SBDGroupChannelPushTriggerOption) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        groupChannel.setMyPushTriggerOption(triggerOption) { [weak self] error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("[Failed] Channel push status request:\(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.set(value: (channel, .notification))
            }
        }
    }

    func inviteUsers(userIds: [String]) {
        SBULog.info("Request invite users: \(userIds)")
        guard let channel = self.channel as? SBDGroupChannel else { return }
        
        channel.inviteUserIds(userIds, completionHandler: { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                SBULog.error("Invite users request Failed: \(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
                return
            }
            
            SBULog.info("[Succeed] Invite users request success")
            
            self.channelRequestCompletion(error, .invite)
        })
    }
    
    
    // MARK: - Open Channel
    func loadOpenChannel(with channelUrl: String) {
        self.loadingObservable.set(value: true)
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.loadingObservable.set(value: false)
                self.errorObservable.set(value: error)
            } else {
                SBDOpenChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                    guard let self = self else { return }
                    
                    self.loadingObservable.set(value: false)
                    if let error = error {
                        self.errorObservable.set(value: error)
                    } else if let channel = channel {
                        self.channel = channel
                        self.channelLoadedObservable.set(value: channel)
                    }
                }
            }
        }
    }
    
    func updateChannel(params: SBDOpenChannelParams) {
        guard let openChannel = self.channel as? SBDOpenChannel else { return }
        guard let operators = openChannel.operators as? [SBDUser] else { return }
        
        self.loadingObservable.set(value: true)
        
        let operatorUserIds = operators.map { $0.userId }
        
        SBULog.info("[Request] Channel update")
        
        openChannel.update(
            withName: params.name,
            coverImage: params.coverImage,
            coverImageName: "cover_image",
            data: nil,
            operatorUserIds: operatorUserIds,
            customType: openChannel.customType,
            progressHandler: nil,
            completionHandler: channelUpdateCompletion
        )
    }
    
    func deleteChannel() {
        guard let channel = self.channel as? SBDOpenChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        channel.delete { [weak self] error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("[Failed] Delete channel request:\(String(error.localizedDescription))")
                self.errorObservable.set(value: error)
            }
            
            self.channel = nil
            self.channelDeletedObservable.set(value: ())
        }
    }
    
    
    // MARK: - Common
    
    func loadChannel(url: String, type: SBDChannelType) {
        switch type {
        case .group: self.loadGroupChannel(with: url)
        case .open: self.loadOpenChannel(with: url)
        @unknown default:
            break
        }
    }
    
    // MARK: - SBUViewModelDelegate
    
    override func dispose() {
        super.dispose()
        self.channelLoadedObservable.dispose()
        self.channelChangedObservable.dispose()
        self.channelDeletedObservable.dispose()
    }
}

