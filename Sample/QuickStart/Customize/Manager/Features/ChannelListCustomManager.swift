//
//  ChannelListCustomManager.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class ChannelListCustomManager: BaseCustomManager {
    static var shared = ChannelListCustomManager()
    
    func startSample(naviVC: UINavigationController, type: ChannelListCustomType?) {
        self.navigationController = naviVC
        
        switch type {
        case .uiComponent:
            uiComponentCustom()
        case .customCell:
            cellCustom()
        case .listQuery:
            listQueryCustom()
        case .functionOverriding:
            functionOverridingCustom()
        case .headerComponentCustom:
            headerComponent()
        case .listComponentcustom:
            listCompponent()
        default:
            break
        }
    }
}


extension ChannelListCustomManager {
    func uiComponentCustom() {
        // This is an example of modifying some ui elements.
        // (The customized part is marked with a red border)
        let channelListVC = SBUGroupChannelListViewController()
        
        // This part changes the default titleView to a custom view.
        channelListVC.headerComponent?.titleView = self.createHighlightedTitleLabel()
        
        // This part changes the default leftBarButton to a custom leftBarButton.
        // RightButton can also be changed in this way.
        channelListVC.headerComponent?.leftBarButton = self.createHighlightedBackButton()
        
        // This part changes the default emptyView to a custom emptyView.
        #if swift(>=5.2)
        let emptyView = CustomEmptyView()
        #else
        let emptyView = CustomEmptyView(frame: .zero)
        #endif
        emptyView.highlight()
        channelListVC.listComponent?.emptyView = emptyView
        
        // Move to ChannelListViewController using customized components
        self.navigationController?.pushViewController(channelListVC, animated: true)
    }
    
    func cellCustom() {
        let channelListVC = SBUGroupChannelListViewController()
        
        // This part changes the default channel cell to a custom cell.
        #if swift(>=5.2)
        channelListVC.listComponent?.register(channelCell: CustomChannelListCell())
        #else
        channelListVC.listComponent?.register(channelCell: CustomChannelListCell(
            style: .default,
            reuseIdentifier: CustomChannelListCell.sbu_className)
        )
        #endif
        
        self.navigationController?.pushViewController(channelListVC, animated: true)
    }
    
    func listQueryCustom() {
        // You can customize the channel list using your own GroupChannelListQuery.
        // For all query options, refer to the `GroupChannelListQuery` class.
        let params = GroupChannelListQueryParams()
        params.includeEmptyChannel = true
        params.includeFrozenChannel = true
        let listQuery = GroupChannel.createMyGroupChannelListQuery(params: params)
        // ... You can set more query options
        
        // This part initialize the channel list with your own GroupChannelListQuery.
        let channelListVC = SBUGroupChannelListViewController(channelListQuery: listQuery)
        
        // Move to the ChannelListViewController created using GroupChannelListQuery.
        self.navigationController?.pushViewController(channelListVC, animated: true)
    }
    
    func functionOverridingCustom() {
        // If you inherit `SBUGroupChannelListViewController`, you can customize it by overriding some functions.
        let channelListVC = ChannelListVC_Overriding()
        self.navigationController?.pushViewController(channelListVC, animated: true)
    }
    
    // MARK: - Module Set
    
    func headerComponent() {
        SBUModuleSet.GroupChannelListModule.HeaderComponent = CustomChannelListModule.Header.self
        
        let channelListVC = ChannelListVC_CustomHeader()
        self.navigationController?.pushViewController(channelListVC, animated: true)
    }
    
    func listCompponent() {
        SBUModuleSet.GroupChannelListModule.ListComponent = CustomChannelListModule.List.self
        
        let channelListVC = ChannelListVC_CustomList()
        self.navigationController?.pushViewController(channelListVC, animated: true)
    }
}
