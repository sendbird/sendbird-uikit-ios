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
    
    // MARK: SwiftUI (Internal)
    var delegates: WeakDelegateStorage<SBURegisterOperatorViewModelDelegate> {
        let computedDelegates = WeakDelegateStorage<SBURegisterOperatorViewModelDelegate>()
        self.baseDelegates.allKeyValuePairs().forEach { key, value in
            if let delegate = value as? SBURegisterOperatorViewModelDelegate {
                computedDelegates.addDelegate(delegate, type: key)
            }
        }
        return computedDelegates
    }
    
    // MARK: - Life Cycle
    required public init(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        channelType: ChannelType = .group,
        users: [SBUUser]? = nil,
        userListQuery: ApplicationUserListQuery? = nil,
        memberListQuery: MemberListQuery? = nil,
        delegate: SBURegisterOperatorViewModelDelegate? = nil,
        dataSource: SBURegisterOperatorViewModelDataSource? = nil
    ) {
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
        self.baseDelegates.addDelegate(delegate, type: .uikit)
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
        
        self.delegates.forEach { $0.shouldUpdateLoadingState(true) }
        SBULog.info("[Request] Register users: \(userIds)")

        channel.addOperators(userIds: userIds) { [weak self] error in
            guard let self = self else { return }
            defer { self.delegates.forEach { $0.shouldUpdateLoadingState(false) } }
            
            if let error = error {
                self.delegates.forEach { $0.didReceiveError(error, isBlocker: false) }
                return
            }
            
            SBULog.info("[Succeed] Register users request success")
            self.delegates.forEach { $0.registerOperatorViewModel(self, didRegisterOperatorIds: userIds) }
        }
    }
}
