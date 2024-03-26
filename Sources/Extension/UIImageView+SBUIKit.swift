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
        /// Failure status
        case failure
        
        var isSuccess: Bool { self == .success }
        var isFailure: Bool { self == .failure }
        var isPlaceholder: Bool { self == .placeholder }
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
    func loadImage(urlString: String,
                   placeholder: UIImage? = nil,
                   errorImage: UIImage? = nil,
                   option: ImageOption = .original,
                   thumbnailSize: CGSize? = nil,
                   tintColor: UIColor? = nil,
                   cacheKey: String? = nil,
                   subPath: String = "",
                   autoset: Bool = true,
                   completion: LoadCompletion? = nil) -> URLSessionTask? {
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
                status: .success,
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
                status: .success,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        
        guard let url = URL(string: urlString) else {
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
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let asset = data?.getAVAsset() else {
                Thread.executeOnMain {
                    completion?(.init(status: .failure, urlString: urlString))
                }
                return
            }
            
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
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
        
        task.resume()
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
        
        // Load thumbnail cacheImage
        if let thumbnailImage = SBUCacheManager.Image.get(fileName: thumbnailFileName, subPath: subPath) {
            let image = thumbnailImage.isAnimatedImage() ? thumbnailImage.images?.first : thumbnailImage
            self.setImage(
                image,
                urlString: urlString,
                tintColor: tintColor,
                status: .success,
                autoset: autoset,
                completion: completion
            )
            return nil
        }
        
        // Load or Download image
        guard let url = URL(string: urlString) else {
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
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil, let image = UIImage.createImage(from: data) else {
                self.setImage(
                    errorImage,
                    urlString: urlString,
                    tintColor: tintColor,
                    status: .failure,
                    autoset: autoset,
                    completion: completion
                )
                return
            }
            
            if image.isAnimatedImage() {
                SBUCacheManager.Image.save(data: data, fileName: thumbnailFileName, subPath: subPath)
                self.setImage(
                    image.images?.first ?? image,
                    urlString: urlString,
                    tintColor: tintColor,
                    status: .success,
                    autoset: autoset,
                    completion: completion
                )
            } else {
                let thumbnailSize: CGSize = thumbnailSize ?? SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize
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
        task.resume()
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
            Thread.executeOnMain {
                completion?(.init(status: .failure, urlString: urlString))
            }
            return
        }
        
        let resultImage = tintColor != nil ? image.sbu_with(tintColor: tintColor!) : image
        
        Thread.executeOnMain { [weak self] in
            self?.contentMode = contentMode
            if autoset == true { self?.image = resultImage }
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
        
        guard let url = URL(string: urlString), url.absoluteURL.host != nil else {
            Thread.executeOnMain {
                completion?(errorImage, false)
            }
            return nil
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion?(errorImage, false)
                return
            }
            
            _ = SBUCacheManager.Image.save(
                data: data,
                fileName: fileName,
                subPath: subPath
            ) { _, _, image in
                Thread.executeOnMain {
                    completion?(image, image != nil)
                }
            }
        }
        task.resume()
        
        return task
    }
}
