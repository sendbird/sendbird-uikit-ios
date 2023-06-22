//
//  ChannelListVC_CustomHeader.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2023/06/13.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


class ChannelListVC_CustomHeader: SBUGroupChannelListViewController {
    
    override func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didTapLeftItem leftItem: UIBarButtonItem) {
        let methodName = "\(#function)"
        let alert = UIAlertController(title: "SBUBaseChannelListModuleHeaderDelegate", message: methodName, preferredStyle: .actionSheet)
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
                handler: { _ in super.baseChannelListModule(headerComponent, didTapLeftItem: leftItem) }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    override func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        let methodName = "\(#function)"
        let alert = UIAlertController(title: "SBUBaseChannelListModuleHeaderDelegate", message: methodName, preferredStyle: .actionSheet)
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
                handler: { _ in super.baseChannelListModule(headerComponent, didTapRightItem: rightItem) }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
}

extension ChannelListVC_CustomHeader {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to focus on header component
        self.listComponent?.alpha = 0.25
        self.listComponent?.isUserInteractionEnabled = false
    }
}
