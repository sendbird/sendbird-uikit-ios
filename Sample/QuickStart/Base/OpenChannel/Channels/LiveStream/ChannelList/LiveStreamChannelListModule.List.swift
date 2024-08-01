//
//  LiveStreamChannelListModule.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2022/09/07.
//  Copyright © 2022 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This page shows how to create a customized list module component by overriding ``SBUOpenChannelListModule/List``.
/// To use customized `UITableViewCell`, call ``SBUBaseChannelListModule/List/register(channelCell:nib:)`` before calling ``SBUOpenChannelListModule/List/setupViews()``
/// Please refer to ``LiveStreamChannelListModule/List/setupViews()``
class LiveStreamChannelListModule {
    class List: SBUOpenChannelListModule.List {
        private lazy var guidelineCell: UITableViewCell = {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Preset channels developed by UIKit"
            cell.textLabel?.font = SBUFontSet.body2
            cell.textLabel?.textColor = SBUTheme.groupChannelCellTheme.memberCountTextColor
            cell.textLabel?.sbu_constraint(
                equalTo: cell.contentView,
                leading: 16,
                top: 16,
                bottom: 8
            )
            cell.contentView.backgroundColor = SBUTheme.groupChannelCellTheme.backgroundColor
            cell.isUserInteractionEnabled = false
            
            return cell
        }()
        
        // MARK: - UITableView relations
        enum SectionType: Int {
            case guideline = 0
            case streamingChannels = 1
        }
        
        override func configure(
            delegate: SBUOpenChannelListModuleListDelegate,
            dataSource: SBUOpenChannelListModuleListDataSource,
            theme: SBUOpenChannelListTheme
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.isPullToRefreshEnabled = false
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        override func setupViews() {
            self.register(channelCell: LiveStreamChannelCell())
            super.setupViews()
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let channelList = self.channelList else { return 0 }
            tableView.backgroundView?.isHidden = !channelList.isEmpty
            if section == SectionType.guideline.rawValue {
                return 1
            } else {
                return channelList.count
            }
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch indexPath.section {
            case SectionType.guideline.rawValue:
                let cell = guidelineCell
                cell.textLabel?.textColor = SBUTheme.groupChannelCellTheme.memberCountTextColor
                cell.contentView.backgroundColor = SBUTheme.groupChannelCellTheme.backgroundColor
                
                return cell
            default:
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
        }
    }
}
