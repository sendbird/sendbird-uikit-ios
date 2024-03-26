//
//  SBUFeedbackAction.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/10.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import UIKit

/// Feedback answer data.
/// This model is used by SBUIKit when exchanging data and handling interactions.
/// - Since: 3.15.0
public struct SBUFeedbackAnswer {
    let action: SBUFeedbackAnswer.Action
    
    let original: Feedback?
    let rating: Feedback.Rating?
    let comment: String?
    
    func updateComment(_ new: String?) -> SBUFeedbackAnswer {
        return SBUFeedbackAnswer(action: action,
                                 original: original,
                                 rating: rating,
                                 comment: new)
    }
}

extension SBUFeedbackAnswer {
    /// internal Feedback interaction action status.
    /// - Since: 3.15.0
    public enum Action {
        /// Represents the rating action in the feedback system.
        case rating
        /// Represents the modify action in the feedback system.
        case modify
    }
    
    /// Methods to expose an alert view that can update the comment.
    /// - Parameters:
    ///   - answer: Feedback answer
    ///   - handler: Update handle (not called on cancellation.)
    /// - Since: 3.15.0
    public static func showCommentPopup(
        answer: SBUFeedbackAnswer,
        handler: @escaping ((SBUFeedbackAnswer) -> Void)
    ) {
        let comment = answer.original?.comment ?? ""
        let confirmTitle = comment.isEmpty ? SBUStringSet.Submit : SBUStringSet.Save
        let confirmButton = SBUAlertButtonItem(
            title: confirmTitle
        ) { info in
            let message = info as? String
            SBULog.info("[Request] submit message: \(String(describing: message))")
            handler(answer.updateComment(message))
        }
        
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        SBUAlertView.show(
            title: SBUStringSet.Feedback_Comment_Title,
            needInputField: true,
            inputText: answer.original?.comment,
            placeHolder: SBUStringSet.Feedback_Comment_Placeholder,
            confirmButtonItem: confirmButton,
            cancelButtonItem: cancelButton
        )
    }
    
    /// Methods that expose the flow for modifying the feedback answer.
    /// If you choose to update the comment, the alert view is also automatically exposed.
    /// - Parameters:
    ///   - theme: Channel Theme to update colors.
    ///   - answer: Feedback answer
    ///   - updateHandler: Update event handler
    ///   - deleteHandler: Delete event handler
    /// - Since: 3.15.0
    public static func showModifications(
        theme: SBUChannelTheme?,
        answer: SBUFeedbackAnswer,
        updateHandler: @escaping ((SBUFeedbackAnswer) -> Void),
        deleteHandler: @escaping ((SBUFeedbackAnswer) -> Void)
    ) {
        let updateItem = SBUActionSheetItem(
            title: SBUStringSet.Feedback_Edit_Comment
        ) {
            SBUFeedbackAnswer.showCommentPopup(
                answer: answer
            ) { updateAnswer in
                updateHandler(updateAnswer)
            }
        }
        
        let deleteItem = SBUActionSheetItem(
            title: SBUStringSet.Feedback_Remove,
            color: theme?.deleteItemColor
        ) {
            deleteHandler(answer)
        }
        
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            completionHandler: nil
        )
        
        SBUActionSheet.show(
            items: [updateItem, deleteItem],
            cancelItem: cancelItem
        )
    }
}
