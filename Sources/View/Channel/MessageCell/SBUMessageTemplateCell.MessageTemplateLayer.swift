//
//  SBUMessageTemplateCell.MessageTemplateLayer.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/19.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

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
        
        var templateView: SBUMessageTemplate.Syntax.TemplateView?
        var messageTemplateRenderer: SBUMessageTemplate.Renderer.RendererType = .inProgress
        
        var templateRetryStatus: SBUTemplateMessageRetryStatus {
            get { self.message?.templateDownloadRetryStatus ?? .initialized }
            set { self.message?.templateDownloadRetryStatus = newValue }
        }
        
        var imagesRetryStatus: SBUTemplateMessageRetryStatus {
            get { self.message?.templateImagesRetryStatus ?? .initialized }
            set { self.message?.templateImagesRetryStatus = newValue }
        }
    }
}

extension SBUMessageTemplateCell.MessageTemplateLayer {
    func renderError() {
        let renderer = SBUMessageTemplate.Renderer.errorRenderer(
            type: .message,
            message: self.message,
            viewStyle: .init(
                backgroundColor: SBUMessageTemplate.Renderer.defaultTheme.viewBackgroundColor.toHexString(),
                radius: 16,
                margin: .init(top: 0, bottom: 0, left: 50, right: 12)
            )
        )
        
        self.messageTemplateRenderer = .error(renderer: renderer)
    }
    
    func renderDownload() {
        let renderer = SBUMessageTemplate.Renderer.downloadingRenderer(
            messageId: message?.messageId,
            downloadingHeight: Self.downloadingHeight,
            viewStyle: .init(
                backgroundColor: SBUMessageTemplate.Renderer.defaultTheme.viewBackgroundColor.toHexString(),
                radius: 16,
                margin: .init(top: 0, bottom: 0, left: 50, right: 12)
            )
        )
        
        self.messageTemplateRenderer = .downloading(renderer: renderer)
    }
    
    var validRenderer: SBUMessageTemplate.Renderer? {
        guard let renderer = messageTemplateRenderer.renderer,
              self.message?.messageId == renderer.messageId else { return nil }
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
        guard let data = message.asMessageTemplate else { return }
        guard let payloadJson = data.toJsonString else { return }
        
        if self.messageTemplateLayer.messageTemplateRenderer.isLoaded { return }
        
        if SBUMessageTemplate.PayloadType(with: data) == .unknown {
            self.messageTemplateLayer.renderError()
            return
        }
        
        if self.messageTemplateLayer.templateRetryStatus.isFailed {
            self.messageTemplateLayer.renderError()
            return
        }
        
        let result = SBUMessageTemplate.Coordinator.execute(
            type: .message,
            message: message,
            payloadJson: payloadJson,
            imageRetryStatus: self.messageTemplateLayer.imagesRetryStatus
        )
        
        switch result {
        case .reload(.download(.template(let keys))):
            self.messageTemplateLayer.renderDownload()
            
            if keys.isEmpty { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.messageTemplateLayer.templateRetryStatus.updateRetry() {
                    self.uncachedMessageTemplateDownloadHandler?(keys, self)
                } else {
                    self.reloadCell()
                }
            }
            
        case .reload(.download(.images(let cacheData))):
            self.messageTemplateLayer.renderDownload()
            
            if cacheData.isEmpty { return }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.messageTemplateLayer.imagesRetryStatus.updateRetry() {
                    self.uncachedMessageTemplateImageHandler?(cacheData, self)
                } else {
                    self.reloadCell()
                }
            }

        case .template(let key, let template):
            self.messageTemplateLayer.templateView = template
            
            if let renderer = SBUMessageTemplate.Renderer.generate(
                template: template,
                delegate: self,
                dataSource: self,
                maxWidth: self.bounds.width,
                actionHandler: { [weak self] in self?.messageTemplateActionHandler?($0) }
            ) {
                self.messageTemplateLayer.messageTemplateRenderer = .loaded(key: key, renderer: renderer)
            } else {
                self.messageTemplateLayer.renderError()
            }
            
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

extension SBUMessageTemplateCell: MessageTemplateRendererDelegate {
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, didFinishLoadingImage imageView: UIImageView) {
        guard self.messageTemplateLayer.hasValidRenderer == true else { return }
        self.reloadCell()
    }
    
    func messageTemplateNeedReloadCell(_ renderer: SBUMessageTemplate.Renderer) {
        guard self.messageTemplateLayer.hasValidRenderer == true else { return }
        self.reloadCell()
    }
    
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, didUpdateValue value: Any, forKey key: SBUMessageTemplate.Renderer.EventSourceKeys) {
        switch key {
        case .carouselRestoreView:
            guard let carouselView = value as? SBUBaseCarouselView else { return }
            self.message?.messageTemplateCarouselView = carouselView
        default: 
            break
        }
    }
}

extension SBUMessageTemplateCell: MessageTemplateRendererDataSource {
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, valueFor key: SBUMessageTemplate.Renderer.EventSourceKeys) -> Any? {
        switch key {
        case .carouselRestoreView:
            return self.message?.messageTemplateCarouselView
        case .templateFactory:
            return self.messageTemplateLayer.templateView?.identifierFactory
        }
    }
}
