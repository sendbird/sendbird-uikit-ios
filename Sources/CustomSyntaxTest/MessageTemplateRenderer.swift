//
//  MessageTemplateRenderer.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol MessageTemplateRendererDelegate: AnyObject {
    func messageTemplateRender(_ renderer: MessageTemplateRenderer, didFinishLoadingImage imageView: UIImageView)
}

/**
 View
    - contentView
        - bodyView
            - item
            - item
            - item
 */

/**
 ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 |          [ParentView]          |
 |       ㅡㅡㅡㅡㅡㅡㅡㅡㅡ        |
 |       |    [baseView]    |      |
 |       |      ㅡㅡㅡㅡㅡ      |      |
 |       |      |              |      |      |
 |  M  |  P  | [Item] | P  |  M  |
 |       |      |              |      |      |
 |       |      ㅡㅡㅡㅡㅡ      |      |
 |       |             P             |     |
 |     ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ      |
 |                    M                   |
 ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 M: margin / P: padding
 */

class MessageTemplateRenderer: UIView {
    // Property(public)
    var contentView = MessageTemplateContentView()
    var bodyView = MessageTemplateBodyView()
    var version: Int = 0

    var themeForDefault: SBUMessageTemplateTheme {
        switch SBUTheme.colorScheme {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: SBUMessageTemplate.Body?

    var actionHandler: ((SBUMessageTemplate.Action) -> Void)?
    var reloadHandler: (() -> Void)?
    
    weak var delegate: MessageTemplateRendererDelegate?
    
    var rendererConstraints: [NSLayoutConstraint] = []
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(with data: String,
          actionHandler: ((SBUMessageTemplate.Action) -> Void)?,
          reloadHandler: (() -> Void)? = nil)
    {
        super.init(frame: .zero)
        
        self.actionHandler = actionHandler
        self.reloadHandler = reloadHandler
        
        let data = Data(data.utf8)
        do {
            let template = try JSONDecoder().decode(MessageTemplateData.self, from: data)
            self.version = template.version ?? 0
            if self.render(template: template) == false { return nil }
        } catch {
            SBULog.error(error)
            return nil
        }
    }
    
    init(body: SBUMessageTemplate.Body,
         actionHandler: ((SBUMessageTemplate.Action) -> Void)? = nil,
         reloadHandler: (() -> Void)? = nil) {
        super.init(frame: .zero)
        
        self.actionHandler = actionHandler
        self.reloadHandler = reloadHandler
        
        // AutoLayout
        self.addSubview(self.contentView)
        self.rendererConstraints += self.contentView.sbu_constraint_v2(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
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
        self.rendererConstraints.forEach { $0.isActive = true }
    }
    
    func render(template: MessageTemplateData) -> Bool {
        guard let body = template.body else { return false }
        
        // AutoLayout
        self.addSubview(self.contentView)
        self.rendererConstraints += self.contentView.sbu_constraint_v2(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
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
        self.rendererConstraints.forEach { $0.isActive = true }
        return true
    }
    
    
    // MARK: - Body
    func renderBody(_ body: SBUMessageTemplate.Body) {
        guard let items = body.items else { return }
        
        var prevView: UIView = self.bodyView
        var prevItem: SBUMessageTemplate.View?
        var currentView: UIView = self.bodyView
        for (index, item) in items.enumerated() {
            var isLastItem = false
            if index == items.count - 1 {
                isLastItem = true
            }
            
            switch item {
            case .box(let boxItem):
                let boxView = self.renderBox(
                    item: boxItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = boxView
                self.bodyView.addSubview(boxView)
                prevItem = boxItem
                
            case .text(let textItem):
                let textLabel = self.renderText(
                    item: textItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = textLabel
                self.bodyView.addSubview(textLabel)
                prevItem = textItem
                
            case .image(let imageItem):
                let imageView = self.renderImage(
                    item: imageItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = imageView
                self.bodyView.addSubview(imageView)
                prevItem = imageItem
                
            case .textButton(let textButtonItem):
                let textButton = self.renderTextButton(
                    item: textButtonItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = textButton
                self.bodyView.addSubview(textButton)
                prevItem = textButtonItem
                
            case .imageButton(let imageButtonItem):
                let imageButton = self.renderImageButton(
                    item: imageButtonItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = imageButton
                self.bodyView.addSubview(imageButton)
                prevItem = imageButtonItem
            }

            prevView = currentView
        }
    }
    
    
    // MARK: - Box
    func renderBox(item: SBUMessageTemplate.Box,
                   parentView: UIView,
                   prevView: UIView,
                   prevItem: SBUMessageTemplate.View? = nil,
                   itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                   layout: SBUMessageTemplate.LayoutType = .column,
                   isLastItem: Bool = false) -> UIView {
        let baseView = MessageTemplateBoxBaseView(item: item)
        let boxView = MessageTemplateBoxView()
        baseView.clipsToBounds = true
        
        baseView.addSubview(boxView)
        parentView.addSubview(baseView)
        
        // Items
        self.renderBoxItems(item, parentView: baseView)
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        // Action
        self.setAction(on: baseView, item: item)
        
        return baseView
    }
    
    // MARK: BoxItems
    func renderBoxItems(_ item: SBUMessageTemplate.Box, parentView: UIView) {
        guard let items = item.items else { return }
        
        let parentBoxView = parentView.subviews[0]
        let sideView1 = UIView()
        let sideView2 = UIView()
        parentBoxView.addSubview(sideView1)
        
        var prevView: UIView = sideView1
        var prevItem: SBUMessageTemplate.View?
        var currentView: UIView = sideView1
        let itemsAlign = item.align
        let layout = item.layout
        
        var widthFillParentCount = 0
        var haveWidthFillParent = false
        var heightFillParentCount = 0
        var haveHeightFillParent = false
        
        for (index, item) in items.enumerated() {
            var isLastItem = false
            if index == items.count - 1 {
                isLastItem = true
            }
            
            switch item {
            case .box(let boxItem):
                let boxView = self.renderBox(
                    item: boxItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout
                )
                currentView = boxView
                prevItem = boxItem
                
            case .text(let textItem):
                let textLabel = self.renderText(
                    item: textItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout
                )
                currentView = textLabel
                prevItem = textItem
                
            case .image(let imageItem):
                let imageView = self.renderImage(
                    item: imageItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout
                )
                currentView = imageView
                prevItem = imageItem
                
            case .textButton(let textButtonItem):
                let textButton = self.renderTextButton(
                    item: textButtonItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    layout: layout
                )
                currentView = textButton
                prevItem = textButtonItem
                
            case .imageButton(let imageButtonItem):
                let imageButton = self.renderImageButton(
                    item: imageButtonItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout
                )
                currentView = imageButton
                prevItem = imageButtonItem
            }
            
            if prevItem?.width.type == .flex,
               prevItem?.width.value == SBUMessageTemplate.FlexSizeType.fillParent.rawValue {
                widthFillParentCount += 1
                haveWidthFillParent = true
            }
            if prevItem?.height.type == .flex,
               prevItem?.height.value == SBUMessageTemplate.FlexSizeType.fillParent.rawValue {
                heightFillParentCount += 1
                haveHeightFillParent = true
            }

            parentBoxView.addSubview(currentView)
            prevView = currentView
        }
        
        parentBoxView.addSubview(sideView2)
        
        if item.layout == .row {
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, top: 0, bottom: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, top: 0, bottom: 0)
            
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, left: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, right: 0)
            
            if haveWidthFillParent || item.align.horizontal == .center {
                sideView1.widthAnchor.constraint(equalTo: sideView2.widthAnchor, multiplier: 1.0).isActive = true
            }
            // INFO: When all items are fill type, the horizontal widths are the same
            if widthFillParentCount == parentBoxView.subviews.count - 2 {
                for (index, subview) in parentBoxView.subviews.enumerated() {
                    if index == 0 || index == parentBoxView.subviews.count - 1 {
                        continue
                    }
                    
                    if index > 1 {
                        subview.widthAnchor.constraint(equalTo: parentBoxView.subviews[index-1].widthAnchor, multiplier: 1.0).isActive = true
                    }
                }
            }
            
            switch item.align.horizontal {
            case .left:
                self.rendererConstraints += sideView1.sbu_constraint_v2(width: 0)
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(width: 0)
            case .center:
                if haveWidthFillParent {
                    self.rendererConstraints += sideView1.sbu_constraint_v2(width: 0)
                } else {
                    self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(width: 0)
                }
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(width: 0)
            case .right:
                self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(width: 0)
                self.rendererConstraints += sideView2.sbu_constraint_v2(width: 0)
            default:
                break
            }
            
            let prevItemRightMargin = prevItem?.viewStyle?.margin?.right ?? 0.0
            self.rendererConstraints += sideView2.sbu_constraint_equalTo_v2(
                leftAnchor: prevView.rightAnchor,
                left: (item.viewStyle?.margin?.left ?? 0.0) + prevItemRightMargin
            )
        }
        else { // column
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, left: 0, right: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, left: 0, right: 0)
            
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, top: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, bottom: 0)
            
            if haveHeightFillParent || item.align.vertical == .center {
                sideView1.heightAnchor.constraint(equalTo: sideView2.heightAnchor, multiplier: 1.0).isActive = true
            }
            // INFO: When all items are fill type, the vertical heights are the same
            if heightFillParentCount == parentBoxView.subviews.count - 2 {
                for (index, subview) in parentBoxView.subviews.enumerated() {
                    if index == 0 || index == parentBoxView.subviews.count - 1 {
                        continue
                    }
                    
                    if index > 1 {
                        subview.heightAnchor.constraint(equalTo: parentBoxView.subviews[index-1].heightAnchor, multiplier: 1.0).isActive = true
                    }
                }
            }
            
            switch item.align.vertical {
            case .top:
                self.rendererConstraints += sideView1.sbu_constraint_v2(height: 0)
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(height: 0)
            case .center:
                if haveHeightFillParent {
                    self.rendererConstraints += sideView1.sbu_constraint_v2(height: 0)
                } else {
                    self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(height: 0)
                }
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(height: 0)
            case .bottom:
                self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(height: 0)
                self.rendererConstraints += sideView2.sbu_constraint_v2(height: 0)
            default:
                break
            }
            
            let prevItemBottomMargin = prevItem?.viewStyle?.margin?.bottom ?? 0.0
            self.rendererConstraints += sideView2.sbu_constraint_equalTo_v2(
                topAnchor: prevView.bottomAnchor,
                top: prevItemBottomMargin
            )
        }
    }
    
    
    // MARK: - Text
    func renderText(item: SBUMessageTemplate.Text,
                    parentView: UIView,
                    prevView: UIView,
                    prevItem: SBUMessageTemplate.View? = nil,
                    itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                    layout: SBUMessageTemplate.LayoutType = .column,
                    isLastItem: Bool = false) -> UIView {
        let baseView = MessageTemplateTextBaseView(item: item)
        baseView.clipsToBounds = true
        let label = MessageTemplateLabel()
        label.text = item.text
        label.numberOfLines = item.maxTextLines
        label.lineBreakMode = .byTruncatingTail
        baseView.addSubview(label)
        parentView.addSubview(baseView)
        
        // Text Style
        if let textStyle = item.textStyle {
            var fontSize = self.themeForDefault.textFont.pointSize
            if let size = textStyle.size {
                fontSize = CGFloat(size)
            }
            
            switch textStyle.weight {
            case .normal:
                label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            case .bold:
                label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            case .none:
                break
            }

            if let textColor = textStyle.color {
                label.textColor = UIColor(hexString: textColor)
            } else {
                label.textColor = self.themeForDefault.textColor
            }
            
        } else {
            label.font = UIFont.systemFont(
                ofSize: self.themeForDefault.textFont.pointSize,
                weight: .regular
            )
            label.textColor = self.themeForDefault.textColor
            label.contentMode = .center // TODO: check
            label.textAlignment = .left
        }
        
        let textAlign = item.align
        switch textAlign.vertical {
        case .top:
            label.contentMode = .top
        case .center:
            label.contentMode = .center
        case .bottom:
            label.contentMode = .bottom
        case .none:
            break
        }
        
        switch textAlign.horizontal {
        case .left:
            label.textAlignment = .left
        case .center:
            label.textAlignment = .center
        case .right:
            label.textAlignment = .right
        case .none:
            break
        }
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        if item.width.type == .flex, item.width.value == 1 {
            label.setContentCompressionResistancePriority(UILayoutPriority(751), for: NSLayoutConstraint.Axis.horizontal)
        }
        
        // Action
        self.setAction(on: baseView, item: item)
        
        return baseView
    }
    
    
    // MARK: - Image
    func renderImage(item: SBUMessageTemplate.Image,
                     parentView: UIView,
                     prevView: UIView,
                     prevItem: SBUMessageTemplate.View? = nil,
                     itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                     layout: SBUMessageTemplate.LayoutType = .column,
                     isLastItem: Bool = false) -> UIView {
        let baseView = MessageTemplateImageBaseView(item: item)
        baseView.clipsToBounds = true
        let imageView: UIImageView = MessageTemplateImageView()
        
        // Image Style
        let imageStyle = item.imageStyle
        let contentMode = imageStyle.contentMode
        imageView.contentMode = contentMode
        var tintColor: UIColor? = nil
        if let tintColorHex = imageStyle.tintColor {
            tintColor = UIColor(hexString: tintColorHex)
        }
        
        baseView.addSubview(imageView)
        parentView.addSubview(baseView)
        
        self.rendererConstraints += imageView.sbu_constraint_equalTo_v2(
            centerXAnchor: baseView.centerXAnchor,
            centerX: 0,
            centerYAnchor: baseView.centerYAnchor,
            centerY: 0
        )
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
       
        var placeholderConstraints: [NSLayoutConstraint] = []
        var isRatioUsed = false
        
        let ratioConstraintsHandler: () -> Void = {
            if let metaData = item.metaData {
                let ratio = metaData.pixelWidth != 0
                ? CGFloat(metaData.pixelHeight) / CGFloat(metaData.pixelWidth)
                : 0
                let heightConst = imageView.heightAnchor.constraint(
                    equalTo: imageView.widthAnchor,
                    multiplier: ratio
                )
                placeholderConstraints.append(heightConst)
            }
            isRatioUsed = true
        }
        
        let minimumConstraintsHandler: () -> Void = {
            placeholderConstraints = imageView.sbu_constraint_greaterThan_v2(width: 1, height: 1, priority: .defaultLow)
        }
        
        
        if item.width.type == .fixed {
            if item.height.type == .fixed {
                minimumConstraintsHandler()
            } else if item.height.type == .flex, item.height.value == 0 { // fillParent
                switch item.imageStyle.contentMode {
                case .scaleAspectFit: ratioConstraintsHandler()
                case .scaleAspectFill: ratioConstraintsHandler()
                case .scaleToFill: minimumConstraintsHandler()
                default: break
                }
            } else if item.height.type == .flex, item.height.value == 1 { // wrapContent
                switch item.imageStyle.contentMode {
                case .scaleAspectFit: ratioConstraintsHandler()
                case .scaleAspectFill: ratioConstraintsHandler()
                case .scaleToFill: minimumConstraintsHandler()
                default: break
                }
            }
            
        } else if item.width.type == .flex, item.width.value == 0 { // fillParent
            switch item.height.type {
            case .fixed: minimumConstraintsHandler()
            case .flex: ratioConstraintsHandler() // fillParent, wrapContent
            }
            
        } else if item.width.type == .flex, item.width.value == 1 { // wrapContent
            switch item.height.type {
            case .fixed: ratioConstraintsHandler()
            case .flex: minimumConstraintsHandler() // fillParent, wrapContent
            }
        }
        
        placeholderConstraints.forEach { $0.isActive = true }
        
        imageView.loadImage(urlString: item.imageUrl, tintColor: tintColor, completion: { [weak self, weak imageView] success in
            guard let self = self else { return }
            
            let constraintSettingHandler: (() -> Void) = {
                if let imageView = imageView,
                   let imageSize = imageView.image?.size {
                    
                    self.rendererConstraints.forEach { $0.isActive = false }
                    placeholderConstraints.forEach { $0.isActive = false }
                    
                    if isRatioUsed == true {
                        let ratio = imageSize.height / imageSize.width
                        
                        let heightConst = imageView.heightAnchor.constraint(
                            equalTo: imageView.widthAnchor,
                            multiplier: ratio
                        )
                        heightConst.priority = UILayoutPriority(750)
                        self.rendererConstraints.append(heightConst)
                    }
                    
                    self.rendererConstraints.forEach { $0.isActive = true }
                    
                    if item.metaData == nil || !isRatioUsed {
                        placeholderConstraints.forEach { $0.isActive = true }
                        self.delegate?.messageTemplateRender(self, didFinishLoadingImage: imageView)
                    }
                }
            }
            if Thread.isMainThread {
                constraintSettingHandler()
            } else {
                DispatchQueue.main.async {
                    constraintSettingHandler()
                }
            }
        })
        
        // Action
        self.setAction(on: baseView, item: item)
        
        return baseView
    }
    
    
    // MARK: - TextButton
    func renderTextButton(item: SBUMessageTemplate.TextButton,
                          parentView: UIView,
                          prevView: UIView,
                          prevItem: SBUMessageTemplate.View? = nil,
                          itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                          layout: SBUMessageTemplate.LayoutType = .column,
                          isLastItem: Bool = false) -> UIView {
        let baseView = MessageTemplateTextButtonBaseView(item: item)
        baseView.clipsToBounds = true
        let textButton = MessageTemplateTextButton()
        textButton.setTitle(item.text, for: .normal)
        textButton.titleLabel?.numberOfLines = item.maxTextLines
        textButton.titleLabel?.lineBreakMode = .byTruncatingTail
        textButton.contentEdgeInsets = UIEdgeInsets(
            top: .leastNormalMagnitude,
            left: .leastNormalMagnitude,
            bottom: .leastNormalMagnitude,
            right: .leastNormalMagnitude
        )
        baseView.addSubview(textButton)
        parentView.addSubview(baseView)
        
        // Text Style
        if let textStyle = item.textStyle {
            var fontSize = self.themeForDefault.textButtonFont.pointSize
            if let size = textStyle.size {
                fontSize = CGFloat(size)
            }

            switch textStyle.weight {
            case .normal:
                textButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            case .bold:
                textButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            case .none:
                break
            }
            
            if let textColor = textStyle.color {
                textButton.setTitleColor(UIColor(hexString: textColor), for: .normal)
            } else {
                textButton.setTitleColor(self.themeForDefault.textButtonTitleColor, for: .normal)
            }
        } else {
            textButton.titleLabel?.font = self.themeForDefault.textButtonFont
            textButton.setTitleColor(self.themeForDefault.textButtonTitleColor, for: .normal)
        }
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        self.rendererConstraints += textButton.sbu_constraint_greaterThan_v2(height: textButton.titleLabel?.font.lineHeight ?? 1, priority: .defaultLow)
        
        // Action
        self.setAction(on: baseView, item: item)
        
        return baseView
    }
    
    
    // MARK: - ImageButton
    func renderImageButton(item: SBUMessageTemplate.ImageButton,
                           parentView: UIView,
                           prevView: UIView,
                           prevItem: SBUMessageTemplate.View? = nil,
                           itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                           layout: SBUMessageTemplate.LayoutType = .column,
                           isLastItem: Bool = false) -> UIView {
        let baseView = MessageTemplateImageButtonBaseView(item: item)
        baseView.clipsToBounds = true
        let imageButton = MessageTemplateImageButton()
        
        // Image Style
        let imageStyle = item.imageStyle
        let contentMode = imageStyle.contentMode
        imageButton.contentMode = contentMode
        imageButton.imageView?.contentMode = contentMode
        var tintColor: UIColor? = nil
        if let tintColorHex = imageStyle.tintColor {
            tintColor = UIColor(hexString: tintColorHex)
        }
        
        baseView.addSubview(imageButton)
        parentView.addSubview(baseView)
        
        self.rendererConstraints += imageButton.sbu_constraint_equalTo_v2(
            centerXAnchor: baseView.centerXAnchor,
            centerX: 0,
            centerYAnchor: baseView.centerYAnchor,
            centerY: 0
        )
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        // Action
        self.setAction(on: baseView, item: item)
        
        var placeholderConstraints: [NSLayoutConstraint] = []
        var isRatioUsed = false
        
        let ratioConstraintsHandler: () -> Void = {
            if let metaData = item.metaData {
                let ratio = metaData.pixelWidth != 0
                ? CGFloat(metaData.pixelHeight) / CGFloat(metaData.pixelWidth)
                : 0
                let heightConst = imageButton.heightAnchor.constraint(
                    equalTo: imageButton.widthAnchor,
                    multiplier: ratio
                )
                placeholderConstraints.append(heightConst)
            }
            isRatioUsed = true
        }
        
        let minimumConstraintsHandler: () -> Void = {
            placeholderConstraints = imageButton.sbu_constraint_greaterThan_v2(width: 1, height: 1, priority: .defaultLow)
        }
        
        
        if item.width.type == .fixed {
            if item.height.type == .fixed {
                minimumConstraintsHandler()
            } else if item.height.type == .flex, item.height.value == 0 { // fillParent
                switch item.imageStyle.contentMode {
                case .scaleAspectFit: ratioConstraintsHandler()
                case .scaleAspectFill: ratioConstraintsHandler()
                case .scaleToFill: minimumConstraintsHandler()
                default: break
                }
            } else if item.height.type == .flex, item.height.value == 1 { // wrapContent
                switch item.imageStyle.contentMode {
                case .scaleAspectFit: ratioConstraintsHandler()
                case .scaleAspectFill: ratioConstraintsHandler()
                case .scaleToFill: minimumConstraintsHandler()
                default: break
                }
            }
            
        } else if item.width.type == .flex, item.width.value == 0 { // fillParent
            switch item.height.type {
            case .fixed: minimumConstraintsHandler()
            case .flex: ratioConstraintsHandler() // fillParent, wrapContent
            }
            
        } else if item.width.type == .flex, item.width.value == 1 { // wrapContent
            switch item.height.type {
            case .fixed: ratioConstraintsHandler()
            case .flex: minimumConstraintsHandler() // fillParent, wrapContent
            }
        }
        
        placeholderConstraints.forEach { $0.isActive = true }

        imageButton.loadImage(urlString: item.imageUrl, tintColor: tintColor, for: .normal, completion: { [weak self, weak imageButton] success in
            guard let self = self else { return }
            
            let constraintSettingHandler: (() -> Void) = {
                if let imageButton = imageButton,
                   let imageSize = imageButton.imageView?.image?.size {
                    
                    self.rendererConstraints.forEach { $0.isActive = false }
                    placeholderConstraints.forEach { $0.isActive = false }
                    
                    if isRatioUsed == true {
                        let ratio = imageSize.height / imageSize.width
                        
                        let heightConst = imageButton.heightAnchor.constraint(
                            equalTo: imageButton.widthAnchor,
                            multiplier: ratio
                        )
                        heightConst.priority = UILayoutPriority(750)
                        self.rendererConstraints.append(heightConst)
                    }
                    
                    self.rendererConstraints.forEach { $0.isActive = true }
                    
                    if let imageView = imageButton.imageView,
                       (item.metaData == nil || !isRatioUsed) {
                        self.delegate?.messageTemplateRender(self, didFinishLoadingImage: imageView)
                    }
                }
            }
            if Thread.isMainThread {
                constraintSettingHandler()
            } else {
                DispatchQueue.main.async {
                    constraintSettingHandler()
                }
            }
        })
        
        
        return baseView
    }
    
    
    // MARK: - ViewStyle
    func renderViewStyle(with item: SBUMessageTemplate.View, to view: UIView) {
        guard let viewStyle = item.viewStyle else {
            if version == 0 { // v0.2
//                Default background
                if item is SBUMessageTemplate.Box {
                    view.backgroundColor = self.themeForDefault.viewBackgroundColor
                }
            }
            return
        }
        
        if let backgroundColor = viewStyle.backgroundColor {
            view.backgroundColor = UIColor(hexString: backgroundColor)
        } else {
            if version == 0 { // v0.2
                if item is SBUMessageTemplate.TextButton {
                    view.backgroundColor = self.themeForDefault.textButtonBackgroundColor
                } else {
                    view.backgroundColor = self.themeForDefault.viewBackgroundColor
                }
            }
        }
        
        if let backgroundImageUrl = viewStyle.backgroundImageUrl,
           let url = URL(string: backgroundImageUrl) {
            view.backgroundColor = UIColor(patternImage: UIImage(url: url))

        }
        if let borderWidth = viewStyle.borderWidth {
            view.layer.borderWidth = CGFloat(borderWidth)
        }
        if let borderColor = viewStyle.borderColor {
            view.layer.borderColor = UIColor(hexString: borderColor).cgColor
        }
        if let borderRadius = viewStyle.radius {
            let width = item.width
            let height = item.height
            
            var maxRadius = borderRadius
            if width.type == .fixed {
                maxRadius = min(maxRadius, width.value / 2)
            }
            if height.type == .fixed {
                maxRadius = min(maxRadius, height.value / 2)
            }
            
            view.roundCorners(corners: .allCorners, radius: CGFloat(maxRadius))
        }
    }
    
    
    // MARK: - ViewLayout
    func renderViewLayout(with item: SBUMessageTemplate.View,
                          to baseView: UIView,
                          parentView: UIView,
                          prevView: UIView,
                          prevItem: SBUMessageTemplate.View? = nil,
                          itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                          layout: SBUMessageTemplate.LayoutType? = .column,
                          isLastItem: Bool = false) {
        var marginInsets: UIEdgeInsets = .zero
        if let margin = item.viewStyle?.margin {
            marginInsets = UIEdgeInsets(
                top: margin.top,
                left: margin.left,
                bottom: margin.bottom,
                right: margin.right
            )
        }
        
        // Size
        let width = item.width
        let height = item.height
        
        let horizontalAlign = itemsAlign?.horizontal ?? .left
        let verticalAlign = itemsAlign?.vertical ?? .top
        let subView = !baseView.subviews.isEmpty ? baseView.subviews[0] : nil
        
        // Size: width
        let padding = item.viewStyle?.padding
        let paddingWidth = (padding?.left ?? 0.0) + (padding?.right ?? 0.0)
        
        if width.type == .fixed {
            self.rendererConstraints += subView?.sbu_constraint_v2(width: CGFloat(width.value) - paddingWidth) ?? []
        } else {
            self.rendererConstraints += subView?.sbu_constraint_lessThan_v2(widthAnchor: baseView.widthAnchor, width: -paddingWidth) ?? []
        }

        // left/right
        if layout == .column { // default
            if width.type == .flex, width.value == SBUMessageTemplate.FlexSizeType.fillParent.rawValue {
                // default
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, centerX: 0)
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, left: marginInsets.left)
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, right: marginInsets.right)
            } else {
                /**
 
                 left:   |ㅁ----|
                 center: |--ㅁ--|
                 right:  |----ㅁ|
                 */
                
                switch horizontalAlign {
                case .left:
                    self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, left: marginInsets.left)
                    self.rendererConstraints += baseView.sbu_constraint_v2(lessThanOrEqualTo: parentView, right: marginInsets.right)
                case .center:
                    self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, centerX: 0)
                    self.rendererConstraints += baseView.sbu_constraint_v2(greaterThanOrEqualTo: parentView, left: marginInsets.left)
                    self.rendererConstraints += baseView.sbu_constraint_v2(lessThanOrEqualTo: parentView, right: marginInsets.right)
                case .right:
                    self.rendererConstraints += baseView.sbu_constraint_v2(greaterThanOrEqualTo: parentView, left: marginInsets.left)
                    self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, right: marginInsets.right)
                }
            }
            
        }
        else { // row
            // left anchor
            if let prevItem = prevItem {
                let prevItemRightMargin = prevItem.viewStyle?.margin?.right ?? 0.0
                self.rendererConstraints += baseView.sbu_constraint_equalTo_v2(
                    leftAnchor: prevView.rightAnchor,
                    left: marginInsets.left + prevItemRightMargin
                )
            } else {
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, left: marginInsets.left)
            }
            
