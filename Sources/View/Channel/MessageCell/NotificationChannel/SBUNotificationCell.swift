//
//  SBUNotificationCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/07.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol SBUNotificationCellDelegate: AnyObject {
    func notificationCellShouldReload(_ cell: SBUNotificationCell)
}

@IBDesignable
class SBUNotificationCell: SBUBaseMessageCell {
    // MARK: - UI Layouts
    var baseStackView = SBUStackView(axis: .horizontal, alignment: .bottom, spacing: 4)
    var contentStackView = SBUStackView(axis: .vertical, spacing: 4)
    var captionStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
    
    let feedNotificationMaxWidth: CGFloat = 380.0
    let chatNotificationMaxWidth: CGFloat = 276.0

    
    // MARK: - UI Views (Public)
    
    var profileView: UIView = SBUMessageProfileView()
    var categoryLabel = UILabel()
    var newNotificationBadge: UIView?
    var dateLabel = UILabel()
    
    /// Specifies the theme object that’s used as the theme of the message template view. The theme must inherit the ``SBUNotificationTheme.NotificationCell`` class.
    var notificationCellTheme: SBUNotificationTheme.NotificationCell {
        switch SBUTheme.colorScheme {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    
    // MARK: - UI Views (Private)
    private var notificationTemplateRenderer: MessageTemplateRenderer?

    /// Shows `message.message`  or ``SBUStringSet/Notification_Template_Error_Title``, ``SBUStringSet/Notification_Template_Error_Subtitle``  if the `message.message` is `nil`
    private var parsingErrorNotificationRenderer: MessageTemplateRenderer {
        if let notification = self.message?.message, notification.count > 0 {
            return MessageTemplateRenderer(body: .parsingError(text: notification))
        } else {
            return MessageTemplateRenderer(body: .parsingError(
                text: SBUStringSet.Notification_Template_Error_Title,
                subText: SBUStringSet.Notification_Template_Error_Subtitle
            ))
        }
    }
    
    private var categoryMargin = UIView()
    private var profileMargin = UIView()
    
    
    /// The green dot icon
    private lazy var defaultNewNotificationBadge: UIView = {
        let length = CGFloat(6)
        let iconView = UIView()
            .sbu_constraint(width: length, height: length)
        iconView.layer.cornerRadius = length / 2
        iconView.layer.masksToBounds = true
        iconView.backgroundColor = self.notificationCellTheme.unreadIndicatorColor
        
        return iconView
    }()
    
    
    // MARK: - Logic
    var type: NotificationType = .none
    
    
    // MARK: - Delegate properties
    weak var delegate: SBUNotificationCellDelegate?
    
    
    // MARK: - Actions
    var notificationActionHandler: ((SBUMessageTemplate.Action) -> Void)?
    
    // MARK: - Sendbird Life cycle
    /// Configures a cell with ``SBUBaseMessageCellParams`` object.
    override func configure(with configuration: SBUBaseMessageCellParams) {
        super.configure(with: configuration)
        
        self.dateLabel.text = Date
            .sbu_from(configuration.message.createdAt)
            .sbu_toString(dateFormat: SBUDateFormatSet.Message.sentTimeFormat)
        
        self.categoryLabel.text = configuration.message.customType ?? ""
        
        self.setupNotificationTemplate(with: self.message)
        
        if type == .chat {
            if let profileView = self.profileView as? SBUMessageProfileView {
                var urlString = ""
                if let profileURLString = configuration.profileImageURL {
                    urlString = profileURLString
                }
                profileView.configure(urlString: urlString)
            }
        }
    }
    
    override func setupViews() {
        self.dateView = SBUNotificationTimelineView()
        self.dateView.isHidden = true
        
        if self.newNotificationBadge == nil {
            self.newNotificationBadge = self.defaultNewNotificationBadge
        }
        self.newNotificationBadge?.isHidden = true
        
        self.contentView.addSubview(
            self.stackView.setVStack([
                self.dateView,
                self.messageContentView
            ])
        )
        
        switch type {
        case .none, .feed:
            self.messageContentView.addSubview(
                self.baseStackView.setHStack([
                    self.contentStackView.setVStack([
                        self.captionStackView.setHStack([
                            self.categoryLabel,
                            UIView(),
                            self.newNotificationBadge,
                            self.dateLabel
                        ]),
                        // messageTemplateRenderer will be located here...
                    ]),
                ])
            )
        case .chat:
            self.messageContentView.addSubview(
                self.baseStackView.setHStack([
                    self.profileView,
                    self.profileMargin,
                    self.contentStackView.setVStack([
                        self.captionStackView.setHStack([
                            self.categoryMargin,
                            self.categoryLabel,
                        ]),
                        // messageTemplateRenderer will be located here...
                    ]),
                    self.dateLabel
                ])
            )
        }
    }
    
    override func setupLayouts() {
        self.stackView
            .sbu_constraint(
                equalTo: self.contentView,
                left: 0,
                right: 0,
                top: 16,
                bottom: 0
            )
        
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        var maxTemplateWidth: CGFloat = 0.0
        var leftMargin = 0.0
        var rightMargin = 0.0
        var availableWidthForTemplate: CGFloat = 0.0
        
        switch type {
        case .none, .feed:
            maxTemplateWidth = feedNotificationMaxWidth
            leftMargin = 16
            rightMargin = 16
            availableWidthForTemplate = screenWidth - (leftMargin + rightMargin)
        case .chat:
            maxTemplateWidth = chatNotificationMaxWidth
            leftMargin = 12
            rightMargin = 12
            availableWidthForTemplate = screenWidth - (leftMargin + 26 + 12 + 4 + 50 + rightMargin)
        }
        
        self.baseStackView
            .sbu_constraint(
                equalTo: self.messageContentView,
                leading: leftMargin,
                top: 0,
                bottom: 0
            )

        self.baseStackView.sbu_constraint(
            equalTo: self.messageContentView,
            trailing: -rightMargin,
            priority: .defaultHigh
            //priority: availableWidthForTemplate > maxTemplateWidth ? .defaultLow : .defaultHigh
        )
        
        self.contentStackView.sbu_constraint_lessThan(
            width: min(availableWidthForTemplate, maxTemplateWidth),
            priority: UILayoutPriority(1000)
        )

        if self.type == .chat {
            self.dateLabel.sbu_constraint(width: 50, priority: .defaultLow)
            self.dateLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
            
            self.profileView.sbu_constraint(width: 26, height: 26)
            self.profileMargin.sbu_constraint(width: 4)
            self.categoryMargin.sbu_constraint(width: 8)
        }
        
        // TODO: need to check
        self.captionStackView
            .sbu_constraint_greaterThan(height: 12)
    }
    
    /// This function handles the initialization of actions.
    /// - NOTE: It is called from intializer of ``SBUTableViewCell``
    /// - NOTE: To customize the action of message template view, please overrides regarding delegate methods in ``SBUFeedNotificationChannelModuleListDelegate``
    /// such as ``SBUFeedNotificationChannelModuleListDelegate/feedNotificationChannelModule(_:shouldHandleWebAction:message:forRowAt:)``,
    /// ``SBUFeedNotificationChannelModuleListDelegate/feedNotificationChannelModule(_:shouldHandlePreDefinedAction:message:forRowAt:)``,
    /// or ``SBUFeedNotificationChannelModuleListDelegate/feedNotificationChannelModule(_:shouldHandleCustomAction:message:forRowAt:)``
    override func setupActions() {
        super.setupActions()
    }
    
    override func setupStyles() {
        self.backgroundColor = .clear
        
        if let dateView = self.dateView as? SBUNotificationTimelineView {
            dateView.setupStyles()
        }
        
        if self.type == .chat {
            if let profileView = self.profileView as? SBUMessageProfileView {
                profileView.setupStyles()
            }
        }
        
        self.categoryLabel.font = self.notificationCellTheme.categoryTextFont
        self.categoryLabel.textColor = self.notificationCellTheme.categoryTextColor
        
        self.dateLabel.font = self.notificationCellTheme.sentAtTextFont //SBUFontSet.caption4
        self.dateLabel.textColor = self.notificationCellTheme.sentAtTextColor
        self.dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    /// Creates the message template view and updates the views hierarchy.
    /// If the `message.extendedMessage["sub_data"]` is invalid, the message template view shows `message.message`  or ``SBUStringSet/Notification_Template_Error_Title``, ``SBUStringSet/Notification_Template_Error_Subtitle`` if the `message.message` is `nil`
    /// - Parameters:
    ///    - notification: If it's `nil`, it uses message value in ``SBUNotificationCell``. The default value is `nil`.
    func setupNotificationTemplate(with notification: BaseMessage? = nil) {
        let notification = notification ?? self.message
        let subType = Int(notification?.extendedMessage["sub_type"] as? String ?? "0")
        
        guard subType == 0 else { return } // subType: 0 is template type
        
        var subData = notification?.extendedMessage["sub_data"] as? String
        var bindedTemplate = SBUNotificationChannelManager.generateTemplate(with: subData) {
            // TODO: 실시간 갱신 하는걸로 결정나면 열기
//            self.reloadCell()
        }
        bindedTemplate = bindedTemplate?.replacingOccurrences(of: "\\n", with: "\\\\n")
        bindedTemplate = bindedTemplate?.replacingOccurrences(of: "\n", with: "\\n")
        var template: MessageTemplateData?
        do {
            template = try JSONDecoder().decode(MessageTemplateData.self, from: Data((bindedTemplate ?? "").utf8))
        } catch{
            SBULog.error(error)
        }

        var showFallback = false
        let version = template?.version ?? 0
        if version != 1 { // Not used now
//            bindedData = subData // v0.2
            showFallback = true
        }
        
        self.notificationTemplateRenderer?.delegate = nil
        self.notificationTemplateRenderer = nil
        if let bindedTemplate = bindedTemplate, !showFallback {
            self.notificationTemplateRenderer = MessageTemplateRenderer(
                with: bindedTemplate,
                actionHandler: self.notificationActionHandler
            ) ?? parsingErrorNotificationRenderer
        } else {
            self.notificationTemplateRenderer = parsingErrorNotificationRenderer
        }
        
        self.notificationTemplateRenderer?.delegate = self
        guard let notificationTemplateRenderer = self.notificationTemplateRenderer else { return }
        notificationTemplateRenderer.backgroundColor = self.notificationCellTheme.backgroundColor
        notificationTemplateRenderer.roundCorners(corners: .allCorners, radius: self.notificationCellTheme.radius)
        notificationTemplateRenderer.clipsToBounds = true
        
        self.baseStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        switch type {
        case .none, .feed:
            self.baseStackView.setHStack([
                self.contentStackView.setVStack([
                    self.captionStackView.setHStack([
                        self.categoryLabel,
                        UIView(),
                        self.newNotificationBadge,
                        self.dateLabel
                    ]),
                    notificationTemplateRenderer
                ]),
            ])
        case .chat:
            self.baseStackView.setHStack([
                self.profileView,
                self.profileMargin,
                self.contentStackView.setVStack([
                    self.captionStackView.setHStack([
                        self.categoryMargin,
                        self.categoryLabel,
                    ]),
                    notificationTemplateRenderer
                ]),
                self.dateLabel
            ])
        }
        
        self.updateLayouts()
    }
    
    /// As a default, it follows the condition: `message.createdAt <= listComponent.lastSeenAt`
    func updateReadStatus(_ read: Bool) {
        self.newNotificationBadge?.isHidden = read
    }
    
    func reloadCell() {
        if Thread.isMainThread {
            self.delegate?.notificationCellShouldReload(self)

        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.notificationCellShouldReload(self)

            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let profileView = self.profileView as? SBUMessageProfileView {
            profileView.imageDownloadTask?.cancel()
            profileView.urlString = ""
            profileView.imageView.image = nil
        }
    }
}


// MARK: - MessageTemplateRendererDelegate
extension SBUNotificationCell: MessageTemplateRendererDelegate {
    func messageTemplateRender(_ renderer: MessageTemplateRenderer, didFinishLoadingImage imageView: UIImageView) {
        self.reloadCell()
    }
}
