//
//  ChannelVC_AdditionalFeatures.swift
//  QuickStart
//
//  Created by Celine Moon on 11/23/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// MARK: - Custom SBUGroupChannelViewController
class ChannelVC_AdditionalFeatures: SBUGroupChannelViewController {
    override func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        showIndicator: Bool = true
    ) {
        self.viewModel = GroupChannelViewModel_AdditionalFeatures(
            channel: channel,
            channelURL: channel?.channelURL,
            messageListParams: nil,
            startingPoint: nil,
            delegate: self,
            dataSource: self,
            displaysLocalCachedListFirst: false
        )
        
        viewModel?.sendUserMessageCompletionHandler = { userMessage, error in
            guard let userMessage = userMessage, error == nil else {
                print("\(error!)")
                return
            }
            print("\(userMessage.translations)")
        }
    }
    
    
    override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didTapSend text: String, parentMessage: BaseMessage?) {
        guard text.count > 0 else { return }
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let messageParam = UserMessageCreateParams(message: text)
        
        messageParam.translationTargetLanguages = ["es", "ko"]   // Spanish and Korean

        self.viewModel?.sendUserMessage(messageParams: messageParam)
    }
    
    override func showChannelSettings() {
        guard let channel = self.channel else { return }
        
        let channelSettingsVC = SBUViewControllerSet.GroupChannelSettingsViewController.init(channel: channel)
        let listComponent = GroupChannelSettingsModuleList_AdditionalFeatures()
        listComponent.additionalFeaturesDelegate = self
        channelSettingsVC.listComponent = listComponent
        
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
}

