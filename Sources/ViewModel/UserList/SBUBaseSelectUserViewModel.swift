//
//  SBUBaseSelectUserViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/29.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


public protocol SBUBaseSelectUserViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the user list has been changed.
    func baseSelectedUserViewModel(
        _ viewModel: SBUBaseSelectUserViewModel,
        didChangeUserList users: [SBUUser]?,
        needsToReload: Bool
    )
    
    /// Called when the selected user list has been updated.
    func baseSelectedUserViewModel(
        _ viewModel: SBUBaseSelectUserViewModel,
        didUpdateSelectedUsers selectedUsers: [SBUUser]?
    )
}


public protocol SBUBaseSelectUserViewModelDataSource: AnyObject {
    /// When creating and using a user list directly, overriding this function and return the next user list.
    /// Make this function return the next list each time it is called.
    /// - Returns: next user list
    func nextUserList() -> [SBUUser]?
}


open class SBUBaseSelectUserViewModel: NSObject {
    // MARK: - Constants
    static let limit: UInt = 20
    
    
    // MARK: - Property (Public)
    public internal(set) var channel: SBDBaseChannel?
    public internal(set) var channelUrl: String?
    public internal(set) var channelType: SBDChannelType = .group
    
    @SBUAtomic public internal(set) var userList: [SBUUser] = []
    @SBUAtomic public internal(set) var selectedUserList: Set<SBUUser> = []
    
    public var userListQuery: SBDApplicationUserListQuery?
    public var memberListQuery: SBDGroupChannelMemberListQuery?
    
    public internal(set) var inviteListType: ChannelInviteListType = .users
    
    
    // MARK: - Property (Private)
    weak var baseDelegate: SBUBaseSelectUserViewModelDelegate?
    weak var baseDataSource: SBUBaseSelectUserViewModelDataSource?
    
    internal var customUserListQuery: SBDApplicationUserListQuery?
    internal var customMemberListQuery: SBDGroupChannelMemberListQuery?
    
    @SBUAtomic private(set) var customizedUsers: [SBUUser]?
    internal var useCustomizedUsers = false

    private(set) var joinedUserIds: Set<String> = []
    
    @SBUAtomic private var isLoading = false

    
    // MARK: - Life Cycle
    init(
        channel: SBDBaseChannel? = nil,
        channelUrl: String? = nil,
        channelType: SBDChannelType = .group,
        users: [SBUUser]? = nil,
        inviteListType: ChannelInviteListType,
        userListQuery: SBDApplicationUserListQuery? = nil,
        memberListQuery: SBDGroupChannelMemberListQuery? = nil,
        delegate: SBUBaseSelectUserViewModelDelegate? = nil,
        dataSource: SBUBaseSelectUserViewModelDataSource? = nil
    ) {
        
        self.baseDelegate = delegate
        self.baseDataSource = dataSource
        
        super.init()
        
        if let channel = channel {
            self.channel = channel
            self.channelUrl = channel.channelUrl
        } else if let channelUrl = channelUrl {
            self.channelUrl = channelUrl
        }
        self.channelType = channelType
        
        self.inviteListType = inviteListType
        
        self.customUserListQuery = userListQuery
        self.customMemberListQuery = memberListQuery
        
        self.customizedUsers = users
        self.useCustomizedUsers = (users?.count ?? 0) > 0
        
        guard let channelUrl = self.channelUrl else { return }
        self.loadChannel(channelUrl: channelUrl, type: channelType)
    }
    
    
    // MARK: - Channel related
    public func loadChannel(channelUrl: String, type: SBDChannelType) {
        self.baseDelegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.baseDelegate?.shouldUpdateLoadingState(false)
                self.baseDelegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((SBDBaseChannel?, SBDError?) -> Void) = {
                    [weak self] channel, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.baseDelegate?.shouldUpdateLoadingState(false)
                        self.baseDelegate?.didReceiveError(error, isBlocker: false)
                    } else if let channel = channel {
                        self.channel = channel
                        self.loadNextUserList(reset: true, users: self.customizedUsers)
                    }
                }
                
