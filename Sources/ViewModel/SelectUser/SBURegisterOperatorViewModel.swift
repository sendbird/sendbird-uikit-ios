//
//  SBURegisterOperatorViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/29.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBURegisterOperatorViewModelDelegate: SBUBaseSelectUserViewModelDelegate {
    /// Called when it has registered operators with their IDs.
    func registerOperatorViewModel(
        _ viewModel: SBURegisterOperatorViewModel,
        didRegisterOperatorIds operatorIds: [String]
    )
}

public protocol SBURegisterOperatorViewModelDataSource: SBUBaseSelectUserViewModelDataSource { }

open class SBURegisterOperatorViewModel: SBUBaseSelectUserViewModel {
    // MARK: - Logic properties (Public)
    public weak var delegate: SBURegisterOperatorViewModelDelegate? {
        get { self.baseDelegate as? SBURegisterOperatorViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public weak var dataSource: SBURegisterOperatorViewModelDataSource? {
        get { self.baseDataSource as? SBURegisterOperatorViewModelDataSource }
        set { self.baseDataSource = newValue }
    }
    
    // MARK: - Life Cycle
    public init(channel: BaseChannel? = nil,
                channelURL: String? = nil,
                channelType: ChannelType = .group,
                users: [SBUUser]? = nil,
                userListQuery: ApplicationUserListQuery? = nil,
                memberListQuery: MemberListQuery? = nil,
                delegate: SBURegisterOperatorViewModelDelegate? = nil,
                dataSource: SBURegisterOperatorViewModelDataSource? = nil) {
        
        super.init(
            channel: channel,
            channelURL: channelURL,
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
    /// Registers users as operator with selected users.
    public func registerAsOperators() {
        self.registerAsOperators(users: Array(self.selectedUserList))
    }
    
    /// Registers users as operator with users array.
    /// - Parameter users: users to register
    public func registerAsOperators(users: [SBUUser]) {
        let userIds = Array(users).sbu_getUserIds()
        self.registerAsOperators(userIds: userIds)
    }
    
    /// Registers users as operator with userIds array.
    /// - Parameter userIds: user IDs to register
    public func registerAsOperators(userIds: [String]) {
        guard let channel = self.channel else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        SBULog.info("[Request] Register users: \(userIds)")

        channel.addOperators(userIds: userIds) { [weak self] error in
            guard let self = self else { return }
            defer { self.delegate?.shouldUpdateLoadingState(false) }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            SBULog.info("[Succeed] Register users request success")
            self.delegate?.registerOperatorViewModel(self, didRegisterOperatorIds: userIds)
        }
    }
}
