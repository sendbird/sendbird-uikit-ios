//
//  ChannelVC_CustomList.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2023/05/22.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// MARK: - Module
extension CustomChannelModule {
    class List: SBUGroupChannelModule.List {
        override func configure(
            delegate: SBUGroupChannelModuleListDelegate,
            dataSource: SBUGroupChannelModuleListDataSource,
            theme: SBUChannelTheme
        ) {
            theme.backgroundColor = .green
            
            super.configure(delegate: delegate, dataSource: dataSource, theme: theme)
        }
    }
}

// MARK: - View Controller
class ChannelVC_CustomList: SBUGroupChannelViewController {
    
    // MARK: `SBUGroupChannelModuleListDelegate` delegate
    override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapMessage message: BaseMessage, forRowAt indexPath: IndexPath) {
        self.alert(methodName: "\(#function)") {
            super.baseChannelModule(listComponent, didTapMessage: message, forRowAt: indexPath)
        }
    }
    
    override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didLongTapMessage message: BaseMessage, forRowAt indexPath: IndexPath) {
        self.alert(methodName: "\(#function)") {
            super.baseChannelModule(listComponent, didLongTapMessage: message, forRowAt: indexPath)
        }
    }
    
    override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapReplyMessage message: BaseMessage) {
        self.alert(methodName: "\(#function)") {
            super.baseChannelModule(listComponent, didTapReplyMessage: message)
        }
    }
    
    override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapDeleteMessage message: BaseMessage) {
        self.alert(methodName: "\(#function)") {
            super.baseChannelModule(listComponent, didTapDeleteMessage: message)
        }
    }
    
    override func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapMentionUser user: SBUUser) {
        self.alert(methodName: "\(#function)") {
            super.groupChannelModule(listComponent, didTapMentionUser: user)
        }
    }
    
    
    override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapVoiceMessage fileMessage: FileMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.alert(methodName: "\(#function)") {
            super.baseChannelModule(listComponent, didTapVoiceMessage: fileMessage, cell: cell, forRowAt: indexPath)
        }
    }
    
    /// Alerts the delegate method name and execute `defaultActionHandler` when you tap `"Execute default action"` button.
    /// - Parameters:
    ///    - methodName: The name of the function you want to present. It's recommended to use `"\(#function)"`
    ///    - defaultActionHandler: The code blocks that executes when the `"Execute default action"` button is tapped. It's recommneded to use `super`'s implementation to figure out the original action.
    func alert(methodName: String, defaultActionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "SBUBaseChannelModuleListDelegate", message: methodName, preferredStyle: .actionSheet)
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
                handler: { _ in defaultActionHandler() }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
}
