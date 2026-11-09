//
//  UIImageView+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/25.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation

public extension UIImageView {
    /// Typealias for load completion
    typealias LoadCompletion = ((LoadResult) -> Void)
    
    /// Enum for ImageOption
    enum ImageOption {
        /// Option for image to thumbnail
        case imageToThumbnail
        /// Option for original image
        case original
        /// Option for video URL to image
        case videoURLToImage
    }
    
    /// Enum for LoadStatus
    enum LoadStatus {
        /// Placeholder status
        case placeholder
        /// Success status
        case success
        /// Success status of loading from cache data
        case successFromCache
        /// Failure status
        case failure
        
        var isSuccess: Bool {
            switch self {
            case .success: return true
            case .successFromCache: return true
            default: return false
            }
        }
        var isFailure: Bool { self == .failure }
        var isPlaceholder: Bool { self == .placeholder }
        var isCached: Bool { self == .successFromCache }
    }
    
    /// Struct for LoadResult
    struct LoadResult {
        let status: LoadStatus
        let urlString: String
        let image: UIImage?
        
        init(
            status: LoadStatus,
            urlString: String,
            image: UIImage? = nil
        ) {
            self.status = status
            self.image = image
            self.urlString = urlString
        }
    }
    
    /// Loads an image from a URL string.
    /// - Returns: A URLSessionTask object.
    @discardableResult
    func loadImage(
        urlString: String,
        placeholder: UIImage? = nil,
        errorImage: UIImage? = nil,
        option: ImageOption = .original,
        thumbnailSize: CGSize? = nil,
        tintColor: UIColor? = nil,
        cacheKey: String? = nil,
        subPath: String = "",
        completion: ((Bool) -> Void)? = nil
    ) -> URLSessionTask? {
        return self.loadImage(
            urlString: urlString,
            placeholder: placeholder,
            errorImage: errorImage,
            option: option,
            thumbnailSize: thumbnailSize,
            tintColor: tintColor,
            cacheKey: cacheKey,
            subPath: subPath,
            autoset: true
        ) { completion?($0.status.isSuccess) }
    }
    
