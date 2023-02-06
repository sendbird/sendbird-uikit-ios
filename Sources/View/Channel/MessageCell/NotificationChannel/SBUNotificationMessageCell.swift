//
//  SBUNotificationMessageCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/07.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol SBUNotificationMessageCellDelegate: AnyObject {
    func messageCellShouldReload(_ cell: SBUNotificationMessageCell)
}

@IBDesignable
open class SBUNotificationMessageCell: SBUBaseMessageCell {
    // MARK: - UI Layouts
    public var baseStackView = SBUStackView(axis: .horizontal, alignment: .top, spacing: 8)
    public var contentStackView = SBUStackView(axis: .vertical, spacing: 4)
    public var captionStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
    
    // MARK: - UI Views (Public)
    
    public var profileView: UIView = UIView()

    public var customTypeView: UIView = UILabel()
    
    public var newMessageBadge: UIView?
    
    public var dateLabel = UILabel()
    
    /// Specifies the theme object that’s used as the theme of the message template view. The theme must inherit the ``SBUMessageTemplateTheme`` class.
    @SBUThemeWrapper(theme: SBUTheme.messageTemplateTheme)
    public var messageTemplateTheme: SBUMessageTemplateTheme
    
    
    // MARK: - UI Views (Private)
    private var messageTemplateRenderer: MessageTemplateRenderer?

    /// Shows `message.message`  or ``SBUStringSet/Message_Template_Error`` if the `message.message` is `nil`
    private var parsingErrorMessageRenderer: MessageTemplateRenderer {
        if let message = self.message?.message {
            return MessageTemplateRenderer(body: .parsingError(text: message))
        } else {
            return MessageTemplateRenderer(body: .parsingError(text: SBUStringSet.Message_Template_Error))
        }
    }
    
    private lazy var defaultProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = SBUIconSetType.iconChannels.image(
            with: self.theme.userPlaceholderTintColor,
            to: SBUIconSetType.Metric.defaultIconSizeVerySmall
        )
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// The green dot icon
    private lazy var defaultNewMessageBadge: UIView = {
        let length = CGFloat(6)
        let iconView = UIView()
            .sbu_constraint(width: length, height: length)
        iconView.layer.cornerRadius = length / 2
        iconView.layer.masksToBounds = true
        iconView.backgroundColor = self.theme.newMessageBadgeColor
        
        return iconView
    }()
    
    
    // MARK: - Delegate properties
    weak var delegate: SBUNotificationMessageCellDelegate?
    
    
    // MARK: - Actions
    var messageActionHandler: ((SBUMessageTemplate.Action) -> Void)?
    
    // MARK: - Sendbird Life cycle
    /// Configures a cell with ``SBUBaseMessageCellParams`` object.
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        super.configure(with: configuration)
        
        self.dateLabel.text = Date
            .lastUpdatedTime(baseTimestamp: configuration.message.createdAt)
        
        (self.customTypeView as? UILabel)?.text = configuration.message.customType ?? ""
        
