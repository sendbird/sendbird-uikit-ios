//
//  SBUMessageTemplateCell.MessageTemplateLayer.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/19.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

extension SBUMessageTemplateCell {
    class MessageTemplateLayer {
        static let downloadingHeight: CGFloat = 274.0
        
        weak var message: BaseMessage? {
            didSet {
                if self.message?.messageId == oldValue?.messageId, self.messageTemplateRenderer.isInProgress { return }
                self.clear()
            }
        }
        
        var templateContainerView = UIStackView()
        
        var templateView: TemplateSyntax.TemplateView?
        var messageTemplateRenderer: SBUMessageTemplate.RendererType = .inProgress
    }
}

extension SBUMessageTemplateCell.MessageTemplateLayer {
    func renderError() {
        let renderer = SBUMessageTemplate.errorRenderer(
            type: .message,
            message: self.message,
            viewStyle: .init(
                backgroundColor: TemplateConfig.defaultTheme.viewBackgroundColor.toHexString(),
                radius: 16,
                margin: .init(top: 0, bottom: 0, left: 50, right: 12)
            )
        )
        
        self.messageTemplateRenderer = .error(messageId: self.message?.messageId, view: renderer)
    }
    
    func renderDownload() {
        let renderer = SBUMessageTemplate.downloadingRenderer(
            messageId: message?.messageId,
            downloadingHeight: Self.downloadingHeight,
            viewStyle: .init(
                backgroundColor: TemplateConfig.defaultTheme.viewBackgroundColor.toHexString(),
                radius: 16,
                margin: .init(top: 0, bottom: 0, left: 50, right: 12)
            )
        )
        
        self.messageTemplateRenderer = .downloading(messageId: self.message?.messageId, view: renderer)
    }
    
    var validRenderer: UIView? {
        guard let renderer = messageTemplateRenderer.renderer,
              let messageId = messageTemplateRenderer.messageId,
              self.message?.messageId == messageId
        else { return nil }
        return renderer
    }
    
    var hasValidRenderer: Bool { validRenderer != nil }
    
    func clear() {
        self.messageTemplateRenderer.clear()
    }
}

extension SBUMessageTemplateCell {
    func setupMessageTemplate() {
        guard let message = self.message else { return }
        
        if self.messageTemplateLayer.messageTemplateRenderer.isLoaded { return }
        
        let params = ViewGeneratorParams(maxWidth: self.bounds.width, delegate: self, dataSource: self)
        let result = SBUMessageTemplate.Coordinator.execute(
            type: .message,
            message: message,
            params: params
        )
        
        switch result {
        case .reload(.download(.template(let keys))):
            switch self.uncachedMessageTemplateStateHandler?(keys) {
            case .some(true):
                self.reloadCell()
            case .some(false):
                self.messageTemplateLayer.renderError()
            case .none:
                self.messageTemplateLayer.renderDownload()
                self.uncachedMessageTemplateDownloadHandler?(keys, self)
            }

        case .template(let syntax, let view):
            self.messageTemplateLayer.templateView = syntax
            self.messageTemplateLayer.messageTemplateRenderer = .loaded(
                messageId: syntax.messageId,
                view: view
            )
            
        default: // include .failed
            self.messageTemplateLayer.renderError()
        }
    }
    
    func setupMessageTemplateLayouts() {
        guard let renderer = self.messageTemplateLayer.validRenderer else { return }
        
        self.messageTemplateLayer.templateContainerView.setVStack([renderer])
    }
    
    func updateMessageTemplateLayouts() {
        guard let renderer = self.messageTemplateLayer.validRenderer else { return }
        
        renderer.sbu_constraint(
            width: self.bounds.width,
            priority: self.messageTemplateLayer.messageTemplateRenderer.isError ? .defaultLow : .required
        )
    }
}

extension SBUMessageTemplateCell: TemplateViewGeneratorDelegate {
    public func templateView(_ templateView: TemplateSyntax.TemplateView, didLoad image: UIImage, from imageURL: String, named fileName: String, in subPath: String) {
        SBUCacheManager.Image.save(image: image, fileName: fileName, subPath: subPath, completionHandler: nil)
    }
    
    public func templateView(_ templateView: TemplateSyntax.TemplateView, didFinishRootView view: UIView, with identifier: String) {
        // do nothing
    }
    
    public func templateView(_ templateView: TemplateSyntax.TemplateView, didDrawPartialItem item: TemplateSyntax.Item, in view: UIView, with identifier: String) {
        switch item {
        case .carouselView(_):
            self.message?.messageTemplateCarouselView = view
        default:
            break
        }
    }
    
    public func templateView(_ templateView: TemplateSyntax.TemplateView, didSelect action: TemplateSyntax.Action) {
        self.messageTemplateActionHandler?(.init(action: action))
    }
}

extension SBUMessageTemplateCell: TemplateViewGeneratorDataSource {
    public func templateView(_ templateView: TemplateSyntax.TemplateView, imageFor urlString: String, named fileName: String, in subPath: String) -> UIImage? {
        SBUCacheManager.Image.get(fileName: fileName, subPath: subPath)
    }
    
    public func templateView(_ templateView: TemplateSyntax.TemplateView, rootViewFor identifier: String) -> UIView? {
        return nil
    }
    
    public func templateView(_ templateView: TemplateSyntax.TemplateView, viewForPartialItem item: TemplateSyntax.Item, with identifier: String) -> UIView? {
        switch item {
        case .carouselView(_):
            return self.message?.messageTemplateCarouselView
        default:
            return nil
        }
    }
}
