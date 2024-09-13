//
//  SBUMessageTemplate.Body.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/*
    Root: `TemplateView`
     ㄴ body
       ㄴ items: `[SBUMessageTemplate.Item]`
         ㄴ Box: `SBUMessageTemplate.Box`
         ㄴ Text: `SBUMessageTemplate.Text`
         ㄴ Image: `SBUMessageTemplate.Image`
         ㄴ Button: `SBUMessageTemplate.TextButton`
         ㄴ Button: `SBUMessageTemplate.ImageButton`
 
    All item of `SBUMessageTemplate.Item` inherited `SBUMessageTemplate.View`.
 */

// MARK: - Root

extension SBUMessageTemplate.Syntax {
    class TemplateView: Decodable, MessageTemplateItemIdentifiable {
        var version: Int?
        var body: SBUMessageTemplate.Syntax.Body?
        var identifierFactory: SBUMessageTemplate.Syntax.Identifier.Factory
        
        enum CodingKeys: String, CodingKey {
            case version, body
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.version = SBUMessageTemplate.decodeIfPresentMultipleTypeForInt(
                forKey: .version,
                from: container,
                defaultValue: 0
            )
            self.body = try container.decodeIfPresent(SBUMessageTemplate.Syntax.Body.self, forKey: .body)
            self.identifierFactory = SBUMessageTemplate.Syntax.Identifier.Factory()
        }
        
        static func generate(
            json: String,
            messageId: Int64,
            replaceEscape: Bool = true // for unit test
        ) -> TemplateView? {
            var result = json
            do {
                if replaceEscape == true {
                    // NOTE: **DO NOT remove below**
                    result = result.replacingOccurrences(of: "\\n", with: "\\\\n")
                    result = result.replacingOccurrences(of: "\n", with: "\\n")
                    // NOTE: **DO NOT remove above**
                }
                
                let template = try JSONDecoder().decode(TemplateView.self, from: Data(result.utf8))
                template.setIdentifier(with: .init(messageId: messageId))
                return template
            } catch {
                SBULog.error(error)
                return nil
            }
        }
        
        func setIdentifier(with factory: SBUMessageTemplate.Syntax.Identifier.Factory) {
            self.identifierFactory = factory
            self.body?.items?.forEach { $0.asView.setIdentifier(with: factory ) }
        }
        
        /*
         template body: vertical_items
         - 0: [_]
         - 1: [____] <--- template max width
         - 2: [__]
         */
        func itemsMaxWidth(with limit: CGFloat) -> CGFloat {
            guard let items = self.body?.items?.compactMap({ $0.asView }) else { return .infinity }
            
            var maxWidth: CGFloat = 0
            var hasWrapContent: Bool = false
            var hasFillParent: Bool = false
            
            for item in items {
                if item.width.internalSizeType.isFillParent { hasFillParent = true }
                if item.width.internalSizeType.isWrapContent { hasWrapContent = true }
                if maxWidth < item.widthValue { maxWidth = item.fullWidthValue }
            }
            
            // If {fill_parent} is present, it will be drawn with {max_fixed_width} or {limit} because it doesn't know how it will be drawn.
            if hasFillParent == true { return max(maxWidth, limit) }
            // If {wrap_content} is present, make it smaller than {limit} and allow it to have a wrap area.
            if hasWrapContent == true { return max(maxWidth, limit) } // NOTE: lessThan `{limit}` in renderer.
            // If there are only fixed width values.
            return maxWidth
        }

        var hasCompositeType: Bool {
            self.body?.items?.contains(where: { $0.hasCompositeType }) ?? false
        }
    }
}

extension SBUMessageTemplate.Syntax {
    class Body: Decodable {
        var items: [SBUMessageTemplate.Syntax.Item]?
    }
    
    class View: Decodable, MessageTemplateItemIdentifiable {
        let type: Item.ItemType
        let action: SBUMessageTemplate.Action?
        let viewStyle: ViewStyle
        let width: SizeSpec // fill
        let height: SizeSpec // wrap
        
        var identifier: SBUMessageTemplate.Syntax.Identifier = .default
        
