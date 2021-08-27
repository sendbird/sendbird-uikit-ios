//
//  InviteUserVC_Cell.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/08.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

/// ------------------------------------------------------
/// This section is related to using the custom user cell.
/// ------------------------------------------------------
class InviteUserVC_Cell: SBUInviteUserViewController {
    open override func tableView(_ tableView: UITableView,
                                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userList[indexPath.row]
        
        if let cell: CustomUserCell = tableView.dequeueReusableCell(
            withIdentifier: "CustomUserCell"
            ) as? CustomUserCell
        {
            cell.selectionStyle = .none
            cell.configure(title: user.nickname ?? "", selected: self.selectedUserList.contains(user))
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let user = userList[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomUserCell {
            if !self.selectedUserList.contains(user) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            cell.selectCheck()
        }
    }
}