            // right anchor
            if isLastItem {
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, right: marginInsets.right)
            }
        }

        // MARK: - Body
        
        // Size: height
        if height.type == .fixed {
            let padding = item.viewStyle?.padding
            let paddingHeight = (padding?.top ?? 0.0) + (padding?.bottom ?? 0.0)
            self.rendererConstraints += subView?.sbu_constraint_v2(height: CGFloat(height.value) - paddingHeight) ?? []
        }
        
        // top/bottom
        if layout == .column { // Default
            // top anchor
            if let prevItem = prevItem {
                let prevItemBottomMargin = prevItem.viewStyle?.margin?.bottom ?? 0.0
                self.rendererConstraints += baseView.sbu_constraint_equalTo_v2(
                    topAnchor: prevView.bottomAnchor,
                    top: marginInsets.top + prevItemBottomMargin
                )
            } else {
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, top: marginInsets.top)
            }
            
            // bottom anchor
            if isLastItem {
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, bottom: marginInsets.bottom)
            }
        } else { // row
            /**
                
             top  center  bottom
             --     --      --
             ㅁ      ㅣ      ㅣ
             ㅣ      ㅁ      ㅣ
             ㅣ      ㅣ      ㅁ
             --     --      --
             */

            if height.type == .flex, height.value == SBUMessageTemplate.FlexSizeType.fillParent.rawValue {
                // default
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, centerY: 0)
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, top: marginInsets.top)
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, bottom: marginInsets.bottom)
            } else {
                switch verticalAlign {
                case .top:
                    self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, top: marginInsets.top)
                    self.rendererConstraints += baseView.sbu_constraint_v2(lessThanOrEqualTo: parentView, bottom: marginInsets.bottom)
                case .center:
                    self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, centerY: 0)
                    self.rendererConstraints += baseView.sbu_constraint_v2(greaterThanOrEqualTo: parentView, top: marginInsets.top)
                    self.rendererConstraints += baseView.sbu_constraint_v2(lessThanOrEqualTo: parentView, bottom: marginInsets.bottom)
                case .bottom:
                    self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, bottom: marginInsets.bottom)
                    self.rendererConstraints += baseView.sbu_constraint_v2(greaterThanOrEqualTo: parentView, top: marginInsets.top)
                }
            }
        }
        
        // Padding
        var paddingInsets = UIEdgeInsets.zero
        if let padding = item.viewStyle?.padding {
            paddingInsets = UIEdgeInsets(
                top: padding.top,
                left: padding.left,
                bottom: padding.bottom,
                right: padding.right
            )
        }
        if !baseView.subviews.isEmpty {
            self.rendererConstraints += subView?.sbu_constraint_v2(
                equalTo: baseView,
                left: paddingInsets.left,
                right: paddingInsets.right,
                top: paddingInsets.top,
                bottom: paddingInsets.bottom,
                priority: UILayoutPriority(1000)
            ) ?? []
        }
    }
    
    // MARK: - Action
    func setAction(on view: UIView, item: SBUMessageTemplate.View) {
        guard !view.subviews.isEmpty, let action = item.action else { return }
        let subView = view.subviews[0]
        
        if let button = subView as? ActionItemButton {
            button.action = action
            button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        } else {
            let tapGesture = ActionTapGesture(target: self, action: #selector(didTapActionGestures(_:)))
            tapGesture.action = action
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
        }
    }
    
    @objc func didTapAction(_ sender: ActionItemButton) {
        if let action = sender.action {
            self.actionHandler?(action)
        }
    }
    
    @objc func didTapActionGestures(_ sender: ActionTapGesture) {
        if let action = sender.action {
            self.actionHandler?(action)
        }
    }
    
    
    // MARK: - BaseView Wrapper class (for debugging, update each item)
    class MessageTemplateContentView: UIView { }
    class MessageTemplateBodyView: UIView { }

    class MessageTemplateBoxBaseView: UIView {
        var item: SBUMessageTemplate.Box? = nil
        
        init(item: SBUMessageTemplate.Box?) {
            self.item = item
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    class MessageTemplateTextBaseView: UIView {
        var item: SBUMessageTemplate.Text? = nil
        
        init(item: SBUMessageTemplate.Text?) {
            self.item = item
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    class MessageTemplateImageBaseView: UIView {
        var item: SBUMessageTemplate.Image? = nil
        
        init(item: SBUMessageTemplate.Image?) {
            self.item = item
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    class MessageTemplateTextButtonBaseView: UIView {
        var item: SBUMessageTemplate.TextButton? = nil
        
        init(item: SBUMessageTemplate.TextButton?) {
            self.item = item
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    class MessageTemplateImageButtonBaseView: UIView {
        var item: SBUMessageTemplate.ImageButton? = nil
        
        init(item: SBUMessageTemplate.ImageButton?) {
            self.item = item
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }


    // MARK: - Item Wrapper class (for debugging, update each item)

    class MessageTemplateBoxView: UIView { }

    /// https://stackoverflow.com/a/32368958

    /// This class supports padding and 9 direction Align.
    ///
    /// How to use
    /// - Padding : `label.padding = edgeInsets`
    /// - Align:
    ///     - horizontal: `label.textAlignment`
    ///     - vertical: `label.contentMode`
    class MessageTemplateLabel: UILabel {
        var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        override func drawText(in rect: CGRect) {
            var newRect = rect
            switch contentMode {
            case .top:
                newRect.size.height = sizeThatFits(rect.size).height
            case .bottom:
                let height = sizeThatFits(rect.size).height
                newRect.origin.y += rect.size.height - height
                newRect.size.height = height
            default:
                ()
            }
            
            super.drawText(in: newRect.inset(by: padding))
        }
        
        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + padding.left + padding.right,
                          height: size.height + padding.top + padding.bottom)
        }
        
        override var bounds: CGRect {
            didSet {
                preferredMaxLayoutWidth = bounds.width - (padding.left + padding.right)
            }
        }
    }

    class MessageTemplateImageView: UIImageView {}

    class MessageTemplateImageViewForAspect: UIImageView {
        override var intrinsicContentSize: CGSize {
            if let image = self.image {
                let width = image.size.width
                let height = image.size.height
     
                let ratio = self.frame.size.width / width
                let scaledHeight = height * ratio

                return CGSize(width: self.frame.size.width, height: scaledHeight)
            }

            return CGSize(width: -1.0, height: -1.0)
        }
    }

    class MessageTemplateTextButton: ActionItemButton {}
    class MessageTemplateImageButton: ActionItemButton {}
    class MessageTemplateImageButtonForAspectFit: MessageTemplateImageButton {
        override var intrinsicContentSize: CGSize {
            if let image = self.imageView?.image {
                let width = image.size.width
                let height = image.size.height
     
                let ratio = self.frame.size.width / width
                let scaledHeight = height * ratio

                return CGSize(width: self.frame.size.width, height: scaledHeight)
            }

            return CGSize(width: -1.0, height: -1.0)
        }
    }
    
    class ActionItemButton: UIButton {
        var action: SBUMessageTemplate.Action? = nil
    }
    
    class ActionTapGesture: UITapGestureRecognizer {
        var action: SBUMessageTemplate.Action? = nil
    }

    //func updateViewStyle(subview: UIView) {
    //    for subview in subview.subviews {
    //        if subview is MessageTemplateBoxBaseView {
    //
    //        } else if subview is MessageTemplateTextBaseView {
    //
    //        } else if subview is MessageTemplateImageBaseView {
    //
    //        } else if subview is MessageTemplateTextButtonBaseView {
    //
    //        } else if subview is MessageTemplateImageButtonBaseView {
    //
    //        }
    //    }
    //}

}
