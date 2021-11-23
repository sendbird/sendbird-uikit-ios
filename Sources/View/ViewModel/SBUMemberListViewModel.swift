//
//  SBUMemberListViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

class SBUMemberListViewModel: SBUChannelActionViewModel  {
    static let limit: UInt = 20
    
    @SBUAtomic private var isLoading = false
    
    private let useCustomList: Bool
    
    private(set) var memberListQuery: SBDGroupChannelMemberListQuery?
    private(set) var operatorListQuery: SBDOperatorListQuery?
    private(set) var mutedMemberListQuery: SBDGroupChannelMemberListQuery?
    private(set) var bannedMemberListQuery: SBDBannedUserListQuery?
    private(set) var participantListQuery: SBDParticipantListQuery?
    
    var resetObservable = SBUObservable<Void>()
    var queryListObservable = SBUObservable<[SBUUser]>()
    
    init(useCustomList: Bool) {
        self.useCustomList = useCustomList
    }
    
    // MARK: - Group Channel Members
    
    func loadMembersFromChannelObject() {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        if let members = channel.members as? [SBDMember] {
            self.resetObservable.set(value: ())
            self.queryListObservable.set(value: members.sbu_convertUserList())
        }
    }
    
    // MARK: - List query
    
    func resetQuery() {
        self.memberListQuery = nil
        self.operatorListQuery = nil
        self.mutedMemberListQuery = nil
        self.bannedMemberListQuery = nil
        self.participantListQuery = nil

        self.resetObservable.set(value: ())
    }
    
    func hasNext(memberListType: ChannelMemberListType) -> Bool {
        return (self.useCustomList || self.queryHasNext(memberListType: memberListType))
            && !self.isLoading
    }
    
    private func queryHasNext(memberListType: ChannelMemberListType) -> Bool {
        var hasNext = false
        switch memberListType {
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
    
    func loadNextMemberList(memberListType: ChannelMemberListType, members: [SBUUser]? = nil) {
        guard !self.isLoading else { return }
        self.isLoading = true
        
        SBULog.info("[Request] Next member List")

        if let members = members {
            // Customized member list
            SBULog.info("\(members.count) customized members have been added.")
            
            self.queryListObservable.set(value: members)
            self.isLoading = false
        }
        else if !self.useCustomList {
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
            SBULog.info("All members have been loaded.")
            return
        }
        
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
            self.queryListObservable.set(value: members)
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
            SBULog.info("All operators have been loaded.")
            return
        }
        
        self.operatorListQuery?.loadNextPage(completionHandler: {
            [weak self] operators, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Operator list request: \(error.localizedDescription)")
                self.errorObservable.set(value: error)
                return
            }
            guard let operators = operators?.sbu_convertUserList() else { return }
            self.queryListObservable.set(value: operators)
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
            SBULog.info("All muted members have been loaded.")
            return
        }
        
        // return [SBDMember]
        self.mutedMemberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Muted member list request: \(error.localizedDescription)")
                self.errorObservable.set(value: error)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            self.queryListObservable.set(value: members)
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
            SBULog.info("All muted members have been loaded.")
            return
        }
        
        // return [SBDUser]
        self.bannedMemberListQuery?.loadNextPage(completionHandler: {
            [weak self] users, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Muted member list request: \(error.localizedDescription)")
                self.errorObservable.set(value: error)
                return
            }
            guard let users = users?.sbu_convertUserList() else { return }
            self.queryListObservable.set(value: users)
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
            SBULog.info("All participants have been loaded.")
            return
        }
        
        self.participantListQuery?.loadNextPage(completionHandler: {
            [weak self] participants, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Participants list request: \(error.localizedDescription)")
                self.errorObservable.set(value: error)
                return
            }
            guard let participants = participants?.sbu_convertUserList() else { return }
            self.queryListObservable.set(value: participants)
        })
    }
    
    override func dispose() {
        super.dispose()
        self.resetObservable.dispose()
        self.queryListObservable.dispose()
    }
}
