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
        case .carouselView:
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
        // 셀을 그리는 중(main)이다. 상한을 넘는 GIF 는 만들 때 모든 프레임을 디코드하므로 여기서 만들지 않고 nil 을 돌려,
        // 렌더러의 `loadImage` 가 main 밖에서 만들게 한다(렌더러 쪽 메모리 캐시에 남는다). 한 번 그렇게 판정한 키는 디스크를
        // 다시 읽지 않는다. 그 밖의 이미지는 develop 처럼 바로 돌려준다(그리는 중 레이아웃이 그대로다).
        SBUCacheManager.Image.getUnlessDecodingAllFrames(fileName: fileName, subPath: subPath)
    }
    
    public func templateView(_ templateView: TemplateSyntax.TemplateView, rootViewFor identifier: String) -> UIView? {
        return nil
    }
    
    public func templateView(_ templateView: TemplateSyntax.TemplateView, viewForPartialItem item: TemplateSyntax.Item, with identifier: String) -> UIView? {
        switch item {
        case .carouselView:
            return self.message?.messageTemplateCarouselView
        default:
            return nil
        }
    }
}
