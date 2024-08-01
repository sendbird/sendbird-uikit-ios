//
//  SBUNotificationCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/07.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@IBDesignable
class SBUNotificationCell: SBUBaseMessageCell {
    // MARK: - UI Layouts
    var baseStackView = SBUStackView(axis: .horizontal, alignment: .bottom, spacing: 4)
    var contentStackView = SBUStackView(axis: .vertical, spacing: 4)
    var captionStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
    
    let feedNotificationMaxWidth: CGFloat = 380.0
    let chatNotificationMaxWidth: CGFloat = 276.0

    let feedNotificationDownloadingHeight: CGFloat = 294.0
    let chatNotificationDownloadingHeight: CGFloat = 274.0
    
    // MARK: - UI Views (Public)
    
    var profileView: UIView = SBUMessageProfileView()
    var categoryLabel = UILabel()
    var newNotificationBadge: UIView?
    var dateLabel = UILabel()
    
    var isTemplateDownloadFailed = false
    var isRendered = false
    
    var topMarginConstraint: NSLayoutConstraint?
    var bottomMarginConstraint: NSLayoutConstraint?
    
    /// Specifies the theme object that’s used as the theme of the message template view. The theme must inherit the ``SBUNotificationTheme.NotificationCell`` class.
    var notificationCellTheme: SBUNotificationTheme.NotificationCell {
        switch SBUTheme.colorScheme {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    // MARK: - UI Views (Private)
    private var notificationTemplateRenderer: SBUMessageTemplate.Renderer?

    /// Shows `message.message`  or ``SBUStringSet/Notification_Template_Error_Title``, ``SBUStringSet/Notification_Template_Error_Subtitle``  if the `message.message` is `nil`
    private var parsingErrorNotificationRenderer: SBUMessageTemplate.Renderer {
        if let fallbackMessage = self.message?.message, fallbackMessage.count > 0 {
            return SBUMessageTemplate.Renderer(
                body: .parsingError(text: fallbackMessage),
                fontFamily: SBUFontSet.FontFamily.notifications
            )
        } else {
            return SBUMessageTemplate.Renderer(
                body: .parsingError(
                    text: SBUStringSet.Notification_Template_Error_Title,
                    subText: SBUStringSet.Notification_Template_Error_Subtitle
                ),
                fontFamily: SBUFontSet.FontFamily.notifications
            )
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
    
    var availableTemplateWidth: CGFloat = 0.0
    
    /// The top margin of the cell.
    var topMargin: CGFloat = 0.0
    
    /// The bottom margin of the cell.
    var bottomMargin: CGFloat = 0.0
    
    // MARK: - Logic
    var type: NotificationType = .none
    
    #if INSPECTION
    // MARK: - Gesture Recognizers
    lazy var contentLongPressRecognizer: UILongPressGestureRecognizer = {
        return .init(target: self, action: #selector(self.onLongPressContentView(sender:)))
    }()

    // MARK: - Action
    @objc
    open func onLongPressContentView(sender: UILongPressGestureRecognizer?) {
        if let sender = sender {
            if sender.state == .began {
                self.longPressHandlerToContent?()
            }
        } else {
            self.longPressHandlerToContent?()
        }
    }
    #endif
    
    // MARK: - Sendbird Life cycle
    /// Configures a cell with ``SBUBaseMessageCellParams`` object.
    override func configure(with configuration: SBUBaseMessageCellParams) {
        super.configure(with: configuration)
         
        self.dateLabel.text = Date
            .sbu_from(configuration.message.createdAt)
            .sbu_toString(dateFormat: SBUDateFormatSet.Message.sentTimeFormat)

        if let configuration = configuration as? SBUFeedNotificationCellParams {
            if let isTemplateLabelEnabled = configuration.isTemplateLabelEnabled, isTemplateLabelEnabled {
                self.categoryLabel.text = configuration.message.notifiationData?.label ?? (configuration.message.customType ?? "")
            } else {
                self.categoryLabel.text = ""
            }
        } else {
            self.categoryLabel.text = configuration.message.notifiationData?.label ?? (configuration.message.customType ?? "")
        }
        
        self.setupNotificationTemplate()
        
        if type == .chat {
            if let profileView = self.profileView as? SBUMessageProfileView {
                var urlString = ""
                if let profileURLString = configuration.profileImageURL {
                    urlString = profileURLString
                }
                profileView.configure(urlString: urlString)
            }
        }
        
        self.setupLayouts()
        self.setNeedsLayout()
    }
    
    override func setupViews() {
        self.dateView = SBUNotificationTimelineView() // timeline
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
        let windowBounds = UIApplication.shared.currentWindow?.bounds ?? .zero
        let screenWidth = min(windowBounds.width, windowBounds.height)
        var maxTemplateWidth: CGFloat = 0.0
        var leftMargin = 0.0
        var rightMargin = 0.0
        
        let dateLabelWidth = self.dateLabel.textWidth()
        
        switch type {
        case .none, .feed:
            maxTemplateWidth = feedNotificationMaxWidth
            leftMargin = 16
            rightMargin = 16
            self.availableTemplateWidth = screenWidth - (leftMargin + rightMargin)
        case .chat:
            maxTemplateWidth = chatNotificationMaxWidth
            leftMargin = 12
            rightMargin = 12
            self.availableTemplateWidth = screenWidth - (leftMargin + 26 + 12 + 4 + dateLabelWidth + rightMargin)
            // leftMargin + (profile) + (caption) + (profile/caption margin) + dataLabel + rightMargin
        }
        self.baseStackView
            .sbu_constraint(
                equalTo: self.messageContentView,
                leading: leftMargin,
                top: 0,
                bottom: 0,
                priority: .required
            )

        self.baseStackView.sbu_constraint(
            equalTo: self.messageContentView,
            trailing: -rightMargin,
            priority: .defaultHigh
        )
        
        self.contentStackView.sbu_constraint(
            width: min(self.availableTemplateWidth, maxTemplateWidth),
            priority: .required
        )

        if self.type == .chat {
            self.dateLabel.sbu_constraint(width: dateLabelWidth, priority: .defaultLow)
            self.dateLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
            
            self.profileView.sbu_constraint(width: 26, height: 26)
            self.profileMargin.sbu_constraint(width: 4)
            self.categoryMargin.sbu_constraint(width: 4)
        }
        
        // TODO: need to check
        self.captionStackView
            .sbu_constraint_greaterThan(height: 12)
        
        self.stackView
            .sbu_constraint(
                equalTo: self.contentView,
                left: 0,
                right: 0 // The top and the bottom have to be set in the subclasses of the SBUNotificationCell.
            )
    }
    
    /// This function handles the initialization of actions.
    /// - NOTE: It is called from intializer of ``SBUTableViewCell``
    /// - NOTE: To customize the action of message template view, please overrides regarding delegate methods in ``SBUFeedNotificationChannelModuleListDelegate``
    /// such as ``SBUFeedNotificationChannelModuleListDelegate/feedNotificationChannelModule(_:shouldHandleWebAction:message:forRowAt:)``,
    /// ``SBUFeedNotificationChannelModuleListDelegate/feedNotificationChannelModule(_:shouldHandlePreDefinedAction:message:forRowAt:)``,
    /// or ``SBUFeedNotificationChannelModuleListDelegate/feedNotificationChannelModule(_:shouldHandleCustomAction:message:forRowAt:)``
    override func setupActions() {
        super.setupActions()
        #if INSPECTION
        self.contentView.addGestureRecognizer(self.contentLongPressRecognizer)
        #endif
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
        
        self.dateLabel.font = self.notificationCellTheme.sentAtTextFont // SBUFontSet.caption4
        self.dateLabel.textColor = self.notificationCellTheme.sentAtTextColor
        self.dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    /// Creates the message template view and updates the views hierarchy.
    /// If the `message.extendedMessage["sub_data"]` is invalid, the message template view shows `message.message`  or ``SBUStringSet/Notification_Template_Error_Title``, ``SBUStringSet/Notification_Template_Error_Subtitle`` if the `message.message` is `nil`
    func setupNotificationTemplate() {
        let notification = self.message
        let subType = Int(notification?.extendedMessage["sub_type"] as? String ?? "0")
        
        guard subType == 0 else { return } // subType: 0 is template type
        
        let subData = notification?.extendedMessage["sub_data"] as? String
        var bindedTemplate: String?
        var isNewTemplateDownloading: Bool = false

        if !isTemplateDownloadFailed {
            (bindedTemplate, isNewTemplateDownloading) = SBUMessageTemplateManager.generateTemplate(
                type: .notification,
                subData: subData,
                themeMode: SBUNotificationChannelManager.notificationChannelThemeMode
            ) { [weak self] success in
                // This completionHandler is only called when a template download is requested.
                self?.isTemplateDownloadFailed = !success
                self?.setupNotificationTemplate() // NOTE: realodCell() 과 중복 처리. 확인 필요.
                self?.reloadCell()
            }
        }

        bindedTemplate = bindedTemplate?.replacingOccurrences(of: "\\n", with: "\\\\n")
        bindedTemplate = bindedTemplate?.replacingOccurrences(of: "\n", with: "\\n")
        
        var template: SBUMessageTemplate.Syntax.TemplateView?
        do {
            template = try JSONDecoder().decode(SBUMessageTemplate.Syntax.TemplateView.self, from: Data((bindedTemplate ?? "").utf8))
            template?.setIdentifier(with: .init(messageId: message?.messageId))
        } catch {
            SBULog.error(error)
        }

        var showFallback = false
        let version = template?.version ?? 0
        if version != 1 { // Not used now
//            bindedData = subData // v0.2
            showFallback = true
        }
        
        self.notificationTemplateRenderer = nil
        if isNewTemplateDownloading {
            self.notificationTemplateRenderer = SBUMessageTemplate.Renderer(
                body: .downloadingTemplate(
                    height: (type == .chat)
                    ? chatNotificationDownloadingHeight
                    : feedNotificationDownloadingHeight
                ),
                fontFamily: SBUFontSet.FontFamily.notifications
            )
        } else if let bindedTemplate = bindedTemplate, !showFallback, // 정상 케이스
            let notificationTemplateRenderer = SBUMessageTemplate.Renderer(
                with: bindedTemplate,
                messageId: message?.messageId,
                delegate: self,
                maxWidth: self.availableTemplateWidth,
                fontFamily: SBUFontSet.FontFamily.notifications,
                actionHandler: { [weak self] action in
                    self?.statisticsForAction(with: subData)
                    self?.messageTemplateActionHandler?(action)
                }
            ) {
            self.notificationTemplateRenderer = notificationTemplateRenderer
            self.isRendered = true
        } else {
            self.notificationTemplateRenderer = parsingErrorNotificationRenderer
        }
        
        self.notificationTemplateRenderer?.delegate = self
        guard let notificationTemplateRenderer = self.notificationTemplateRenderer else { return }
        notificationTemplateRenderer.backgroundColor = self.notificationCellTheme.backgroundColor
        notificationTemplateRenderer.roundCorners(corners: .allCorners, radius: self.notificationCellTheme.radius)
        notificationTemplateRenderer.clipsToBounds = true

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let profileView = self.profileView as? SBUMessageProfileView {
            profileView.imageDownloadTask?.cancel()
            profileView.urlString = ""
            profileView.imageView.image = nil
        }
    }
    
    // MARK: - Common
    
    /// Adds stat for action of notification to SendbirdStatistics.
    /// - Parameter subData: for exporting templateKey and tags.
    /// - Since: 3.5.7
    @discardableResult
    func statisticsForAction(with subData: String?) -> Bool {
        guard let subData = subData else { return false }
        
        // data scheme
        var templateKey: String?
        var tags: [String] = []
        do {
            if let subDataDic = try JSONSerialization.jsonObject(
                with: Data(subData.utf8),
                options: []
            ) as? [String: Any] {
                templateKey = subDataDic["template_key"] as? String
                tags = subDataDic["tags"] as? [String] ?? []
            }
        } catch {
            SBULog.error(error.localizedDescription)
            return false
        }
        
        guard let templateKey = templateKey,
              let message = self.message else { return false }
        
        let type = "noti:stats"
        let action = "clicked"
        let source = "notification"

        let isSucceed = __SendbirdStatistics.__appendStat(
            type: type,
            data: [
                "action": action,
                "template_key": templateKey,
                "channel_url": message.channelURL,
                "tags": tags,
                "message_id": message.messageId,
                "source": source,
                "message_ts": message.createdAt,
                "notification_event_deadline": message.notificationEventDeadline
            ]
        )
        
        SBULog.info("[\(isSucceed ? "Succeed" : "Failed")] SendbirdStatistics - \(type), \(action)")
        return isSucceed
    }
}

// MARK: - MessageTemplateRendererDelegate
extension SBUNotificationCell: MessageTemplateRendererDelegate {
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, didFinishLoadingImage imageView: UIImageView) {
        self.reloadCell()
    }
    
    func messageTemplateNeedReloadCell(_ renderer: SBUMessageTemplate.Renderer) {
        self.reloadCell()
    }
}
