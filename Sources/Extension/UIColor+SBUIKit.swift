//
//  UIColor+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 02/03/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UIColor {
    public static func sbu_from(image: UIImage,
                                imageView: UIImageView? = nil,
                                size: CGFloat,
                                backgroundColor: UIColor) -> UIColor {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size*3, height: size))
        let imageView = imageView ?? UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        imageView.image = image
        imageView.contentMode = .center
        view.addSubview(imageView)
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return .clear }
        
        view.layer.render(in: context)
        let contextImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = contextImage else { return .clear }
        
        return UIColor(patternImage: image)
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}
