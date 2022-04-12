//
//  SBUMemberListViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK


public protocol SBUMemberListViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the members has been changed
    func memberListViewModel(
        _ viewModel: SBUMemberListViewModel,
        didChangeMembers members: [SBUUser],
        needsToReload: Bool
    )
    
    /// Called when the channel has been changed.
    func memberListViewModel(
        _ viewModel: SBUMemberListViewModel,
        didChangeChannel channel: SBDBaseChannel?,
        withContext context: SBDMessageContext
    )
}


public protocol SBUMemberListViewModelDataSource: AnyObject {
    /// Asks to data source to return the next member list for the channel. When create and use the member list directly, override this function.
    /// - Important: If you want to use this function, please set the `SBUMemberListViewModelDataSource` in your class.
    /// - Returns: The next member list.
    func memberListViewModel(
        _ viewModel: SBUMemberListViewModel,
        nextMemberListForChannel channel: SBDBaseChannel?
    ) -> [SBUUser]?
}



open class SBUMemberListViewModel: NSObject  {
    // MARK: - Constants
    static let limit: UInt = 20
    
    
    // MARK: - Property (Public)
    public private(set) var channel: SBDBaseChannel?
    public private(set) var channelUrl: String?
    public private(set) var channelType: SBDChannelType = .group
    
    @SBUAtomic public private(set) var memberList: [SBUUser] = []
    
    public var memberListQuery: SBDGroupChannelMemberListQuery?
    public var operatorListQuery: SBDOperatorListQuery?
    public var mutedMemberListQuery: SBDGroupChannelMemberListQuery?
    public var bannedMemberListQuery: SBDBannedUserListQuery?
    public var participantListQuery: SBDParticipantListQuery?
    
    public private(set) var memberListType: ChannelMemberListType = .none
    
    
    // MARK: - Property (Private)
    weak var delegate: SBUMemberListViewModelDelegate?
    weak var dataSource: SBUMemberListViewModelDataSource?
    
    @SBUAtomic private var customizedMembers: [SBUUser]?
    private var useCustomizedMembers = false

    @SBUAtomic private var isLoading = false
    
    var memberStateChangedHandler: ((SBDError?) -> Void)?

    
    // MARK: - Life Cycle
    public init(
        channel: SBDBaseChannel? = nil,
        channelUrl: String? = nil,
        channelType: SBDChannelType = .group,
        members: [SBUUser]? = nil,
        memberListType: ChannelMemberListType,
        memberListQuery: SBDGroupChannelMemberListQuery? = nil,
        operatorListQuery: SBDOperatorListQuery? = nil,
        mutedMemberListQuery: SBDGroupChannelMemberListQuery? = nil,
        bannedMemberListQuery: SBDBannedUserListQuery? = nil,
        participantListQuery: SBDParticipantListQuery? = nil,
        delegate: SBUMemberListViewModelDelegate? = nil,
        dataSource: SBUMemberListViewModelDataSource? = nil
    ) {
        self.delegate = delegate
        self.dataSource = dataSource
        
        super.init()
        
        if let channel = channel {
            self.channel = channel
            self.channelUrl = channel.channelUrl
        } else if let channelUrl = channelUrl {
            self.channelUrl = channelUrl
        }
        self.channelType = channelType
        
        self.memberListType = memberListType
        
        self.memberListQuery = memberListQuery
        self.operatorListQuery = operatorListQuery
        self.mutedMemberListQuery = mutedMemberListQuery
        self.bannedMemberListQuery = bannedMemberListQuery
        self.participantListQuery = participantListQuery
        
        self.customizedMembers = members
        self.useCustomizedMembers = (members?.count ?? 0) > 0
        
        self.memberStateChangedHandler = { [weak self] error in
            defer { self?.delegate?.shouldUpdateLoadingState(false) }
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            // If want using your custom member list, filled users with your custom user list.
            self.loadNextMemberList(reset: true, members: self.customizedMembers ?? nil)
        }
        
        
        SBDMain.add(
            self as SBDChannelDelegate,
            identifier: "\(SBUConstant.channelDelegateIdentifier).\(self.description)"
        )
        
        guard let channelUrl = self.channelUrl else { return }
        self.loadChannel(channelUrl: channelUrl, type: channelType)
    }
    
