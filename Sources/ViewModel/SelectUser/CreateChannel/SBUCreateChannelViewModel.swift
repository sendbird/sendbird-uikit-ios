//
//  SBUCreateChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUCreateChannelViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the user list has been changed
    func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        didChangeUsers users: [SBUUser],
        needsToReload: Bool
    )
    
    /// Called when it has created channel with `MessageListParams` object.
    func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        didCreateChannel channel: BaseChannel?,
        withMessageListParams messageListParams: MessageListParams?
    )
    
    /// Called when the selected users has been updated.
    func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        didUpdateSelectedUsers selectedUsers: [SBUUser]
    )
}

public protocol SBUCreateChannelViewModelDataSource: AnyObject {
    /// Asks to data source to return the next member list for the channel type. When create and use the member list directly, override this function.
    /// - Important: If you want to use this function, please set the `SBUCreateChannelViewModelDataSource` in your class.
    /// - Returns: The next member list.
    func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        nextUserListForChannelType channelType: ChannelCreationType
    ) -> [SBUUser]?
}

/// `SBUCreateChannelViewModel` is a class that handles the creation of channels.
open class SBUCreateChannelViewModel {
    // MARK: - Constants
    static let limit: UInt = 20
    
    // MARK: - Property (Public)
    /// Delegate for `SBUCreateChannelViewModel`
    public weak var delegate: SBUCreateChannelViewModelDelegate?
    /// The data source for `SBUCreateChannelViewModel`. This is used to provide the next member list for the channel type.
    public weak var dataSource: SBUCreateChannelViewModelDataSource?
    
    // MARK: SwiftUI (Internal)
    var delegates = WeakDelegateStorage<SBUCreateChannelViewModelDelegate>()

    /// The type of channel to be created. Default is `.group`.
    public private(set) var channelType: ChannelCreationType = .group
    
    /// The list of users
    @SBUAtomic public private(set) var userList: [SBUUser] = []
    /// Represents the list of selected users in the `SBUCreateChannelViewModel` class.
    @SBUAtomic public private(set) var selectedUserList: Set<SBUUser> = []

    /// The query object for fetching the application user list.
    public private(set) var userListQuery: ApplicationUserListQuery?
    
    // MARK: - Property (Private)
    @SBUAtomic private(set) var customizedUsers: [SBUUser]?
    private var useCustomizedUsers = false

    @SBUAtomic private var isLoading = false
    
    // MARK: - Life Cycle
    /// Initializes a new instance of `SBUCreateChannelViewModel`.
    ///
    /// - Parameters:
    ///   - channelType: The type of channel to be created. Default is `.group`.
    ///   - users: An optional array of `SBUUser` to be added to the user list. Default is `nil`.
    ///   - delegate: An optional delegate for `SBUCreateChannelViewModelDelegate`. Default is `nil`.
    ///   - dataSource: An optional data source for `SBUCreateChannelViewModelDataSource`. Default is `nil`.
    required public init(
        channelType: ChannelCreationType = .group,
        users: [SBUUser]? = nil,
        delegate: SBUCreateChannelViewModelDelegate? = nil,
        dataSource: SBUCreateChannelViewModelDataSource? = nil
    ) {
        self.delegate = delegate
        self.dataSource = dataSource
        self.delegates.addDelegate(delegate, type: .uikit)
        
        self.channelType = channelType
        
        self.customizedUsers = users
        self.useCustomizedUsers = (users?.count ?? 0) > 0
        
        self.initializeAndLoad(users: users)
    }
    
    func initializeAndLoad(
        users: [SBUUser]? = nil
    ) {
        if let users { self.customizedUsers = users }
        self.useCustomizedUsers = (users?.count ?? 0) > 0
        
        // If want using your custom user list, filled users with your custom user list.
        self.loadNextUserList(reset: true, users: self.customizedUsers ?? nil)
    }
    
    // MARK: - List handling
    
    /// Load user list.
    ///
    /// If want using your custom user list, filled users with your custom user list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset user list and load new list
    ///   - users: customized `SBUUser` array for add to user list
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        guard !self.isLoading else { return }
        self.delegates.forEach { $0.shouldUpdateLoadingState(true) }
        
        if reset {
            self.userListQuery = nil
            self.userList = []
            
            SBULog.info("[Request] User List")
        } else {
            SBULog.info("[Request] Next user List")
        }

