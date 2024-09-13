//
//  SBUMessageTemplateCell.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 8/22/24.
//

import UIKit

/// Cell for rendering the MessageTemplate in the GroupChannel List.
/// - Since: 3.27.2
open class SBUMessageTemplateCell: SBUBaseMessageCell, SBUSuggestedReplyViewDelegate {
    // MARK: - UI Layouts
    lazy var layout: SBUMessageTemplateCellLayout = { self.createLayout() }()
    
    func createLayout() -> SBUMessageTemplateCellLayout {
        let layout = SBUMessageTemplateCellLayout()
        layout.target = self
        return layout
    }
    
    // MARK: - UI Views (Public)
    /// profile view property
    public lazy var profileView: UIView = { self.createProfileView() }()
    /// user name view property
    public lazy var userNameView: UIView = { self.createUserNameView() }()
    /// state view property
    public lazy var stateView: UIView = { self.createStateView() }()
    
    /// Methods for creating a profile view. Can be overridden.
    open func createProfileView() -> SBUMessageProfileView { SBUMessageProfileView() }
    /// Methods for creating a user name view. Can be overridden.
    open func createUserNameView() -> SBUUserNameView { SBUUserNameView() }
    /// Methods for creating a state view. Can be overridden.
    open func createStateView() -> SBUMessageStateView { SBUMessageStateView() }
    
    private(set) var messageTemplateLayer = MessageTemplateLayer()
    
    /// message tempalte container view
    public var messageTemplateContainer: UIView {
        messageTemplateLayer.templateContainerView
    }
    
    // MARK: - Suggested Replies
    
    /// ``SBUSuggestedReplyView`` instance.
    /// If you want to override that view, override the ``createSuggestedReplyView()`` constructor function.
    public private(set) var suggestedReplyView: SBUSuggestedReplyView?
    
    /// The boolean value whether the ``suggestedReplyView`` instance should appear or not. The default is `true`
    /// - Important: If it's true, ``suggestedReplyView`` never appears even if the ``userMessage`` has quick reply options.
    public private(set) var shouldHideSuggestedReplies: Bool = true
    
    // MARK: - UI Views (Private)
    private var renderer: SBUMessageTemplate.Renderer?
    
    // MARK: - Sendbird Life cycle
    /// Configures a cell with ``SBUBaseMessageCellParams`` object.
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUMessageTemplateCellParams else { return }
        
        self.shouldHideSuggestedReplies = configuration.shouldHideSuggestedReplies
        
        super.configure(with: configuration)
        
        self.configureProfileView()
        self.configureUserNameView()
        self.configureStateView()
        
        self.configureMessageTemplateContainer()
        self.configureMessageTemplateLayer()
        
        self.updateSuggestedReplyView(with: configuration.message.suggestedReplies)
        
        self.setupLayouts()
        self.setNeedsLayout()
    }
    
    // MARK: - configure methods for subviews.
        
    /// Methods to configure profile view
    open func configureProfileView() {
        guard let profileView = self.profileView as? SBUMessageProfileView else { return }
        
        let urlString = self.message?.sender?.profileURL ?? ""
        profileView.configure(urlString: urlString)
    }
    
    /// Methods to configure userName view
    open func configureUserNameView() {
        guard let userNameView = self.userNameView as? SBUUserNameView else { return }
        
        if let sender = self.message?.sender {
            let username = SBUUser(user: sender).refinedNickname()
            userNameView.configure(username: username)
        } else {
            userNameView.configure(username: "")
        }
    }
    
    /// Methods to configure state view
    open func configureStateView() {
        guard let stateView = self.stateView as? SBUMessageStateView else { return }
        guard let message = self.message else { return }
        
        let configuration = SBUMessageStateViewParams(
            timestamp: message.createdAt,
            sendingState: message.sendingStatus,
            receiptState: .none,
            position: .left,
            isQuotedReplyMessage: false
        )
        stateView.configure(with: configuration)
    }
    
    // MARK: - message template configuration methods
    
    // Methods to configure the value of the container property of a message template
    public func configureMessageTemplateContainer() {
        guard let options = (self.configuration as? SBUMessageTemplateCellParams)?.container.containerOptions else { return }
        
        self.profileView.alpha = options.profile == false ? 0.0 : 1.0
        self.userNameView.alpha = options.nickname == false ? 0.0 : 1.0
        self.stateView.alpha = options.time == false ? 0.0 : 1.0
    }
    
    // Methods to configure the message template layer
    public func configureMessageTemplateLayer() {
        self.messageTemplateLayer.message = self.message
        self.setupMessageTemplate()
        self.setupMessageTemplateLayouts()
        self.updateMessageTemplateLayouts()
    }
    
    // MARK: - tableview cell life cycle methods
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        (self.profileView as? SBUMessageProfileView)?.configure(urlString: ReuseConstant.profileUrl)
        (self.userNameView as? SBUUserNameView)?.configure(username: ReuseConstant.userName)
        (self.stateView as? SBUMessageStateView)?.configure(with: ReuseConstant.stateParameter)
        
        self.profileView.alpha = 0.0
        self.userNameView.alpha = 0.0
        self.stateView.alpha = 0.0
        
        self.layout.prepareForReuse()
    }
    
    // MARK: - layout cycle methods
    
    open override func setupViews() {
        super.setupViews()
        self.layout.configureViews()
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        self.layout.configureLayouts()
    }
    
    open override func updateLayouts() {
        super.updateLayouts()
    }
    
    open override func setupStyles() {
        self.backgroundColor = .clear

        (self.profileView as? SBUMessageProfileView)?.setupStyles()
        (self.userNameView as? SBUUserNameView)?.setupStyles()
        (self.stateView as? SBUMessageStateView)?.setupStyles()
    }
    
    open override func setupActions() {
        super.setupActions()

        self.profileView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapUserProfileView(sender:)))
        )
    }
    
    // MARK: - Action
    @objc
    open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }
    
    // MARK: - Suggested Replies view method
    
    open func updateSuggestedReplyView(with options: [String]?) {
        self.suggestedReplyView =
        SBUSuggestedReplyView.updateSuggestedReplyView(
            with: options,
            message: self.message,
            shouldHide: shouldHideSuggestedReplies,
            delegate: self
        )
    }
    
    public func suggestedReplyView(_ view: SBUSuggestedReplyView, didSelectOption optionView: SBUSuggestedReplyOptionView) {
        self.suggestedReplySelectHandler?(optionView)
        
        self.suggestedReplyView?.removeFromSuperview()
        self.suggestedReplyView = nil
        
        self.layoutIfNeeded()
    }
}

extension SBUMessageTemplateCell {
    struct ReuseConstant {
        fileprivate static var profileUrl: String = ""
        fileprivate static var userName: String = ""
        fileprivate static var stateParameter: SBUMessageStateViewParams {
            SBUMessageStateViewParams(
                timestamp: 0,
                sendingState: .none,
                receiptState: .none,
                position: .left
            )
        }
        
    }
}
