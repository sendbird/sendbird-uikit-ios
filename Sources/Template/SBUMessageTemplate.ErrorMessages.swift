//
//  SendbirdMessageTemplate.ErrorMessages.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

extension TemplateSyntax.Body {
    static func parsingError(
        text: String,
        subText: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        containerViewStyle viewStyle: TemplateSyntax.ViewStyle? = nil
    ) -> TemplateSyntax.Body {
        var textItems: [TemplateSyntax.Item] = [
            .text(.init(
                text: text,
                maxTextLines: 10,
                textStyle: .init(
                    size: 14,
                    color: SBUTheme.notificationTheme.notificationCell.fallbackMessageTitleHexColor,
                    weight: .normal
                ),
                type: .text,
                viewStyle: .init(
                    padding: .init(top: 0, bottom: 0, left: 0, right: 0)
                )
            ))
        ]
        if let subText = subText {
            textItems.append(
                .text(.init(
                    text: subText,
                    maxTextLines: 10,
                    textStyle: .init(
                        size: 14,
                        color: SBUTheme.notificationTheme.notificationCell.fallbackMessageSubtitleHexColor,
                        weight: .normal
                    ),
                    type: .text,
                    viewStyle: .init(
                        padding: .init(top: 0, bottom: 0, left: 0, right: 0)
                    )
                ))
            )
        }
        
        let body = TemplateSyntax.Body()
        body.items = [
            .box(.init(
                layout: .column,
                align: TemplateSyntax.ItemsAlign(horizontal: .left, vertical: .center),
                type: .box,
                viewStyle: viewStyle,
                width: width != nil ? .init(type: .fixed, value: Int(width!)) : .wrapContent,
                height: height != nil ? .init(type: .fixed, value: Int(height!)) : .wrapContent,
                items: [
                    .box(.init(
                        layout: .column,
                        align: .init(horizontal: .left, vertical: .center),
                        type: .box,
                        viewStyle: .init(
                            padding: .init(top: 12, bottom: 12, left: 12, right: 12)
                        ),
                        items: textItems
                    ))
                ]
            ))
        ]
        return body
    }
    
    static func downloadingTemplate(
        width: CGFloat? = nil,
        height: CGFloat,
        containerViewStyle viewStyle: TemplateSyntax.ViewStyle? = nil
    ) -> TemplateSyntax.Body {
        let spinnerItems: [TemplateSyntax.Item] = [
            .image(.init(
                imageUrl: TemplateConfig.urlForTemplateDownload,
                imageStyle: .init(
                    contentMode: .center,
                    tintColor: SBUTheme.notificationTheme.notificationCell.downloadingBackgroundHexColor
                ),
                metaData: nil
            ))
        ]
        
        let body = TemplateSyntax.Body()
        body.items = [
            .box(.init(
                layout: .column,
                align: TemplateSyntax.ItemsAlign(horizontal: .center, vertical: .center),
                type: .box,
                viewStyle: viewStyle,
                width: width != nil ? .init(type: .fixed, value: Int(width!)) : .wrapContent,
                height: .init(type: .fixed, value: Int(height)),
                items: [
                    .box(.init(
                        layout: .column,
                        align: .init(horizontal: .center, vertical: .center),
                        type: .box,
                        viewStyle: .init(
                            padding: .init(top: 0, bottom: 0, left: 0, right: 0)
                        ),
                        width: .init(type: .fixed, value: 36),
                        height: .init(type: .fixed, value: 36),
                        items: spinnerItems
                    ))
                ]
            ))
        ]
        return body
    }
    
    static func dataTemplate(text: String, subText: String? = nil) -> TemplateSyntax.Body {
        var textItems: [TemplateSyntax.Item] = [
               .text(.init(
                   text: text,
                   maxTextLines: 10,
                   textStyle: .init(
                       size: 14,
                       color: SBUTheme.notificationTheme.notificationCell.fallbackMessageTitleHexColor,
                       weight: .normal
                   ),
                   type: .text,
                   viewStyle: .init(
                       padding: .init(top: 0, bottom: 0, left: 0, right: 0)
                   )
               ))
           ]
           if let subText = subText {
               textItems.append(
                   .text(.init(
                       text: subText,
                       maxTextLines: 0,
                       textStyle: .init(
                           size: 14,
                           color: SBUTheme.notificationTheme.notificationCell.fallbackMessageSubtitleHexColor,
                           weight: .normal
                       ),
                       type: .text,
                       viewStyle: .init(
                           padding: .init(top: 0, bottom: 0, left: 0, right: 0)
                       )
                   ))
               )
           }

        let body = TemplateSyntax.Body()
           body.items = [
               .box(.init(
                   layout: .column,
                   align: TemplateSyntax.ItemsAlign(horizontal: .left, vertical: .center),
                   type: .box,
                   items: [
                       .box(.init(
                           layout: .column,
                           align: .init(horizontal: .left, vertical: .center),
                           type: .box,
                           viewStyle: .init(
                               padding: .init(top: 12, bottom: 12, left: 12, right: 12)
                           ),
                           items: textItems
                       ))
                   ]
               ))
           ]
           return body
       }
}