        if let users = users {
            // for using customized user list
            SBULog.info("\(users.count) customized users have been added.")
            
            self.userList += users
            self.delegates.forEach { $0.shouldUpdateLoadingState(false) }
            self.delegates.forEach {
                $0.createChannelViewModel(
                    self,
                    didChangeUsers: self.userList,
                    needsToReload: true
                )
            }
        } else {
            guard !self.useCustomizedUsers else {
                self.delegates.forEach { $0.shouldUpdateLoadingState(false) }
                
                return
            }
            
            if self.userListQuery == nil {
                let params = ApplicationUserListQueryParams()
                params.limit = SBUCreateChannelViewModel.limit
                self.userListQuery = SendbirdChat.createApplicationUserListQuery(params: params)
            }
            
            guard self.userListQuery?.hasNext == true else {
                self.delegates.forEach { $0.shouldUpdateLoadingState(false) }
                SBULog.info("All users have been loaded.")
                return
            }
            
            self.userListQuery?.loadNextPage { [weak self] users, error in
                guard let self = self else { return }
                defer { self.delegates.forEach { $0.shouldUpdateLoadingState(false) } }
                
                if let error = error {
                    self.delegates.forEach { $0.didReceiveError(error, isBlocker: true) }
                    return
                }
                
                let filteredUsers = users?.filter { $0.userId != SBUGlobals.currentUser?.userId }
                
                guard let users = filteredUsers?.sbu_convertUserList() else { return }
                
                SBULog.info("[Response] \(users.count) users")
                
                guard !users.isEmpty else { return }
                
                self.userList += users
                self.delegates.forEach { $0.createChannelViewModel(self, didChangeUsers: self.userList, needsToReload: true) }
            }
        }
    }
    
    /// This function pre-loads user list.
    ///
    /// When a part of the Tableview is displayed, then this function is load the next user list.
    ///
    /// - Parameter indexPath: TableView's indexpath
    public func preLoadNextUserList(indexPath: IndexPath) {
        if self.userList.count > 0,
            (self.useCustomizedUsers ||
                (self.userListQuery?.hasNext == true && self.userListQuery != nil)),
            indexPath.row == (self.userList.count - Int(SBUInviteUserViewModel.limit)/2),
            !self.isLoading {
            
            let nextUserList = self.dataSource?.createChannelViewModel(
                self,
                nextUserListForChannelType: self.channelType
            )
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
    
    // MARK: - Create Channel
    /// Creates the channel with userIds.
    /// - Parameter userIds: User Ids to include
    public func createChannel(userIds: [String]) {
        let params = GroupChannelCreateParams()
        params.name = ""
        params.coverURL = ""
        params.addUserIds(userIds)
        params.isDistinct = false

        let type = self.channelType
        params.isSuper = (type == .broadcast) || (type == .supergroup)
        params.isBroadcast = (type == .broadcast)
        
        if let currentUser = SBUGlobals.currentUser {
            params.operatorUserIds = [currentUser.userId]
        }

        SBUGlobalCustomParams.groupChannelParamsCreateBuilder?(params)
        
        self.createChannel(params: params)
    }
    
    /// Creates the channel with channelParams.
    ///
    /// You can create a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `GroupChannelCreateParams` class object
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    public func createChannel(params: GroupChannelCreateParams,
                              messageListParams: MessageListParams? = nil) {
        SBULog.info("""
            [Request] Create channel with users,
            Users: \(Array(self.selectedUserList))
            """)
        self.delegates.forEach { $0.shouldUpdateLoadingState(true) }
        
        GroupChannel.createChannel(params: params) { [weak self] channel, error in
            defer { self?.delegates.forEach { $0.shouldUpdateLoadingState(false) } }
            guard let self = self else { return }
            
            if let error = error {
                SBULog.error("""
                    [Failed] Create channel request:
                    \(String(error.localizedDescription))
                    """)
                self.delegates.forEach { $0.didReceiveError(error) }
                return
            }
            
            SBULog.info("[Succeed] Create channel: \(channel?.description ?? "")")
            self.delegates.forEach {
                $0.createChannelViewModel(
                    self,
                    didCreateChannel: channel,
                    withMessageListParams: messageListParams
                )
            }
        }
    }
    
    // MARK: - Select user
    /// Selects a user.
    ///
    /// This function is used to select a user. If the user is already selected, it will be removed from the selection. Otherwise, the user will be added to the selection.
    /// - Parameter user: The `SBUUser` to be selected.
    public func selectUser(user: SBUUser) {
        if let index = self.selectedUserList.firstIndex(of: user) {
            self.selectedUserList.remove(at: index)
        } else {
            self.selectedUserList.insert(user)
        }
        
        SBULog.info("Selected user: \(user)")
        
        self.delegates.forEach {
            $0.createChannelViewModel(
                self,
                didUpdateSelectedUsers: Array(self.selectedUserList)
            )
        }
    }
}
