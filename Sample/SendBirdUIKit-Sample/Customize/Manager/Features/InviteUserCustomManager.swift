//
//  InviteUserCustomManager.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class InviteUserCustomManager: BaseCustomManager {
    static var shared = InviteUserCustomManager()
    
    func startSample(naviVC: UINavigationController, type: InviteUserCustomType?) {
        self.navigationController = naviVC
        
        switch type {
        case .uiComponent:
            uiComponentCustom()
        case .customCell:
            cellCustom()
        case .userList:
            userListCustom()
        default:
            break
        }
    }
}


extension InviteUserCustomManager {
    func uiComponentCustom() {
        ChannelManager.getSampleChannel { channel in
            let inviteUserVC = SBUInviteUserViewController(channel: channel)
            
            // This part changes the default titleView to a custom view.
            inviteUserVC.titleView = self.createHighlightedTitleLabel()
            
            // This part changes the default leftBarButton to a custom leftBarButton.
            // RightButton can also be changed in this way.
            inviteUserVC.leftBarButton = self.createHighlightedBackButton()
            
            // Move to InviteUserViewController using customized components
            self.navigationController?.pushViewController(inviteUserVC, animated: true)
        }
    }
    
    func cellCustom() {
        ChannelManager.getSampleChannel { channel in
            let inviteUserVC = InviteUserVC_Cell(channel: channel)
            
            // This part changes the default user cell to a custom cell.
            inviteUserVC.register(userCell: CustomUserCell())
            
            self.navigationController?.pushViewController(inviteUserVC, animated: true)
        }
    }
    
    func userListCustom() {
        let userListQuery = SBDMain.createApplicationUserListQuery()
        userListQuery?.limit = 20
        userListQuery?.loadNextPage(completionHandler: { users, error in
            guard error == nil else { return }
            
            // This is a user list object used for testing.
            guard let users = users?.sbu_convertUserList() else { return }
            
            ChannelManager.getSampleChannel { channel in
                // If you use a list of users who have internally generated relationship data, you can use it as follows:
                // When you're actually using it, include a list of users you're managing directly here.
                let inviteUserVC = InviteUserVC_UserList(channel: channel, users: users)
                
                // Push ViewController after calling the dummy user list.
                inviteUserVC.loadDummyUsers {
                    self.navigationController?.pushViewController(inviteUserVC, animated: true)
                }
            }
        })
    }
}
