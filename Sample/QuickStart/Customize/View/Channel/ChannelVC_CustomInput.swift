//
//  ChannelVC_CustomInput.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2023/05/22.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
 
// MARK: - Module

extension CustomChannelModule {
    class Input: SBUGroupChannelModule.Input {
        override func configure(
            delegate: SBUGroupChannelModuleInputDelegate,
            dataSource: SBUGroupChannelModuleInputDataSource,
            mentionManagerDataSource: SBUMentionManagerDataSource? = nil,
            theme: SBUChannelTheme
        ) {
            super.configure(
                delegate: delegate,
                dataSource: dataSource,
                mentionManagerDataSource: mentionManagerDataSource,
                theme: theme
            )
            // Update colors
            guard let inputView = self.messageInputView as? SBUMessageInputView else { return }
            let theme = SBUTheme.messageInputTheme
            theme.backgroundColor = .black
            theme.buttonTintColor = .white
            theme.saveButtonTextColor = .black
            inputView.theme = theme
        }
    }
}

// MARK: - View Controller
class ChannelVC_CustomInput: SBUGroupChannelViewController {
    // MARK: `SBUGroupChannelModuleInputDelegate` delegate
    override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didTapSend text: String, parentMessage: BaseMessage?) {
        // To see regarding delegate method name
        let newText = "[SBUBaseChannelModuleInputDelegate] \(#function)\nYOUR MESSAGE: \"\(text)\""
        super.baseChannelModule(inputComponent, didTapSend: newText, parentMessage: parentMessage)
    }
    
    
    override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didTapResource type: MediaResourceType) {
        self.alert(methodName: "\(#function)") {
            super.baseChannelModule(inputComponent, didTapResource: type)
        }
    }
    
    override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didChangeMode mode: SBUMessageInputMode, message: BaseMessage?) {
        self.alert(methodName: "\(#function)") {
            super.baseChannelModule(inputComponent, didChangeMode: mode, message: message)
        }
    }
    override func groupChannelModule(_ inputComponent: SBUGroupChannelModule.Input, didPickFileData fileData: Data?, fileName: String, mimeType: String, parentMessage: BaseMessage?) {
        self.alert(methodName: "\(#function)") {
            super.groupChannelModule(inputComponent, didPickFileData: fileData, fileName: fileName, mimeType: mimeType, parentMessage: parentMessage)
        }
    }
    
    /// Alerts the delegate method name and execute `defaultActionHandler` when you tap `"Execute default action"` button.
    /// - Parameters:
    ///    - methodName: The name of the function you want to present. It's recommended to use `"\(#function)"`
    ///    - defaultActionHandler: The code blocks that executes when the `"Execute default action"` button is tapped. It's recommneded to use `super`'s implementation to figure out the original action.
    func alert(methodName: String, defaultActionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "SBUGroupChannelModuleInputDelegate", message: methodName, preferredStyle: .actionSheet)
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
