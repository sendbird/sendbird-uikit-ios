//
//  SBUMessageTemplate.ErrorMessages.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate.Syntax.Body {
    static func parsingError(text: String, subText: String? = nil) -> SBUMessageTemplate.Syntax.Body {
        var textItems: [SBUMessageTemplate.Syntax.Item] = [
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
        
        let body = SBUMessageTemplate.Syntax.Body()
        body.items = [
            .box(.init(
                layout: .column,
                align: SBUMessageTemplate.Syntax.ItemsAlign(horizontal: .left, vertical: .center),
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
    
    static func downloadingTemplate(height: CGFloat) -> SBUMessageTemplate.Syntax.Body {
        let spinnerItems: [SBUMessageTemplate.Syntax.Item] = [
            .image(.init(
                imageUrl: SBUMessageTemplate.urlForTemplateDownload,
                imageStyle: .init(
                    contentMode: .center,
                    tintColor: SBUTheme.notificationTheme.notificationCell.downloadingBackgroundHexColor
                ),
                metaData: nil
            ))
        ]
        
        let body = SBUMessageTemplate.Syntax.Body()
        body.items = [
            .box(.init(
                layout: .column,
                align: SBUMessageTemplate.Syntax.ItemsAlign(horizontal: .center, vertical: .center),
                type: .box,
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
}
