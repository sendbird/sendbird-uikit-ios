//
//  SBUQuotedBaseMessageView.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/05.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

enum QuotedMessageType {
    case none
    case userMessage
    case fileMessage(_ name: String, _ type: String, _ urlString: String)
}

@objc
public protocol SBUQuotedMessageViewDelegate: AnyObject {
    func didTapQuotedMessageView(_ quotedMessageView: SBUQuotedBaseMessageView)
}

@objcMembers @IBDesignable
open class SBUQuotedBaseMessageView: SBUView, SBUQuotedMessageViewProtocol {
    // MARK: - Properties
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// The ID of parent message
    public var messageId: Int64 = 0
    
    /// The position of parent message view
    public var messagePosition: MessagePosition = .center {
        didSet {
            switch messagePosition {
            case .left:
                self.messageStackView.alignment = .leading
                self.repliedToLabel.textAlignment = .left
            case .right:
                self.messageStackView.alignment = .trailing
                self.repliedToLabel.textAlignment = .right
            case .center:
                self.messageStackView.alignment = .leading
                self.repliedToLabel.textAlignment = .left
            }
        }
    }
    /// The sender nickname of the quoted message.
    /// - Since: 2.2.0
    public var quotedMessageNickname: String = ""
    
    /// The sender nickname of the reply message.
    /// - Since: 2.2.0
    public var replierNickname: String = ""
    
    /// "{`replierNickname`} replied to {`quotedMessageNickname`}"
    /// - Since: 2.2.0
    public var repliedToText: String {
        SBUStringSet.Message_Replied_To(
            self.replierNickname,
            self.quotedMessageNickname
        )
    }
    /// The text of the quoted message
    /// - Since: 2.2.0
    public var text: String? = ""
    
    /// If `true`, the quoted message is type of `SBDFileMessage`.
    /// - Since: 2.2.0
    public var isFileType: Bool {
        switch messageType {
            case .fileMessage: return true
            default: return false
        }
    }
    
    // MARK: Internal (only for Swift)
    var messageType: QuotedMessageType = .none {
        didSet {
            switch messageType {
                case .userMessage: return
                case .fileMessage: return
                default: return
            }
        }
    }
    
    private let repliedToPaddingWidth: CGFloat = 8
    
    // MARK: - Views
    
    /// The UILabel displaying whom user replies to.
    /// e.g. “You replied to Jasmine”
    /// - Since: 2.2.0
    public private(set) lazy var repliedToLabel: UILabel = UILabel()
    
    /// The UIImageView displaying `iconReplied`.
    /// - Since: 2.2.0
    public private(set) lazy var repliedIconView = UIImageView()
    
    let repliedToLeadingPadding = UIView()
    
    let repliedToTrailingPadding = UIView()
    
    // MARK: - Views: Layouts

