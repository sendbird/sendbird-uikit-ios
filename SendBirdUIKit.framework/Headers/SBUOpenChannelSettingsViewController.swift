//
//  SBUOpenChannelSettingsViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/11/09.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUOpenChannelSettingsViewController: SBUBaseChannelSettingViewController {
    
    // MARK: - Logic properties (Public)
    
    public private(set) var channel: SBDOpenChannel? {
        get { super.baseChannel as? SBDOpenChannel }
        set { super.baseChannel = newValue }
    }

    // MARK: - Logic properties (Private)
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUOpenChannelSettingsViewController(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUOpenChannelSettingsViewController(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }

    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    public init(channel: SBDOpenChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channel = channel
        self.channelUrl = channel.channelUrl
        
        self.bindViewModel()
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameter channelUrl: Channel url string
    public init(channelUrl: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        
        self.bindViewModel()
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        self.tableView.register(
            type(of: SBUOpenChannelSettingCell()),
            forCellReuseIdentifier: SBUOpenChannelSettingCell.sbu_className
        )
        
        super.loadView()
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public override func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        SBULog.info("[Request] Load channel: \(String(channelUrl))")
        
        self.channelActionViewModel.loadOpenChannel(with: channelUrl)
    }

    /// Used to update the channel name or cover image. `channelName` and` coverImage` are used for updating only the set values.
    /// - Parameters:
    ///   - channelName: Channel name to update
    ///   - coverImage: Cover image to update
    public override func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) {
        let channelParams = SBDOpenChannelParams()
        
        channelParams.name = channelName
        
        if let coverImage = coverImage {
            channelParams.coverImage = coverImage.jpegData(compressionQuality: 0.5)
        } else {
            channelParams.coverUrl = self.channel?.coverUrl
        }
        
        SBUGlobalCustomParams.openChannelParamsUpdateBuilder?(channelParams)

        self.updateChannel(params: channelParams)
    }
    
    /// Updates the channel with channelParams.
    ///
    /// You can update a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `SBDOpenChannelParams` class object
    public func updateChannel(params: SBDOpenChannelParams) {
        self.channelActionViewModel.updateChannel(params: params)
    }
    
    /// Deletes the channel.
    public func deleteChannel() {
        SBULog.info("""
            [Request] Delete channel,
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)

        self.channelActionViewModel.deleteChannel()
    }
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SBUOpenChannelSettingCell.sbu_className
            ) as? SBUOpenChannelSettingCell else { fatalError() }
        
        cell.selectionStyle = .none

        let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
        if let type = OpenChannelSettingItemType(rawValue: rowValue) {
            cell.configure(type: type, channel: self.channel)
        }

        return cell
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OpenChannelSettingItemType.allTypes(isOperator: self.isOperator).count
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
            userInfoView.endEditing(true)
        }
        
        let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
        let type = OpenChannelSettingItemType(rawValue: rowValue)
        switch type {
        case .participants: self.showParticipantsList()
        case .delete: self.deleteChannel()
        default: return
        }
    }
}

