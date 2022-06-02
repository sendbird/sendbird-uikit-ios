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
    
    public static var GroupChannelViewController: SBUGroupChannelViewController.Type = SBUGroupChannelViewController.self
    public static var OpenChannelViewController: SBUOpenChannelViewController.Type = SBUOpenChannelViewController.self
    
    public static var CreateChannelViewController: SBUCreateChannelViewController.Type = SBUCreateChannelViewController.self
    public static var InviteUserViewContoller: SBUInviteUserViewController.Type = SBUInviteUserViewController.self
    public static var PromoteMemberViewController: SBUPromoteMemberViewController.Type = SBUPromoteMemberViewController.self
    
    public static var MemberListViewController: SBUMemberListViewController.Type = SBUMemberListViewController.self
    
    public static var groupChannelPushSettingsViewController: SBUGroupChannelPushSettingsViewController.Type = SBUGroupChannelPushSettingsViewController.self
    
    public static var GroupChannelSettingsViewController: SBUGroupChannelSettingsViewController.Type = SBUGroupChannelSettingsViewController.self
    public static var OpenChannelSettingsViewController: SBUOpenChannelSettingsViewController.Type = SBUOpenChannelSettingsViewController.self
    
    public static var ModerationsViewController: SBUModerationsViewController.Type = SBUModerationsViewController.self
    
    public static var MessageSearchViewController: SBUMessageSearchViewController.Type = SBUMessageSearchViewController.self
}
