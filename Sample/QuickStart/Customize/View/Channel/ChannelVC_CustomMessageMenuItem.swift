//
//  ChannelVC_CustomMessageMenuItem.swift
//  QuickStart
//
//  Created by Celine Moon on 5/23/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This is an example of adding a custom menu item that is shown when a message is long-pressed.

// Create a custom Group Channel ViewController by overriding `SBUGroupChannelViewController`.
class ChannelVC_CustomMessageMenuItem: SBUGroupChannelViewController {}

// Make your custom Group Channel ViewController conform to your custom delegate.
extension ChannelVC_CustomMessageMenuItem: CustomGroupChannelModuleListDelegate {
    func groupChannelModule(
        _ listComponent: CustomGroupChannelModuleList,
        didTapReportMessage message: BaseMessage
    ) {
        DispatchQueue.main.async {
            guard let groupChannel = self.channel else { return }
            
            let customAlert = CustomAlertController()
            customAlert.modalPresentationStyle = .overCurrentContext
            customAlert.modalTransitionStyle = .crossDissolve

            customAlert.confirmHandler = { category in
                groupChannel.report(
                    message: message,
                    reportCategory: category,
                    reportDescription: nil
                ) { error in
                    guard error == nil else {
                        print("Failed to report message.")
                        let item = SBUToastViewItem(
                            title: "Failed to report the \(category.rawValue) message.",
                            color: .systemRed
                        )
                        SBUToastView.show(item: item)
                        return
                    }
                    print("Rerported the \(category.rawValue) message.")
                    let item = SBUToastViewItem(
                        title: "Successfully rerported the \(category.rawValue) message.",
                        color: .systemGreen
                    )
                    SBUToastView.show(item: item)
                }
            }

            self.present(customAlert, animated: true, completion: nil)
        }
    }
}

// Create a custom Group Channel Module List Delegate by overriding `SBUGroupChannelModuleListDelegate` to define custom delegate methods.
protocol CustomGroupChannelModuleListDelegate: SBUGroupChannelModuleListDelegate {
    func groupChannelModule(_ listComponent: CustomGroupChannelModuleList, didTapReportMessage message: BaseMessage)
}

// Create a custom Group Channel Module List by overriding `SBUGroupChannelModule.List`.
class CustomGroupChannelModuleList: SBUGroupChannelModule.List {
    // Override `createMessageMenuItems(for:)` to add or remove menu items.
    override func createMessageMenuItems(for message: BaseMessage) -> [SBUMenuItem] {
        var items = super.createMessageMenuItems(for: message)
        
        switch message {
        case is UserMessage, is FileMessage, is MultipleFilesMessage:
            let reportMessageItem = self.createReportMessageMenuItem(for: message)
            items.append(reportMessageItem)
        default: break
        }
        
        return items
    }
        
    // Create your custom message menu item.
    private func createReportMessageMenuItem(for message: BaseMessage) -> SBUMenuItem {
        var iconImage: UIImage?
        
        if #available(iOS 13.0, *) {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
            iconImage = UIImage(
                systemName: "exclamationmark.triangle",
                withConfiguration: symbolConfiguration
            )
        }
        
        let menuItem = SBUMenuItem(
            title: "Report",
            color: self.theme?.menuTextColor,
            image: iconImage
        ) { [weak self, message] in
            guard let self = self else { return }

            (self.delegate as? CustomGroupChannelModuleListDelegate)?.groupChannelModule(
                self,
                didTapReportMessage: message
            )
        }
        menuItem.isEnabled = true
        menuItem.transitionsWhenSelected = false
        
        return menuItem
    }
}
