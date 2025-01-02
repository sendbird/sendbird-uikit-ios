//
//  SBUMessageTemplate.RendererType.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/27.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

extension SBUMessageTemplate {
    enum RendererType {
        case inProgress
        case downloading(messageId: Int64?, view: UIView)
        case error(messageId: Int64?, view: UIView)
        case loaded(messageId: Int64?, view: UIView)
        
        var isInProgress: Bool {
            guard case .inProgress = self else { return false }
            return true
        }
    }
}

extension SBUMessageTemplate.RendererType {
    var isLoaded: Bool {
        switch self {
        case .loaded: return true
        default: return false
        }
    }
    
    var isError: Bool {
        switch self {
        case .error: return true
        default: return false
        }
    }
    
    var renderer: UIView? {
        switch self {
        case .inProgress: return nil
        case let .downloading(_, view): return view
        case let .error(_, view): return view
        case let .loaded(_, view): return view
        }
    }
    
    var messageId: Int64? {
        switch self {
        case .inProgress: return nil
        case let .downloading(messageId, _): return messageId
        case let .error(messageId, _): return messageId
        case let .loaded(messageId, _): return messageId
        }
    }
    
    mutating func clear() {
        self.renderer?.removeFromSuperview()
        self = .inProgress
    }
}

extension SBUMessageTemplate {
    static func parsingErrorMesageTemplateBody(
        type: SBUMessageTemplate.TemplateType,
        message: BaseMessage?,
        containerViewStyle viewStyle: TemplateSyntax.ViewStyle? = nil
    ) -> TemplateSyntax.Body {
        if let defaultMessage = message?.message, defaultMessage.hasElements {
            return .parsingError(
                text: defaultMessage,
                containerViewStyle: viewStyle
            )
        }
        
        switch type {
        case .notification:
            return .parsingError(
                text: SBUStringSet.Notification_Template_Error_Title,
                subText: SBUStringSet.Notification_Template_Error_Subtitle,
                containerViewStyle: viewStyle
            )
        case .message:
            return .parsingError(
                text: SBUStringSet.Message_Template_Error_Title,
                subText: SBUStringSet.Message_Template_Error_Subtitle,
                containerViewStyle: viewStyle
            )
        }
    }
    
    static func errorRenderer(
        type: SBUMessageTemplate.TemplateType,
        message: BaseMessage?,
        viewStyle: TemplateSyntax.ViewStyle? = nil
    ) -> UIView {
        let body: TemplateSyntax.Body = parsingErrorMesageTemplateBody(
            type: type,
            message: message,
            containerViewStyle: viewStyle
        )
        
        guard let view = try? ViewGenerator.draw(templateView: .init(body: body, messageId: message?.messageId)) else {
            return UIView()
        }

        return view
    }
    
    static func downloadingRenderer(
        messageId: Int64?,
        downloadingHeight: CGFloat,
        viewStyle: TemplateSyntax.ViewStyle? = nil
    ) -> UIView {
        let body: TemplateSyntax.Body = .downloadingTemplate(
            height: downloadingHeight,
            containerViewStyle: viewStyle
        )
        
        guard let view = try? ViewGenerator.draw(templateView: .init(body: body, messageId: messageId)) else {
            return UIView()
        }
        
        return view
    }
}