    // + ---------------- +
    // | messageStackView |
    // + ---------------- +
    /// UIStackView containing `messageStackView`.
    /// - Since: 2.2.0
    public lazy var contentStackView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .top, spacing: 0)
    }()
    
    // + ------------------- +
    // | repliedToStackView  |
    // + ------------------- +
    // | mainContainerView   |
    // + ------------------- +
    /// UIStackView containing `repliedToStackView` and `mainContainerView`.
    /// - Since: 2.2.0
    public lazy var messageStackView: UIStackView = {
        return SBUStackView(axis: .vertical, alignment: .leading, spacing: 6)
    }()
    
    // + --------- + --------------- + -------------- + --------- +
    // | replyToLP | repliedIconView | repliedToLabel | replyToTP |
    // + --------- + --------------- + -------------- + --------- +
    //
    // * LP: LeadingPadding
    // * TP: TrailingPadding
    /// UIStackView containing `repliedToLabel` and `repliedIconView`.
    /// - Since: 2.2.0
    public lazy var repliedToStackView: UIStackView = {
        return SBUStackView(axis: .horizontal , alignment: .center, spacing: 4)
    }()
    
    /// The selectable stack view that displays text or thumbnail image of the quoted message.
    /// - Since: 2.2.0
    public var mainContainerView: SBUSelectableStackView = {
        let mainView = SBUSelectableStackView()
        mainView.layer.cornerRadius = 16
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.borderWidth = 1
        mainView.clipsToBounds = true
        return mainView
    }()
    
    // MARK: - Actions
    /// `SBUQuotedMessageViewDelegate`
    /// - Since: 2.2.0
    public weak var delegate: SBUQuotedMessageViewDelegate?
    
    // 액션들에 대한 통일성이 필요
    // IMO: 가장 이상적인 케이스는 기본 액션은 우리가 정의해주고 전부 커스터마이징 할 수 잇게 오픈
    // 메세지셀 말고 다른 쪽은 핸들러를 제공하고 있지 않고 있음.
    // 테크뎁!
    var tapHandlerToContent: (() -> Void)?
    
    lazy var contentTapRecognizer: UITapGestureRecognizer = {
        return .init(target: self, action: #selector(didTapQuotedMessageView(sender:)))
    }()
    
    // MARK: - Initializer
    public override init() {
        super.init()
        
        self.setupStyles()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.setupStyles()
    }
    
    // MARK: - Views: Life cycle
    open override func setupViews() {
        // + --------- + --------------- + -------------- + --------- +
        // | replyToLP | repliedIconView | repliedToLabel | replyToTP |
        // + --------- + --------------- + -------------- + --------- +
        // |                    mainContainerView                     |
        // + -------------------------------------------------------- +
        //
        // * LP: LeadingPadding
        // * TP: TrailingPadding
        self.contentStackView.setHStack([
            self.messageStackView.setVStack([
                self.repliedToStackView.setHStack([
                    self.repliedToLeadingPadding,
                    self.repliedIconView,
                    self.repliedToLabel,
                    self.repliedToTrailingPadding
                ]),
                self.mainContainerView
            ])
        ])
        
        self.addSubview(contentStackView)
    }
    
    open override func setupAutolayout() {
        self.contentStackView
            .setConstraint(from: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.repliedIconView
            .setConstraint(width: 12, height: 12)
        
        self.repliedToLeadingPadding
            .setConstraint(width: self.repliedToPaddingWidth)
        
        self.repliedToTrailingPadding
            .setConstraint(width: self.repliedToPaddingWidth)
    }
    
    open override func setupStyles() {
        self.theme = SBUTheme.messageCellTheme
        
        self.mainContainerView.leftBackgroundColor = self.theme.quotedMessageBackgroundColor
        self.mainContainerView.rightBackgroundColor = self.theme.quotedMessageBackgroundColor
        
        self.repliedToLabel.textColor = self.theme.repliedToTextColor
        self.repliedToLabel.font = self.theme.repliedToTextFont
        self.repliedIconView.image = SBUIconSetType.iconReplied.image(
            with: self.theme.repliedIconColor,
            to: SBUIconSetType.Metric.defaultIconSizeVerySmall
        )
    }
    
    open override func setupActions() {
        self.mainContainerView.addGestureRecognizer(self.contentTapRecognizer)
        self.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapQuotedMessageView(self)
        }
    }
    
    public func configure(with configuration: SBUQuotedBaseMessageViewParams) {
        // TODO: re arrange stack view in contentView
        self.isHidden = false
        self.messageId = configuration.messageId
        self.messagePosition = configuration.messagePosition
        self.quotedMessageNickname = configuration.quotedMessageNickname
        self.replierNickname = configuration.replierNickname
        self.repliedToLabel.text = repliedToText
        
        self.messageType = configuration.messageType
    }
    
    // MARK: - Actions
    // Tap 했을 때 다른 동작할 수 있도록 수정이 필요
    
    /**
     The action invokes  `SBUQuotedMessageViewDelegate didTapQuotedMessageView(_:)` method and scrolls to parent message cell.
     */
    open func didTapQuotedMessageView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
    }
}