        enum CodingKeys: String, CodingKey {
            case type, action, width, height, viewStyle
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(SBUMessageTemplate.Syntax.Item.ItemType.self, forKey: .type)
            self.action = try container.decodeIfPresent(SBUMessageTemplate.Action.self, forKey: .action)
            self.width = try container.decodeIfPresent(SBUMessageTemplate.Syntax.SizeSpec.self, forKey: .width) ?? SizeSpec.fillParent()
            self.height = try container.decodeIfPresent(SBUMessageTemplate.Syntax.SizeSpec.self, forKey: .height) ?? SizeSpec.wrapContent()
            self.viewStyle = try container.decodeIfPresent(SBUMessageTemplate.Syntax.ViewStyle.self, forKey: .viewStyle) ?? ViewStyle.Default()
        }
        
        init(
            type: Item.ItemType,
            viewStyle: ViewStyle? = nil,
            width: SizeSpec = .fillParent(),
            height: SizeSpec = .wrapContent(),
            action: SBUMessageTemplate.Action? = nil
        ) {
            self.type = type
            self.viewStyle = viewStyle ?? ViewStyle.Default()
            self.width = width
            self.height = height
            self.action = action
        }
        
        // MARK: Common
        func setDefaultRadiusIfNeeded(_ radius: Int) {
            if self.viewStyle.radius == nil {
                self.viewStyle.radius = radius
            }
        }
        
        var widthValue: CGFloat { CGFloat(self.width.value) }
        var leftMarginValue: CGFloat { self.viewStyle.margin?.left ?? 0 }
        var rightMarginValue: CGFloat { self.viewStyle.margin?.right ?? 0 }
        var fullWidthValue: CGFloat { self.widthValue + self.leftMarginValue + self.rightMarginValue }
        
        func setDefaultPaddingIfNeeded(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
            if self.viewStyle.padding == nil {
                self.viewStyle.padding = Padding(top: top, bottom: bottom, left: left, right: right)
            }
        }
        
        func setIdentifier(with factory: SBUMessageTemplate.Syntax.Identifier.Factory) {
            self.identifier = factory.generate(with: self)
        }
        
        var imageUrlString: String? {
            switch self {
            case let item as SBUMessageTemplate.Syntax.ImageButton: return item.imageUrl
            case let item as SBUMessageTemplate.Syntax.Image: return item.imageUrl
            default: return nil
            }
        }
        
        var isFixedSize: Bool {
            self.width.type == .fixed && self.height.type == .fixed
        }
    }
}

extension SBUMessageTemplate.Syntax {
    class Box: View {
        let layout: LayoutType
        let items: [Item]?
        let align: ItemsAlign
        
        enum CodingKeys: String, CodingKey {
            case items, layout, align
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.layout = try container.decodeIfPresent(LayoutType.self, forKey: .layout) ?? .row
            self.items = try container.decodeIfPresent([Item].self, forKey: .items)
            self.align = try container.decodeIfPresent(ItemsAlign.self, forKey: .align) ?? ItemsAlign.defaultAlign()
            
            try super.init(from: decoder)
        }
        
        init(
            layout: LayoutType,
            align: ItemsAlign,
            type: Item.ItemType,
            viewStyle: ViewStyle? = nil,
            width: SizeSpec = .fillParent(),
            height: SizeSpec = .wrapContent(),
            items: [Item]?,
            action: SBUMessageTemplate.Action? = nil
        ) {
            self.layout = layout
            self.items = items
            self.align = align
            
            super.init(
                type: type,
                viewStyle: viewStyle,
                width: width,
                height: height,
                action: action
            )
        }
        
        override func setIdentifier(with factory: SBUMessageTemplate.Syntax.Identifier.Factory) {
            self.identifier = factory.generate(with: self)
            self.items?.forEach { $0.asView.setIdentifier(with: factory) }
        }
    }
    
    class Text: View {
        let text: String
        let maxTextLines: Int
        let textStyle: TextStyle?
        let align: TextAlign
        
        enum CodingKeys: String, CodingKey {
            case text, maxTextLines, textStyle, align
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.text = try container.decode(String.self, forKey: .text)
            self.maxTextLines = SBUMessageTemplate.decodeIfPresentMultipleTypeForInt(
                forKey: .maxTextLines,
                from: container,
                defaultValue: 0
            ) ?? 0
            self.textStyle = try container.decodeIfPresent(TextStyle.self, forKey: .textStyle)
            self.align = try container.decodeIfPresent(TextAlign.self, forKey: .align) ?? TextAlign.defaultAlign()
            
