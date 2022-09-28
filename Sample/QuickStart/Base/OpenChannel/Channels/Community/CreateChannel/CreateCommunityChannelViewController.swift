//
//  CreateCommunityChannelViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/12/04.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This page shows how to customize the *view controller* and the *view model* regarding *"Creating an open channel" key function.*
/// Please refer to ``SBUCreateOpenChannelViewController`` and ``SBUCreateOpenChannelViewModel``

// MARK: - (Customization) View Model
class CreateCommunityChannelViewModel: SBUCreateOpenChannelViewModel {
    // MARK: - Constant
    static let customType: String = "SB_COMMUNITY_TYPE"
    
    // MARK: - (Customization)
    /// Override the below method to create channels with a specific ``CreateCommunityChannelViewModel/customType`` value.
    override func createChannel(params: OpenChannelCreateParams) {
        params.customType = Self.customType
        super.createChannel(params: params)
    }
}

// MARK: - View Controller
class CreateCommunityChannelViewController: SBUCreateOpenChannelViewController {
    // MARK: - (Customization) View Model
    /// Override the below method to use a customized view model instead of the default view model. 
    override func createViewModel() {
        self.viewModel = CreateCommunityChannelViewModel(delegate: self)
    }
}
