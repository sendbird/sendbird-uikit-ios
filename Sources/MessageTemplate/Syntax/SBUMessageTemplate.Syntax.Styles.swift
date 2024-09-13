//
//  SBUMessageTemplate.Styles.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate.Syntax {
    
    // MARK: - Style
    class ViewStyle: Decodable {
        var isDefault: Bool { false }
        
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
    
    class ImageStyle: Decodable {
        let contentMode: UIView.ContentMode
        private let decodedContentMode: ContentMode
        let tintColor: String?
        
        var tintColorValue: UIColor? {
            guard let color = tintColor else { return nil }
            return UIColor(hexString: color)
        }
        
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
}


extension SBUMessageTemplate.Syntax.ViewStyle {
    class Default: SBUMessageTemplate.Syntax.ViewStyle {
        override var isDefault: Bool { true }
    }
}
