//
//  MemberListVC_Cell.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/08.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

/// ------------------------------------------------------
/// This section is related to using the custom user cell.
/// ------------------------------------------------------
class MemberListModule_List_CustomCell: SBUUserListModule.List {
    override func configure(delegate: SBUUserListModuleListDelegate,
                            dataSource: SBUUserListModuleListDataSource,
                            userListType: ChannelUserListType,
                            theme: SBUUserListTheme,
                            componentTheme: SBUComponentTheme) {
        super.configure(
            delegate: delegate,
            dataSource: dataSource,
            userListType: userListType,
            theme: theme,
            componentTheme: componentTheme
        )
        self.register(userCell: CustomUserCell())
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let member = userList[indexPath.row]

        if let cell: CustomUserCell = tableView.dequeueReusableCell(
            withIdentifier: "CustomUserCell"
            ) as? CustomUserCell
        {
            cell.selectionStyle = .none
            cell.configure(title: member.nickname ?? "")
            return cell
        }
        return UITableViewCell()
    }
}
