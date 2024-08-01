//
//  SBUMessageTemplate.Renderer.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/**
 View
    - contentView
        - bodyView
            - item
            - item
            - item
 */

/**
 ---------------------------------
 |           ParentView          |
 |     ---------------------     |
 |     |      baseView     |     |
 |     |     ----------    |     |
 |     |     |        |    |     |
 |  M  |  P  |  Item  | P  |  M  |
 |     |     |        |    |     |
 |     |     ----------    |     |
 |     |         P         |     |
 |     ---------------------     |
 |               M               |
 ---------------------------------
 M: margin / P: padding
 */

extension SBUMessageTemplate {
    class Renderer: UIView {
        // Property(public)
        var messageId: Int64 = 0
        var contentView = ContentView()
        var bodyView = BodyView()
        var version: Int = 0

        var themeForDefault: SBUMessageTemplateTheme { Self.defaultTheme }
        
        var body: SBUMessageTemplate.Syntax.Body?

        var actionHandler: ((SBUMessageTemplate.Action) -> Void)?
        
        var maxWidth: CGFloat = 0.0
        
        let flexTypeWrapValue = SBUMessageTemplate.Syntax.FlexSizeType.wrapContent.rawValue
        let flexTypeFillValue = SBUMessageTemplate.Syntax.FlexSizeType.fillParent.rawValue
        
        weak var delegate: MessageTemplateRendererDelegate?
        weak var dataSource: MessageTemplateRendererDataSource?
        
        var rendererConstraints: [NSLayoutConstraint] = []
        
        /// If this value is set, all of the fonts in Template are use this fontFamily.
        /// - Since: 3.5.7
        var fontFamily: String?
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        func didTapAction(_ sender: ActionItemButton) {
            if let action = sender.action {
                self.actionHandler?(action)
            }
        }
        
        @objc
        func didTapActionGestures(_ sender: ActionTapGesture) {
            if let action = sender.action {
                self.actionHandler?(action)
            }
        }
        
        // MARK: - Common
        func reloadCell() {
            self.delegate?.messageTemplateNeedReloadCell(self)
        }
        
        init?(
            template: SBUMessageTemplate.Syntax.TemplateView,
            delegate: MessageTemplateRendererDelegate? = nil,
            dataSource: MessageTemplateRendererDataSource? = nil,
            maxWidth: CGFloat = UIApplication.shared.currentWindow?.bounds.width ?? 0.0,
            fontFamily: String? = nil,
            actionHandler: ((Action) -> Void)?
        ) {
            super.init(frame: .zero)
            
            guard template.identifierFactory.isValid == true else { return nil }
            
            self.messageId = template.identifierFactory.messageId
            self.actionHandler = actionHandler
            self.delegate = delegate
            self.dataSource = dataSource
            self.version = template.version ?? 0
            self.maxWidth = maxWidth
            self.fontFamily = fontFamily

            if self.render(template: template) == false { return nil }
        }
        
        // for tester
        init?(
            with data: String,
            messageId: Int64? = 0,
            delegate: MessageTemplateRendererDelegate? = nil,
            dataSource: MessageTemplateRendererDataSource? = nil,
            maxWidth: CGFloat = UIApplication.shared.currentWindow?.bounds.width ?? 0.0,
            fontFamily: String? = nil,
            actionHandler: ((Action) -> Void)?
        ) {
            super.init(frame: .zero)
            
            self.messageId = messageId ?? 0
            self.delegate = delegate
            self.dataSource = dataSource
            self.maxWidth = maxWidth
            self.fontFamily = fontFamily
            self.actionHandler = actionHandler
            
            let data = Data(data.utf8)
            do {
                let template = try JSONDecoder().decode(SBUMessageTemplate.Syntax.TemplateView.self, from: data)
                template.setIdentifier(with: .init(messageId: messageId))
                self.version = template.version ?? 0
                if self.render(template: template) == false { return nil }
            } catch {
                SBULog.error(error)
                return nil
            }
        }
        
        // for error messages
        init(
            messageId: Int64? = 0,
            body: SBUMessageTemplate.Syntax.Body,
            fontFamily: String? = nil,
            actionHandler: ((Action) -> Void)? = nil
        ) {
            super.init(frame: .zero)
            
            self.messageId = messageId ?? 0
            self.fontFamily = fontFamily
            self.actionHandler = actionHandler
            
            // AutoLayout
            self.addSubview(self.contentView)
            self.rendererConstraints += self.contentView.sbu_constraint_v2(
                equalTo: self,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0,
                priority: .required
            )
            
            // Render subview
            self.contentView.addSubview(self.bodyView)
            self.rendererConstraints += self.bodyView.sbu_constraint_v2(
                equalTo: self.contentView,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
            
            self.renderBody(body)
            NSLayoutConstraint.activate(self.rendererConstraints)
        }
        
    }
}

extension SBUMessageTemplate.Renderer {
    static let sideViewTypeLeft = 10
    static let sideViewTypeRight = 20
    
    static var defaultTheme: SBUMessageTemplateTheme {
        switch SBUTheme.colorScheme {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension SBUMessageTemplate.Renderer {
    
    /// Returns system font or custom font by checking if there is a set fontFamily value for Template.
    /// - Since: 3.5.7
    func templateFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        guard let fontFamily = self.fontFamily else {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        
        let descriptor = UIFontDescriptor(
            fontAttributes: [
                .family: fontFamily,
                .traits: [UIFontDescriptor.TraitKey.weight: weight]
            ]
        )
        let font = UIFont(descriptor: descriptor, size: size)
        return font
    }
    
    // factory-v2
    static func generate(
        template: SBUMessageTemplate.Syntax.TemplateView,
        delegate: MessageTemplateRendererDelegate? = nil,
        dataSource: MessageTemplateRendererDataSource? = nil,
        maxWidth: CGFloat = UIApplication.shared.currentWindow?.bounds.width ?? 0.0,
        fontFamily: String? = nil,
        actionHandler: ((SBUMessageTemplate.Action) -> Void)?
    ) -> SBUMessageTemplate.Renderer? {
        guard let renderer = SBUMessageTemplate.Renderer(
            template: template,
            delegate: delegate,
            dataSource: dataSource,
            maxWidth: maxWidth,
            fontFamily: fontFamily,
            actionHandler: actionHandler
        ) else { return nil }
        
        guard [1, 2].contains(renderer.version) else { return nil }
        
        return renderer
    }
}