    deinit {
        SBDMain.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.channelDelegateIdentifier).\(self.description)"
        )
    }
    
    
    // MARK: - Channel related
    public func loadChannel(channelUrl: String, type: SBDChannelType) {
        self.delegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.shouldUpdateLoadingState(false)
                self.delegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((SBDBaseChannel?, SBDError?) -> Void) = {
                    [weak self] channel, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    } else if let channel = channel {
                        self.channel = channel
                        
                        let context = SBDMessageContext()
                        context.source = .eventChannelChanged
                        self.delegate?.memberListViewModel(self, didChangeChannel: channel, withContext: context)
                        
                        // If want using your custom member list, filled users with your custom user list.
                        self.loadNextMemberList(reset: true, members: self.customizedMembers ?? nil)
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
    
    
    // MARK: - List handling
    
    /// This function to load the member list.
    ///
    /// This requests the required list according to `memberListType`.
    /// If you want using your custom member list, filled members with your custom member list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset member list and load new list
    ///   - members: customized `SBUUser` array for add to member list
    public func loadNextMemberList(reset: Bool, members: [SBUUser]? = nil) {
        if reset { self.resetQuery() }
        
        guard !self.isLoading else { return }
        self.isLoading = true
        self.delegate?.shouldUpdateLoadingState(true)
        
        SBULog.info("[Request] Next member List")

        if let members = members {
            // Customized member list
            SBULog.info("\(members.count) customized members have been added.")
            
            self.memberList += members
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            self.delegate?.memberListViewModel(self, didChangeMembers: self.memberList, needsToReload: true)
        }
        else if self.useCustomizedMembers, let customizedMembers = self.customizedMembers {
            self.memberList += customizedMembers
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            self.delegate?.memberListViewModel(self, didChangeMembers: self.memberList, needsToReload: true)
        }
        else if !self.useCustomizedMembers {
            switch memberListType {
            case .channelMembers:
                self.loadNextChannelMemberList()
            case .operators:
                self.loadNextOperatorList()
            case .mutedMembers:
                self.loadNextMutedMemberList()
            case .bannedMembers:
                self.loadNextBannedMemberList()
            case .participants:
                self.loadNextChannelParticipantsList()
            default:
                break
            }
        }
    }

    /// This function loads channel member list.
    ///
    /// If you want to call a list of operators, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `MemberList` alone.
    private func loadNextChannelMemberList() {
        if self.memberListQuery == nil, let channel = self.channel as? SBDGroupChannel {
            self.memberListQuery = channel.createMemberListQuery()
            self.memberListQuery?.limit = SBUMemberListViewModel.limit
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
            self.memberList += members
            self.delegate?.memberListViewModel(self, didChangeMembers: self.memberList, needsToReload: true)
        })
    }
    
    /// This function loads operator list.
    ///
    /// If you want to call a list of operators, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `OperatorList` alone.
    private func loadNextOperatorList() {
        guard let channel = self.channel else { return }
        if self.operatorListQuery == nil {
            self.operatorListQuery = channel.createOperatorListQuery()
            self.operatorListQuery?.limit = SBUMemberListViewModel.limit
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
            self.memberList += operators
            self.delegate?.memberListViewModel(self, didChangeMembers: self.memberList, needsToReload: true)
        })
    }
    
    /// This function loads muted member list.
    ///
    /// If you want to call a list of muted members, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `MutedMemberList` alone.
    private func loadNextMutedMemberList() {
        if self.mutedMemberListQuery == nil, let channel = self.channel as? SBDGroupChannel {
            self.mutedMemberListQuery = channel.createMemberListQuery()
            self.mutedMemberListQuery?.limit = SBUMemberListViewModel.limit
            self.mutedMemberListQuery?.mutedMemberFilter = .muted
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
            self.memberList += members
            self.delegate?.memberListViewModel(self, didChangeMembers: self.memberList, needsToReload: true)
        })
    }
    
    
    /// This function loads banned member list.
    ///
    /// If you want to call a list of banned members, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `BannedMemberList` alone.
    private func loadNextBannedMemberList() {
        if self.bannedMemberListQuery == nil, let channel = self.channel as? SBDGroupChannel {
            self.bannedMemberListQuery = channel.createBannedUserListQuery()
            self.bannedMemberListQuery?.limit = SBUMemberListViewModel.limit
        }
        
        guard self.bannedMemberListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All muted members have been loaded.")
            return
        }
        
        // return [SBDUser]
        self.bannedMemberListQuery?.loadNextPage(completionHandler: {
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
            self.memberList += users
            self.delegate?.memberListViewModel(self, didChangeMembers: self.memberList, needsToReload: true)
        })
    }
    
    /// This function loads channel participants list.
    ///
    /// If you want to call a list of operators, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `MemberList` alone.
    /// - Since: 2.0.0
    private func loadNextChannelParticipantsList() {
        if self.participantListQuery == nil, let channel = self.channel as? SBDOpenChannel {
            self.participantListQuery = channel.createParticipantListQuery()
            self.participantListQuery?.limit = SBUMemberListViewModel.limit
        }
        
        guard self.participantListQuery?.hasNext == true else {
            self.isLoading = false
            self.delegate?.shouldUpdateLoadingState(false)
            SBULog.info("All participants have been loaded.")
            return
        }
        
        self.participantListQuery?.loadNextPage(completionHandler: {
            [weak self] participants, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.delegate?.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            guard let participants = participants?.sbu_convertUserList() else { return }
            self.memberList += participants
            self.delegate?.memberListViewModel(self, didChangeMembers: self.memberList, needsToReload: true)
        })
    }
    
    /// This function pre-loads member list.
    ///
    /// When a part of the Tableview is displayed, then this function is load the next member list.
    ///
    /// - Parameter indexPath: TableView's indexpath
    public func preLoadNextMemberList(indexPath: IndexPath) {
        guard self.memberList.count > 0,
              indexPath.row >= (self.memberList.count - Int(SBUMemberListViewModel.limit) / 2),
              (self.hasNext() == true) else { return }
        let nextMemberList = self.dataSource?.memberListViewModel(
            self,
            nextMemberListForChannel: self.channel
        )
        self.loadNextMemberList(
            reset: false,
            members: nextMemberList
        )
    }
    
    /// This function resets the member list.
    public func resetMemberList() {
        self.loadNextMemberList(reset: true, members: self.customizedMembers)
    }
    
    
    // MARK: - Query related
    public func hasNext() -> Bool {
        return (self.useCustomizedMembers || self.queryHasNext())
            && !self.isLoading
    }
    
    private func queryHasNext() -> Bool {
        var hasNext = false
        switch self.memberListType {
        case .channelMembers:
            hasNext = self.memberListQuery?.hasNext ?? false
        case .operators:
            hasNext = self.operatorListQuery?.hasNext ?? false
        case .mutedMembers:
            hasNext = self.mutedMemberListQuery?.hasNext ?? false
        case .bannedMembers:
            hasNext = self.bannedMemberListQuery?.hasNext ?? false
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
        self.bannedMemberListQuery = nil
        self.participantListQuery = nil
        self.memberList = []
    }
    
    
    // MARK: - Channel actions
    
    /// Promotes member as operator with member onject.
    /// - Parameter member: member to promote
    func promoteToOperator(member: SBUUser) {
        guard let channel = self.channel else { return }
        let userId = member.userId
        
        self.delegate?.shouldUpdateLoadingState(true)
        SBULog.info("[Request] Promote member: \(userId)")

        channel.addOperators(withUserIds: [userId], completionHandler: self.memberStateChangedHandler)
    }

    /// Dismisses member with member onject.
    /// - Parameter member: member to dismiss
    func dismissOperator(member: SBUUser) {
        guard let channel = self.channel else { return }
        let userId = member.userId
        
        self.delegate?.shouldUpdateLoadingState(true)
        SBULog.info("[Request] Dismiss operator: \(userId)")
        
        channel.removeOperators(withUserIds: [userId], completionHandler: self.memberStateChangedHandler)
    }
    
    /// This function mutes the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be muted
    func mute(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            groupChannel.muteUser(withUserId: member.userId, completionHandler: self.memberStateChangedHandler)
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.muteUser(withUserId: member.userId, completionHandler: self.memberStateChangedHandler)
        }
    }
    
    /// This function unmutes the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be unmuted
    func unmute(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            groupChannel.unmuteUser(withUserId: member.userId, completionHandler: self.memberStateChangedHandler)
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.unmuteUser(withUserId: member.userId, completionHandler: self.memberStateChangedHandler)
        }
    }
    
    /// This function bans the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be banned
    public func ban(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            groupChannel.banUser(
                withUserId: member.userId,
                seconds: -1,
                description: nil,
                completionHandler: self.memberStateChangedHandler
            )
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.banUser(
                withUserId: member.userId,
                seconds: -1,
                completionHandler: self.memberStateChangedHandler
            )
        }
    }

    /// This function unbans the member.
    /// - Parameter member: A member to be unbanned
    public func unban(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            groupChannel.unbanUser(
                withUserId: member.userId,
                completionHandler: self.memberStateChangedHandler
            )
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.delegate?.shouldUpdateLoadingState(true)
            openChannel.unbanUser(
                withUserId: member.userId,
                completionHandler: self.memberStateChangedHandler
            )
        }
    }
}


// MARK: - SBDChannelDelegate
extension SBUMemberListViewModel: SBDChannelDelegate {
    open func channelDidUpdateOperators(_ sender: SBDBaseChannel) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        self.resetMemberList()
    }
}
