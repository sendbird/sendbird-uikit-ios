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
    func messageTemplateNeedReloadCell()
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
    
    var maxWidth: CGFloat = 0.0
    
    let flexTypeWrapValue = SBUMessageTemplate.FlexSizeType.wrapContent.rawValue
    let flexTypeFillValue = SBUMessageTemplate.FlexSizeType.fillParent.rawValue
    
    weak var delegate: MessageTemplateRendererDelegate?
    
    var rendererConstraints: [NSLayoutConstraint] = []
    
    /// If this value is set, all of the fonts in Template are use this fontFamily.
    /// - Since: 3.5.7
    var fontFamily: String?
    
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
    
    let SideView1Tag = 10
    let SideView2Tag = 20
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: will be changed to use params (builder)
    init?(with data: String,
          delegate: MessageTemplateRendererDelegate? = nil,
          maxWidth: CGFloat = UIApplication.shared.currentWindow?.bounds.width ?? 0.0,
          fontFamily: String? = nil,
          actionHandler: ((SBUMessageTemplate.Action) -> Void)?,
          reloadHandler: (() -> Void)? = nil) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        self.maxWidth = maxWidth
        self.fontFamily = fontFamily
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
         fontFamily: String? = nil,
         actionHandler: ((SBUMessageTemplate.Action) -> Void)? = nil,
         reloadHandler: (() -> Void)? = nil) {
        super.init(frame: .zero)
        
        self.fontFamily = fontFamily
        self.actionHandler = actionHandler
        self.reloadHandler = reloadHandler
        
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
        self.rendererConstraints.forEach { $0.isActive = true }
    }
    
    func render(template: MessageTemplateData) -> Bool {
        guard let body = template.body else { return false }
        
        // AutoLayout
        self.addSubview(self.contentView)
        self.rendererConstraints += self.contentView.sbu_constraint_v2(
            equalTo: self,
            leading: 0,
            trailing: 0,
            top: 0,
            bottom: 0
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
            let isLastItem = (index == items.count - 1)
            
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
        let baseView = MessageTemplateBoxBaseView(item: item, layout: layout)
        let boxView = MessageTemplateBoxView()
        boxView.layout = layout
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
        // INFO: SideViews are placed at the top/bottom or left/right and used for align. According to Align, the area of the SideView is adjusted in the form of holding the position of the actual item.
        let sideView1 = UIView()
        sideView1.tag = SideView1Tag
        let sideView2 = UIView()
        sideView2.tag = SideView2Tag
        parentBoxView.addSubview(sideView1)
        
        var prevView: UIView = sideView1
        var prevItem: SBUMessageTemplate.View?
        var currentView: UIView = sideView1
        let itemsAlign = item.align
        let layout = item.layout
        
        var haveWidthFillParent = false
        var heightFillParentCount = 0
        var haveHeightFillParent = false
        
        for (index, item) in items.enumerated() {
            let isLastItem = false// edge case (wrap contents separate issue)
            
            switch item {
            case .box(let boxItem):
                let boxView = self.renderBox(
                    item: boxItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout,
                    isLastItem: isLastItem
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
                    layout: layout,
                    isLastItem: isLastItem
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
                    layout: layout,
                    isLastItem: isLastItem
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
                    layout: layout,
                    isLastItem: isLastItem
                )
                currentView = imageButton
                prevItem = imageButtonItem
            }
            
            if prevItem?.width.type == .flex,
               prevItem?.width.value == flexTypeFillValue {
                haveWidthFillParent = true
            }
            if prevItem?.height.type == .flex,
               prevItem?.height.value == flexTypeFillValue {
                heightFillParentCount += 1
                haveHeightFillParent = true
            }

            parentBoxView.addSubview(currentView)
            prevView = currentView
            currentView.setContentHuggingPriority(UILayoutPriority(Float(250 - index)), for: .horizontal)
        }
        
        parentBoxView.addSubview(sideView2)
        
        if item.layout == .row {
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, top: 0, bottom: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, top: 0, bottom: 0)
            
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, left: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, right: 0)
            
            if haveWidthFillParent || item.align.horizontal == .center {
                sideView1.widthAnchor.constraint(
                    equalTo: sideView2.widthAnchor,
                    multiplier: 1.0
                ).isActive = true
            }
            
            // INFO: When all items are fill type, the horizontal widths are the same
            let fillParentViews = parentBoxView
                .subviews
                .compactMap { $0 as? MessageTemplateBaseView }
                .filter {
                    ($0.width.type == .flex)
                    && ($0.width.value == flexTypeFillValue)
                }
            let filleParentBaseWidthAnchor = fillParentViews.first?.widthAnchor

            if let filleParentBaseWidthAnchor = filleParentBaseWidthAnchor {
                for view in fillParentViews {
                    view.widthAnchor.constraint(
                        equalTo: filleParentBaseWidthAnchor,
                        multiplier: 1.0
                    ).isActive = true
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
        } else { // column
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, left: 0, right: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, left: 0, right: 0)
            
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, top: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, bottom: 0)
            
            if haveHeightFillParent || item.align.vertical == .center {
                sideView1.heightAnchor.constraint(
                    equalTo: sideView2.heightAnchor,
                    multiplier: 1.0
                ).isActive = true
            }
            
            // INFO: When all items are fill type, the vertical heights are the same
            let fillParentViews = parentBoxView
                .subviews
                .compactMap { $0 as? MessageTemplateBaseView }
                .filter {
                    ($0.height.type == .flex)
                    && ($0.height.value == flexTypeFillValue)
                }
            let filleParentBaseHeightAnchor = fillParentViews.first?.heightAnchor

            if let filleParentBaseHeightAnchor = filleParentBaseHeightAnchor {
                for view in fillParentViews {
                    view.heightAnchor.constraint(
                        equalTo: filleParentBaseHeightAnchor,
                        multiplier: 1.0
                    ).isActive = true
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
        return renderCommonText(
            item: item,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
    }
    
    // MARK: - TextButton
    func renderTextButton(item: SBUMessageTemplate.TextButton,
                          parentView: UIView,
                          prevView: UIView,
                          prevItem: SBUMessageTemplate.View? = nil,
                          itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                          layout: SBUMessageTemplate.LayoutType = .column,
                          isLastItem: Bool = false) -> UIView {
        return renderCommonText(
            item: item,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
    }
    
    // MARK: - CommonText: Text, TextButton
    func renderCommonText(item: SBUMessageTemplate.View,
                          parentView: UIView,
                          prevView: UIView,
                          prevItem: SBUMessageTemplate.View? = nil,
                          itemsAlign: SBUMessageTemplate.ItemsAlign? = .defaultAlign(),
                          layout: SBUMessageTemplate.LayoutType = .column,
                          isLastItem: Bool = false) -> UIView {

        let isTextButton = (item is SBUMessageTemplate.TextButton)
        
        let baseView = isTextButton
                        ? MessageTemplateTextButtonBaseView(item: item, layout: layout)
                        : MessageTemplateTextBaseView(item: item, layout: layout)
        baseView.clipsToBounds = true

        var text: String?
        var numberOfLines = 0
        var textStyle: SBUMessageTemplate.TextStyle?
        var textAlign: SBUMessageTemplate.TextAlign?
        
        switch item {
        case let textItem as SBUMessageTemplate.Text:
            text = textItem.text
            numberOfLines = textItem.maxTextLines
            textStyle = textItem.textStyle
            textAlign = textItem.align
        case let textButtonItem as SBUMessageTemplate.TextButton:
            text = textButtonItem.text
            numberOfLines = textButtonItem.maxTextLines
            textStyle = textButtonItem.textStyle
        default:
            break
        }
        
        let label = isTextButton ? MessageTemplateTextButton() : MessageTemplateLabel()
        label.padding = item.viewStyle?.padding
        label.updateLayoutHandler = { constraints, deactivatedConstraints in
            self.rendererConstraints.forEach { $0.isActive = false }
            self.rendererConstraints += constraints
            self.rendererConstraints = self.rendererConstraints.filter { !deactivatedConstraints.contains($0) }
            self.rendererConstraints.forEach { $0.isActive = true }
        }
        
        label.text = text
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = isTextButton
        
        // INFO: Edge case - text wrap issue
        if baseView.layout == .row {
            let totalTextWidth = parentView
                .subviews
                .compactMap { $0.subviews.first as? MessageTemplateLabel }
                .filter { $0.isWrapTypeWidth }
                .reduce(0) { $0 + $1.fullTextViewWidth }
            
            if totalTextWidth >= self.maxWidth {
                label.numberOfLines = 1
            }
        }
        
        baseView.addSubview(label)
        parentView.addSubview(baseView)
        
        // Text Style
        if let textStyle = textStyle {
            var fontSize = self.themeForDefault.textFont.pointSize
            if let size = textStyle.size {
                fontSize = CGFloat(size)
            }
            
            switch textStyle.weight {
            case .normal:
                label.font = self.templateFont(size: fontSize)
            case .bold:
                label.font = self.templateFont(size: fontSize, weight: .bold)
            case .none:
                break
            }

            if let textColor = textStyle.color {
                label.textColor = UIColor(hexString: textColor)
            } else {
                label.textColor = self.themeForDefault.textColor
            }
            
        } else {
            label.font = self.templateFont(size: self.themeForDefault.textFont.pointSize)
            label.textColor = self.themeForDefault.textColor
            label.contentMode = .center // TODO: check
            label.textAlignment = .left
        }
        
        if let textAlign = textAlign {
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
        } else {
            // Text(no textAlign) | TextButton
            label.contentMode = .center
            label.textAlignment = .center
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
        
        if baseView.layout == .row {
            if item.width.type == .flex, item.width.value == flexTypeWrapValue {
                label.setContentCompressionResistancePriority(UILayoutPriority(751), for: NSLayoutConstraint.Axis.horizontal)
            }
        } else {
            if item.height.type == .flex, item.height.value == flexTypeWrapValue {
                label.setContentCompressionResistancePriority(UILayoutPriority(751), for: NSLayoutConstraint.Axis.vertical)
            }
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
                     itemsAlign: SBUMessageTemplate.ItemsAlign = .defaultAlign(),
                     layout: SBUMessageTemplate.LayoutType = .column,
                     isLastItem: Bool = false) -> UIView {
        let baseView = MessageTemplateImageBaseView(item: item, layout: layout)
        baseView.clipsToBounds = true
        let imageView: UIImageView = MessageTemplateImageView()
        
        let isForDownloadingTemplate = (item.imageUrl == SBUMessageTemplate.urlForTemplateDownload)
        
        // Image Style
        let imageStyle = item.imageStyle
        let contentMode = imageStyle.contentMode
        imageView.contentMode = contentMode
        
        // INFO: Edge case - image height is wrap
        var needResizeImage =
        (item.width.type == .fixed || (item.width.type == .flex && item.width.value == 0))
        && (item.height.type == .flex && item.height.value == 1)
        
        if isForDownloadingTemplate {
            needResizeImage = false
            imageView.contentMode = .center
        }
        
        if needResizeImage {
            switch (itemsAlign.vertical, itemsAlign.horizontal) {
            case (.top, .left):
                imageView.contentMode = .topLeft
            case (.top, .center):
                imageView.contentMode = .top
            case (.top, .right):
                imageView.contentMode = .topRight
            case (.center, .left):
                imageView.contentMode = .left
            case (.center, .center):
                imageView.contentMode = .center
            case (.center, .right):
                imageView.contentMode = .right
            case (.bottom, .left):
                imageView.contentMode = .bottomLeft
            case (.bottom, .center):
                imageView.contentMode = .bottom
            case (.bottom, .right):
                imageView.contentMode = .bottomRight
            default:
                break
            }
        }
        (imageView as? MessageTemplateImageView)?.needResizeImage = needResizeImage
        
        var tintColor: UIColor?
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
                case .scaleToFill: ratioConstraintsHandler()
                default: break
                }
            } else if item.height.type == .flex, item.height.value == 1 { // wrapContent
                switch item.imageStyle.contentMode {
                case .scaleAspectFit: ratioConstraintsHandler()
                case .scaleAspectFill: ratioConstraintsHandler()
                case .scaleToFill: ratioConstraintsHandler() // QM-2657
                default: break
                }
            }
            
        } else if item.width.type == .flex, item.width.value == 0 { // fillParent
            switch item.height.type {
            case .fixed: ratioConstraintsHandler()
            case .flex: ratioConstraintsHandler() // fillParent, wrapContent
            }
            
        } else if item.width.type == .flex, item.width.value == 1 { // wrapContent
            switch item.height.type {
            case .fixed: ratioConstraintsHandler()
            case .flex: minimumConstraintsHandler() // fillParent, wrapContent
            }
        }
        
        placeholderConstraints.forEach { $0.isActive = true }
        
        // Action
        self.setAction(on: baseView, item: item)

        // Load image
        if isForDownloadingTemplate {
            imageView.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
            
            let image = SBUIconSetType.iconSpinner
                .image(
                    to: SBUIconSetType.Metric.iconSpinnerSizeForTemplate
                ).sbu_with(
                    tintColor: tintColor,
                    forTemplate: true
                )
            imageView.image = image
            
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2 * Double.pi
            rotation.duration = 1.1
            rotation.repeatCount = Float.infinity
            imageView.layer.add(rotation, forKey: SBUAnimation.Key.spin.identifier)
            return baseView
        }
        
        imageView.loadImage(
            urlString: item.imageUrl,
            subPath: SBUCacheManager.PathType.template,
            completion: { [weak self, weak imageView] _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    let image = imageView?.image?.sbu_with(
                        tintColor: tintColor,
                        forTemplate: true
                    )
                    
                    // INFO: Edge case - image height is wrap
                    imageView?.image = image
                    imageView?.layoutIfNeeded()
                    
                    if let imageView = imageView as? MessageTemplateImageView,
                       imageView.needResizeImage {
                        imageView.image = image?.resizeTopAlignedToFill(newWidth: imageView.frame.width)
                        imageView.layoutIfNeeded()
                    }
                }
                
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
                            heightConst.priority = .defaultHigh
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
            }
        )
        
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
        let baseView = MessageTemplateImageButtonBaseView(item: item, layout: layout)
        baseView.clipsToBounds = true
        let imageButton = MessageTemplateImageButton()
        
        // Image Style
        let imageStyle = item.imageStyle
        let contentMode = imageStyle.contentMode
        imageButton.contentMode = contentMode
        imageButton.imageView?.contentMode = contentMode
        var tintColor: UIColor?
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

        imageButton.loadImage(
            urlString: item.imageUrl,
            for: .normal,
            subPath: SBUCacheManager.PathType.template,
            completion: { [weak self, weak imageButton] _ in
                guard let self = self else { return }
                
                let image = imageButton?.imageView?.image?.sbu_with(
                    tintColor: tintColor,
                    forTemplate: true
                )
                imageButton?.setImage(image, for: .normal)
                
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
                            heightConst.priority = .defaultHigh
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
            }
        )
        
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
            if width.type == .flex, width.value == flexTypeFillValue {
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
            
        } else { // row
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
        let paddingHeight = (padding?.top ?? 0.0) + (padding?.bottom ?? 0.0)

        if height.type == .fixed {
            self.rendererConstraints += subView?.sbu_constraint_v2(height: CGFloat(height.value) - paddingHeight) ?? []
        } else {
            self.rendererConstraints += subView?.sbu_constraint_lessThan_v2(heightAnchor: baseView.heightAnchor, height: -paddingHeight) ?? []
        }
        
        // top/bottom
        if layout == .column { // Default
            // top anchor
            if prevItem == nil && prevView.tag != SideView1Tag {
                self.rendererConstraints += baseView.sbu_constraint_v2(equalTo: parentView, top: marginInsets.top)
            } else {
                let prevItemBottomMargin = prevItem?.viewStyle?.margin?.bottom ?? 0.0
                self.rendererConstraints += baseView.sbu_constraint_equalTo_v2(
                    topAnchor: prevView.bottomAnchor,
                    top: marginInsets.top + prevItemBottomMargin
                )
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

            if height.type == .flex, height.value == flexTypeFillValue {
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
                top: paddingInsets.top,
                bottom: paddingInsets.bottom,
                priority: .required
            ) ?? []

            // INFO: Edge case - for right padding constraint adjustment
            if let baseView = baseView as? MessageTemplateBaseView,
               let rightPaddingConstraint = subView?.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -paddingInsets.right) {
                baseView.rightPaddingConstraint = rightPaddingConstraint
                baseView.rightPaddingConstraint?.priority = .required
                
                if let baseViewRightPaddingConstraint = baseView.rightPaddingConstraint {
                    self.rendererConstraints += [baseViewRightPaddingConstraint]
                }
            }
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
    
    // MARK: - Common
    func reloadCell() {
        self.delegate?.messageTemplateNeedReloadCell()
    }
    
    // MARK: - BaseView Wrapper class (for debugging, update each item)
    class MessageTemplateContentView: UIView {}
    class MessageTemplateBodyView: UIView {}

    class MessageTemplateBaseView: UIView {
        var item: SBUMessageTemplate.View
        var layout: SBUMessageTemplate.LayoutType
        
        var width: SBUMessageTemplate.SizeSpec { self.item.width }
        var height: SBUMessageTemplate.SizeSpec { self.item.height }
        
        weak var rightPaddingConstraint: NSLayoutConstraint?
        
        init(item: SBUMessageTemplate.View, layout: SBUMessageTemplate.LayoutType) {
            self.item = item
            self.layout = layout
        
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class MessageTemplateBoxBaseView: MessageTemplateBaseView {}
    class MessageTemplateTextBaseView: MessageTemplateBaseView {}
    class MessageTemplateImageBaseView: MessageTemplateBaseView {}
    class MessageTemplateTextButtonBaseView: MessageTemplateTextBaseView {
        // TODO: click effect animation
    }
    class MessageTemplateImageButtonBaseView: MessageTemplateBaseView {}

    // MARK: - Item Wrapper class (for debugging, update each item)

    class MessageTemplateBoxView: UIView {
        var layout: SBUMessageTemplate.LayoutType = .column
    }
    
    /// https://stackoverflow.com/a/32368958

    /// This class supports padding and 9 direction Align.
    ///
    /// How to use
    /// - Padding : `label.padding = edgeInsets`
    /// - Align:
    ///     - horizontal: `label.textAlignment`
    ///     - vertical: `label.contentMode`
    class MessageTemplateLabel: UILabel {
        var padding: SBUMessageTemplate.Padding?
        var updateLayoutHandler: (([NSLayoutConstraint], [NSLayoutConstraint]) -> Void)?
        
        var fullTextViewWidth: CGFloat {
            (self.padding?.left ?? 0)
            + (self.padding?.right ?? 0)
            + self.textWidth()
        }
        
        var boxWidth: CGFloat = 0.0
        var fullTextViewHeight: CGFloat {
            (self.padding?.top ?? 0)
            + (self.padding?.bottom ?? 0)
            + self.textHeight(with: boxWidth, numberOfLines: self.numberOfLines)
        }

        var isWrapTypeWidth: Bool {
            let width = (self.superview as? MessageTemplateTextBaseView)?.width
            return (width?.type == .flex &&
                    width?.value == SBUMessageTemplate.FlexSizeType.wrapContent.rawValue)
        }
        
        var isWrapTypeHeight: Bool {
            let height = (self.superview as? MessageTemplateTextBaseView)?.height
            return (height?.type == .flex &&
                    height?.value == SBUMessageTemplate.FlexSizeType.wrapContent.rawValue)
        }

        var isFixedTypeWidth: Bool {
            let width = (self.superview as? MessageTemplateTextBaseView)?.width
            return width?.type == .fixed
        }
        
        var isFixedTypeHeight: Bool {
            let height = (self.superview as? MessageTemplateTextBaseView)?.height
            return height?.type == .fixed
        }
        
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
            
            super.drawText(in: newRect.inset(by: .zero))
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // INFO: Edge case - text wrap issue: width
            guard let baseView = self.superview as? MessageTemplateTextBaseView,
                  let boxView = baseView.superview as? MessageTemplateBoxView,
                  let currentIndex = boxView.subviews.firstIndex(of: baseView) else { return }
                  
            if baseView.layout == .row {
                if isWrapTypeWidth {
                    var constraints: [NSLayoutConstraint] = []
                    var deactivatedConstraints: [NSLayoutConstraint] = []
                    
                    boxWidth = boxView.frame.width
                    let isOverSize = (baseView.frame.origin.x + fullTextViewWidth) > boxWidth
                    
                    constraints += self.sbu_constraint_v2(width: self.textWidth(), priority: .defaultLow)
                    
                    if isOverSize {
                        constraints += baseView.sbu_constraint_v2(
                            greaterThanOrEqualTo: boxView,
                            right: 0,
                            priority: .required
                        )
                        
                        for (index, baseView) in boxView.subviews.enumerated() {
                            if index <= currentIndex { continue }
                            deactivatedConstraints += baseView.constraints
                            baseView.isHidden = true
                        }
                        
                        for (index, baseView) in boxView.subviews.enumerated() {
                            if index >= currentIndex { continue }
                            if let width = (baseView as? MessageTemplateBaseView)?.width,
                               (width.type == .flex && width.value == SBUMessageTemplate.FlexSizeType.fillParent.rawValue) {
                                deactivatedConstraints += baseView.constraints
                                baseView.isHidden = true
                            }
                        }
                    }
                    
                    updateLayoutHandler?(constraints, deactivatedConstraints)
                } else if isFixedTypeWidth {
                    // INFO: Edge case - If all items are fixed, the last fixed label should not pad the text when over the box area
                    
                    boxWidth = boxView.frame.width
                    let isOverSize = (baseView.frame.origin.x + fullTextViewWidth) > boxWidth
                    
                    let itemCount: Int = boxView.subviews.count - 2
                    if let index = boxView.subviews.firstIndex(of: baseView),
                       index == (boxView.subviews.count - 2), // check last item
                        isOverSize { // when only over size
                    
                        let fixedWidthItems = boxView
                            .subviews
                            .compactMap { $0.subviews.first as? MessageTemplateLabel }
                            .filter { $0.isFixedTypeWidth }
                        if fixedWidthItems.count == itemCount {
                            baseView.rightPaddingConstraint?.priority = .defaultLow
                        }
                    }
                }
            } else if baseView.layout == .column,
                    let boxBaseView = boxView.superview as? MessageTemplateBoxBaseView,
                    boxBaseView.height.type == .fixed {
                // INFO: Edge case - text wrap/fixed issue: height
                
                if !isWrapTypeHeight { return }
                var constraints: [NSLayoutConstraint] = []
                var deactivatedConstraints: [NSLayoutConstraint] = []
                
                self.boxWidth = boxView.frame.width - ((self.padding?.left ?? 0)
                                                      + (self.padding?.right ?? 0))
                let boxHeight = boxView.frame.height - ((self.padding?.top ?? 0)
                                                        + (self.padding?.bottom ?? 0))
                
                let isOverSize = (baseView.frame.origin.y + fullTextViewHeight) >= boxHeight
                
                let totalTextHeight = boxView
                    .subviews
                    .compactMap { $0.subviews.first as? MessageTemplateLabel }
                    .filter { $0.isWrapTypeHeight || $0.isFixedTypeHeight }
                    .reduce(0) { $0 + $1.fullTextViewHeight }
                let needToRemoveFillTypes = totalTextHeight >= boxHeight

                constraints += self.sbu_constraint_v2(height: self.textHeight(with: boxWidth, numberOfLines: self.numberOfLines), priority: .defaultLow)
                
                if isOverSize {
                    constraints += baseView.sbu_constraint_v2(
                        greaterThanOrEqualTo: boxView,
                        bottom: 0,
                        priority: .required
                    )
                    
                    for (index, baseView) in boxView.subviews.enumerated() {
                        if currentIndex >= index { continue }
                        deactivatedConstraints += baseView.constraints
                        baseView.isHidden = true
                    }
                    
                    if needToRemoveFillTypes {
                        for (index, baseView) in boxView.subviews.enumerated() {
                            if currentIndex <= index { continue }
                            if let height = (baseView as? MessageTemplateBaseView)?.height,
                               (height.type == .flex && height.value == SBUMessageTemplate.FlexSizeType.fillParent.rawValue) {
                                deactivatedConstraints += baseView.constraints
                                baseView.isHidden = true
                            }
                        }
                    }
                }
                
                updateLayoutHandler?(constraints, deactivatedConstraints)
            }
        }
        
        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width,
                          height: size.height)
        }
        
        override var bounds: CGRect {
            didSet {
                preferredMaxLayoutWidth = bounds.width
            }
        }
    }

    class MessageTemplateTextButton: MessageTemplateLabel {}
    
    class MessageTemplateImageView: UIImageView {
        var needResizeImage: Bool = false
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // INFO: Edge case - image height is wrap
            if self.needResizeImage,
               (UIApplication.shared.currentWindow?.bounds.size.width ?? 0) < self.frame.width {
                self.image = image?.resizeTopAlignedToFill(newWidth: self.frame.width)
                self.layoutIfNeeded()
            }
        }
        
        override func updateConstraints() {
            super.updateConstraints()
        }
    }

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
        var action: SBUMessageTemplate.Action?
    }
    
    class ActionTapGesture: UITapGestureRecognizer {
        var action: SBUMessageTemplate.Action?
    }

    // func updateViewStyle(subview: UIView) {
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
    // }

}

extension UIImage {
    // https://stackoverflow.com/a/47884962
    // INFO: Edge case - image height is wrap
    func resizeTopAlignedToFill(newWidth: CGFloat) -> UIImage? {
        // Calculate ratio used for resizing the image
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)

        // Array that stores image frames
        var images: [UIImage] = []

        // If animated GIF image, resize all images in frames and append them to the array
        if let animatedImages = self.images {
            for animatedImage in animatedImages {
                guard let cgImage = animatedImage.cgImage else { continue }
                let image = UIImage(cgImage: cgImage)
                UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
                let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
                image.draw(in: rect)
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                guard let newImage = newImage else { continue }
                images.append(newImage)
            }
        } else {
            // If not an animated GIF image, create a new image with resizing
            UIGraphicsBeginImageContextWithOptions(newSize, false, UIApplication.shared.currentWindow?.screen.scale ?? 1.0)
            draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }

        // Create a new GIF image with modified images
        return UIImage.animatedImage(with: images, duration: self.duration)
    }
}