        self.setupMessageTemplate(theme: self.messageTemplateTheme)
    }
    
    open override func setupViews() {
        if self.newMessageBadge == nil {
            self.newMessageBadge = self.defaultNewMessageBadge
        }
        self.newMessageBadge?.isHidden = true
        
        self.contentView.addSubview(
            self.stackView.setVStack([
                self.messageContentView
            ])
        )
        
        self.messageContentView.addSubview(
            self.baseStackView.setHStack([
                self.profileView,
                self.contentStackView.setVStack([
                    self.captionStackView.setHStack([
                        self.customTypeView,
                        UIView(),
                        self.newMessageBadge,
                        self.dateLabel
                    ]),
                    // messageTemplateRenderer will be located here...
                ])
            ])
        )
        self.profileView.addSubview(defaultProfileImageView)
    }
    
    open override func setupLayouts() {
        self.stackView
            .sbu_constraint(
                equalTo: self.contentView,
                left: 0,
                right: 0,
                top: 0,
                bottom: 0
            )
        
        self.baseStackView
            .sbu_constraint(
                equalTo: self.messageContentView,
                leading: 16,
                trailing: -16,
                top: 16,
                bottom: 0
            )
        
        self.profileView
            .sbu_constraint(width: 24, height: 24)
        
        self.defaultProfileImageView
            .sbu_constraint(width: 12, height: 12)
            .sbu_constraint(
                equalTo: self.profileView,
                centerX: 0,
                centerY: 0
            )
        
        self.captionStackView
            .sbu_constraint(height: 12)
    }
    
    /// This function handles the initialization of actions.
    /// - NOTE: It is called from intializer of ``SBUTableViewCell``
    /// - NOTE: To customize the action of message template view, please overrides regarding delegate methods in ``SBUNotificationChannelModuleListDelegate``
    /// such as ``SBUNotificationChannelModuleListDelegate/notificationChannelModule(_:shouldHandleWebAction:message:forRowAt:)``,
    /// ``SBUNotificationChannelModuleListDelegate/notificationChannelModule(_:shouldHandlePreDefinedAction:message:forRowAt:)``,
    /// or ``SBUNotificationChannelModuleListDelegate/notificationChannelModule(_:shouldHandleCustomAction:message:forRowAt:)``
    open override func setupActions() {
        super.setupActions()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.captionStackView.arrangedSubviews.forEach {
            $0.tintColor = self.theme.dateTextColor
        }
        
        self.profileView.backgroundColor = self.theme.userPlaceholderBackgroundColor
        self.profileView.layer.cornerRadius = 12
        self.profileView.clipsToBounds = true
        
        (self.customTypeView as? UILabel)?.font = self.theme.userNameFont
        (self.customTypeView as? UILabel)?.textColor = self.theme.userNameTextColor
        
        self.dateLabel.font = self.theme.timeFont //SBUFontSet.caption4
        self.dateLabel.textColor = self.theme.timeTextColor
        
        self.setupMessageTemplate(theme: self.messageTemplateTheme)
    }
    
    /// Creates the message template view and updates the views hierarchy.
    /// If the `message.extendedMessage["sub_data"]` is invalid, the message template view shows `message.message`  or ``SBUStringSet/Message_Template_Error`` if the `message.message` is `nil`
    /// - Parameters:
    ///    - message: If it's `nil`, it uses message value in ``SBUNotificationMessageCell``. The default value is `nil`.
    ///    - theme: The
    open func setupMessageTemplate(with message: BaseMessage? = nil, theme: SBUMessageTemplateTheme = SBUTheme.messageTemplateTheme) {
        let message = self.message ?? message
        let data = message?.extendedMessage["sub_data"] as? String
        self.messageTemplateTheme = theme
        self.messageTemplateRenderer?.delegate = nil
        self.messageTemplateRenderer = nil
        if let data = data {
            self.messageTemplateRenderer = MessageTemplateRenderer(
                with: data,
                theme: theme,
                actionHandler: self.messageActionHandler
            ) ?? parsingErrorMessageRenderer
        } else {
            self.messageTemplateRenderer = parsingErrorMessageRenderer
        }
        
        self.messageTemplateRenderer?.delegate = self
        guard let messageTemplateRenderer = self.messageTemplateRenderer else { return }
        messageTemplateRenderer.roundCorners(corners: .allCorners, radius: 8.0)
        messageTemplateRenderer.clipsToBounds = true
        
        self.baseStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        self.baseStackView.setHStack([
            self.profileView,
            self.contentStackView.setVStack([
                self.captionStackView.setHStack([
                    self.customTypeView,
                    UIView(),
                    self.newMessageBadge,
                    self.dateLabel
                ]),
                messageTemplateRenderer
            ])
        ])
        
        self.updateLayouts()
    }
    
    /// As a default, it follows the condition: `message.createdAt <= listComponent.lastSeenAt`
    public func updateReadStatus(_ read: Bool) {
        self.newMessageBadge?.isHidden = read
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}


// MARK: - MessageTemplateRendererDelegate
extension SBUNotificationMessageCell: MessageTemplateRendererDelegate {
    func messageTemplateRender(_ renderer: MessageTemplateRenderer, didFinishLoadingImage imageView: UIImageView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.messageCellShouldReload(self)
        }
    }
}
