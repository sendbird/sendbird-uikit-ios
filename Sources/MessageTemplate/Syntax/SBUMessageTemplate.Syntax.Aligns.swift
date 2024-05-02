//
//  SBUMessageTemplate.Aligns.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate.Syntax {
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
}
