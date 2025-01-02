//
//  UILabel+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 11/21/24.
//

import UIKit

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
        size.width += extra.width
        size.height += extra.height
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
