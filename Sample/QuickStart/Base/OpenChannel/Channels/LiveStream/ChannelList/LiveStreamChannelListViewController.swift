//
//  LiveStreamChannelListViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/11/15.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class LiveStreamChannelListViewController: SBUOpenChannelListViewController {
    // MARK: - Channel
    override func baseChannelListModule(_ listComponent: SBUBaseChannelListModule.List, didSelectRowAt indexPath: IndexPath) {
        guard let channel = self.viewModel?.channelList[indexPath.row] else { return }
        guard let liveStreamData = channel.liveStreamData else { return }
        let channelVC = LiveStreamChannelViewController(
            channel: channel,
            liveStreamData: liveStreamData
        )
        channelVC.mediaComponent = LiveStreamChannelModule.Media()
        channelVC.hideChannelInfoView = false
        channelVC.enableMediaView()
        channelVC.updateMessageListRatio(to: LiveStreamChannelViewController.defaultRatio)
        channelVC.mediaViewIgnoringSafeArea(false)
        channelVC.channelDescription = liveStreamData.creatorInfo.name
        
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
}


// MARK: - Tab bar controller
extension LiveStreamChannelListViewController {
    // MARK: - Tab bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}
