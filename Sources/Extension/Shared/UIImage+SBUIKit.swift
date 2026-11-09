//
//  UIImage+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 16/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//
// swiftlint:disable identifier_name

import UIKit

// MARK: - Public extension
public extension UIImage {
    /// This applies the tint color to the `UIImage`.
    /// - Parameter tintColor: tint color
    /// - Returns: `Uiimage` objects with tint color
    func sbu_with(tintColor: UIColor?) -> UIImage {
        guard let tintColor = tintColor else { return self }
        return withTintColor(tintColor)
    }
    
    /// This applies the tint color to the `UIImage` with `forTemplate` option.
    /// - Parameters:
    ///   - tintColor: tint color
    ///   - forTemplate: If this option is `true`, the Blend mode of tint color will be applied to `sourceAtop` after `colorBurn`.
    /// - Returns: `UIImage` objects with tint color
    /// - Since: 3.5.4
    func sbu_with(tintColor: UIColor?, forTemplate: Bool) -> UIImage {
        if !forTemplate {
            return self.sbu_with(tintColor: tintColor)
        }
        
        guard let tintColor = tintColor else { return self }
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        if let context = UIGraphicsGetCurrentContext() {
            tintColor.setFill()
            
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            context.setBlendMode(CGBlendMode.colorBurn)
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            if let cgImage = self.cgImage {
                context.draw(cgImage, in: rect)
                
                context.setBlendMode(CGBlendMode.sourceAtop)
                context.addRect(rect)
                context.drawPath(using: CGPathDrawingMode.fill)
                
                if let coloredImage = UIGraphicsGetImageFromCurrentImageContext() {
                    return coloredImage
                }
            }
        }
        return self
    }
    
    /// Converts image to data.
    ///
    /// - Note: If the `SBUGlobals.isImageCompressionEnabled` is `true`, the image will be resized with `SBUGlobals.imageResizingSize` and compressed with `SBUGlobals.imageCompressionRate`.
    /// - Returns: Image Data
    ///
    /// - Since: 3.3.1
    func sbu_convertToData() -> Data? {
        var image = self
        if SBUGlobals.isImageCompressionEnabled {
            image = self.resize(with: SBUGlobals.imageResizingSize)
        }
        
        let data = image.jpegData(
            compressionQuality: SBUGlobals.imageCompressionQuality
        )
        
        if data == nil {
            Log.error("No image data")
        }
        
        return data
    }
    
    /// Resizes the image to the target size.
    /// - Since: 3.22.0
    func sbu_resize(with targetSize: CGSize) -> UIImage {
        self.resize(with: targetSize)
    }
    
    /// Creates an image with a background color, optional margin, and circular clipping.
    ///
    /// This method draws the current image onto a background of the specified color. If `circle` is true, the image will be clipped to a circular shape. A margin can be added around the image.
    ///
    /// - Parameters:
    ///   - color: The background color.
    ///   - margin: The margin around the image. Defaults to 0 if not specified.
    ///   - circle: A Boolean value that determines whether the image should be clipped to a circle. Defaults to false.
    /// - Returns: A new image with the background color, optional margin, and circular clipping if specified.
    ///
    /// - Since: 3.22.0
    func sbu_withBackground(color: UIColor, margin: CGFloat, circle: Bool = false) -> UIImage {
        self.withBackground(color: color, margin: margin, circle: circle)
    }

    /// Creates an image entirely filled with the specified color.
    ///
    /// This method generates a 1x1 pixel image and scales it to fill the entire view, effectively creating a solid color image. This can be useful for creating placeholder images, backgrounds, or any other elements where a solid color image is required.
    ///
    /// - Parameter color: The color to fill the image with.
    /// - Returns: A `UIImage` object filled with the specified color.
    ///
    /// - Since: 3.22.0
    static func sbu_from(color: UIColor) -> UIImage {
        UIImage.from(color: color)
    }

