//
//  SBUMessageTemplate.Renderer+Events.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol MessageTemplateRendererDelegate: AnyObject {
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, didFinishLoadingImage imageView: UIImageView)
    func messageTemplateNeedReloadCell(_ renderer: SBUMessageTemplate.Renderer)
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, didUpdateValue value: Any, forKey key: SBUMessageTemplate.Renderer.EventSourceKeys)
}
extension MessageTemplateRendererDelegate { // optional
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, didUpdateValue value: Any, forKey key: SBUMessageTemplate.Renderer.EventSourceKeys) { }
}

protocol MessageTemplateRendererDataSource: AnyObject {
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, valueFor key: SBUMessageTemplate.Renderer.EventSourceKeys) -> Any?
}

extension SBUMessageTemplate.Renderer {
    enum EventSourceKeys: String {
        case templateFactory
        case carouselRestoreView
    }
}

extension SBUMessageTemplate.Renderer {
    func rendererValueFor<Element>(
        key: EventSourceKeys,
        defaultValue: Element
    ) -> Element {
        (self.dataSource?.messageTemplateRender(self, valueFor: key) as? Element) ?? defaultValue
    }
    
    func rendererValueFor<Element>(
        key: EventSourceKeys
    ) -> Element? {
        (self.dataSource?.messageTemplateRender(self, valueFor: key) as? Element)
    }
    
    func rendererUpdateValue<Element>(
        _ value: Element,
        forKey key: EventSourceKeys
    ) {
        self.delegate?.messageTemplateRender(self, didUpdateValue: value, forKey: key)
    }
}
