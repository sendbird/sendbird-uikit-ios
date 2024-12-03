//
//  SBUViewModelSet.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/21/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/// A class that holds references to various view model types used in the Sendbird UIKit.
/// - Since: 3.28.0
public class SBUViewModelSet {
    /// The view model for the group channel list.
    public static var GroupChannelListViewModel: SBUGroupChannelListViewModel.Type = SBUGroupChannelListViewModel.self
    /// The view model for the open channel list.
    public static var OpenChannelListViewModel: SBUOpenChannelListViewModel.Type = SBUOpenChannelListViewModel.self
    
    /// The view model for the group channel chat.
    public static var GroupChannelViewModel: SBUGroupChannelViewModel.Type = SBUGroupChannelViewModel.self
    /// The view model for the open channel chat.
    public static var OpenChannelViewModel: SBUOpenChannelViewModel.Type = SBUOpenChannelViewModel.self
    
    // TODO: Not supported yet
//    /// The view model for the feed notification channel.
//    public static var FeedNotificationChannelViewModel: SBUFeedNotificationChannelViewModel.Type = SBUFeedNotificationChannelViewModel.self
//    /// The view model for the chat notification channel.
//    public static var ChatNotificationChannelViewModel: SBUChatNotificationChannelViewModel.Type = SBUChatNotificationChannelViewModel.self
    
    /// The view model for creating a group channel.
    public static var CreateGroupChannelViewModel: SBUCreateChannelViewModel.Type = SBUCreateChannelViewModel.self
    /// The view model for creating an open channel.
    public static var CreateOpenChannelViewModel: SBUCreateOpenChannelViewModel.Type = SBUCreateOpenChannelViewModel.self
    
    /// The view model for inviting users.
    public static var InviteUserViewModel: SBUInviteUserViewModel.Type = SBUInviteUserViewModel.self

    /// The view model for registering an operator for a group channel.
    public static var GroupChannelRegisterOperatorViewModel: SBURegisterOperatorViewModel.Type = SBURegisterOperatorViewModel.self
    /// The view model for registering an operator for an open channel.
    public static var OpenChannelRegisterOperatorViewModel: SBURegisterOperatorViewModel.Type = SBURegisterOperatorViewModel.self
    
    /// The view model for the group channel user list.
    public static var GroupUserListViewModel: SBUUserListViewModel.Type = SBUUserListViewModel.self
    /// The view model for the open channel user list.
    public static var OpenUserListViewModel: SBUUserListViewModel.Type = SBUUserListViewModel.self
    
    /// The view model for the group channel push settings.
    public static var GroupChannelPushSettingsViewModel: SBUGroupChannelPushSettingsViewModel.Type = SBUGroupChannelPushSettingsViewModel.self
    
    /// The view model for the group channel settings.
    public static var GroupChannelSettingsViewModel: SBUGroupChannelSettingsViewModel.Type = SBUGroupChannelSettingsViewModel.self
    /// The view model for the open channel settings.
    public static var OpenChannelSettingsViewModel: SBUOpenChannelSettingsViewModel.Type = SBUOpenChannelSettingsViewModel.self
    
    /// The view model for the group channel moderations.
    public static var GroupModerationsViewModel: SBUModerationsViewModel.Type = SBUModerationsViewModel.self
    /// The view model for the open channel moderations.
    public static var OpenModerationsViewModel: SBUModerationsViewModel.Type = SBUModerationsViewModel.self
    
    /// The view model for the message search.
    public static var MessageSearchViewModel: SBUMessageSearchViewModel.Type = SBUMessageSearchViewModel.self
    
    /// The view model for the group channel message thread.
    public static var MessageThreadViewModel: SBUMessageThreadViewModel.Type = SBUMessageThreadViewModel.self
}
