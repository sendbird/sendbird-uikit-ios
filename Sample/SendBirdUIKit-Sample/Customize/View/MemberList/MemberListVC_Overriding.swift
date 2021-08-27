//
//  MemberListVC_Overriding.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/08.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

/// ------------------------------------------------------
/// This section is related to overriding.
/// ------------------------------------------------------
class MemberListVC_Overriding: SBUMemberListViewController {
    // MARK: - Show relations
    override func showInviteUser() {
        // If you want to use your own InviteUserViewController,
        // you can override and customize it here.
        AlertManager.showCustomInfo(#function)
    }
    
    
    // MARK: - Action relations
    override func onClickInviteUser() {
        // If you want to customize invite user button action,
        // you can override and customize it here.
        AlertManager.showCustomInfo(#function)
    }
    
    
    // MARK: - Error handling
    override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        // If you override and customize this function,
        // you can handle it when error received.
        print(message as Any);
    }
}
