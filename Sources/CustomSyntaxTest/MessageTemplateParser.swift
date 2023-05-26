//
//  MessageTemplateParser.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

public class MessageTemplateParser: NSObject {
    static let MockJson = """
        {
            "version": "1",
            "body": {
              "items": [
                {
                  "type": "box",
                  "layout": "column",
                  "items": [
                    {
                      "type": "box",
                      "layout": "column",
                      "items": [
                        {
                          "type": "image",
                          "imageUrl": "https://dxstmhyqfqr1o.cloudfront.net/notifications/preset-notification-channel-cover.png",
                          "imageStyle": {
                            "contentMode": "aspectFill"
                          },
                          "viewStyle": {},
                          "metaData": {
                            "pixelWidth": "168",
                            "pixelHeight": "168"
                          }
                        },
                        {
                          "type": "box",
                          "layout": "column",
                          "viewStyle": {
                            "radius": "8",
                            "padding": {
                              "top": "12",
                              "bottom": "12",
                              "left": "12",
                              "right": "12"
                            }
                          },
                          "items": [
                            {
                              "type": "text",
                              "align": {
                                "horizontal": "left",
                                "vertical": "top"
                              },
                              "viewStyle": {},
                              "width": {
                                "type": "flex",
                                "value": "1"
                              },
                              "height": {
                                "type": "flex",
                                "value": "1"
                              },
                              "text": "Hello tez",
                              "textStyle": {
                                "color": "#ffbdb8bd",
                                "size": "16",
                                "weight": "normal"
                              },
                              "maxTextLines": "1"
                            },
                            {
                              "type": "text",
                              "align": {
                                "horizontal": "left",
                                "vertical": "top"
                              },
                              "viewStyle": {},
                              "width": {
                                "type": "fixed",
                                "value": "1"
                              },
                              "height": {
                                "type": "flex",
                                "value": "1"
                              },
                              "text": "Your order #123123 has been shipped.",
                              "textStyle": {
                                "color": "#ffbdb8bd",
                                "size": "16",
                                "weight": "normal"
                              },
                              "maxTextLines": "1"
                            },
                            {
                              "type": "textButton",
                              "viewStyle": {
                                "backgroundColor": "#E0E0E0",
                                "padding": {
                                  "top": "10",
                                  "bottom": "10",
                                  "left": "20",
                                  "right": "20"
                                }
                              },
                              "width": {
                                "type": "flex",
                                "value": "0"
                              },
                              "height": {
                                "type": "flex",
                                "value": "0"
                              },
                              "text": "Check status",
                              "textStyle": {
                                "color": "#742DDD",
                                "size": "16",
                                "weight": "normal"
                              },
                              "maxTextLines": "5",
                              "action": {
                                "type": "web",
                                "data": "https://naver.com"
                              }
                            }
                          ],
                          "height": {
                            "type": "fixed",
                            "value": "300"
                          },
                          "width": {
                            "type": "flex",
                            "value": "0"
                          },
                          "align": {
                            "horizontal": "left",
                            "vertical": "top"
                          }
                        }
                      ],
                      "viewStyle": {}
                    }
                  ],
                  "viewStyle": {}
                }
              ]
            }
          }
        """
    
