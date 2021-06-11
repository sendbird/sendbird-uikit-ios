//
//  SBUChannelSettingsViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUChannelSettingsViewController: SBUBaseChannelSettingViewController {
    
    // MARK: - Logic properties (Public)
    
    public private(set) var channel: SBDGroupChannel? {
        get { super.baseChannel as? SBDGroupChannel }
        set { super.baseChannel = newValue }
    }

    // MARK: - Logic properties (Private)
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUChannelSettingsViewController.init(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUChannelSettingsViewController.init(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }

    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    public init(channel: SBDGroupChannel) {
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
            type(of: SBUChannelSettingCell()),
            forCellReuseIdentifier: SBUChannelSettingCell.sbu_className
        )
        
        super.loadView()
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public override func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        SBULog.info("[Request] Load channel: \(String(channelUrl))")
        
        self.channelActionViewModel.loadGroupChannel(with: channelUrl)
    }

    @available(*, deprecated, message: "deprecated in 1.0.9", renamed: "updateChannel(channelName:coverImage:)")
    public func updateChannelInfo(channelName: String? = nil) {
        self.updateChannel(channelName: channelName)
    }
    
    /// Used to update the channel name or cover image. `channelName` and` coverImage` are used for updating only the set values.
    /// - Parameters:
    ///   - channelName: Channel name to update
    ///   - coverImage: Cover image to update
    /// - Since: 1.0.9
    public override func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) {
        let channelParams = SBDGroupChannelParams()
        
        channelParams.name = channelName
        
        if let coverImage = coverImage {
            channelParams.coverImage = coverImage.jpegData(compressionQuality: 0.5)
        } else {
            channelParams.coverUrl = self.channel?.coverUrl
        }
        
        SBUGlobalCustomParams.groupChannelParamsUpdateBuilder?(channelParams)

        self.updateChannel(params: channelParams)
    }
    
    /// Updates the channel with channelParams.
    ///
    /// You can update a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `SBDGroupChannelParams` class object
    /// - Since: 1.0.9
    public func updateChannel(params: SBDGroupChannelParams) {
        self.channelActionViewModel.updateChannel(params: params)
    }
    
    /// Changes push trigger option on channel.
    /// - Parameter isOn: notification status
    public func changeNotification(isOn: Bool) {
        let triggerOption: SBDGroupChannelPushTriggerOption = isOn ? .all : .off
        
        SBULog.info("""
            [Request] Channel push status :
            \(triggerOption == .off ? "on" : "off"),
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)
        
        self.channelActionViewModel.changeNotification(triggerOption: triggerOption)
    }
    
    /// Leaves the channel.
    public func leaveChannel() {
        SBULog.info("""
            [Request] Leave channel,
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)
        self.channelActionViewModel.leaveChannel()
    }
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource

    open override func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SBUChannelSettingCell.sbu_className
            ) as? SBUChannelSettingCell else { fatalError() }
        
        cell.selectionStyle = .none
        
        let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
        guard let type = ChannelSettingItemType.from(row: rowValue) else { return cell }
        
        cell.configure(type: type, channel: self.channel)
        
        if type == .notifications {
            cell.switchAction = { [weak self] isOn in
                guard let self = self else { return }
                self.changeNotification(isOn: isOn)
            }
        }

        return cell
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChannelSettingItemType.allTypes(isOperator: self.isOperator).count
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let userInfoView = self.userInfoView as? SBUChannelSettingsUserInfoView {
            userInfoView.endEditing(true)
        }
        
        let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
        guard let type = ChannelSettingItemType.from(row: rowValue) else { return }
        
        switch type {
        case .moderations:
            self.showModerationList()
        case .notifications:
            break
        case .members:
            self.showMemberList()
        case .leave:
            self.leaveChannel()
        case .search:
            self.showSearch()
        default:
            break
        }
    }
}
