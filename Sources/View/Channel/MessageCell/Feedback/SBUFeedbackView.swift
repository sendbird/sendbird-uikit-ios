//
//  SBUFeedbackView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/08.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.15.0
public protocol SBUFeedbackViewDelegate: AnyObject {
    /// Called when `form` is submitted.
    /// - Parameters:
    ///    - view: ``SBUFeedbackView`` object.
    ///    - answer: the submitted ``SBUFeedbackAnswer`` object.
    func feedbackView(_ view: SBUFeedbackView, didAnswer answer: SBUFeedbackAnswer)
}

/// - Since: 3.15.0
open class SBUFeedbackView: SBUView {
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// (Read-only) The feedback from ``SBUFeedbackViewParams``
    public var feedback: SendbirdChatSDK.Feedback? { params?.feedback }
    
    /// (Read-only) The status of feedwback from ``SBUFeedbackViewParams``
    public var status: SendbirdChatSDK.Feedback.Status? { params?.status }
    
    /// (Read-only) The message ID for feedback is from ``SBUFeedbackViewParams``
    public var messageId: Int64? { params?.messageId }
    
    /// (Read-only) The data structure for ``SBUFeedbackViewParams``. Please use ``configure(with:delegate:)`` to update ``params``
    public private(set) var params: SBUFeedbackViewParams?
    
    /// The delegate that is type of ``SBUFeedbackViewDelegate``
    public weak var delegate: SBUFeedbackViewDelegate?
    
    /// Updates UI with ``SBUFeedbackViewParams`` object and ``SBUFeedbackViewDelegate``.
    /// - Parameters:
    ///    - configuration: ``SBUFeedbackViewParams`` object.
    ///    - delegate: ``SBUFeedbackViewDelegate``, the delegate object that handles the feedback interaction event.
    /// - Note: This method updates ``params`` and ``delegate`` then, calls ``setupViews()``, ``setupLayouts()`` and ``setupStyles()``
    open func configure(with configuration: SBUFeedbackViewParams, delegate: SBUFeedbackViewDelegate? = nil) {
        self.params = configuration
        self.delegate = delegate
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
}

/// - Since: 3.15.0
open class SBUSimpleFeedbackView: SBUFeedbackView {
    // views
    
    /// A container view to wrap `stackView`.
    public var container: UIView = UIView()
    /// A vertical stack view to configure layouts of the forms.
    public var stackView: UIStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 4)
    
    /// The `UIButton` displaying the `good` button.
    public var goodButton: UIButton = UIButton(type: .custom)
    /// The `UIButton` displaying the `bad` button.
    public var badButton: UIButton = UIButton(type: .custom)
    
    // MARK: - Sendbird UIKit Life Cycle
    
    open override func setupViews() {
        super.setupViews()
        
        // + ---- stackView ---- +
        // | [ like  | dislike ] |
        // + ------------------- +

        self.stackView.setHStack([goodButton, badButton])
        self.container.addSubview(self.stackView)
        self.addSubview(self.container)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.stackView
            .sbu_constraint(equalTo: self.container, leading: 50, top: 0, bottom: 0)
            .sbu_constraint(height: 36)
        
        self.goodButton
            .sbu_constraint(width: 42, height: 36)
        
        self.badButton
            .sbu_constraint(width: 42, height: 36)
        
        self.container
            .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.container.backgroundColor = .clear
        
        self.goodButton.layer.cornerRadius = theme.feedbackRadius
        self.goodButton.layer.borderWidth = 1
        self.goodButton.clipsToBounds = true
        
        self.badButton.layer.cornerRadius = theme.feedbackRadius
        self.badButton.layer.borderWidth = 1
        self.badButton.clipsToBounds = true
        
        let iconGood = SBUIconSet.iconGood.resize(with: .init(value: 24))
        let iconBad = SBUIconSet.iconBad.resize(with: .init(value: 24))
        
        switch feedback?.rating {
        case .good:
            self.goodButton.setImage(iconGood.sbu_with(tintColor: theme.feedbackIconSelectColor), for: .normal)
            self.goodButton.layer.borderColor = theme.feedbackBorderSelectColor.cgColor
            self.goodButton.setBackgroundImage(UIImage.from(color: theme.feedbackBackgroundSelectColor), for: .normal)
            self.goodButton.isUserInteractionEnabled = true
            
            self.badButton.setImage(iconBad.sbu_with(tintColor: theme.feedbackIconDeselectColor), for: .normal)
            self.badButton.layer.borderColor = theme.feedbackBorderDeselectColor.cgColor
            self.badButton.setBackgroundImage(UIImage.from(color: theme.feedbackBackgroundDeselectColor), for: .normal)
            self.badButton.isUserInteractionEnabled = false
            
        case .bad:
            self.goodButton.setImage(iconGood.sbu_with(tintColor: theme.feedbackIconDeselectColor), for: .normal)
            self.goodButton.layer.borderColor = theme.feedbackBorderDeselectColor.cgColor
            self.goodButton.setBackgroundImage(UIImage.from(color: theme.feedbackBackgroundDeselectColor), for: .normal)
            self.goodButton.isUserInteractionEnabled = false
            
            self.badButton.setImage(iconBad.sbu_with(tintColor: theme.feedbackIconSelectColor), for: .normal)
            self.badButton.layer.borderColor = theme.feedbackBorderSelectColor.cgColor
            self.badButton.setBackgroundImage(UIImage.from(color: theme.feedbackBackgroundSelectColor), for: .normal)
            self.badButton.isUserInteractionEnabled = true
            
        default:
            self.goodButton.setImage(iconGood.sbu_with(tintColor: theme.feedbackIconColor), for: .normal)
            self.goodButton.layer.borderColor = theme.feedbackBorderColor.cgColor
            self.goodButton.setBackgroundImage(UIImage.from(color: theme.feedbackBackgroundNormalColor), for: .normal)
            self.goodButton.isUserInteractionEnabled = true
            
            self.badButton.setImage(iconBad.sbu_with(tintColor: theme.feedbackIconColor), for: .normal)
            self.badButton.layer.borderColor = theme.feedbackBorderColor.cgColor
            self.badButton.setBackgroundImage(UIImage.from(color: theme.feedbackBackgroundNormalColor), for: .normal)
            self.badButton.isUserInteractionEnabled = true
        }
    }
    
    open override func setupActions() {
        super.setupActions()
        
        self.goodButton.addTarget(self, action: #selector(onClickLike), for: .touchUpInside)
        self.badButton.addTarget(self, action: #selector(onClickDislike), for: .touchUpInside)
    }
    
    /// action for like
    @objc
    open func onClickLike() {
        guard let feedback = self.feedback else {
            self.onAction(with: .rating, rating: .good)
            return
        }
        
        if feedback.rating == .good {
            self.onAction(with: .modify, rating: .good)
        }
    }
    
    /// action for dislike
    @objc
    open func onClickDislike() {
        guard let feedback = self.feedback else {
            self.onAction(with: .rating, rating: .bad)
            return
        }
        
        if feedback.rating == .bad {
            self.onAction(with: .modify, rating: .bad)
        }
    }
    
    /// Processing action from buttons.
    /// - Parameters:
    ///   - action: ``SBUFeedbackAnswer/Action``.
    ///   - rating: ``Feedback.Rating``
    open func onAction(with action: SBUFeedbackAnswer.Action, rating: Feedback.Rating) {

        let answer = SBUFeedbackAnswer(action: action, original: self.feedback, rating: rating, comment: nil)

        self.delegate?.feedbackView(self, didAnswer: answer)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
