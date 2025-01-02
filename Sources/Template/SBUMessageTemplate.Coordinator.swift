//
//  SBUMessageTemplate.Coordinator.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

extension SBUMessageTemplate.Coordinator {
    enum ResultType {
        case reload(ReloadType)
        case template(syntax: TemplateSyntax.TemplateView, view: UIView)
        case failed
        
        enum ReloadType {
            case download(DownloadType)
        }
        
        enum DownloadType {
            case template(keys: [String])
        }
        
        var template: TemplateSyntax.TemplateView? {
            switch self {
            case .template(let syntax, _): return syntax
            default: return nil
            }
        }
        
        var view: UIView? {
            switch self {
            case .template(_, let view): return view
            default: return nil
            }
        }
    }
}

extension SBUMessageTemplate {
    class Coordinator {
        static func execute(
            type: SBUMessageTemplate.TemplateType,
            message: BaseMessage?,
            theme: TemplateColorScheme? = nil,
            params: ViewGeneratorParams
        ) -> SBUMessageTemplate.Coordinator.ResultType {
            guard let message = message else { return .failed }
            guard let payload = type.payload(from: message) else { return .failed }
            
            do {
                let result = try TemplateParser(provider: type).parse(
                    key: payload.key,
                    messageId: payload.messageId,
                    dataVariables: payload.datas,
                    viewVariables: payload.views,
                    theme: theme
                )
                
                var templateView = result
                
                if result.templateModel?.isDataTemplate == true {
                    templateView = .init(
                        body: .dataTemplate(
                            text: "[This message is sent from data template.]",
                            subText: result.templateJson
                        ),
                        messageId: message.messageId
                    )
                }
                
                let view = try ViewGenerator.draw(
                    templateView: templateView,
                    params: params
                )
                
                return .template(
                    syntax: templateView,
                    view: view
                )
                    
            } catch {
                switch error {
                case let TemplateError.noExist(keys):
                    return .reload(.download(.template(keys: keys)))
                default:
                    return .failed
                }
            }
        }
    }
}