    public static func getMock(widthT: String, widthV: Int, heightT: String, heightV: Int, contentMode: String) -> String {
            return """
    {"version": 1,"body": {"items": [{"type": "box","layout": "column","items": [{"type": "image","metaData": {"pixelWidth": 4000,"pixelHeight": 3000},"width": {"type": "\(widthT)","value": \(widthV)},"height": {"type": "\(heightT)","value": \(heightV)},"imageStyle": {"contentMode": "\(contentMode)"},"imageUrl": "https://images.unsplash.com/photo-1579393329936-4bc9bc673651?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format"},{"type": "box","viewStyle": {"padding": {"top": 12,"right": 12,"bottom": 12,"left": 12}},"layout": "column","items": [{"type": "box","layout": "row","items": [{"type": "box","layout": "column","items": [{"type": "text","text": "Notification channel creation guide","maxTextLines": 3,"viewStyle": {"padding": {"top": 0,"bottom": 6,"left": 0,"right": 0}},"textStyle": {"size": 16,"weight": "bold"}},{"type": "text","text": "Notification Center is basically a group channel to which a single user, the receiver of a notification, belongs. A notification channel, which is a single group channel dedicated to the Notification Center, must be created for each user.","maxTextLines": 10,"textStyle": {"size": 14}}]}]},{"type": "box","layout": "column","items": [{"type": "box","viewStyle": {"margin": {"top": 16,"bottom": 0,"left": 0,"right": 0}},"align": {"horizontal": "left","vertical": "center"},"layout": "row","action": {"type": "web","data": "www.sendbird.com"},"items": [{"type": "box","viewStyle": {"margin": {"top": 0,"bottom": 0,"left": 12,"right": 0}},"layout": "column","items": [{"type": "text","text": "Title","maxTextLines": 1,"textStyle": {"size": 16,"weight": "bold"}},{"type": "text","viewStyle": {"margin": {"top": 4,"bottom": 0,"left": 0,"right": 0}},"text": "Hi","maxTextLines": 1,"textStyle": {"size": 14}}]}]}]}]}]}]}}
    """
    }
    /**
     var tmpData = MessageTemplateParser.getMock(
//            widthT: "fixed", widthV: 200,
//            widthT: "flex", widthV: 0,
         widthT: "flex", widthV: 1,
//            heightT: "fixed", heightV: 200,
//            heightT: "flex", heightV: 0,
         heightT: "flex", heightV: 1,
//            contentMode: "aspectFit"
//            contentMode: "aspectFill"
         contentMode: "scalesToFill"
     )
     */
    
    public func parserTest() {
        let data = Data(MessageTemplateParser.MockJson.utf8)
        let decoded = try? JSONDecoder().decode(MessageTemplateData.self, from: data)

        let items = decoded?.body?.items
        
        let item = items?[0]
        switch item {
        case .box(let box):
            print(box)
        case .text(let text):
            print(text)
        case .image(let image):
            print(image)
        case .textButton(let textButton):
            print(textButton)
        case .imageButton(let imageButton):
            print(imageButton)
        case .none:
            break
        }
    }
}

