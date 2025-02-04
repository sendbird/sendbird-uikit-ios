//
//  ChannelVC_CustomHeader.swift
//  QuickStart
//
//  Created by Tez Park on 2022/07/19.
//  Copyright © 2022 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import SendbirdUIKit

// MARK: - Module
class CustomChannelModule { }

protocol CustomChannelModuleHeaderDelegate: SBUBaseChannelModuleHeaderDelegate {
    /// Customized delegate method for header component in channel module. It's called when the `titleView` is tapped.
    func customChannelModule(_ headerComponent: CustomChannelModule.Header, didTapTitleView titleView: UIView)
}

/**
 ```swift
 SBUModuleSet.GroupChannelModule.HeaderComponent = CustomChannelModule.Header.self
 ```
 */
extension CustomChannelModule {
    class Header: SBUGroupChannelModule.Header {
        override func setupViews() {
            // "X" mark button
            self.leftBarButton = UIBarButtonItem(
                image: SBUIconSet.iconClose.sbu_resize(with: CGSize(width: 24, height: 24)),
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
            // Search button
            self.rightBarButton = UIBarButtonItem(
                image: SBUIconSet.iconSearch.sbu_resize(with: CGSize(width: 24, height: 24)),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            
            super.setupViews()
            
            // Add the gesture recognizer to a view
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTitleView(sender:)))
            self.titleView?.addGestureRecognizer(tapGesture)
        }
        
        /// Calls ``CustomChannelModuleHeaderDelegate/customChannelModule(_:didTapTitleView:)`` delegate method.
        func onTapTitleView(sender: UITapGestureRecognizer){
            if let titleView = self.titleView {
                (self.delegate as? CustomChannelModuleHeaderDelegate)?.customChannelModule(self, didTapTitleView: titleView)
            }
        }
    }
}

// MARK: - View Controller
class ChannelVC_CustomHeader: SBUGroupChannelViewController {
    // MARK: `SBUGroupChannelModuleHeaderDelegate` delegate
    
    // shows message search view controller
    override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        guard let channel = self.channel else { return }
        
        let searchVC = SBUViewControllerSet.MessageSearchViewController.init(channel: channel)
        let nav = UINavigationController(rootViewController: searchVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension ChannelVC_CustomHeader: CustomChannelModuleHeaderDelegate {
    func customChannelModule(_ headerComponent: CustomChannelModule.Header, didTapTitleView titleView: UIView) {
        guard let channel = self.viewModel?.channel as? GroupChannel else { return }
        let members = channel.members.compactMap { $0.nickname.isEmpty ? $0.userId : $0.nickname }
        print(members)
    }
}


extension ChannelVC_CustomHeader {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to focus on header component
        self.listComponent?.alpha = 0.25
        self.listComponent?.isUserInteractionEnabled = false
        
        self.inputComponent?.alpha = 0.25
        self.inputComponent?.isUserInteractionEnabled = false
    }
}
