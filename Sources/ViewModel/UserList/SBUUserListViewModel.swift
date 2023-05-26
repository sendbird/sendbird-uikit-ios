//
//  SBUUserListViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

public protocol SBUUserListViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the users has been changed
    func userListViewModel(
        _ viewModel: SBUUserListViewModel,
        didChangeUsers users: [SBUUser],
        needsToReload: Bool
    )
    
    /// Called when the channel has been changed.
    func userListViewModel(
        _ viewModel: SBUUserListViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    )
    
    /// Called when the user list should dismiss
    /// - Parameters:
    ///   - viewModel: `SBUUserListViewModel` object
    ///   - channel: channel object. If you want to move to the channel view, put the channel object or empty the channel object to go to the channel list.
    func userListViewModel(
        _ viewModel: SBUUserListViewModel,
        shouldDismissForUserList channel: BaseChannel?
    )
}

public protocol SBUUserListViewModelDataSource: AnyObject {
    /// Asks to data source to return the next user list for the channel. When create and use the user list directly, override this function.
    /// - Important: If you want to use this function, please set the `SBUUserListViewModelDataSource` in your class.
    /// - Returns: The next user list.
    func userListViewModel(
        _ viewModel: SBUUserListViewModel,
        nextUserListForChannel channel: BaseChannel?
    ) -> [SBUUser]?
}

open class SBUUserListViewModel: NSObject {
    // MARK: - Constants
    static let limit: UInt = 20
    
    // MARK: - Property (Public)
    public weak var delegate: SBUUserListViewModelDelegate?
    public weak var dataSource: SBUUserListViewModelDataSource?
    
    public private(set) var channel: BaseChannel?
    public private(set) var channelURL: String?
    public private(set) var channelType: ChannelType = .group
    
    @SBUAtomic public private(set) var userList: [SBUUser] = []
    
    public var memberListQuery: MemberListQuery? // Group
    public var operatorListQuery: OperatorListQuery? // Group/Open
    public var mutedMemberListQuery: MemberListQuery? // Group
    public var mutedParticipantListQuery: MutedUserListQuery? // Open
    public var bannedUserListQuery: BannedUserListQuery? // Group/Open
    public var participantListQuery: ParticipantListQuery? // Open
    
    public private(set) var userListType: ChannelUserListType = .none
    
    // MARK: - Property (Private)
    @SBUAtomic private var customizedUsers: [SBUUser]?
    private var useCustomizedUsers = false

    @SBUAtomic private var isLoading = false
    
    var userStateChangedHandler: ((SBError?) -> Void)?
    
    // MARK: - Life Cycle
    public init(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        channelType: ChannelType = .group,
        users: [SBUUser]? = nil,
        userListType: ChannelUserListType,
        memberListQuery: MemberListQuery? = nil,
        operatorListQuery: OperatorListQuery? = nil,
        mutedMemberListQuery: MemberListQuery? = nil,
        mutedParticipantListQuery: MutedUserListQuery? = nil,
        bannedUserListQuery: BannedUserListQuery? = nil,
        participantListQuery: ParticipantListQuery? = nil,
        delegate: SBUUserListViewModelDelegate? = nil,
        dataSource: SBUUserListViewModelDataSource? = nil
    ) {
        self.delegate = delegate
        self.dataSource = dataSource
        
        super.init()
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        self.channelType = channelType
        
        self.userListType = userListType
        
        self.memberListQuery = memberListQuery
        self.operatorListQuery = operatorListQuery
        self.mutedMemberListQuery = mutedMemberListQuery
        self.mutedParticipantListQuery = mutedParticipantListQuery
        self.bannedUserListQuery = bannedUserListQuery
        self.participantListQuery = participantListQuery
        
        self.customizedUsers = users
        self.useCustomizedUsers = (users?.count ?? 0) > 0
        
        self.userStateChangedHandler = { [weak self] error in
            defer { self?.delegate?.shouldUpdateLoadingState(false) }
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            // If want using your custom user list, filled users with your custom user list.
            self.loadNextUserList(reset: true, users: self.customizedUsers ?? nil)
        }
        
        if self.channelType == .group {
            SendbirdChat.addChannelDelegate(
                self,
                identifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
            )
        } else if self.channelType == .open {
            SendbirdChat.addChannelDelegate(
                self,
                identifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
            )
        }
        
        guard let channelURL = self.channelURL else { return }
        self.loadChannel(channelURL: channelURL, type: channelType)
    }
    