// TODO: will be separated by a file
extension UILabel {
    func textWidth() -> CGFloat {
        return UILabel.textWidth(font: self.font, text: self.text ?? "")
    }

    class func textWidth(font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text).width
    }
    
    func textHeight(with width: CGFloat, numberOfLines: Int = 0) -> CGFloat {
        return UILabel.textHeight(with: width, font: self.font, text: self.text ?? "", numberOfLines: numberOfLines)
    }

    class func textHeight(with width: CGFloat, font: UIFont, text: String, numberOfLines: Int = 0) -> CGFloat {
        return textSize(font: font, text: text, numberOfLines: numberOfLines, width: width).height
    }

    class func textSize(font: UIFont, text: String, extra: CGSize) -> CGSize {
        var size = textSize(font: font, text: text)
        size.width = size.width + extra.width
        size.height = size.height + extra.height
        return size
    }

    class func textSize(
        font: UIFont,
        text: String,
        numberOfLines: Int = 0,
        width: CGFloat = .greatestFiniteMagnitude,
        height: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = numberOfLines
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }

    class func countLines(font: UIFont, text: String, width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        let myText = text as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }

    func countLines(width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        let myText = (self.text ?? "") as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(
            with: rect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: self.font ?? UIFont()],
            context: nil
        )

        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
}
