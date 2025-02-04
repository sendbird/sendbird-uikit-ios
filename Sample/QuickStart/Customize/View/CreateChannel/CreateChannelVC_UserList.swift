//
//  CreateChannelVC_UserList.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/07.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// -------------------------------------------------------------------
/// This section is related to using the custom user list. (Overriding)
/// -------------------------------------------------------------------
class CreateChannelVC_UserList: SBUCreateChannelViewController {
    public var dummyUserList: [SBUUser] = []
    public var dummyUserListPage = 0
    
    /// When creating and using a user list directly, overriding this function and return the next user list.
    open override func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        nextUserListForChannelType channelType: ChannelCreationType) -> [SBUUser]?
    {
        let startIdx = dummyUserListPage*10
        let endIdx = (dummyUserListPage+1)*10
        
        var userList: [SBUUser] = []
        guard dummyUserList.count >= endIdx, dummyUserList.count != 0 else { return nil }
        
        for i in startIdx..<endIdx {
            userList += [dummyUserList[i]]
        }
        dummyUserListPage += 1
            
        return userList
    }
}

/// -------------------------------------------------------------------
/// This section is related to using the custom user list. (Function call)
/// -------------------------------------------------------------------
extension CreateChannelVC_UserList {
    func loadCustomUserList() {
        // If you use a list of users who have internally generated relationship data,
        // you can use it as follows:
        // Case: 1st list call
        let users: [SBUUser] = [] // Include a list of users you have created here.
        self.viewModel?.loadNextUserList(reset: true, users: users)
    }
    
    func loadNextCustomUserList() {
        // If you use a list of users who have internally generated relationship data,
        // you can use it as follows:
        // Case: next list call
        let users: [SBUUser] = [] // Include a list of users you have created here.
        self.viewModel?.loadNextUserList(reset: false, users: users)
    }

    func customCreateChannelAction() {
        // The createChannel(userIds:) function allows you to use user list objects that you manage yourself.
        let users: [SBUUser] = [] // Include a list of users you have created here.
        let userIds = users.sbu_getUserIds()
        self.viewModel?.createChannel(userIds: userIds)
    }
}


/// This function gets dummy users for testing.
extension CreateChannelVC_UserList {
    public func loadDummyUsers(completionHandler: @escaping () -> Void) {
        // Sendbird provides various access control options when using the Chat SDK. By default, the Allow retrieving user list attribute is turned on to facilitate creating sample apps. However, this may grant access to unwanted data or operations, leading to potential security concerns. To manage your access control settings, you can turn on or off each setting on Sendbird Dashboard.
        let params = ApplicationUserListQueryParams()
        params.limit = 100
        let userListQuery = SendbirdChat.createApplicationUserListQuery(params: params)
        userListQuery.loadNextPage { users, error in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            // This is a user list object used for testing.
            guard let users = users?.sbu_convertUserList() else { return }
            self.dummyUserList = users
            completionHandler()
        }
    }
}
