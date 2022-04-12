//
//  InviteUserVC_Cell.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/08.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

/// ------------------------------------------------------
/// This section is related to using the custom user cell.
/// ------------------------------------------------------
class InviteUserModule_List_Cell: SBUInviteUserModule.List {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: CustomUserCell = tableView.dequeueReusableCell(
            withIdentifier: "CustomUserCell"
            ) as? CustomUserCell,
           let user = self.userList?[indexPath.row]
        {
            cell.selectionStyle = .none
            cell.configure(title: user.nickname ?? "", selected: self.selectedUserList?.contains(user) ?? false)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomUserCell,
           let user = self.userList?[indexPath.row] {
            if !(self.selectedUserList?.contains(user) ?? false) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            cell.selectCheck()
        }
    }
}
