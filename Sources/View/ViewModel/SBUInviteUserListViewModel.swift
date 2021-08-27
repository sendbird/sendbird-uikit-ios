//
//  SBUInviteUserViewModel.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2021/05/20.
//  Copyright © 2021 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objc public protocol SBUInviteUserListDatasource: NSObjectProtocol {
    /// When creating and using a user list directly, overriding this function and return the next user list.
    /// Make this function return the next list each time it is called.
    /// - Returns: next user list
    /// - Since: 1.1.1
    func nextUserList() -> [SBUUser]?
}

class SBUInviteUserListViewModel: SBUChannelActionViewModel {
    static let limit: UInt = 20
    
    private(set) var inviteListType: ChannelInviteListType = .users
    weak var datasource: SBUInviteUserListDatasource?
    
    @SBUAtomic private(set) var userList: [SBUUser] = [] {
        didSet { self.userListChangedObservable.set(value: userList) }
    }
    @SBUAtomic private(set) var selectedUserList: Set<SBUUser> = []
    @SBUAtomic private(set) var customizedUsers: [SBUUser]?
    var useCustomizedUsers = false

    private(set) var joinedUserIds: Set<String> = []
    private(set) var userListQuery: SBDApplicationUserListQuery?
    private(set) var memberListQuery: SBDGroupChannelMemberListQuery?
    
    var userListChangedObservable = SBUObservable<[SBUUser]>()
    var selectedUserObservable = SBUObservable<Set<SBUUser>>()
    
    @SBUAtomic private var isLoading = false

    
    init(users: [SBUUser]? = nil,
         type: ChannelInviteListType)
    {
        super.init()
        self.inviteListType = type
        self.customizedUsers = users
        self.useCustomizedUsers = (users?.count ?? 0) > 0
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
    
    
    // MARK: - Load user list
    func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
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
            self.userListQuery = SBDMain.createApplicationUserListQuery()
            self.userListQuery?.limit = SBUInviteUserListViewModel.limit
        }
        
        guard self.userListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All users have been loaded.")
            return
        }
        
        self.userListQuery?.loadNextPage(completionHandler: { [weak self] users, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] User list request: \(error.localizedDescription)")
                self.errorObservable.set(value: error)
                return
            }
            guard let users = users?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(users.count) users")
            
            self.appendUsersWithFiltering(users: users)
        })
    }
    
    /// This function loads channel member list.
    ///
    /// If you want to call a list of users, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `MemberList` alone.
    private func loadNextChannelMemberList() {
        if self.memberListQuery == nil,
           let channel = self.channel as? SBDGroupChannel {
            self.memberListQuery = channel.createMemberListQuery()
            self.memberListQuery?.limit = SBUInviteUserListViewModel.limit
            self.memberListQuery?.operatorFilter = .nonOperator
        }
        
        guard self.memberListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All members have been loaded.")
            return
        }
        
        // return [SBDMember]
        self.memberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Member list request: \(error.localizedDescription)")
                self.errorObservable.set(value: error)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(members.count) members")
            
            self.userList += members
        })
    }
    
    /// This function pre-loads user list.
    ///
    /// When a part of the Tableview is displayed, then this function is load the next user list.
    ///
    /// - Parameter indexPath: TableView's indexpath
    func preLoadNextUserList(indexPath: IndexPath) {
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
            indexPath.row == (self.userList.count - Int(SBUInviteUserListViewModel.limit)/2),
            !self.isLoading {
            let nextUserList = self.datasource?.nextUserList()
            self.loadNextUserList(
                reset: false,
                users: self.useCustomizedUsers ? nextUserList : nil
            )
        }
    }
    
    
    // MARK: - Append userlist
    private func appendUsersWithFiltering(users: [SBUUser]) {
        // Super,Broadcast channel does not contain all information in joined members.
        if let channel = channel as? SBDGroupChannel,
           (channel.isBroadcast || channel.isSuper) {
            self.userList += users
            return
        }

        guard !self.joinedUserIds.isEmpty else {
            self.userList += users
            return
        }
        
        let filteredUsers = users.filter { joinedUserIds.contains($0.userId) == false }
        if filteredUsers.isEmpty {
            self.isLoading = false
            let nextUserList = (self.datasource?.nextUserList()?.count ?? 0) > 0
                ? self.datasource?.nextUserList()
                : nil
            self.loadNextUserList(
                reset: false,
                users: self.useCustomizedUsers ? nextUserList : nil
            )
        } else {
            self.userList += filteredUsers
        }
    }
    
    
    // MARK: - Select user
    func selectUser(user: SBUUser) {
        if let index = self.selectedUserList.firstIndex(of: user) {
            self.selectedUserList.remove(at: index)
        } else {
            self.selectedUserList.insert(user)
        }
        
        SBULog.info("Selected user: \(user)")
        
        self.selectedUserObservable.set(value: selectedUserList)
    }
    
    
    // MARK: - dispose
    override func dispose() {
        super.dispose()
        self.userListChangedObservable.dispose()
        self.selectedUserObservable.dispose()
    }
}
