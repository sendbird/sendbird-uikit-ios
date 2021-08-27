//
//  UIImage+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 16/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public extension UIImage {
    /// This applies the tint color to the `UIImage`.
    /// - Parameter tintColor: tint color
    /// - Returns: `Uiimage` objects with tint color
    @objc func sbu_with(tintColor: UIColor?) -> UIImage {
        guard let tintColor = tintColor else { return self }
        if #available(iOS 13.0, *) {
            return withTintColor(tintColor)
        } else {
            let image = self
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            tintColor.setFill()
            let context = UIGraphicsGetCurrentContext()
            context?.translateBy(x: 0, y: image.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.setBlendMode(CGBlendMode.normal)
            let rect = CGRect(
                origin: .zero,
                size: CGSize(width: image.size.width, height: image.size.height)
            )
            context?.clip(to: rect, mask: image.cgImage!)
            context?.fill(rect)
            
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
                return self
            }
            
            UIGraphicsEndImageContext()
            
            return newImage
        }
    }
}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage()}
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }
    
    func resize(with targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scale = max(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
    
    func isAnimatedImage() -> Bool {
        return self.images?.count ?? 0 > 1
    }

    func fixedOrientation() -> UIImage {
        switch self.imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            self.draw(in: rect)

            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
            return normalizedImage
        }
    }
    
    func withBackground(color: UIColor, margin: CGFloat, circle: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        guard let context = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let backgroundRect = CGRect(origin: .zero, size: size)
        context.setFillColor(color.cgColor)

        if circle {
            let radiusSize = min(size.width, size.height)
            let clipPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: radiusSize/2).cgPath
            context.addPath(clipPath)
            context.closePath()
            context.fillPath()
        } else {
            context.fill(backgroundRect)
        }
        context.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))

        let imageRect = CGRect(
            origin: .init(x: margin, y: margin),
            size: .init(width: self.size.width - margin*2, height: self.size.height - margin*2)
        )
        context.draw(image, in: imageRect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    class func createImage(from data: Data) -> UIImage? {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           CGImageSourceGetCount(source) > 1 {
            // Animated image
            return UIImage.animatedImageWithSource(source)
        } else {
            // Singe image
            return UIImage(data: data)
        }
    }
    
    // MARK: - GIF image handling (figuring out gif delays)
    /// Note: https://github.com/kiritmodi2702/GIF-Swift/blob/master/GIF-Swift/iOSDevCenters%2BGIF.swift
    
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.0
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as? Double ?? 0
        
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
}
