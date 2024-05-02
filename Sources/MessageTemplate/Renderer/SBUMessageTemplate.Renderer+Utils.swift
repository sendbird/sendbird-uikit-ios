//
//  SBUMessageTemplate.Renderer+Utils.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

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
