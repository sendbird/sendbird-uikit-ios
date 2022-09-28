//
//  UITextField+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/30.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UITextField {
    func setPlaceholderColor(_ placeholderColor: UIColor?) {
        guard let placeholderColor = placeholderColor else { return }

        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font
            ].compactMapValues { $0 }
        )
    }
}