                switch type {
                case .group:
                    SBDGroupChannel.getWithUrl(channelUrl, completionHandler: completionHandler)
                case .open:
                    SBDOpenChannel.getWithUrl(channelUrl, completionHandler: completionHandler)
                default:
                    break
                }
            }
        }
    }
    
    
    // MARK: - Prepare datas
    func prepareDatas() {
        guard self.inviteListType == .users else { return }
        
        guard let channel = self.channel as? SBDGroupChannel,
              let members = channel.members as? [SBDUser] else { return }
        
        prepareJoinedUserIds(members)
    }
    
    func prepareJoinedUserIds(_ members: [SBDUser]) {
        let joinedMemberList = members.sbu_convertUserList()
        if joinedMemberList.count > 0 {
            self.joinedUserIds = Set(joinedMemberList.sbu_getUserIds())
        }
    }
    
    
    // MARK: - List handling
    
    /// Load user list.
    ///
    /// If want using your custom user list, filled `users` with your custom user list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset user list and load new list
    ///   - users: customized `SBUUser` array for add to user list
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        if self.isLoading { return }
        self.isLoading = true
        
        if reset {
            self.userListQuery = nil
            self.memberListQuery = nil
            self.userList = []
            
            self.prepareDatas()
            
            SBULog.info("[Request] User List")
        } else {
            SBULog.info("[Request] Next user List")
        }

        if let users = users {
            // Customized user list
            SBULog.info("\(users.count) customized users have been added.")
            
            self.isLoading = false
            self.appendUsersWithFiltering(users: users)
        }
        else if !self.useCustomizedUsers {
            switch self.inviteListType {
            case .users:
                self.loadNextApplicationUserList()
            case .operators:
                self.loadNextChannelMemberList()
            default:
                break
            }
        }
    }
    
    /// This function loads application user list.
    ///
    /// If you want to call a list of users, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `ApplicationUserList` alone.
    private func loadNextApplicationUserList() {
        if self.userListQuery == nil {
            if self.customUserListQuery != nil {
                self.userListQuery = self.customUserListQuery
            } else {
                self.userListQuery = SBDMain.createApplicationUserListQuery()
                self.userListQuery?.limit = SBUBaseSelectUserViewModel.limit
            }
        }
        
        guard self.userListQuery?.hasNext == true else {
            self.isLoading = false
            self.baseDelegate?.shouldUpdateLoadingState(false)
            SBULog.info("All users have been loaded.")
            return
        }
        
        self.userListQuery?.loadNextPage(completionHandler: { [weak self] users, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.baseDelegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.baseDelegate?.didReceiveError(error, isBlocker: false)
                return
            }
            guard let users = users?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(users.count) users")
            
            self.appendUsersWithFiltering(users: users)
        })
    }
    
    private func appendUsersWithFiltering(users: [SBUUser]) {
        defer {
            self.isLoading = false
            self.baseDelegate?.shouldUpdateLoadingState(false)
        }
        
        // Super,Broadcast channel does not contain all information in joined members.
        if let channel = channel as? SBDGroupChannel,
           (channel.isBroadcast || channel.isSuper) {
            self.userList += users
            self.baseDelegate?.baseSelectedUserViewModel(
                self,
                didChangeUserList: self.userList,
                needsToReload: true
            )
            return
        }

        guard !self.joinedUserIds.isEmpty else {
            self.userList += users
            self.baseDelegate?.baseSelectedUserViewModel(
                self,
                didChangeUserList: self.userList,
                needsToReload: true
            )
            return
        }
        
        let filteredUsers = users.filter { joinedUserIds.contains($0.userId) == false }
        if filteredUsers.isEmpty {
            let nextUserList = (self.baseDataSource?.nextUserList()?.count ?? 0) > 0
            ? self.baseDataSource?.nextUserList()
                : nil
            self.loadNextUserList(
                reset: false,
                users: self.useCustomizedUsers ? nextUserList : nil
            )
        } else {
            self.userList += filteredUsers
            self.baseDelegate?.baseSelectedUserViewModel(
                self,
                didChangeUserList: self.userList,
                needsToReload: true
            )
        }
    }
    
    /// This function loads channel member list.
    ///
    /// If you want to call a list of users, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `MemberList` alone.
    private func loadNextChannelMemberList() {
        if self.memberListQuery == nil {
            if self.customMemberListQuery != nil {
                self.memberListQuery = self.customMemberListQuery
            } else {
                if let channel = self.channel as? SBDGroupChannel {
                    self.memberListQuery = channel.createMemberListQuery()
                    self.memberListQuery?.limit = SBUBaseSelectUserViewModel.limit
                    self.memberListQuery?.operatorFilter = .nonOperator
                }
                else {
                    let error = SBDError(domain: "Cannot create the memberListQuery.", code: -1, userInfo: nil)
                    self.baseDelegate?.shouldUpdateLoadingState(false)
                    self.baseDelegate?.didReceiveError(error)
                }
            }
        }
        
        guard self.memberListQuery?.hasNext == true else {
            self.isLoading = false
            self.baseDelegate?.shouldUpdateLoadingState(false)
            SBULog.info("All members have been loaded.")
            return
        }
        
        self.memberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.baseDelegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.baseDelegate?.didReceiveError(error, isBlocker: false)
                return
            }
        
            guard let members = members?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(members.count) members")
            
            self.userList += members
            self.baseDelegate?.baseSelectedUserViewModel(
                self,
                didChangeUserList: self.userList,
                needsToReload: true
            )
        })
    }
    
    /// This function pre-loads user list.
    ///
    /// When a part of the Tableview is displayed, then this function is load the next user list.
    ///
    /// - Parameter indexPath: TableView's indexpath
    public func preLoadNextUserList(indexPath: IndexPath) {
        var queryCheck = false
        switch self.inviteListType {
        case .users:
            queryCheck = (self.userListQuery?.hasNext == true && self.userListQuery != nil)
        case .operators:
            queryCheck = (self.memberListQuery?.hasNext == true && self.memberListQuery != nil)
        default:
            break
        }
        
        if self.userList.count > 0,
            (self.useCustomizedUsers || queryCheck),
            indexPath.row == (self.userList.count - Int(SBUBaseSelectUserViewModel.limit)/2),
            !self.isLoading {
            let nextUserList = self.baseDataSource?.nextUserList()
            self.loadNextUserList(
                reset: false,
                users: self.useCustomizedUsers ? nextUserList : nil
            )
        }
    }
        
    /// This function resets the user list.
    public func resetUserList() {
        self.loadNextUserList(reset: true, users: self.customizedUsers)
    }
    
    
    // MARK: - Select user
    
    /// This function selects or deselects user.
    /// - Parameter user: `SBUUser` object
    public func selectUser(user: SBUUser) {
        if let index = self.selectedUserList.firstIndex(of: user) {
            self.selectedUserList.remove(at: index)
        } else {
            self.selectedUserList.insert(user)
        }
        
        SBULog.info("Selected user: \(user)")
        
        self.baseDelegate?.baseSelectedUserViewModel(
            self,
            didUpdateSelectedUsers: Array(self.selectedUserList)
        )
    }
}
