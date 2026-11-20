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
              let pixelSize = self.orientedPixelSize(source: source) else {
            return nil
        }
        let (width, height) = pixelSize
        let ratio = min(1, Double(size.width * scale) / width, Double(size.height * scale) / height)
        return max(1, (max(width, height) * ratio).rounded(.down))
    }
    
    /// 방향을 적용한(보이는) `index` 프레임의 pixel 너비와 높이. 썸네일은 방향을 적용해 만들므로 크기 계산도 같은 기준이어야 한다.
    private static func orientedPixelSize(source: CGImageSource, at index: Int = 0) -> (width: Double, height: Double)? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.doubleValue,
              let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.doubleValue,
              width > 0, height > 0 else {
            return nil
        }
        // EXIF 방향 5~8 은 90도 회전이라 보이는 너비와 높이가 바뀐다.
        if let orientation = (properties[kCGImagePropertyOrientation] as? NSNumber)?.intValue, (5...8).contains(orientation) {
            return (height, width)
        }
        return (width, height)
    }
    
    /// `size`(point) 를 aspect fill 로 채우는 셀에 넣을 첫 프레임 한 장.
    ///
    /// 원본이 셀보다 크면 셀을 덮을 만큼만 줄여 디코드한다. 원본 크기 이미지를 셀에 넣으면 그릴 때 원본 크기로 풀리고,
    /// GIF 는 모든 프레임을 만든다. 줄일 필요가 없으면 첫 프레임을 원본 크기로 쓴다.
    static func firstFrame(data: Data, filling size: CGSize, scale: CGFloat) -> UIImage? {
        let scale = scale > 0 ? scale : 1
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return UIImage(data: data)
        }
        let count = CGImageSourceGetCount(source)
        // 처음 쓸 수 있는 프레임을 찾고 그 프레임 크기로 줄일지 정한다. 손상돼 디코드되지 않는 프레임은 `createImage(from:)` 처럼 건너뛴다.
        // 크기 메타데이터가 손상돼도 「줄일 필요 없음」으로 보지 않고 프레임 실제 크기로 정한다(원본 크기로 넣지 않게).
        for index in 0..<count {
            // lazy 프레임이라 만들어도 픽셀은 풀지 않는다.
            guard let frame = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            let pixelSize = self.orientedPixelSize(source: source, at: index)
                ?? (width: Double(frame.width), height: Double(frame.height))
            guard let maxPixelSize = self.fillingMaxPixelSize(pixelSize: pixelSize, size: size, scale: scale) else {
                // 줄일 필요가 없다. 한 장짜리는 `UIImage(data:)` 그대로, GIF 는 `createImage(from:)` 처럼 모든 프레임을 만들지 않고 이 프레임 하나만.
                return count > 1 ? UIImage(cgImage: frame) : UIImage(data: data)
            }
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
            ]
            if let cgImage = CGImageSourceCreateThumbnailAtIndex(source, index, options as CFDictionary) {
                return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
            }
        }
        return count == 0 ? UIImage(data: data) : nil
    }
    
    /// 방향을 적용한 `pixelSize` 프레임이 `size` 를 덮는 데 필요한 긴 변의 pixel 수. 원본이 이미 그보다 작거나 `size` 가 잘못되면 nil.
    private static func fillingMaxPixelSize(pixelSize: (width: Double, height: Double), size: CGSize, scale: CGFloat) -> CGFloat? {
        guard size.width > 0, size.height > 0, size.width.isFinite, size.height.isFinite,
              pixelSize.width > 0, pixelSize.height > 0 else {
            return nil
        }
        let (width, height) = pixelSize
        let ratio = max(Double(size.width * scale) / width, Double(size.height * scale) / height)
        guard ratio < 1 else { return nil }
        return max(1, (max(width, height) * ratio).rounded(.up))
    }
    
    /// - Parameter reusedFrame: 이미 만든 프레임(`firstFrameOfOversizedAnimation(data:)`). 그 자리 프레임을 다시 디코드하지 않고 같은 비트맵을 쓴다.
    class func createImage(from data: Data, reusedFrame: (index: Int, image: CGImage)? = nil) -> UIImage? {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           CGImageSourceGetCount(source) > 1 {
            // Animated image
            return UIImage.animatedImageWithSource(source, reusedFrame: reusedFrame)
        } else {
            // Singe image
            return UIImage(data: data)
        }
    }
    
    /// `createImage(from:)` 와 같지만 상한을 넘어도 프레임을 줄여 디코드하지 않고 develop 처럼 원본 크기 lazy 프레임으로 만든다(만들기가 짧다).
    /// 이미지 소스는 한 번만 만들어 상한 판정과 만들기에 같이 쓴다.
    /// - Returns: 만든 이미지와, `createImage(from:)` 라면 만들 때 모든 프레임을 디코드했을지(프레임 비트맵 합이 상한을 넘음).
    class func createImageKeepingLazyFrames(from data: Data) -> (image: UIImage, exceedsBudget: Bool)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetCount(source) > 1 else {
            return UIImage(data: data).map { ($0, false) }
        }
        let result = UIImage.makeAnimatedImage(source: source, reusedFrame: nil, keepsLazyFrames: true)
        return result.image.map { ($0, result.exceedsBudget) }
    }
}