    /// Adds a circular background around the image by extending the canvas size.
    ///
    /// Unlike `sbu_withBackground` which keeps the canvas size and shrinks the icon,
    /// this method EXPANDS the canvas by adding padding around the original image,
    /// keeping the icon at its original size.
    ///
    /// - Parameters:
    ///   - color: The background color for the circular area.
    ///   - padding: The padding to add around all sides of the image. The final image size will be `(originalSize + padding * 2)`.
    /// - Returns: A new image with the circular background added around the original image.
    ///
    /// Example: A 22x22 icon with padding of 3 results in a 28x28 image with:
    /// - A 28pt diameter circle as background
    /// - The original 22x22 icon centered inside
    ///
    /// - Since: 3.34.0
    func sbu_addCircularBackgroundPadding(_ padding: CGFloat, color: UIColor) -> UIImage {
        self.addCircularBackgroundPadding(padding, color: color)
    }
}

// MARK: - Private extension
extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }
    
    func resize(with targetSize: CGSize) -> UIImage {
        let size = self.size
        var scale = 1.0
        
        if size.width <= targetSize.width && size.height <= targetSize.height {
            
        } else if size.width > targetSize.width && size.height <= targetSize.height {
            scale = targetSize.width / size.width
        } else if size.width <= targetSize.width && size.height > targetSize.height {
            scale = targetSize.height / size.height
        } else if size.width > targetSize.width && size.height > targetSize.height {
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            scale = min(widthRatio, heightRatio)
        }
        
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
    
    convenience init(url: URL) {
        self.init()
        DispatchQueue.global().async { [weak self] in
            if self == nil { return }
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self = image as? Self
                    }
                }
            }
        }
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
    
    /// For documentation, see ``sbu_addCircularBackgroundPadding(_:color:)``
    /// 3.34.0
    func addCircularBackgroundPadding(_ padding: CGFloat, color: UIColor) -> UIImage {
        let expandedSize = CGSize(
            width: size.width + padding * 2,
            height: size.height + padding * 2
        )

        UIGraphicsBeginImageContextWithOptions(expandedSize, false, scale)

        guard let context = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
        defer { UIGraphicsEndImageContext() }

        // Draw circular background on the expanded canvas
        let backgroundRect = CGRect(origin: .zero, size: expandedSize)
        context.setFillColor(color.cgColor)

        let radiusSize = min(expandedSize.width, expandedSize.height)
        let clipPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: radiusSize / 2).cgPath
        context.addPath(clipPath)
        context.closePath()
        context.fillPath()

        // Flip the coordinate system for drawing the image
        context.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: expandedSize.height))

        // Draw the original image centered (with padding offset)
        let imageRect = CGRect(
            origin: CGPoint(x: padding, y: padding),
            size: size
        )
        context.draw(image, in: imageRect)

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    /// 여러 프레임 이미지(GIF 등)의 첫 프레임만 `size`(point) 안에 들어가게 디코드한다.
    ///
    /// 썸네일은 첫 프레임만 보여 주므로, 전체 animation 을 원본 크기로 만들면 프레임 수만큼 비트맵이 생긴다.
    /// 원본보다 크게 키우지 않는다. `size` 가 0 이하이면 첫 프레임을 원본 크기로 디코드한다.
    static func firstFrameThumbnail(source: CGImageSource, fitting size: CGSize, scale: CGFloat) -> UIImage? {
        let scale = scale > 0 ? scale : 1
        var options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ]
        if let maxPixelSize = self.maxPixelSize(source: source, fitting: size, scale: scale) {
            options[kCGImageSourceThumbnailMaxPixelSize] = maxPixelSize
        }
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

    /// 너비와 높이가 모두 `size` 안에 들어가는 긴 변의 pixel 수. 썸네일 API 는 긴 변 하나만 받는다.
    private static func maxPixelSize(source: CGImageSource, fitting size: CGSize, scale: CGFloat) -> CGFloat? {
        guard size.width > 0, size.height > 0, size.width.isFinite, size.height.isFinite,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.doubleValue,
              let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.doubleValue,
              width > 0, height > 0 else {
            return nil
        }
        let ratio = min(1, Double(size.width * scale) / width, Double(size.height * scale) / height)
        return max(1, (max(width, height) * ratio).rounded(.down))
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
}

