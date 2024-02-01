//
//  SBUBaseMessageCell.Feedback.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/23.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUBaseMessageCell {
    /// This is function to create and set up the `SBUFeedbackView`.
    /// - Parameter feedback: Form list data.
    /// - Parameter Status: Cached form answer datas.
    /// - Returns: If `true`, succeeds in creating a valid form view
    /// - since: 3.15.0
    public func updateFeedbackView(with message: BaseMessage?) {
        self.feedbackView?.removeFromSuperview()
        self.feedbackView = nil
        
        guard SendbirdUI.config.groupChannel.channel.isFeedbackEnabled else { return }
        guard shouldHideFeedback == false else { return }
        
        guard let message = message else { return }
        if message.sender?.userId == SBUGlobals.currentUser?.userId { return }
        if message.myFeedbackStatus == .notApplicable { return }

        let feedbackView = self.feedbackView ?? createFeedbackView()
        let configuration = SBUFeedbackViewParams(
            messageId: message.messageId,
            feedback: message.myFeedback,
            status: message.myFeedbackStatus
        )
        feedbackView.configure(with: configuration, delegate: self)
        
        if let last = self.stackView.subviews.last {
            self.stackView.setCustomSpacing(4, after: last)
        }
        self.stackView.addArrangedSubview(feedbackView)
        
        feedbackView.sbu_constraint(equalTo: self.stackView, leading: 0, trailing: 0)
        self.feedbackView = feedbackView

        self.layoutIfNeeded()
    }
    
    /// Methods to use when you want to fully customize the design of the ``SBUFeedbackView``.
    /// Create your own view that inherits from ``SBUFeedbackView`` and return it.
    /// NOTE: The default view is ``SBUSimpleFeedbackView``, which has default icons.
    /// - Returns: Views that inherit from ``SBUFeedbackView``.
    /// - since: 3.15.0
    open func createFeedbackView() -> SBUFeedbackView { SBUSimpleFeedbackView() }
}
