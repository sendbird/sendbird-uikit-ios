//
//  SBUInviteUserViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/05/20.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUInviteUserViewModelDelegate: SBUBaseSelectUserViewModelDelegate {
    /// Called when it has invited users with their IDs.
    func inviteUserViewModel(
        _ viewModel: SBUInviteUserViewModel,
        didInviteUserIds userIds: [String]
    )
}

public protocol SBUInviteUserViewModelDataSource: SBUBaseSelectUserViewModelDataSource {
}

open class SBUInviteUserViewModel: SBUBaseSelectUserViewModel {
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUInviteUserViewModelDelegate? {
        get { self.baseDelegate as? SBUInviteUserViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public weak var dataSource: SBUInviteUserViewModelDataSource? {
        get { self.baseDataSource as? SBUInviteUserViewModelDataSource }
        set { self.baseDataSource = newValue }
    }
    
    // MARK: - Life Cycle
    public init(channel: BaseChannel? = nil,
                channelURL: String? = nil,
                channelType: ChannelType = .group,
                users: [SBUUser]? = nil,
                userListQuery: ApplicationUserListQuery? = nil,
                memberListQuery: MemberListQuery? = nil,
                delegate: SBUInviteUserViewModelDelegate? = nil,
                dataSource: SBUInviteUserViewModelDataSource? = nil) {

        super.init(
            channel: channel,
            channelURL: channelURL,
            channelType: channelType,
            users: users,
            inviteListType: .users,
            userListQuery: userListQuery,
            memberListQuery: memberListQuery,
            delegate: delegate,
            dataSource: dataSource
        )
    }
    
    // MARK: - Channel actions
    
    /// Invites users in the channel with selected users.
    public func inviteUsers() {
        self.invite(users: Array(self.selectedUserList))
    }
    
    /// Invites users in the channel with userIds array.
    /// - Parameter users: Users to invite
    public func invite(users: [SBUUser]) {
        let userIds = Array(users).sbu_getUserIds()
        self.invite(userIds: userIds)
    }
    
    /// Invites users in the channel with userIds array.
    /// - Parameter userIds: User IDs to invite
    public func invite(userIds: [String]) {
        guard let channel = self.channel as? GroupChannel else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        SBULog.info("Request invite users: \(userIds)")
        
        channel.inviteUserIds(userIds, completionHandler: { [weak self] error in
            guard let self = self else { return }
            defer { self.delegate?.shouldUpdateLoadingState(false) }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            SBULog.info("[Succeed] Invite users request success")
            self.delegate?.inviteUserViewModel(self, didInviteUserIds: userIds)
        })
    }
}
