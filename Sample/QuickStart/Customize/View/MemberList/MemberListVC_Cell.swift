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
class MemberListModule_List_CustomCell: SBUMemberListModule.List {
    override func configure(delegate: SBUMemberListModuleListDelegate,
                            dataSource: SBUMemberListModuleListDataSource,
                            memberListType: ChannelMemberListType,
                            theme: SBUUserListTheme,
                            componentTheme: SBUComponentTheme) {
        super.configure(
            delegate: delegate,
            dataSource: dataSource,
            memberListType: memberListType,
            theme: theme,
            componentTheme: componentTheme
        )
        self.register(memberCell: CustomUserCell())
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let member = memberList[indexPath.row]

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