/**
    Root: `MessageTemplateData`
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
class MessageTemplateData: Decodable {
    var version: Int?
    var body: SBUMessageTemplate.Body?
    
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
        self.body = try container.decodeIfPresent(SBUMessageTemplate.Body.self, forKey: .body)
    }
}

// MARK: - Body
public class SBUMessageTemplate {
    
    static let urlForTemplateDownload = "TEMPLATE_DOWNLOAD"
    
    class Body: Decodable {
        var items: [SBUMessageTemplate.Item]?
    }
    
    enum Item {
        case box(Box)
        case text(Text)
        case textButton(TextButton)
        case imageButton(ImageButton)
        case image(Image)
    }
    
    // MARK: Base Item
    class View: Decodable {
        let type: Item.ItemType
        let action: Action?
        let viewStyle: ViewStyle?
        let width: SizeSpec // fill
        let height: SizeSpec // wrap
        
        enum CodingKeys: String, CodingKey {
            case type, action, width, height, viewStyle
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(Item.ItemType.self, forKey: .type)
            self.action = try container.decodeIfPresent(Action.self, forKey: .action)
            self.width = try container.decodeIfPresent(SizeSpec.self, forKey: .width) ?? SizeSpec.fillParent()
            self.height = try container.decodeIfPresent(SizeSpec.self, forKey: .height) ?? SizeSpec.wrapContent()
            self.viewStyle = try container.decodeIfPresent(ViewStyle.self, forKey: .viewStyle)
        }
        
        init(
            type: Item.ItemType,
            viewStyle: ViewStyle? = nil,
            width: SizeSpec = .fillParent(),
            height: SizeSpec = .wrapContent(),
            action: Action? = nil
        ) {
            self.type = type
            self.viewStyle = viewStyle
            self.width = width
            self.height = height
            self.action = action
        }
        
        // MARK: Common
        func setDefaultRadiusIfNeeded(_ radius: Int) {
            if self.viewStyle?.radius == nil {
                self.viewStyle?.radius = radius
            }
        }
        
        func setDefaultPaddingIfNeeded(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
            if self.viewStyle?.padding == nil {
                self.viewStyle?.padding = Padding(top: top, bottom: bottom, left: left, right: right)
            }
        }
    }
    
    // MARK: Items
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
            type: SBUMessageTemplate.Item.ItemType,
            viewStyle: SBUMessageTemplate.ViewStyle? = nil,
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
            type: SBUMessageTemplate.Item.ItemType,
            viewStyle: SBUMessageTemplate.ViewStyle? = nil,
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

    class Image: View {
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
            viewStyle: SBUMessageTemplate.ViewStyle? = nil,
            width: SBUMessageTemplate.SizeSpec = .fillParent(),
            height: SBUMessageTemplate.SizeSpec = .wrapContent(),
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
            self.setDefaultPaddingIfNeeded(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0)
        }
    }
    
    class ImageButton: View {
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

    // MARK: - Style
    class ViewStyle: Decodable {
        let backgroundColor: String?
        let backgroundImageUrl: String?
        let borderWidth: Int?
        let borderColor: String?
        var radius: Int?
        let margin: Margin?
        var padding: Padding?
        
        enum CodingKeys: String, CodingKey {
            case backgroundColor, backgroundImageUrl, borderWidth, borderColor, radius, margin, padding
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
            self.backgroundImageUrl = try container.decodeIfPresent(String.self, forKey: .backgroundImageUrl)
            self.borderWidth = SBUMessageTemplate.decodeIfPresentMultipleTypeForInt(
                forKey: .borderWidth,
                from: container
            )
            self.borderColor = try container.decodeIfPresent(String.self, forKey: .borderColor)
            self.radius = SBUMessageTemplate.decodeIfPresentMultipleTypeForInt(
                forKey: .radius,
                from: container
            )
            self.margin = try container.decodeIfPresent(Margin.self, forKey: .margin)
            self.padding = try container.decodeIfPresent(Padding.self, forKey: .padding)
        }
        
        init(
            backgroundColor: String? = nil,
            backgroundImageUrl: String? = nil,
            borderWidth: Int? = nil,
            borderColor: String? = nil,
            radius: Int? = nil,
            margin: Margin? = nil,
            padding: Padding? = nil
        ) {
            self.backgroundColor = backgroundColor
            self.backgroundImageUrl = backgroundImageUrl
            self.borderWidth = borderWidth
            self.borderColor = borderColor
            self.radius = radius
            self.margin = margin
            self.padding = padding
        }
    }

    class TextStyle: Decodable {
        let size: Int?
        let color: String?
        let weight: WeightType?
        
        enum CodingKeys: String, CodingKey {
            case size, color, weight, align
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.size = SBUMessageTemplate.decodeIfPresentMultipleTypeForInt(
                forKey: .size,
                from: container
            )
            self.color = try container.decodeIfPresent(String.self, forKey: .color)
            self.weight = try container.decodeIfPresent(WeightType.self, forKey: .weight) ?? .normal
        }
        
        init(
            size: Int? = nil,
            color: String? = nil,
            weight: WeightType? = nil
        ) {
            self.size = size
            self.color = color
            self.weight = weight
        }
    }
    
    class Align: Decodable {
        var horizontal: HorizontalAlign?
        var vertical: VerticalAlign?
        
        enum CodingKeys: String, CodingKey {
            case horizontal, vertical
        }
        
        init(horizontal: HorizontalAlign = .left, vertical: VerticalAlign = .top) {
            self.horizontal = horizontal
            self.vertical = vertical
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.horizontal = try container.decode(HorizontalAlign.self, forKey: .horizontal)
            self.vertical = try container.decode(VerticalAlign.self, forKey: .vertical)
        }
    }
    
    class TextAlign: Align {
        class func defaultAlign() -> TextAlign {
            let align = TextAlign()
            align.horizontal = .left
            align.vertical = .top
            return align
        }
    }
    
    class ItemsAlign: Align {
        class func defaultAlign() -> ItemsAlign {
            let align = ItemsAlign()
            align.horizontal = .left
            align.vertical = .top
            return align
        }
    }

    class ImageStyle: Decodable {
        let contentMode: UIView.ContentMode
        private let decodedContentMode: ContentMode
        let tintColor: String?
        
        enum CodingKeys: String, CodingKey {
            case contentMode, tintColor
        }
        
        init() {
            self.contentMode = .scaleAspectFit
            self.decodedContentMode = .aspectFit
            self.tintColor = nil
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.decodedContentMode = try container.decodeIfPresent(ContentMode.self, forKey: .contentMode) ?? .aspectFit
            switch self.decodedContentMode {
            case .scalesToFill:
                self.contentMode = .scaleToFill
            case .aspectFit:
                self.contentMode = .scaleAspectFit
            case .aspectFill:
                self.contentMode = .scaleAspectFill
            }
            self.tintColor = try container.decodeIfPresent(String.self, forKey: .tintColor)
        }
        
        init (
            contentMode: UIView.ContentMode,
            tintColor: String?
        ) {
            self.contentMode = contentMode
            self.decodedContentMode = .aspectFit
            self.tintColor = tintColor
        }
    }
    
    // MARK: - Action
    public class Action: Decodable {
        public let type: ActionType
        public let data: String
        public let alterData: String?
        
        enum CodingKeys: String, CodingKey {
            case type, data, alterData
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(ActionType.self, forKey: .type)
            self.data = try container.decode(String.self, forKey: .data)
            self.alterData = try container.decodeIfPresent(String.self, forKey: .alterData)
        }
    }
    
    // MARK: - Size
    class SizeSpec: Decodable {
        var type: SizeType
        var value: Int // flex -> 0: fillParent, 1: wrapContent
        
        enum CodingKeys: String, CodingKey {
            case type, value
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(SizeType.self, forKey: .type)
            self.value = SBUMessageTemplate.decodeMultipleTypeForInt(
                forKey: .value,
                from: container
            )
        }
        
        init(type: SizeType = .fixed, value: Int = 0) {
            self.type = type
            self.value = value
        }
        
        class func fillParent() -> SizeSpec {
            let sizeSpec = SizeSpec(
                type: .flex,
                value: FlexSizeType.fillParent.rawValue
            )
            return sizeSpec
        }
        
        class func wrapContent() -> SizeSpec {
            let sizeSpec = SizeSpec(
                type: .flex,
                value: FlexSizeType.wrapContent.rawValue
            )
            return sizeSpec
        }
    }
    
    class MetaData: Decodable {
        var pixelWidth: Int
        var pixelHeight: Int
        
        enum CodingKeys: String, CodingKey {
            case pixelWidth, pixelHeight
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.pixelWidth = SBUMessageTemplate.decodeMultipleTypeForInt(
                forKey: .pixelWidth,
                from: container
            )
            self.pixelHeight = SBUMessageTemplate.decodeMultipleTypeForInt(
                forKey: .pixelHeight,
                from: container
            )
        }
    }
    
    // MARK: - Margin, Padding
    class Margin: Decodable {
        let top: CGFloat
        let bottom: CGFloat
        let left: CGFloat
        let right: CGFloat
        
        enum CodingKeys: String, CodingKey {
            case top, bottom, left, right
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.top = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .top,
                from: container
            )
            self.bottom = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .bottom,
                from: container
            )
            self.left = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .left,
                from: container
            )
            self.right = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .right,
                from: container
            )
        }
    }
    
    class Padding: Decodable {
        var top: CGFloat
        var bottom: CGFloat
        var left: CGFloat
        var right: CGFloat
        
        enum CodingKeys: String, CodingKey {
            case top, bottom, left, right
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.top = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .top,
                from: container
            )
            self.bottom = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .bottom,
                from: container
            )
            self.left = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .left,
                from: container
            )
            self.right = SBUMessageTemplate.decodeMultipleTypeForCGFloat(
                forKey: .right,
                from: container
            )
        }
        
        init(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
            self.top = top
            self.bottom = bottom
            self.left = left
            self.right = right
        }
    }
    
    // MARK: - Type
    enum LayoutType: String, Decodable {
        case row, column
    }
    
    enum WeightType: String, Decodable {
        case normal, bold
    }
    
    enum ContentMode: String, Decodable {
        case aspectFill, aspectFit, scalesToFill
    }
    
    public enum ActionType: String, Decodable {
        case web, custom, uikit
    }
    
    enum SizeType: String, Decodable {
        case fixed, flex
        
        init(from decoder: Decoder) throws {
            self = try SizeType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .fixed
        }
    }
    
    enum FlexSizeType: Int, Decodable {
        case fillParent = 0
        case wrapContent = 1
    }
    
    enum HorizontalAlign: String, Decodable {
        case left, center, right
    }
    
    enum VerticalAlign: String, Decodable {
        case top, center, bottom
    }
}

extension SBUMessageTemplate.Item: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKey.self)
        let singleContainer = try decoder.singleValueContainer()
        let type = try container.decode(ItemType.self, forKey: .type)
        switch type {
        case .box:
            let box = try singleContainer.decode(SBUMessageTemplate.Box.self)
            self = .box(box)
        case .text:
            let text = try singleContainer.decode(SBUMessageTemplate.Text.self)
            self = .text(text)
        case .textButton:
            let textButton = try singleContainer.decode(SBUMessageTemplate.TextButton.self)
            self = .textButton(textButton)
        case .imageButton:
            let imageButton = try singleContainer.decode(SBUMessageTemplate.ImageButton.self)
            self = .imageButton(imageButton)
        case .image:
            let image = try singleContainer.decode(SBUMessageTemplate.Image.self)
            self = .image(image)
        }
    }

    enum TypeCodingKey: String, CodingKey {
        case type
    }
    
    enum ItemType: String, Decodable {
        case box
        case text
        case image
        case textButton
        case imageButton
    }
}

// MARK: - Utils
extension SBUMessageTemplate {
    static func decodeMultipleTypeForInt<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>
    ) -> Int {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return Int(stringValue) ?? 0
        } else if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        } else {
            return 0
        }
    }
    
    static func decodeIfPresentMultipleTypeForInt<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>,
        defaultValue: Int = 0
    ) -> Int? {
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return intValue
        } else {
            return nil
        }
    }
    
    static func decodeMultipleTypeForCGFloat<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>
    ) -> CGFloat {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return CGFloat(Double(stringValue) ?? 0.0)
        } else if let floatValue = try? container.decode(CGFloat.self, forKey: key) {
            return floatValue
        } else {
            return 0.0
        }
    }
    
    static func decodeIfPresentMultipleTypeForCGFloat<C: CodingKey>(
        forKey key: C,
        from container: KeyedDecodingContainer<C>,
        defaultValue: CGFloat = 0
    ) -> CGFloat? {
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            if let doubleValue = Double(stringValue) {
                return CGFloat(doubleValue)
            } else {
                return nil
            }
        } else if let floatValue = try? container.decodeIfPresent(CGFloat.self, forKey: key) {
            return floatValue
        } else {
            return nil
        }
    }
}

// MARK: - Error message

extension SBUMessageTemplate.Body {
    static func parsingError(text: String, subText: String? = nil) -> SBUMessageTemplate.Body {
        var textItems: [SBUMessageTemplate.Item] = [
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
        
        let body = SBUMessageTemplate.Body()
        body.items = [
            .box(.init(
                layout: .column,
                align: SBUMessageTemplate.ItemsAlign(horizontal: .left, vertical: .center),
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
    
    static func downloadingTemplate(height: CGFloat) -> SBUMessageTemplate.Body {
        let spinnerItems: [SBUMessageTemplate.Item] = [
            .image(.init(
                imageUrl: SBUMessageTemplate.urlForTemplateDownload,
                imageStyle: .init(
                    contentMode: .center,
                    tintColor: SBUTheme.notificationTheme.notificationCell.downloadingBackgroundHexColor
                ),
                metaData: nil
            ))
        ]
        
        let body = SBUMessageTemplate.Body()
        body.items = [
            .box(.init(
                layout: .column,
                align: SBUMessageTemplate.ItemsAlign(horizontal: .center, vertical: .center),
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
