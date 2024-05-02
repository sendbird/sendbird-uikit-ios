//
//  SBUMessageTemplate.Item.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate {
    struct Syntax { } // namespace
}

extension SBUMessageTemplate.Syntax {
    enum Item {
        case box(Box)
        case text(Text)
        case textButton(TextButton)
        case imageButton(ImageButton)
        case image(Image)
        case carouselView(CarouselItem)
        
        var asView: View {
            switch self {
            case .box(let view): return view
            case .text(let view): return view
            case .textButton(let view): return view
            case .imageButton(let view): return view
            case .image(let view): return view
            case .carouselView(let view): return view
            }
        }
        
        var hasCompositeType: Bool {
            switch self {
            case .box: return false
            case .text: return false
            case .textButton: return false
            case .imageButton: return false
            case .image: return false
            case .carouselView: return true
            }
        }
    }
}

extension SBUMessageTemplate.Syntax.Item: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKey.self)
        let singleContainer = try decoder.singleValueContainer()
        let type = try container.decode(ItemType.self, forKey: .type)
        switch type {
        case .box:
            let box = try singleContainer.decode(SBUMessageTemplate.Syntax.Box.self)
            self = .box(box)
        case .text:
            let text = try singleContainer.decode(SBUMessageTemplate.Syntax.Text.self)
            self = .text(text)
        case .textButton:
            let textButton = try singleContainer.decode(SBUMessageTemplate.Syntax.TextButton.self)
            self = .textButton(textButton)
        case .imageButton:
            let imageButton = try singleContainer.decode(SBUMessageTemplate.Syntax.ImageButton.self)
            self = .imageButton(imageButton)
        case .image:
            let image = try singleContainer.decode(SBUMessageTemplate.Syntax.Image.self)
            self = .image(image)
        case .carouselView:
            let carousel = try singleContainer.decode(SBUMessageTemplate.Syntax.CarouselItem.self)
            self = .carouselView(carousel)
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
        case carouselView
    }
}