    deinit {
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
        
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
        )
    }
    
    // MARK: - Channel related
    public func loadChannel(channelURL: String, type: ChannelType) {
        self.delegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.shouldUpdateLoadingState(false)
                self.delegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((BaseChannel?, SBError?) -> Void) = {
                    [weak self] channel, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    } else if let channel = channel {
                        self.channel = channel
                        
                        let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                        self.delegate?.userListViewModel(self, didChangeChannel: channel, withContext: context)
                        
                        // If want using your custom user list, filled users with your custom user list.
                        self.loadNextUserList(reset: true, users: self.customizedUsers ?? nil)
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
    
    // MARK: - List handling
    
    /// This function to load the user list.
    ///
    /// This requests the required list according to `userListType`.
    /// If you want using your custom user list, filled users with your custom user list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset user list and load new list
    ///   - users: customized `SBUUser` array for add to user list
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        if reset { self.resetQuery() }
        
        guard !self.isLoading else { return }
        self.isLoading = true
        self.delegate?.shouldUpdateLoadingState(true)
        
        SBULog.info("[Request] Next user List")

        if let users = users {
            // Customized user list
            SBULog.info("\(users.count) customized users have been added.")
            
            self.userList += users
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        } else if self.useCustomizedUsers, let customizedUsers = self.customizedUsers {
            self.userList += customizedUsers
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        } else if !self.useCustomizedUsers {
            switch userListType {
            case .members:
                self.loadNextChannelMemberList()
            case .operators:
                self.loadNextOperatorList()
            case .muted:
                if self.channel is GroupChannel {
                    self.loadNextMutedMemberList()
                } else if self.channel is OpenChannel {
                    self.loadNextMutedParticipantList()
                }
            case .banned:
                self.loadNextBannedUserList()
            case .participants:
                self.loadNextChannelParticipantsList()
            default:
                break
            }
        }
    }

    /// This function loads channel member list. (Group channel)
    ///
    /// If you want to call a list of operators, use the `loadNextUserList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `UserList` alone.
    private func loadNextChannelMemberList() {
        if self.memberListQuery == nil, let channel = self.channel as? GroupChannel {
            let params = MemberListQueryParams()
            params.limit = SBUUserListViewModel.limit
            self.memberListQuery = channel.createMemberListQuery(params: params)
        }
        
        guard self.memberListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All members have been loaded.")
            return
        }
        
        self.memberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.delegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            SBULog.info("[Response] \(members.count) members")

            self.userList += members
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        })
    }
    
    /// This function loads operator list.
    ///
    /// If you want to call a list of operators, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `OperatorList` alone.
    private func loadNextOperatorList() {
        guard let channel = self.channel else { return }
        if self.operatorListQuery == nil {
            let params = OperatorListQueryParams()
            params.limit = SBUUserListViewModel.limit
            self.operatorListQuery = channel.createOperatorListQuery(params: params)
        }
        
        guard self.operatorListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All operators have been loaded.")
            return
        }
        
        self.operatorListQuery?.loadNextPage(completionHandler: {
            [weak self] operators, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.delegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            guard let operators = operators?.sbu_convertUserList() else { return }
            SBULog.info("[Response] \(operators.count) operators")

            self.userList += operators
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        })
    }
    
    /// This function loads muted member list. (Group channel)
    ///
    /// If you want to call a list of muted members, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `MutedMemberList` alone.
    private func loadNextMutedMemberList() {
        if self.mutedMemberListQuery == nil, let channel = self.channel as? GroupChannel {
            let params = MemberListQueryParams()
            params.limit = SBUUserListViewModel.limit
            params.mutedMemberFilter = .muted
            self.mutedMemberListQuery = channel.createMemberListQuery(params: params)
        }
        
        guard self.mutedMemberListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All muted members have been loaded.")
            return
        }
        
        self.mutedMemberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.delegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            SBULog.info("[Response] \(members.count) members")

            self.userList += members
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        })
    }
    
    /// This function loads muted participant list. (Open channel)
    ///
    /// If you want to call a list of muted participants, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `MutedParticipantList` alone.
    ///
    /// - Since: 3.1.0
    private func loadNextMutedParticipantList() {
        if self.mutedParticipantListQuery == nil, let channel = self.channel as? OpenChannel {
            let params = MutedUserListQueryParams()
            params.limit = SBUUserListViewModel.limit
            self.mutedParticipantListQuery = channel.createMutedUserListQuery(params: params)
        }
        
        guard self.mutedParticipantListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All muted participants have been loaded.")
            return
        }
        
        self.mutedParticipantListQuery?.loadNextPage(completionHandler: {
            [weak self, weak channel] members, error in
            guard let self = self, let channel = channel else { return }
            defer {
                self.isLoading = false
                self.delegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            SBULog.info("[Response] \(members.count) members")

            self.userList += members.sbu_updateOperatorStatus(channel: channel)
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        })
    }
    
    /// This function loads banned user list.
    ///
    /// If you want to call a list of banned users, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `BannedUserList` alone.
    private func loadNextBannedUserList() {
        if self.bannedUserListQuery == nil, let channel = self.channel {
            let params = BannedUserListQueryParams()
            params.limit = SBUUserListViewModel.limit
            self.bannedUserListQuery = channel.createBannedUserListQuery(params: params)
        }
        
        guard self.bannedUserListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All banned users have been loaded.")
            return
        }
        
        // return [User]
        self.bannedUserListQuery?.loadNextPage(completionHandler: {
            [weak self] users, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.delegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            guard let users = users?.sbu_convertUserList() else { return }
            SBULog.info("[Response] \(users.count) users")

            self.userList += users
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        })
    }
    
    /// This function loads channel participants list. (Open channel)
    ///
    /// If you want to call a list of operators, use the `loadNextUserList(reset:users:)` function.
    /// - Warning: Use this function only when you need to call `ParticipantList` alone.
    /// - Since: 2.0.0
    private func loadNextChannelParticipantsList() {
        if self.participantListQuery == nil, let channel = self.channel as? OpenChannel {
            let params = ParticipantListQueryParams()
            params.limit = SBUUserListViewModel.limit
            self.participantListQuery = channel.createParticipantListQuery(params: params)
        }
        
        guard self.participantListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All participants have been loaded.")
            return
        }
        
        self.participantListQuery?.loadNextPage(completionHandler: {
            [weak self, weak channel] participants, error in
            guard let self = self, let channel = channel else { return }
            defer {
                self.isLoading = false
                self.delegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            guard let participants = participants?.sbu_convertUserList() else { return }
            SBULog.info("[Response] \(participants.count) participants")

            self.userList += participants.sbu_updateOperatorStatus(channel: channel)
            self.delegate?.userListViewModel(self, didChangeUsers: self.userList, needsToReload: true)
        })
    }
    
    /// This function pre-loads user list.
    ///
    /// When a part of the Tableview is displayed, then this function is load the next user list.
    ///
    /// - Parameter indexPath: TableView's indexpath
    public func preLoadNextUserList(indexPath: IndexPath) {
        guard self.userList.count > 0,
              indexPath.row >= (self.userList.count - Int(SBUUserListViewModel.limit) / 2),
              (self.hasNext() == true) else { return }
        let nextUserList = self.dataSource?.userListViewModel(
            self,
            nextUserListForChannel: self.channel
        )
        self.loadNextUserList(
            reset: false,
            users: nextUserList
        )
    }
    
    /// This function resets the user list.
    public func resetUserList(channel: BaseChannel? = nil) {
        if let channel = channel {
            self.channel = channel
        }
        self.loadNextUserList(reset: true, users: self.customizedUsers)
    }
    
    // MARK: - Query related
    public func hasNext() -> Bool {
        return (self.useCustomizedUsers || self.queryHasNext())
            && !self.isLoading
    }
    
    private func queryHasNext() -> Bool {
        var hasNext = false
        switch self.userListType {
        case .members:
            hasNext = self.memberListQuery?.hasNext ?? false
        case .operators:
            hasNext = self.operatorListQuery?.hasNext ?? false
        case .muted:
            if self.channel is GroupChannel {
                hasNext = self.mutedMemberListQuery?.hasNext ?? false
            } else if self.channel is OpenChannel {
                hasNext = self.mutedParticipantListQuery?.hasNext ?? false
            }
        case .banned:
            hasNext = self.bannedUserListQuery?.hasNext ?? false
        case .participants:
            hasNext = self.participantListQuery?.hasNext ?? false
        default:
            break
        }
        
        return hasNext
    }
    
    public func resetQuery() {
        self.memberListQuery = nil
        self.operatorListQuery = nil
        self.mutedMemberListQuery = nil
        self.mutedParticipantListQuery = nil
        self.bannedUserListQuery = nil
        self.participantListQuery = nil
        self.userList = []
    }
    
    // MARK: - Channel actions
    
    /// Register as operator with user onject.
    /// - Parameter user: user to register
    public func registerAsOperator(user: SBUUser) {
        guard let channel = self.channel else { return }
        let userId = user.userId
        
        self.delegate?.shouldUpdateLoadingState(true)
        SBULog.info("[Request] Register user: \(userId)")

        channel.addOperators(userIds: [userId], completionHandler: self.userStateChangedHandler)
    }

    /// Unregister operator with member onject.
    /// - Parameter user: operator to unregister
    public func unregisterOperator(user: SBUUser) {
        guard let channel = self.channel else { return }
        let userId = user.userId
        
        self.delegate?.shouldUpdateLoadingState(true)
        SBULog.info("[Request] Unregister operator: \(userId)")
        
        channel.removeOperators(userIds: [userId], completionHandler: self.userStateChangedHandler)
    }
    
    /// This function mutes the member in the case of channel.
    /// - Parameter user: A member/participant to be muted
    public func mute(user: SBUUser) {
        if let groupChannel = self.channel as? GroupChannel {
            groupChannel.muteUser(userId: user.userId, seconds: -1, description: nil, completionHandler: self.userStateChangedHandler)
        } else if let openChannel = self.channel as? OpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.muteUser(userId: user.userId, seconds: -1, description: nil, completionHandler: self.userStateChangedHandler)
        }
    }
    
    /// This function unmutes the member in the case of channel.
    /// - Parameter user: A member/participant to be unmuted
    public func unmute(user: SBUUser) {
        if let groupChannel = self.channel as? GroupChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            groupChannel.unmuteUser(userId: user.userId, completionHandler: self.userStateChangedHandler)
        } else if let openChannel = self.channel as? OpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.unmuteUser(userId: user.userId, completionHandler: self.userStateChangedHandler)
        }
    }
    
    /// This function bans the user in the case of channel.
    /// - Parameter user: A user to be banned
    public func ban(user: SBUUser) {
        if let groupChannel = self.channel as? GroupChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            groupChannel.banUser(
                userId: user.userId,
                seconds: -1,
                description: nil,
                completionHandler: self.userStateChangedHandler
            )
        } else if let openChannel = self.channel as? OpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.banUser(
                userId: user.userId,
                seconds: -1,
                description: nil,
                completionHandler: self.userStateChangedHandler
            )
        }
    }

    /// This function unbans the user.
    /// - Parameter user: A user to be unbanned
    public func unban(user: SBUUser) {
        if let groupChannel = self.channel as? GroupChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            groupChannel.unbanUser(
                userId: user.userId,
                completionHandler: self.userStateChangedHandler
            )
        } else if let openChannel = self.channel as? OpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.unbanUser(
                userId: user.userId,
                completionHandler: self.userStateChangedHandler
            )
        }
    }
}