extension ChannelVC_AdditionalFeatures: GroupChannelSettingsModuleList_AdditionalFeaturesDelegate {
    func groupChannelSettingsModuleDidReportChannel(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        category: ReportCategory,
        channel: GroupChannel,
        error: SBError?
    ) {
        // Show alert.
        let channelName = channel.name.isEmpty ? channel.channelURL : channel.name
        
        let successMessage =
        """
        Successfully reported
        channel \(channelName)
        as \(category.rawValue.uppercased()).
        """
        
        let failedMessage =
        """
        Failed to report
        channel \(channelName)
        as \(category.rawValue.uppercased()).
        \(String(describing: error))
        """
        
        var alert = UIAlertController(
            title: error == nil ? "✅" : "❌",
            message: error == nil ? successMessage : failedMessage,
            preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func groupChannelSettingsModuleDidReportUser(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        category: ReportCategory,
        user: User,
        error: SBError?
    ) {
        // Show alert.
        let successMessage =
        """
        Successfully reported
        user \(user.userId.uppercased())
        as \(category.rawValue.uppercased()).
        """
        let failedMessage = "Failed to report a \(category.rawValue.uppercased()) user \(user.userId.uppercased()). \(String(describing: error))"
        var alert = UIAlertController(
            title: error == nil ? "✅" : "❌",
            message: error == nil ? successMessage : failedMessage,
            preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func groupChannelSettingsModuleDidReportMessage(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        category: ReportCategory,
        message: BaseMessage,
        error: SBError?
    ) {
        // Show alert.
        var chatMessage = ""
        if let userMessage = message as? UserMessage {
            chatMessage = userMessage.message
        } else if let fileMessage = message as? FileMessage {
            chatMessage = fileMessage.name
        } else if let multipleFilesMessage = message as? MultipleFilesMessage,
                  let firstFileName = multipleFilesMessage.files.first?.fileName {
            chatMessage = firstFileName
        } else {
            chatMessage = message.message
        }
        
        let successMessage =
        """
        Successfully reported
        the last message (\(chatMessage))
        as \(category.rawValue.uppercased()).
        """
        let failedMessage = "Failed to report the last message (\(chatMessage) as \(category.rawValue.uppercased()). \(String(describing: error))"
        var alert = UIAlertController(
            title: error == nil ? "✅" : "❌",
            message: error == nil ? successMessage : failedMessage,
            preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func groupChannelSettingsModuleDidSelectCreateMetadata(_ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures, channel: GroupChannel) {
        let vc = MetadataViewController(channel: channel, mode: .create)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func groupChannelSettingsModuleDidSelectUpdateMetadata(_ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures, channel: GroupChannel) {
        let vc = MetadataViewController(channel: channel, mode: .update)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func groupChannelSettingsModuleDidSelectDeleteMetadata(_ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures, channel: GroupChannel) {
        let vc = MetadataViewController(channel: channel, mode: .delete)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - Custom UserMessageCell
class UserMessageCell_AdditionalFeatures: SBUUserMessageCell {
    lazy var translationLabel: PaddedLabel = {
        let messageLabel = PaddedLabel()
        messageLabel.textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 12)
        messageLabel.textColor = .systemPink
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        self.mainContainerView.addArrangedSubview(translationLabel)
    }
    
    override func configure(with configuration: SBUBaseMessageCellParams) {
        super.configure(with: configuration)
        
        guard let configuration = configuration as? SBUUserMessageCellParams else { return }
        guard let message = configuration.userMessage else { return }
        
        guard let koTranslatedMessage = message.translations["ko"] else {
            return
        }
        print("\(koTranslatedMessage)")
        translationLabel.text = koTranslatedMessage
    }
}

// MARK: - Custom GroupChannel Settings Module List
class GroupChannelSettingsModuleList_AdditionalFeatures: SBUGroupChannelSettingsModule.List {
    var additionalFeaturesDelegate: GroupChannelSettingsModuleList_AdditionalFeaturesDelegate?
    
    // MARK: UI methods.
    override func setupStyles(theme: SBUChannelSettingsTheme? = nil) {
        super.setupStyles(theme: theme)
        self.channelInfoView?.backgroundColor = .white
    }
    
    override func setupItems() {
        super.setupItems()
        
        let reportChannelItems = createReportChannelItems()
        self.items += reportChannelItems
        
        let reportUserItems = createReportUserItems()
        self.items += reportUserItems
        
        let reportMessageItems = createReportMessageItems()
        self.items += reportMessageItems
        
        let metadataItems = createChannelMetadataItems()
        self.items += metadataItems
    }
    
    // Report Channel
    func createReportChannelItems() -> [SBUChannelSettingItem] {
        var items = [SBUChannelSettingItem]()
        
        for category in ReportCategory.allCases() {
            let item = SBUChannelSettingItem(
                title: "Report Channel - \(category.rawValue.uppercased())",
                icon: SBUIconSetType.iconBan.image(
                    with: .systemPink,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                isRightButtonHidden: true
            ) { [weak self] in
                guard let self = self else { return }
                self.reportChannel(category: category)
            }
            items.append(item)
        }
        
        return items
    }
    
    // Report User
    func createReportUserItems() -> [SBUChannelSettingItem] {
        var items = [SBUChannelSettingItem]()
        
        for category in ReportCategory.allCases() {
            let item = SBUChannelSettingItem(
                title: "Report User (alphabetical last) - \(category.rawValue.uppercased())",
                icon: SBUIconSetType.iconBan.image(
                    with: .systemBlue,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                isRightButtonHidden: true
            ) { [weak self] in
                guard let self = self else { return }
                self.reportUser(category: category)
            }
            items.append(item)
        }
        
        return items
    }
    
    // Report Message
    func createReportMessageItems() -> [SBUChannelSettingItem] {
        var items = [SBUChannelSettingItem]()
        
        for category in ReportCategory.allCases() {
            let item = SBUChannelSettingItem(
                title: "Report Last Message - \(category.rawValue.uppercased())",
                icon: SBUIconSetType.iconBan.image(
                    with: .systemYellow,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                isRightButtonHidden: true
            ) { [weak self] in
                guard let self = self else { return }
                self.reportLastMessage(category: category)
            }
            items.append(item)
        }
        
        return items
    }
    
    // Metadata create, update, delete
    func createChannelMetadataItems() -> [SBUChannelSettingItem] {
        var items = [SBUChannelSettingItem]()
        
        let createItem = SBUChannelSettingItem(
            title: "Create metadata",
            icon: SBUIconSetType.iconAdd.image(
                with: .systemGreen, // theme?.cellTypeIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            isRightButtonHidden: false
        ) { [weak self] in
            guard let self = self else { return }
            guard let channel = self.channel else { return }
            
            self.additionalFeaturesDelegate?.groupChannelSettingsModuleDidSelectCreateMetadata(self, channel: channel)
        }
        
        let updateItem = SBUChannelSettingItem(
            title: "Update metadata",
            icon: SBUIconSetType.iconAdd.image(
                with: .systemGreen,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            isRightButtonHidden: false
        ) { [weak self] in
            guard let self = self else { return }
            guard let channel = self.channel else { return }
            
            self.additionalFeaturesDelegate?.groupChannelSettingsModuleDidSelectUpdateMetadata(self, channel: channel)
        }
        
        
        let deleteItem = SBUChannelSettingItem(
            title: "Delete metadata",
            icon: SBUIconSetType.iconAdd.image(
                with: .systemGreen,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            isRightButtonHidden: false
        ) { [weak self] in
            guard let self = self else { return }
            guard let channel = self.channel else { return }
            
            self.additionalFeaturesDelegate?.groupChannelSettingsModuleDidSelectDeleteMetadata(self, channel: channel)
        }
        
        items.append(createItem)
        items.append(updateItem)
        items.append(deleteItem)
        
        return items
    }
    
    // MARK: Report methods.
    func reportChannel(category: ReportCategory) {
        self.channel?.report(category: .suspicious, reportDescription: "\(category.rawValue) channel report!") { (error) in
            guard let channel = self.channel else { return }
            self.additionalFeaturesDelegate?.groupChannelSettingsModuleDidReportChannel(
                self,
                category: category,
                channel: channel,
                error: error
            )
        }
    }
    
    func reportUser(category: ReportCategory) {
        guard let channel = self.channel else { return }
        guard let currentUser = SBUGlobals.currentUser else { return }
        
        var otherMembers = channel.members.filter({ $0.userId != currentUser.userId })
        otherMembers.sort { $0.nickname.lowercased() < $1.nickname.lowercased() }
        
        guard let otherUser = otherMembers.last else {
            return
        }
        
        channel.report(
            offendingUser: otherUser,
            reportCategory: category, 
            reportDescription: "\(category.rawValue) user report"
        ) { (error) in
            self.additionalFeaturesDelegate?.groupChannelSettingsModuleDidReportUser(self, category: category, user: otherUser, error: error)
        }
    }
    
    func reportLastMessage(category: ReportCategory) {
        guard let channel = self.channel else { return }
        guard let lastMessage = channel.lastMessage else {
            return
        }
        
        channel.report(
            message: lastMessage,
            reportCategory: category,
            reportDescription: "Reporting last message as \(category.rawValue.uppercased())"
        ) { (error) in
            self.additionalFeaturesDelegate?.groupChannelSettingsModuleDidReportMessage(
                self,
                category: category,
                message: lastMessage,
                error: error
            )
        }
    }
}

protocol GroupChannelSettingsModuleList_AdditionalFeaturesDelegate {
    // Report
    func groupChannelSettingsModuleDidReportChannel(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        category: ReportCategory,
        channel: GroupChannel,
        error: SBError?
    )
    
    func groupChannelSettingsModuleDidReportUser(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        category: ReportCategory,
        user: User,
        error: SBError?
    )
    
    func groupChannelSettingsModuleDidReportMessage(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        category: ReportCategory,
        message: BaseMessage,
        error: SBError?
    )
    
    // Metadata
    func groupChannelSettingsModuleDidSelectCreateMetadata(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        channel: GroupChannel
    )
    
    func groupChannelSettingsModuleDidSelectUpdateMetadata(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        channel: GroupChannel
    )
    
    func groupChannelSettingsModuleDidSelectDeleteMetadata(
        _ listComponent: GroupChannelSettingsModuleList_AdditionalFeatures,
        channel: GroupChannel
    )
}

extension ReportCategory {
    static func allCases() -> [ReportCategory] {
        return [.suspicious, .harassing, .spam, .inappropriate]
    }
}
