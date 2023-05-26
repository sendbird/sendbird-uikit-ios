//
//  SBUViewControllerSet.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUViewControllerSet {
    
    public static var GroupChannelListViewController: SBUGroupChannelListViewController.Type = SBUGroupChannelListViewController.self
    public static var OpenChannelListViewController: SBUOpenChannelListViewController.Type = SBUOpenChannelListViewController.self
    
    public static var GroupChannelViewController: SBUGroupChannelViewController.Type = SBUGroupChannelViewController.self
    public static var OpenChannelViewController: SBUOpenChannelViewController.Type = SBUOpenChannelViewController.self
    
    public static var FeedNotificationChannelViewController: SBUFeedNotificationChannelViewController.Type = SBUFeedNotificationChannelViewController.self
    public static var ChatNotificationChannelViewController: SBUChatNotificationChannelViewController.Type = SBUChatNotificationChannelViewController.self
    
    public static var CreateChannelViewController: SBUCreateChannelViewController.Type = SBUCreateChannelViewController.self
    public static var CreateOpenChannelViewController: SBUCreateOpenChannelViewController.Type = SBUCreateOpenChannelViewController.self
    
    public static var InviteUserViewController: SBUInviteUserViewController.Type = SBUInviteUserViewController.self
    
    public static var GroupChannelRegisterOperatorViewController: SBURegisterOperatorViewController.Type = SBURegisterOperatorViewController.self
    public static var OpenChannelRegisterOperatorViewController: SBURegisterOperatorViewController.Type = SBURegisterOperatorViewController.self
    
    public static var GroupUserListViewController: SBUUserListViewController.Type = SBUUserListViewController.self
    public static var OpenUserListViewController: SBUUserListViewController.Type = SBUUserListViewController.self
    
    public static var GroupChannelPushSettingsViewController: SBUGroupChannelPushSettingsViewController.Type = SBUGroupChannelPushSettingsViewController.self
    
    public static var GroupChannelSettingsViewController: SBUGroupChannelSettingsViewController.Type = SBUGroupChannelSettingsViewController.self
    public static var OpenChannelSettingsViewController: SBUOpenChannelSettingsViewController.Type = SBUOpenChannelSettingsViewController.self
    
    public static var GroupModerationsViewController: SBUModerationsViewController.Type = SBUModerationsViewController.self
    public static var OpenModerationsViewController: SBUModerationsViewController.Type = SBUModerationsViewController.self
    
    public static var MessageSearchViewController: SBUMessageSearchViewController.Type = SBUMessageSearchViewController.self
    
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