// MARK: - GIF image handling (figuring out gif delays)
/// Note: https://github.com/kiritmodi2702/GIF-Swift/blob/master/GIF-Swift/iOSDevCenters%2BGIF.swift
extension UIImage {
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource?) -> Float {
        guard let source = source else { return 0 }
        guard let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) else { return 0 }
        guard let gifProperties = (cfProperties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary else { return 0 }
         
        var clampedDelayTime = Float.zero
        var unclampedDelayTime = Float.zero
        
        if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
            clampedDelayTime = delayTime.floatValue
        }
        
        if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
            unclampedDelayTime = delayTime.floatValue
        }
        
        return max(clampedDelayTime, unclampedDelayTime)
    }
    
    /// Greatest common divisor
    internal class func gcdForPair(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        
        if a < b { swap(&a, &b) }
        b = b != 0 ? b : 1
        while true {
            guard b != 0 else { return a == 0 ? 1 : a }
            guard a % b > 0 else { return b }
            let temp = a
            a = b
            b = temp % b
        }
    }
    
    internal class func gcdForArray(_ array: [Int]) -> Int {
        guard var gcd = array.first else { return 1 }
        array.forEach { gcd = UIImage.gcdForPair($0, gcd) }
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // 손상된 GIF 는 일부 프레임만 디코드에 실패할 수 있다. 프레임과 지연을 같이 모아야
        // 두 배열 길이가 어긋나 images[i] 가 범위를 넘는 일이 없다.
        (0..<count).forEach {
            guard let image = CGImageSourceCreateImageAtIndex(source, $0, nil) else { return }
            
            let delaySeconds = UIImage.delayForImageAtIndex($0, source: source)
            
            images.append(image)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        guard images.isEmpty == false else { return nil }
        
        let duration = delays.reduce(0, +)
        
        let gcd = gcdForArray(delays)
        
        var frames: [UIImage] = []
        zip(images, delays).forEach { image, delay in
            let frame = UIImage(cgImage: image)
            let frameCount = gcd == 0 ? 0 : Int(delay / gcd)
            frames.append(contentsOf: [UIImage](repeating: frame, count: frameCount))
        }
        
        let animation = UIImage.animatedImage(
            with: frames,
            duration: Double(duration) / 1000.0
        )
        
        return animation
    }
}
// swiftlint:enable identifier_name

extension UIImage {
    /// test downloader 
    static var sbu_imageDownloader = SBUImageDownloader()
}

/// image downloader
class SBUImageDownloader {
    /// string to url.
    func url(string: String) -> URL? {
        URL(string: string)
    }
    
    /// url to image.
    func image(url: URL) -> UIImage? {
        UIImage(url: url)
    }
    
    // download image from url.
    func downloadImage(
        from url: URL,
        completion: @escaping (Data?, Error?) -> Void
    ) -> URLSessionDataTask? {
        URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            completion(data, error)
        }
    }
    
    /// 영상처럼 큰 파일을 메모리에 올리지 않고 임시 파일로 받는다.
    ///
    /// AVFoundation 이 확장자로 형식을 알아보므로 받은 파일을 `pathExtension` 이름으로 옮긴다.
    /// 받은 파일은 부른 쪽이 다 쓴 뒤 지운다. 실패하거나 취소되면 파일 없이 한 번 부른다.
    func downloadFile(
        from url: URL,
        pathExtension: String,
        completion: @escaping (URL?, Error?) -> Void
    ) -> URLSessionTask? {
        URLSession(configuration: .default).downloadTask(with: url) { location, _, error in
            guard let location = location, error == nil else {
                completion(nil, error)
                return
            }
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(pathExtension)
            do {
                try FileManager.default.moveItem(at: location, to: fileURL)
            } catch {
                completion(nil, error)
                return
            }
            completion(fileURL, nil)
        }
    }
}

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
