//
//  CustomChannelListModule.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2023/05/22.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class CustomChannelListModule: SBUGroupChannelListModule {
    // MARK: - Header
    class Header: SBUGroupChannelListModule.Header {
        override func configure(
            delegate: SBUGroupChannelListModuleHeaderDelegate,
            theme: SBUGroupChannelListTheme
        ) {
            // Update title, left/right bar buttons
            let titleView = SBUNavigationTitleView()
            titleView.text = "titleView"
            self.titleView = titleView
            self.leftBarButton = UIBarButtonItem(
                title: "leftBarButton",
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
            self.rightBarButton = UIBarButtonItem(
                title: "rightBarButton",
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            
            super.configure(delegate: delegate, theme: theme)
        }
        
    }
    
    // MARK: - List
    class List: SBUGroupChannelListModule.List {
        override func configure(
            delegate: SBUGroupChannelListModuleListDelegate,
            dataSource: SBUGroupChannelListModuleListDataSource,
            theme: SBUGroupChannelListTheme
        ) {
            tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header.footer.view")
            
            // update background color of table view
            theme.backgroundColor = .blue
            
            super.configure(
                delegate: delegate,
                dataSource: dataSource,
                theme: theme
            )
        }
        
        // cell theme
        override func configureCell(_ channelCell: SBUBaseChannelCell?, indexPath: IndexPath) {
            if let groupChannelCell = channelCell as? SBUGroupChannelCell {
                let cellTheme = SBUGroupChannelCellTheme()
                cellTheme.backgroundColor = .black
                cellTheme.titleTextColor = .white
                cellTheme.messageTextColor = .white
                cellTheme.unreadCountBackgroundColor = .white
                cellTheme.unreadCountTextColor = .black
                cellTheme.unreadMentionTextColor = .white
                cellTheme.lastUpdatedTimeTextColor = .white
                cellTheme.memberCountTextColor = .white
                
                groupChannelCell.theme = cellTheme
            }
            super.configureCell(channelCell, indexPath: indexPath)
        }
        
        // section header
        override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header.footer.view")
            header?.textLabel?.text = "Go to documentation"
            header?.textLabel?.textColor = .white
            header?.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(didTapSectionHeaderView)
                )
            )
            return header
        }
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            32
        }
        
        @objc
        func didTapSectionHeaderView() {
            let link = "https://sendbird.com/docs/uikit/v3/ios/key-functions/list-channels"
            guard let url = URL(string: link) else { return }
            guard UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url)
        }
    }
}
