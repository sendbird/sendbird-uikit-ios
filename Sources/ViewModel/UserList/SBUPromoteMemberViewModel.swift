//
//  SBUPromoteMemberViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/29.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

public protocol SBUPromoteMemberViewModelDelegate: SBUBaseSelectUserViewModelDelegate {
    /// Called when it has promoted members with their IDs.
    func promoteMemberViewModel(
        _ viewModel: SBUPromoteMemberViewModel,
        didPromoteMemberIds memberIds: [String]
    )
}


public protocol SBUPromoteMemberViewModelDataSource: SBUBaseSelectUserViewModelDataSource { }


open class SBUPromoteMemberViewModel: SBUBaseSelectUserViewModel {
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUPromoteMemberViewModelDelegate? {
        get { self.baseDelegate as? SBUPromoteMemberViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public weak var dataSource: SBUPromoteMemberViewModelDataSource? {
        get { self.baseDataSource as? SBUPromoteMemberViewModelDataSource }
        set { self.baseDataSource = newValue }
    }
    
    
    // MARK: - Life Cycle
    init(channel: SBDBaseChannel? = nil,
         channelUrl: String? = nil,
         channelType: SBDChannelType = .group,
         users: [SBUUser]? = nil,
         userListQuery: SBDApplicationUserListQuery? = nil,
         memberListQuery: SBDGroupChannelMemberListQuery? = nil,
         delegate: SBUPromoteMemberViewModelDelegate? = nil,
         dataSource: SBUPromoteMemberViewModelDataSource? = nil) {

        super.init(
            channel: channel,
            channelUrl: channelUrl,
            channelType: channelType,
            users: users,
            inviteListType: .operators,
            userListQuery: userListQuery,
            memberListQuery: memberListQuery,
            delegate: delegate,
            dataSource: dataSource
        )
    }
    
    
    // MARK: - Channel actions
    /// Promotes members as operator with selected users.
    public func promoteToOperators() {
        self.promoteToOperators(members: Array(self.selectedUserList))
    }
    
    /// Promotes members as operator with members array.
    /// - Parameter members: members to promote
    public func promoteToOperators(members: [SBUUser]) {
        let memberIds = Array(members).sbu_getUserIds()
        self.promoteToOperators(memberIds: memberIds)
    }
    
    /// Promotes members as operator with memberIds array.
    /// - Parameter memberIds: member IDs to promote
    public func promoteToOperators(memberIds: [String]) {
        guard let channel = self.channel else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        SBULog.info("[Request] Promote members: \(memberIds)")

        channel.addOperators(withUserIds: memberIds) { [weak self] error in
            guard let self = self else { return }
            defer { self.delegate?.shouldUpdateLoadingState(false) }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            SBULog.info("[Succeed] Promote members request success")
            self.delegate?.promoteMemberViewModel(self, didPromoteMemberIds: memberIds)
        }
    }
}
