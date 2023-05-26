//
//  SBUBaseSelectUserViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/29.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

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
    public internal(set) var channel: BaseChannel?
    public internal(set) var channelURL: String?
    public internal(set) var channelType: ChannelType = .group
    
    @SBUAtomic public internal(set) var userList: [SBUUser] = []
    @SBUAtomic public internal(set) var selectedUserList: Set<SBUUser> = []
    
    public var userListQuery: ApplicationUserListQuery?
    public var memberListQuery: MemberListQuery?
    public var participantListQuery: ParticipantListQuery?
    
    public internal(set) var inviteListType: ChannelInviteListType = .users

    public private(set) var joinedUserIds: Set<String> = []
    
    // MARK: - Property (Private)
    weak var baseDelegate: SBUBaseSelectUserViewModelDelegate?
    weak var baseDataSource: SBUBaseSelectUserViewModelDataSource?
    
    internal var customUserListQuery: ApplicationUserListQuery?
    internal var customMemberListQuery: MemberListQuery?
    internal var customParticipantListQuery: ParticipantListQuery?
    
    @SBUAtomic private(set) var customizedUsers: [SBUUser]?
    internal var useCustomizedUsers = false

    @SBUAtomic private var isLoading = false
    
    // MARK: - Life Cycle
    public init(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        channelType: ChannelType = .group,
        users: [SBUUser]? = nil,
        inviteListType: ChannelInviteListType,
        userListQuery: ApplicationUserListQuery? = nil,
        memberListQuery: MemberListQuery? = nil,
        participantListQuery: ParticipantListQuery? = nil,
        delegate: SBUBaseSelectUserViewModelDelegate? = nil,
        dataSource: SBUBaseSelectUserViewModelDataSource? = nil
    ) {
        
        self.baseDelegate = delegate
        self.baseDataSource = dataSource
        
        super.init()
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        self.channelType = channelType
        
        self.inviteListType = inviteListType
        
        self.customUserListQuery = userListQuery
        self.customMemberListQuery = memberListQuery
        self.customParticipantListQuery = participantListQuery
        
        self.customizedUsers = users
        self.useCustomizedUsers = (users?.count ?? 0) > 0
        
        guard let channelURL = self.channelURL else { return }
        self.loadChannel(channelURL: channelURL, type: channelType)
    }
    
    // MARK: - Channel related
    public func loadChannel(channelURL: String, type: ChannelType) {
        self.baseDelegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.baseDelegate?.shouldUpdateLoadingState(false)
                self.baseDelegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((BaseChannel?, SBError?) -> Void) = {
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
                    GroupChannel.getChannel(url: channelURL, completionHandler: completionHandler)
                case .open:
                    OpenChannel.getChannel(url: channelURL, completionHandler: completionHandler)
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Prepare datas
    func prepareDatas() {
        guard self.inviteListType == .users else { return }
        guard let channel = self.channel as? GroupChannel else { return }
        
        prepareJoinedUserIds(channel.members)
    }
    
    func prepareJoinedUserIds(_ members: [User]) {
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
            self.participantListQuery = nil
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
        } else if !self.useCustomizedUsers {
            switch self.inviteListType {
            case .users:
                self.loadNextApplicationUserList()
            case .operators:
                if self.channelType == .group {
                    self.loadNextChannelMemberList()
                } else if self.channelType == .open {
                    self.loadNextChannelParticipantList()
                }
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
                let params = ApplicationUserListQueryParams()
                params.limit = SBUBaseSelectUserViewModel.limit
                self.userListQuery = SendbirdChat.createApplicationUserListQuery(params: params)
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
            guard !users.isEmpty else { return }
            
            self.appendUsersWithFiltering(users: users)
        })
    }
    
    private func appendUsersWithFiltering(users: [SBUUser]) {
        defer {
            self.isLoading = false
            self.baseDelegate?.shouldUpdateLoadingState(false)
        }
        
        // Super,Broadcast channel does not contain all information in joined members.
        if let channel = channel as? GroupChannel,
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
                if let channel = self.channel as? GroupChannel {
                    let params = MemberListQueryParams()
                    params.limit = SBUBaseSelectUserViewModel.limit
                    params.operatorFilter = .nonOperator
                    self.memberListQuery = channel.createMemberListQuery(params: params)
                } else {
                    let error = SBError(domain: "Cannot create the memberListQuery.", code: -1, userInfo: nil)
                    self.baseDelegate?.shouldUpdateLoadingState(false)
                    self.baseDelegate?.didReceiveError(error)
                    return
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
            guard !members.isEmpty else { return }
            
            self.userList += members
            self.baseDelegate?.baseSelectedUserViewModel(
                self,
                didChangeUserList: self.userList,
                needsToReload: true
            )
        })
    }
    
    /// This function loads channel participant list.
    ///
    /// If you want to call a list of users, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `MemberList` alone.
    private func loadNextChannelParticipantList() {
        if self.participantListQuery == nil {
            if self.customParticipantListQuery != nil {
                self.participantListQuery = self.customParticipantListQuery
            } else {
                if let channel = self.channel as? OpenChannel {
                    let params = ParticipantListQueryParams()
                    params.limit = SBUBaseSelectUserViewModel.limit
                    self.participantListQuery = channel.createParticipantListQuery(params: params)
                } else {
                    let error = SBError(domain: "Cannot create the participantListQuery.", code: -1, userInfo: nil)
                    self.baseDelegate?.shouldUpdateLoadingState(false)
                    self.baseDelegate?.didReceiveError(error)
                    return
                }
            }
        }
        
        guard self.participantListQuery?.hasNext == true else {
            self.isLoading = false
            self.baseDelegate?.shouldUpdateLoadingState(false)
            SBULog.info("All participants have been loaded.")
            return
        }
        
        self.participantListQuery?.loadNextPage(completionHandler: { [weak self, weak channel] users, error in
            guard let self = self, let channel = channel else { return }
            defer {
                self.isLoading = false
                self.baseDelegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.baseDelegate?.didReceiveError(error, isBlocker: false)
                return
            }
        
            guard let users = users?.sbu_convertUserList() else { return }
            SBULog.info("[Response] \(users.count) participants")
            guard !users.isEmpty else { return }
            
            self.userList += users.sbu_updateOperatorStatus(channel: channel)
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
            if self.channelType == .group {
                queryCheck = (self.memberListQuery?.hasNext == true && self.memberListQuery != nil)
            } else if self.channelType == .open {
                queryCheck = (self.participantListQuery?.hasNext == true && self.participantListQuery != nil)
            }
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
        if let index = self.selectedUserList.firstIndex(where: { $0.userId == user.userId }) {
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