// MARK: - GroupChannelDelegate
extension SBUUserListViewModel: BaseChannelDelegate {
    public func channel(_ channel: BaseChannel, userWasMuted user: RestrictedUser) {
        guard self.userListType != .members,
              self.userListType != .participants else { return }
        self.resetUserList(channel: channel)
    }
    public func channel(_ channel: BaseChannel, userWasUnmuted user: User) {
        guard self.userListType != .members,
              self.userListType != .participants else { return }
        self.resetUserList(channel: channel)
    }
    public func channelDidUpdateOperators(_ channel: BaseChannel) {
        guard self.userListType != .members,
              self.userListType != .participants else { return }
        self.resetUserList(channel: channel)
    }
    public func channel(_ channel: BaseChannel, userWasBanned user: RestrictedUser) {
        guard self.userListType != .members,
              self.userListType != .participants else { return }
        self.resetUserList(channel: channel)
    }
    public func channel(_ channel: BaseChannel, userWasUnbanned user: User) {
        guard self.userListType != .members,
              self.userListType != .participants else { return }
        self.resetUserList(channel: channel)
    }
    
    public func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {
        self.delegate?.userListViewModel(self, shouldDismissForUserList: nil)
    }
}

extension SBUUserListViewModel: GroupChannelDelegate {
    open func channel(_ channel: GroupChannel, userDidJoin user: User) {
        self.resetUserList(channel: channel)
    }
    
    open func channel(_ channel: GroupChannel, userDidLeave user: User) {
        self.resetUserList(channel: channel)
    }
}

// MARK: - OpenChannelDelegate
extension SBUUserListViewModel: OpenChannelDelegate {
    open func channel(_ channel: OpenChannel, userDidExit user: User) {
//        self.resetUserList()
    }

    open func channel(_ channel: OpenChannel, userDidEnter user: User) {
//        self.resetUserList()
    }
}
