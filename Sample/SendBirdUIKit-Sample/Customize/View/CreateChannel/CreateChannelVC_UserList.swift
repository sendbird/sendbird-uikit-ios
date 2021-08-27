//
//  CreateChannelVC_UserList.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/07.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

/// -------------------------------------------------------------------
/// This section is related to using the custom user list. (Overriding)
/// -------------------------------------------------------------------
class CreateChannelVC_UserList: SBUCreateChannelViewController {
    public var dummyUserList: [SBUUser] = []
    public var dummyUserListPage = 0
    
    /// When creating and using a user list directly, overriding this function and return the next user list.
    open override func nextUserList() -> [SBUUser]? {
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
        self.loadNextUserList(reset: true, users: users)
    }
    
    func loadNextCustomUserList() {
        // If you use a list of users who have internally generated relationship data,
        // you can use it as follows:
        // Case: next list call
        let users: [SBUUser] = [] // Include a list of users you have created here.
        self.loadNextUserList(reset: false, users: users)
    }

    func customCreateChannelAction() {
        // The createChannel(userIds:) function allows you to use user list objects that you manage yourself.
        let users: [SBUUser] = [] // Include a list of users you have created here.
        let userIds = users.sbu_getUserIds()
        self.createChannel(userIds: userIds)
    }
}


/// This function gets dummy users for testing.
extension CreateChannelVC_UserList {
    public func loadDummyUsers(completionHandler: @escaping () -> Void) {
        let userListQuery = SBDMain.createApplicationUserListQuery()
        userListQuery?.limit = 100
        userListQuery?.loadNextPage(completionHandler: { users, error in
            guard error == nil else { return }
            
            // This is a user list object used for testing.
            guard let users = users?.sbu_convertUserList() else { return }
            self.dummyUserList = users
            completionHandler()
        })
    }
}
