//
//  SBUViewControllerSet.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//
// swiftlint:disable identifier_name
// swiftlint:disable missing_docs

import UIKit

public class SBUViewControllerSet {
    // MARK: Key functions
    /// The view controller for the group channel list.
    public static var GroupChannelListViewController: SBUGroupChannelListViewController.Type = SBUGroupChannelListViewController.self
    /// The view controller for the open channel list.
    public static var OpenChannelListViewController: SBUOpenChannelListViewController.Type = SBUOpenChannelListViewController.self
    
    /// The view controller for the group channel chat.
    public static var GroupChannelViewController: SBUGroupChannelViewController.Type = SBUGroupChannelViewController.self
    /// The view controller for the open channel chat.
    public static var OpenChannelViewController: SBUOpenChannelViewController.Type = SBUOpenChannelViewController.self
    
    /// The view controller for the feed notification channel.
    public static var FeedNotificationChannelViewController: SBUFeedNotificationChannelViewController.Type = SBUFeedNotificationChannelViewController.self
    /// The view controller for the chat notification channel.
    public static var ChatNotificationChannelViewController: SBUChatNotificationChannelViewController.Type = SBUChatNotificationChannelViewController.self
    
    /// The view controller for creating a group channel.
    public static var CreateChannelViewController: SBUCreateChannelViewController.Type = SBUCreateChannelViewController.self
    /// The view controller for creating an open channel.
    public static var CreateOpenChannelViewController: SBUCreateOpenChannelViewController.Type = SBUCreateOpenChannelViewController.self
    
    /// The view controller for inviting users.
    public static var InviteUserViewController: SBUInviteUserViewController.Type = SBUInviteUserViewController.self

    /// The view controller for registering an operator for a group channel.
    public static var GroupChannelRegisterOperatorViewController: SBURegisterOperatorViewController.Type = SBURegisterOperatorViewController.self
    /// The view controller for registering an operator for an open channel.
    public static var OpenChannelRegisterOperatorViewController: SBURegisterOperatorViewController.Type = SBURegisterOperatorViewController.self
    
    /// The view controller for the group channel user list.
    public static var GroupUserListViewController: SBUUserListViewController.Type = SBUUserListViewController.self
    /// The view controller for the open channel user list.
    public static var OpenUserListViewController: SBUUserListViewController.Type = SBUUserListViewController.self
    
    /// The view controller for the group channel push settings.
    public static var GroupChannelPushSettingsViewController: SBUGroupChannelPushSettingsViewController.Type = SBUGroupChannelPushSettingsViewController.self
    
    /// The view controller for the group channel settings.
    public static var GroupChannelSettingsViewController: SBUGroupChannelSettingsViewController.Type = SBUGroupChannelSettingsViewController.self
    /// The view controller for the open channel settings.
    public static var OpenChannelSettingsViewController: SBUOpenChannelSettingsViewController.Type = SBUOpenChannelSettingsViewController.self
    
    /// The view controller for the group channel moderations.
    public static var GroupModerationsViewController: SBUModerationsViewController.Type = SBUModerationsViewController.self
    /// The view controller for the open channel moderations.
    public static var OpenModerationsViewController: SBUModerationsViewController.Type = SBUModerationsViewController.self
    
    /// The view controller for the message search.
    public static var MessageSearchViewController: SBUMessageSearchViewController.Type = SBUMessageSearchViewController.self
    
    /// The view controller for the group channel message thread.
    public static var MessageThreadViewController: SBUMessageThreadViewController.Type = SBUMessageThreadViewController.self
}

extension SBUViewControllerSet {
    @available(*, unavailable, message: "This property had been seperated to `GroupChannelRegisterOperatorViewController` and `OpenChannelRegisterOperatorViewController`") // 3.1.0
    public static var RegisterOperatorViewController: SBURegisterOperatorViewController.Type = SBURegisterOperatorViewController.self
    
    @available(*, unavailable, message: "This property had been seperated to `GroupUserListViewController` and `OpenUserListViewController`") // 3.1.0
    public static var UserListViewController: SBUUserListViewController.Type = SBUUserListViewController.self
    
    @available(*, unavailable, message: "This property had been seperated to `GroupModerationsViewController` and `OpenModerationsViewController`") // 3.1.0
    public static var ModerationsViewController: SBUModerationsViewController.Type = SBUModerationsViewController.self
    
    @available(*, unavailable, message: "This property had renamed `InviteUserViewController`") // 3.1.2
    public static var InviteUserViewContoller: SBUInviteUserViewController.Type = SBUInviteUserViewController.self
}

// swiftlint:enable identifier_name
// swiftlint:enable missing_docs
