//
//  SBUMessageTemplate.Renderer.RendererType.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/27.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUMessageTemplate.Renderer {
    enum RendererType {
        case inProgress
        case downloading(renderer: SBUMessageTemplate.Renderer)
        case error(renderer: SBUMessageTemplate.Renderer)
        case loaded(key: String, renderer: SBUMessageTemplate.Renderer)
        
        var isInProgress: Bool {
            guard case .inProgress = self else { return false }
            return true
        }
    }
}

extension SBUMessageTemplate.Renderer.RendererType {
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
    
    var renderer: SBUMessageTemplate.Renderer? {
        switch self {
        case .inProgress: return nil
        case .downloading(let renderer): return renderer
        case .error(let renderer): return renderer
        case .loaded(_, let renderer): return renderer
        }
    }
    
    mutating func clear() {
        self.renderer?.removeFromSuperview()
        self.renderer?.delegate = nil
        self = .inProgress
    }
}

extension SBUMessageTemplate.Renderer {
    static func parsingErrorMesageTemplateBody(
        type: SBUTemplateType,
        message: BaseMessage?,
        containerViewStyle viewStyle: SBUMessageTemplate.Syntax.ViewStyle? = nil
    ) -> SBUMessageTemplate.Syntax.Body {
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
        type: SBUTemplateType,
        message: BaseMessage?,
        viewStyle: SBUMessageTemplate.Syntax.ViewStyle? = nil
    ) -> SBUMessageTemplate.Renderer {
        let body: SBUMessageTemplate.Syntax.Body = parsingErrorMesageTemplateBody(
            type: type,
            message: message,
            containerViewStyle: viewStyle
        )
        return SBUMessageTemplate.Renderer(
            messageId: message?.messageId,
            body: body
        )
    }
    
    static func downloadingRenderer(
        messageId: Int64?,
        downloadingHeight: CGFloat,
        viewStyle: SBUMessageTemplate.Syntax.ViewStyle? = nil
    ) -> SBUMessageTemplate.Renderer {
        let body: SBUMessageTemplate.Syntax.Body = .downloadingTemplate(
            height: downloadingHeight,
            containerViewStyle: viewStyle
        )
        return SBUMessageTemplate.Renderer(
            messageId: messageId,
            body: body
        )
    }
}