    /// Loads an image from a URL string.
    /// - Returns: A URLSessionTask object.
    @discardableResult
    func loadImage(
        urlString: String,
        placeholder: UIImage? = nil,
        errorImage: UIImage? = nil,
        option: ImageOption = .original,
        thumbnailSize: CGSize? = nil,
        tintColor: UIColor? = nil,
        cacheKey: String? = nil,
        subPath: String = "",
        autoset: Bool = true,
        completion: LoadCompletion? = nil
    ) -> URLSessionTask? {
        let originalContentMode = self.contentMode
        let onCompletion: ((LoadResult) -> Void) = { [weak self, completion, originalContentMode] result in
            Thread.executeOnMain {
                if result.image != nil {
                    if result.status.isSuccess {
                        self?.contentMode = originalContentMode
                    } else {
                        self?.contentMode = .center
                    }
                }
                completion?(result)
            }
        }
        
        // placeholder-image without completion.
        self.setImage(
            placeholder,
            urlString: urlString,
            tintColor: tintColor,
            contentMode: placeholder != nil ? .center : self.contentMode,
            status: .placeholder,
            autoset: autoset
        ) { result in
            if autoset == false { completion?(result) }
        }
        
        // error-image
        if urlString.isEmpty {
            self.setImage(
                errorImage,
                urlString: urlString,
                contentMode: self.contentMode,
                status: .failure,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        
        switch option {
        case .original:
            return self.loadOriginalImage(
                urlString: urlString,
                errorImage: errorImage,
                tintColor: tintColor,
                cacheKey: cacheKey,
                subPath: subPath,
                autoset: autoset,
                completion: onCompletion
            )
        case .imageToThumbnail:
            return self.loadThumbnailImage(
                urlString: urlString,
                errorImage: errorImage,
                thumbnailSize: thumbnailSize,
                tintColor: tintColor,
                cacheKey: cacheKey,
                subPath: subPath,
                autoset: autoset,
                completion: onCompletion
            )
        case .videoURLToImage:
            return self.loadVideoThumbnailImage(
                urlString: urlString,
                errorImage: errorImage,
                tintColor: tintColor,
                cacheKey: cacheKey,
                subPath: subPath,
                autoset: autoset,
                completion: onCompletion
            )
        }
    }
}

internal extension UIImageView {
    // When failed, return error, like failure?(error)
    static let error = NSError(
        domain: SBUConstant.bundleIdentifier,
        code: -1,
        userInfo: nil
    )

    func loadOriginalImage(urlString: String,
                           errorImage: UIImage? = nil,
                           tintColor: UIColor? = nil,
                           cacheKey: String? = nil,
                           subPath: String,
                           autoset: Bool = true,
                           completion: LoadCompletion? = nil) -> URLSessionTask? {
        
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey
        )
        
        if let image = SBUCacheManager.Image.get(fileName: fileName, subPath: subPath) {
            self.setImage(
                image,
                urlString: urlString,
                tintColor: tintColor,
                status: .successFromCache,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        
        return Self.getOriginalImage(
            urlString: urlString,
            cacheKey: cacheKey,
            errorImage: errorImage,
            subPath: subPath) { [weak self] image, success in
                self?.setImage(
                    image,
                    urlString: urlString,
                    tintColor: tintColor,
                    status: success ? .success : .failure,
                    autoset: autoset,
                    completion: completion
                )
        }
    }
    
    func loadVideoThumbnailImage(urlString: String,
                                 errorImage: UIImage? = nil,
                                 tintColor: UIColor? = nil,
                                 cacheKey: String? = nil,
                                 subPath: String,
                                 autoset: Bool = true,
                                 completion: LoadCompletion? = nil) -> URLSessionTask? {
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey,
            needPathExtension: false
        )
        
        if let image = SBUCacheManager.Image.get(fileName: fileName, subPath: subPath) {
            self.setImage(
                image,
                urlString: urlString,
                tintColor: tintColor,
                status: .successFromCache,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        
        guard let url = UIImage.sbu_imageDownloader.url(string: urlString) else {
            self.setImage(
                errorImage,
                urlString: urlString,
                tintColor: tintColor,
                status: .failure,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        // 썸네일 한 장을 위해 영상 전체를 Data 로 받지 않고 파일로 받는다. 프레임을 뽑은 뒤 파일을 지운다.
        let task = UIImage.sbu_imageDownloader.downloadFile(from: url, pathExtension: "mov") { [weak self] fileURL, _ in
            defer { if let fileURL = fileURL { try? FileManager.default.removeItem(at: fileURL) } }
            guard let self = self, let fileURL = fileURL else {
                Thread.executeOnMain {
                    completion?(.init(status: .failure, urlString: urlString))
                }
                return
            }
            
            let avAssetImageGenerator = AVAssetImageGenerator(asset: AVURLAsset(url: fileURL))
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let cmTime = CMTimeMake(value: 2, timescale: 1)
            guard let cgImage = try? avAssetImageGenerator
                .copyCGImage(at: cmTime, actualTime: nil) else {
                Thread.executeOnMain {
                    completion?(.init(status: .failure, urlString: urlString))
                }
                return
            }
            
            let image = UIImage(cgImage: cgImage)
            SBUCacheManager.Image.save(image: image, fileName: fileName, subPath: subPath)
            self.setImage(
                image,
                urlString: urlString,
                tintColor: tintColor,
                status: .success,
                autoset: autoset,
                completion: completion
            )
        }
        
        task?.resume()
        return task
    }
    
    func loadThumbnailImage(urlString: String,
                            errorImage: UIImage? = nil,
                            thumbnailSize: CGSize? = SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize,
                            tintColor: UIColor? = nil,
                            cacheKey: String? = nil,
                            subPath: String,
                            autoset: Bool = true,
                            completion: LoadCompletion? = nil) -> URLSessionTask? {
        
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey
        )
        let thumbnailFileName = "thumb_" + fileName
        let thumbnailSize: CGSize = thumbnailSize ?? SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize
        // 정적 이미지의 `resize(with:)` 와 같은 scale 로 맞춘다.
        let displayScale = UIGraphicsImageRendererFormat.default().scale
        
        // Load thumbnail cacheImage
        if let thumbnailImage = SBUCacheManager.Image.getThumbnail(
            fileName: thumbnailFileName,
            subPath: subPath,
            fitting: thumbnailSize,
            scale: displayScale
        ) {
            let image = thumbnailImage.isAnimatedImage() ? thumbnailImage.images?.first : thumbnailImage
            self.setImage(
                image,
                urlString: urlString,
                tintColor: tintColor,
                status: .successFromCache,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        
        // Load or Download image
        guard let url = UIImage.sbu_imageDownloader.url(string: urlString) else {
            self.setImage(
                errorImage,
                urlString: urlString,
                tintColor: tintColor,
                status: .failure,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        
        let task = UIImage.sbu_imageDownloader.downloadImage(from: url) { [weak self] data, error in
            guard let self = self else { return }
            let failure = {
                self.setImage(
                    errorImage,
                    urlString: urlString,
                    tintColor: tintColor,
                    status: .failure,
                    autoset: autoset,
                    completion: completion
                )
            }
            guard let data = data, error == nil else {
                failure()
                return
            }
            
            // 썸네일은 GIF 의 첫 프레임만 보여 주므로, 전체 animation 을 만들지 않고 첫 프레임만 표시 크기로
            // 디코드해 정적 이미지로 저장한다.
            if let source = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(source) > 1 {
                guard let firstFrame = UIImage.firstFrameThumbnail(
                    source: source,
                    fitting: thumbnailSize,
                    scale: displayScale
                ) else {
                    failure()
                    return
                }
                SBUCacheManager.Image.save(
                    image: firstFrame,
                    fileName: thumbnailFileName,
                    subPath: subPath,
                    preservesTransparency: true
                )
                self.setImage(
                    firstFrame,
                    urlString: urlString,
                    tintColor: tintColor,
                    status: .success,
                    autoset: autoset,
                    completion: completion
                )
            } else {
                guard let image = UIImage(data: data) else {
                    failure()
                    return
                }
                let thumbnailImage = image.resize(with: thumbnailSize)
                SBUCacheManager.Image.save(image: thumbnailImage, fileName: thumbnailFileName, subPath: subPath)
                self.setImage(
                    thumbnailImage,
                    urlString: urlString,
                    tintColor: tintColor,
                    status: .success,
                    autoset: autoset,
                    completion: completion
                )
            }
        }
        task?.resume()
        return task
    }
    
    private func setImage(_ image: UIImage?,
                          urlString: String,
                          tintColor: UIColor? = nil,
                          contentMode: ContentMode = .scaleAspectFill,
                          status: LoadStatus = .success,
                          autoset: Bool,
                          completion: LoadCompletion? = nil) {
        guard let image = image else {
            if status != .placeholder {
                Thread.executeOnMain {
                    completion?(.init(status: .failure, urlString: urlString))
                }
            }
            return
        }
        
        let resultImage = tintColor != nil ? image.sbu_with(tintColor: tintColor!) : image
        
        Thread.executeOnMain { [weak self] in
            self?.contentMode = contentMode
            if autoset == true {
                self?.image = resultImage
            }
            completion?(.init(status: status, urlString: urlString, image: resultImage))
        }
    }
}

internal extension UIImageView {
    /// Downloads an image from the network.
    /// - Parameters:
    ///   - urlString: The URL string of the image.
    ///   - errorImage: The error image that will be returned when the image downloading is failed.
    ///   - subPath: The subpath to store the image into the cache.
    ///   - completion: The callback to return the result.
    /// - Returns: The URLSessionTask object for downloading the image.
    @discardableResult
    static func getOriginalImage(
        urlString: String,
        cacheKey: String? = nil,
        errorImage: UIImage? = nil,
        subPath: String,
        completion: ((UIImage?, Bool) -> Void)? = nil
    ) -> URLSessionTask? {
        
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey
        )
        
        guard let url = UIImage.sbu_imageDownloader.url(string: urlString), url.absoluteURL.host != nil else {
            Thread.executeOnMain {
                completion?(errorImage, false)
            }
            return nil
        }
        
        let task = UIImage.sbu_imageDownloader.downloadImage(from: url) { data, error in
            guard let data = data, error == nil else {
                completion?(errorImage, false)
                return
            }
            
            let image = SBUCacheManager.Image.save(
                data: data,
                fileName: fileName,
                subPath: subPath
            )
            
            Thread.executeOnMain {
                completion?(image, image != nil)
            }
        }
        task?.resume()
        
        return task
    }
}
