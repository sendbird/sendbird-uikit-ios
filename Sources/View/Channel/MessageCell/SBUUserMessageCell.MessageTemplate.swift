//
//  SBUUserMessageCell.MessageTemplate.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/19.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUUserMessageCell {
    class MessageTemplateLayer {
        static let downloadingHeight: CGFloat = 274.0
        
        weak var message: BaseMessage? {
            didSet {
                if self.message?.messageId == oldValue?.messageId, self.messageTemplateRenderer.isInProgress { return }
                self.clear()
            }
        }
        
        var templateContainerView = UIStackView()
        var spaceArea = SpaceArea()
        
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
        
        var containerSizeFactory: SBUMessageContainerSizeFactory = .default
    }
    
    class SpaceArea {
        var name = UIView()
        var contents = UIView()
        var time = UIView()
        
        init() {
            self.name.backgroundColor = .clear
            self.contents.backgroundColor = .clear
            self.time.backgroundColor = .clear
        }
    }
}

extension SBUUserMessageCell.MessageTemplateLayer {
    func renderError() {
        let renderer = SBUMessageTemplate.Renderer.errorRenderer(
            type: .group,
            message: self.message
        )
        
        if message?.asUiSettingContainerType != .full {
            renderer.layer.cornerRadius = 16
            renderer.layer.borderColor = UIColor.clear.cgColor
            renderer.layer.borderWidth = 1
            renderer.clipsToBounds = true
            renderer.backgroundColor = SBUMessageTemplate.Renderer.defaultTheme.viewBackgroundColor
        }
        
        self.messageTemplateRenderer = .error(renderer: renderer)
    }
    
    func renderDownload() {
        let renderer = SBUMessageTemplate.Renderer.downloadingRenderer(
            messageId: message?.messageId,
            downloadingHeight: Self.downloadingHeight
        )
        
        if message?.asUiSettingContainerType != .full {
            renderer.layer.cornerRadius = 16
            renderer.layer.borderColor = UIColor.clear.cgColor
            renderer.layer.borderWidth = 1
            renderer.clipsToBounds = true
            renderer.backgroundColor = SBUMessageTemplate.Renderer.defaultTheme.viewBackgroundColor
        }
        
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
        self.containerSizeFactory = .default
    }
}

extension SBUUserMessageCell {
    
    func updateTemplateSizeFactory() {
        self.messageTemplateLayer.containerSizeFactory = SBUMessageContainerSizeFactory(
            type: self.message?.asUiSettingContainerType ?? .default,
            profileWidth: (self.profileView as? SBUMessageProfileView)?.imageSize,
            timpstampWidth: (self.stateView as? SBUMessageStateView)?.timeLabelCustomSize?.width
        )
    }
    
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
        
        self.updateTemplateSizeFactory()
        
        let result = SBUMessageTemplate.Coordinator.execute(
            type: .group,
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
            
        case .reload(.compositeType):
            guard let prev = self.configuration else {
                self.messageTemplateLayer.renderDownload()
                self.reloadCell()
                return
            }
            
            self.isMessyViewHierarchy = true
            self.prepareForReuse()
            self.configure(with: prev)

        case .template(let key, let template):
            self.messageTemplateLayer.templateView = template
            
            if let renderer = SBUMessageTemplate.Renderer.generate(
                template: template,
                delegate: self,
                dataSource: self,
                maxWidth: self.messageTemplateLayer.containerSizeFactory.getWidth(),
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
        
        switch self.containerType {
        case .`default`:
            self.messageTextView.removeFromSuperview()
            self.messageTemplateLayer.templateContainerView.setVStack([renderer])
            
        case .wide:
            self.messageTextView.removeFromSuperview()
            self.messageTemplateLayer.templateContainerView.setVStack([renderer])
            
        case .full:
            self.messageTextView.removeFromSuperview()
            
            self.fullSizeMessageContainerView.setVStack([
                self.messageTemplateLayer.spaceArea.name,
                renderer,
                self.messageTemplateLayer.spaceArea.time,
            ])
            self.messageTemplateLayer.templateContainerView.setVStack([self.messageTemplateLayer.spaceArea.contents])
            self.messageTemplateLayer.spaceArea.name.setHeightConstraints(with: userNameView)
            self.messageTemplateLayer.spaceArea.contents.setHeightConstraints(with: renderer)
            self.messageTemplateLayer.spaceArea.time.setHeightConstraints(with: wideSizeStateContainerView)
        }
        
        self.isMessyViewHierarchy = true
    }
    
    func updateMessageTemplateLayouts() {
        guard let renderer = self.messageTemplateLayer.validRenderer else {
            NSLayoutConstraint.deactivate(self.fullSizeMessageConstraints)
            return
        }
        
        if self.containerType == .full {
            NSLayoutConstraint.activate(self.fullSizeMessageConstraints)
        } else {
            NSLayoutConstraint.deactivate(self.fullSizeMessageConstraints)
        }
        
        renderer.sbu_constraint(
            width: self.messageTemplateLayer.containerSizeFactory.getWidth(),
            priority: self.messageTemplateLayer.messageTemplateRenderer.isError ? .defaultLow : UILayoutPriority(rawValue: 1000)
        )
    }
    
    func setupMesageTemplateStyles() {
        guard self.messageTemplateLayer.hasValidRenderer == true else { return }
        
        self.mainContainerView.layer.cornerRadius = 0.0
        self.mainContainerView.layer.borderWidth = 0.0
        self.mainContainerView.setTransparentBackgroundColor()
    }
    
    func clearMessageTemplateLayouts() {
        NSLayoutConstraint.deactivate(self.fullSizeMessageConstraints)
    }
}

extension SBUUserMessageCell: MessageTemplateRendererDelegate {
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
        default: break
        }
    }
}

extension SBUUserMessageCell: MessageTemplateRendererDataSource {
    func messageTemplateRender(_ renderer: SBUMessageTemplate.Renderer, valueFor key: SBUMessageTemplate.Renderer.EventSourceKeys) -> Any? {
        switch key {
        case .carouselRestoreView:
            return self.message?.messageTemplateCarouselView
        case .carouselProfileAreaSize:
            return self.messageTemplateLayer.containerSizeFactory.getProfileArea()
        case .templateFactory:
            return self.messageTemplateLayer.templateView?.identifierFactory
        }
    }
}

fileprivate extension UIView {
    func setHeightConstraints(with target: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 0).isActive = true
        self.heightAnchor.constraint(equalTo: target.heightAnchor, multiplier: 1).isActive = true
    }
}
