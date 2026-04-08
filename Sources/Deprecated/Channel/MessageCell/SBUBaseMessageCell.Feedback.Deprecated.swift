//
//  SBUBaseMessageCell.Feedback.Deprecated.swift
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
    @available(*, deprecated, message: "This method is deprecated in 3.34.1")
    public func updateFeedbackView(with message: BaseMessage?) {
        SBULog.info("[Deprecated] Feedback feature is deprecated in 3.34.1")
        self.feedbackView?.removeFromSuperview()
        self.feedbackView = nil
    }

    /// Methods to use when you want to fully customize the design of the ``SBUFeedbackView``.
    /// Create your own view that inherits from ``SBUFeedbackView`` and return it.
    /// NOTE: The default view is ``SBUSimpleFeedbackView``, which has default icons.
    /// - Returns: Views that inherit from ``SBUFeedbackView``.
    /// - since: 3.15.0
    @available(*, deprecated, message: "This method is deprecated in 3.34.1")
    open func createFeedbackView() -> SBUFeedbackView { SBUSimpleFeedbackView() }
}
