//
//  ChannelListVC_CustomList.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2023/06/13.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class ChannelListVC_CustomList: SBUGroupChannelListViewController {
    
    // MARK: Select row (enter channel)
    override func baseChannelListModule(_ listComponent: SBUBaseChannelListModule.List, didSelectRowAt indexPath: IndexPath) {
        let methodName = "\(#function)"
        let alert = UIAlertController(title: "SBUBaseChannelListModuleListDelegate", message: methodName, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "Default action"),
                style: .default,
                handler: { _ in }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Execute default action", comment: "Default action"),
                style: .default,
                handler: { _ in super.baseChannelListModule(listComponent, didSelectRowAt: indexPath) }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Trailing action items (leave, notifications)
    override func groupChannelListModule(_ listComponent: SBUGroupChannelListModule.List, didSelectLeave channel: GroupChannel) {
        let methodName = "\(#function)"
        let alert = UIAlertController(title: "SBUGroupChannelListModuleListDelegate", message: methodName, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "Default action"),
                style: .default,
                handler: { _ in }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Execute default action", comment: "Default action"),
                style: .default,
                handler: { _ in super.groupChannelListModule(listComponent, didSelectLeave: channel) }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    override func groupChannelListModule(_ listComponent: SBUGroupChannelListModule.List, didChangePushTriggerOption option: GroupChannelPushTriggerOption, channel: GroupChannel) {
        let methodName = "\(#function)"
        let alert = UIAlertController(title: "SBUGroupChannelListModuleListDelegate", message: methodName, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "Default action"),
                style: .default,
                handler: { _ in }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Execute default action", comment: "Default action"),
                style: .default,
                handler: { _ in super.groupChannelListModule(listComponent, didChangePushTriggerOption: option, channel: channel) }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
}