            try super.init(from: decoder)
        }
        
        init(
            text: String,
            maxTextLines: Int,
            textStyle: TextStyle?,
            type: Item.ItemType,
            viewStyle: ViewStyle? = nil,
            width: SizeSpec = .fillParent(),
            height: SizeSpec = .wrapContent(),
            action: SBUMessageTemplate.Action? = nil,
            align: TextAlign = .defaultAlign()
        ) {
            self.text = text
            self.maxTextLines = maxTextLines
            self.textStyle = textStyle
            self.align = align
            
            super.init(
                type: type,
                viewStyle: viewStyle,
                width: width,
                height: height,
                action: action
            )
        }
    }
    
    class Image: View, MessageTemplateImageRatioType {
        let imageUrl: String
        let imageStyle: ImageStyle
        let metaData: MetaData?
        
        enum CodingKeys: String, CodingKey {
            case imageUrl, imageStyle, metaData
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
            self.imageStyle = try container.decodeIfPresent(ImageStyle.self, forKey: .imageStyle) ?? ImageStyle()
            self.metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData)
            
            try super.init(from: decoder)
        }
        
        init(
            imageUrl: String,
            imageStyle: ImageStyle,
            metaData: MetaData?,
            viewStyle: ViewStyle? = nil,
            width: SizeSpec = .fillParent(),
            height: SizeSpec = .wrapContent(),
            action: SBUMessageTemplate.Action? = nil
        ) {
            self.imageUrl = imageUrl
            self.imageStyle = imageStyle
            self.metaData = metaData
            
            super.init(
                type: .image,
                viewStyle: viewStyle,
                width: width,
                height: height,
                action: action
            )
        }
    }
    
    class TextButton: View {
        let text: String?
        let maxTextLines: Int
        let textStyle: TextStyle?
        
        enum CodingKeys: String, CodingKey {
            case text, maxTextLines, textStyle
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.text = try container.decode(String.self, forKey: .text)
            self.maxTextLines = SBUMessageTemplate.decodeIfPresentMultipleTypeForInt(
                forKey: .maxTextLines,
                from: container,
                defaultValue: 1
            ) ?? 1
            self.textStyle = try container.decodeIfPresent(TextStyle.self, forKey: .textStyle)
            
            try super.init(from: decoder)
            
            self.setDefaultRadiusIfNeeded(6)
            self.setDefaultPaddingIfNeeded(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0)
        }
    }
    
    class ImageButton: View, MessageTemplateImageRatioType {
        let imageUrl: String
        let imageStyle: ImageStyle
        let metaData: MetaData?
        
        enum CodingKeys: String, CodingKey {
            case imageUrl, imageStyle, metaData
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
            self.imageStyle = try container.decodeIfPresent(ImageStyle.self, forKey: .imageStyle) ?? ImageStyle()
            self.metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData)
            
            try super.init(from: decoder)
        }
    }
    
    class CarouselItem: View {
        let items: [TemplateView]?
        let carouselStyle: CarouselStyle
        
        enum CodingKeys: String, CodingKey {
            case items, carouselStyle
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let items = try container.decodeIfPresent([TemplateView].self, forKey: .items) ?? []
            self.items = items
            
            self.carouselStyle = try container.decodeIfPresent(CarouselStyle.self, forKey: .carouselStyle) ?? .init()
            
            try super.init(from: decoder)
        }
        
        override func setIdentifier(with factory: SBUMessageTemplate.Syntax.Identifier.Factory) {
            self.identifier = factory.generate(with: self)
            items?.forEach { $0.setIdentifier(with: factory) }
        }
        
        class CarouselStyle: Decodable {
            let spacing: CGFloat
            let maxChildWidth: CGFloat
            
            enum CodingKeys: String, CodingKey {
                case spacing
                case maxChildWidth
            }
            
            init(spacing: CGFloat = 10, maxChildWidth: CGFloat = SBUMessageTemplate.defaultMaxSize) {
                self.spacing = spacing
                self.maxChildWidth = maxChildWidth
            }
            
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self.spacing = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                    forKey: .spacing,
                    from: container
                )
                self.maxChildWidth = SBUMessageTemplate.decodeIfPresentMultipleTypeForCGFloat(
                    forKey: .maxChildWidth,
                    from: container
                ) ?? SBUMessageTemplate.defaultMaxSize
            }
        }
    }
}