private var isFromOversizedGIFKey: UInt8 = 0

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
    
    /// 원본 GIF 를 풀 때 프레임 비트맵 합의 상한(byte).
    static let animatedImageBitmapBudget = 50 * 1024 * 1024
    
    /// 프레임 비트맵 합이 상한을 넘는 GIF 로 만든 이미지인지. 모든 프레임을 썸네일로 만든 애니메이션과,
    /// 그것을 main 밖에서 만드는 동안 먼저 넣는 첫 프레임(`firstFrameOfOversizedAnimation(data:)`)이 그렇다.
    var isFromOversizedGIF: Bool {
        get { (objc_getAssociatedObject(self, &isFromOversizedGIFKey) as? Bool) ?? false }
        set {
            objc_setAssociatedObject(self, &isFromOversizedGIFKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// `createImage(from:)` 가 만들 때 모든 프레임을 디코드하는지. 프레임 비트맵 합이 상한을 넘는 여러 프레임 이미지가 그렇다.
    /// 상한 안이면 lazy 프레임이라 만들기가 짧다. 크기는 `animatedImageWithSource` 처럼 처음 디코드되는 프레임의 실제 크기로 본다.
    /// lazy 프레임을 만들 뿐 픽셀은 풀지 않는다.
    class func decodesAllFramesOnCreate(data: Data) -> Bool {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return false }
        let count = CGImageSourceGetCount(source)
        guard count > 1 else { return false }
        for index in 0..<count {
            guard let frame = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            return self.frameThumbnailMaxPixelSize(
                frameWidth: frame.width,
                frameHeight: frame.height,
                frameCount: count
            ) != nil
        }
        return false
    }

    /// 프레임 비트맵 합이 상한을 넘어 `createImage(from:)` 가 만들 때 모든 프레임을 디코드하는 GIF 면, 그 애니메이션의 첫 프레임과
    /// 같은 이미지 한 장(pixel 크기, scale, point 크기가 같음)과 그 프레임 번호. 모든 프레임을 main 밖에서 만드는 동안 먼저 넣고,
    /// 모든 프레임을 만들 때 그 자리에 같은 비트맵을 쓴다(`createImage(from:reusedFrame:)`).
    /// 프레임 하나만 썸네일로 디코드한다. 상한 안이거나 여러 프레임 이미지가 아니면 nil.
    class func firstFrameOfOversizedAnimation(data: Data) -> (image: UIImage, index: Int)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        guard count > 1 else { return nil }
        // `animatedImageWithSource` 처럼 처음 디코드되는 lazy 프레임의 실제 크기로 줄일 크기를 정하고, 그 프레임부터 썸네일을 만든다.
        guard let (firstIndex, frame) = (0..<count).lazy
            .compactMap({ index in CGImageSourceCreateImageAtIndex(source, index, nil).map { (index, $0) } })
            .first,
              let maxPixelSize = self.frameThumbnailMaxPixelSize(
                frameWidth: frame.width,
                frameHeight: frame.height,
                frameCount: count
              ) else {
            return nil
        }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary
        let originalLongSide = CGFloat(max(frame.width, frame.height))
        for index in firstIndex..<count {
            guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, index, options) else { continue }
            let scale = CGFloat(max(thumbnail.width, thumbnail.height)) / originalLongSide
            let image = UIImage(cgImage: thumbnail, scale: scale, orientation: .up)
            image.isFromOversizedGIF = true
            return (image, index)
        }
        return nil
    }

    internal class func animatedImageWithSource(
        _ source: CGImageSource,
        reusedFrame: (index: Int, image: CGImage)? = nil
    ) -> UIImage? {
        self.makeAnimatedImage(source: source, reusedFrame: reusedFrame, keepsLazyFrames: false).image
    }
    
    /// - Parameter keepsLazyFrames: `true` 면 상한을 넘어도 프레임을 줄여 디코드하지 않고 원본 크기 lazy 프레임으로 둔다.
    /// - Returns: 애니메이션과, 프레임 비트맵 합이 상한을 넘는지.
    private class func makeAnimatedImage(
        source: CGImageSource,
        reusedFrame: (index: Int, image: CGImage)?,
        keepsLazyFrames: Bool
    ) -> (image: UIImage?, exceedsBudget: Bool) {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // 큰 GIF 를 모든 프레임 원본 크기로 풀면 화면에 그릴 때 프레임 수만큼 큰 비트맵이 생겨 메모리 부족으로 종료될 수 있다.
        // 프레임 비트맵 합이 상한을 넘으면 프레임마다 줄여 디코드한 썸네일을 쓰고, point 크기는 scale 로 원본과 같게 둔다.
        // 상한 안이면 지금처럼 lazy 프레임을 그대로 쓴다.
        // 크기는 처음 디코드한 프레임의 실제 크기로 정한다. 0번 프레임 메타데이터가 손상돼도 상한이 빠지지 않는다.
        var thumbnailOptions: CFDictionary?
        var originalLongSide: CGFloat?
        var isSizeDecided = false
        var exceedsBudget = false
        
        // 손상된 GIF 는 일부 프레임만 디코드에 실패할 수 있다. 프레임과 지연을 같이 모아야
        // 두 배열 길이가 어긋나 images[i] 가 범위를 넘는 일이 없다.
        (0..<count).forEach { index in
            let decoded: CGImage? = autoreleasepool {
                guard let frame = CGImageSourceCreateImageAtIndex(source, index, nil) else { return nil }
                if !isSizeDecided {
                    isSizeDecided = true
                    if let maxPixelSize = UIImage.frameThumbnailMaxPixelSize(
                        frameWidth: frame.width,
                        frameHeight: frame.height,
                        frameCount: count
                    ) {
                        exceedsBudget = true
                        guard !keepsLazyFrames else { return frame }
                        originalLongSide = CGFloat(max(frame.width, frame.height))
                        thumbnailOptions = [
                            kCGImageSourceCreateThumbnailFromImageAlways: true,
                            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
                        ] as CFDictionary
                    }
                }
                guard let thumbnailOptions = thumbnailOptions else { return frame }
                // 먼저 넣은 첫 프레임과 같은 옵션으로 만든 썸네일이라, 다시 디코드하지 않고 그 비트맵을 같이 쓴다(첫 프레임과 GIF 가 같이 있어도 한 장).
                if let reusedFrame = reusedFrame, reusedFrame.index == index { return reusedFrame.image }
                // CGContext 에 다시 그린 비트맵을 들면 화면에 그릴 때 표시용 사본이 하나 더 생겨, 원본 lazy 프레임보다 메모리가 더 든다.
                // 썸네일은 화면에 그대로 쓰여 사본이 생기지 않았다(시뮬레이터 측정). 줄이지 못한 프레임은 원본 크기로 섞지 않고 디코드 실패처럼 뺀다.
                return CGImageSourceCreateThumbnailAtIndex(source, index, thumbnailOptions)
            }
            guard let image = decoded else { return }
            let delaySeconds = UIImage.delayForImageAtIndex(index, source: source)
            
            images.append(image)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        guard images.isEmpty == false else { return (nil, exceedsBudget) }
        
        let duration = delays.reduce(0, +)
        
        let gcd = gcdForArray(delays)
        
        var frames: [UIImage] = []
        zip(images, delays).forEach { image, delay in
            // 썸네일은 긴 변 기준으로 줄었으므로 그 비율을 scale 로 써서 point 크기를 원본과 같게 둔다.
            let scale = originalLongSide.map { CGFloat(max(image.width, image.height)) / $0 } ?? 1
            let frame = UIImage(cgImage: image, scale: scale, orientation: .up)
            let frameCount = gcd == 0 ? 0 : Int(delay / gcd)
            frames.append(contentsOf: [UIImage](repeating: frame, count: frameCount))
        }
        
        let animation = UIImage.animatedImage(
            with: frames,
            duration: Double(duration) / 1000.0
        )
        if thumbnailOptions != nil {
            animation?.isFromOversizedGIF = true
        }
        
        return (animation, exceedsBudget)
    }
    
    /// 프레임 비트맵 합이 `animatedImageBitmapBudget` 안에 들어가게 하는 썸네일 긴 변의 pixel 수. 줄일 필요가 없으면 nil.
    /// 프레임은 모두 같은 캔버스 크기로 디코드되므로, 디코드한 프레임 한 장의 크기와 프레임 수로 합을 잡는다.
    private class func frameThumbnailMaxPixelSize(frameWidth: Int, frameHeight: Int, frameCount: Int) -> CGFloat? {
        guard frameWidth > 0, frameHeight > 0, frameCount > 0 else { return nil }
        let width = Double(frameWidth)
        let height = Double(frameHeight)
        let budget = Double(UIImage.animatedImageBitmapBudget)
        // 화면에 그리는 비트맵은 행을 16 byte 단위로 맞춘다. 폭이 좁은 GIF 는 이 여분이 커서 같이 센다.
        func totalBytes(width: Double, height: Double) -> Double {
            (width * 4 / 16).rounded(.up) * 16 * height * Double(frameCount)
        }
        let originalBytes = totalBytes(width: width, height: height)
        guard originalBytes > budget else { return nil }
        let longSide = max(width, height)
        var maxPixelSize = (longSide * (budget / originalBytes).squareRoot()).rounded(.down)
        // 행 여분 때문에 아직 넘으면 넘지 않을 때까지 줄인다.
        while maxPixelSize > 1 {
            let ratio = maxPixelSize / longSide
            if totalBytes(width: (width * ratio).rounded(.up), height: (height * ratio).rounded(.up)) <= budget { break }
            maxPixelSize = (maxPixelSize * 0.95).rounded(.down)
        }
        return CGFloat(max(1, maxPixelSize))
    }
}
// swiftlint:enable identifier_name

extension UIImage {
    /// test downloader 
    static var sbu_imageDownloader = SBUImageDownloader()
}

/// image downloader
class SBUImageDownloader {
    /// 이 downloader 의 요청이 모두 쓰는 세션입니다. 주입받은 세션도 invalidate 하지 않습니다.
    let session: URLSession

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

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
        self.session.dataTask(with: url) { data, _, error in
            // 이미지 디코딩이 공유 세션의 직렬 콜백 큐에서 다른 다운로드를 막지 않도록 한다.
            DispatchQueue.global(qos: .userInitiated).async {
                completion(data, error)
            }
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
        self.session.downloadTask(with: url) { location, _, error in
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
            // 영상 프레임 추출이 공유 세션의 직렬 콜백 큐를 막지 않도록 한다.
            DispatchQueue.global(qos: .userInitiated).async {
                completion(fileURL, nil)
            }
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
