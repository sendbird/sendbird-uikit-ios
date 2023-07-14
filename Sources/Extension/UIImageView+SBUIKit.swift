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
    enum ImageOption {
        case imageToThumbnail
        case original
        case videoURLToImage
    }

    @discardableResult
    func loadImage(urlString: String,
                   placeholder: UIImage? = nil,
                   errorImage: UIImage? = nil,
                   option: ImageOption = .original,
                   thumbnailSize: CGSize? = nil,
                   tintColor: UIColor? = nil,
                   cacheKey: String? = nil,
                   subPath: String = "",
                   completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        let originalContentMode = self.contentMode
        let onCompletion: ((Bool) -> Void) = { [completion, originalContentMode] onSucceed in
            
            if Thread.isMainThread {
                self.contentMode = originalContentMode
            } else {
                DispatchQueue.main.async {
                    self.contentMode = originalContentMode
                }
            }
            
            completion?(onSucceed)
        }
        
        if let placeholder = placeholder {
            self.setImage(placeholder, tintColor: tintColor, contentMode: .center)
        } else {
            self.setImage(nil, tintColor: tintColor, contentMode: self.contentMode)
        }
        
        if urlString.isEmpty {
            if let errorImage = errorImage {
                self.image = errorImage
            }
            onCompletion(false)
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
                completion: onCompletion
            )
        case .videoURLToImage:
            return self.loadVideoThumbnailImage(
                urlString: urlString,
                errorImage: errorImage,
                tintColor: tintColor,
                cacheKey: cacheKey,
                subPath: subPath,
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
                           completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey
        )
        
        if let image = SBUCacheManager.Image.get(fileName: fileName, subPath: subPath) {
            self.setImage(image, tintColor: tintColor, completion: completion)
            return nil
        }
        
        guard let url = URL(string: urlString), url.absoluteURL.host != nil else {
            self.setImage(errorImage, tintColor: tintColor) { _ in
                completion?(false)
            }
            return nil
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else {
                completion?(false)
                return
            }
            
            guard let data = data, error == nil else {
                self.setImage(errorImage, tintColor: tintColor) { _ in
                    completion?(false)
                }
                return
            }
            
            let image = SBUCacheManager.Image.save(data: data, fileName: fileName, subPath: subPath)
            self.setImage(image, tintColor: tintColor, completion: completion)
        }
        task.resume()
        return task
    }
    
    func loadVideoThumbnailImage(urlString: String,
                                 errorImage: UIImage? = nil,
                                 tintColor: UIColor? = nil,
                                 cacheKey: String? = nil,
                                 subPath: String,
                                 completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey,
            needPathExtension: false
        )
        
        if let image = SBUCacheManager.Image.get(fileName: fileName, subPath: subPath) {
            self.setImage(image, tintColor: tintColor, completion: completion)
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            self.setImage(errorImage, tintColor: tintColor) { _ in
                completion?(false)
            }
            return nil
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let asset = data?.getAVAsset() else {
                completion?(false)
                return
            }
            
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let cmTime = CMTimeMake(value: 2, timescale: 1)
            guard let cgImage = try? avAssetImageGenerator
                .copyCGImage(at: cmTime, actualTime: nil) else {
                completion?(false)
                return
            }
            
            let image = UIImage(cgImage: cgImage)
            SBUCacheManager.Image.save(image: image, fileName: fileName, subPath: subPath)
            self.setImage(image, tintColor: tintColor, completion: completion)
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
                            completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey
        )
        let thumbnailFileName = "thumb_" + fileName
        
        // Load thumbnail cacheImage
        if let thumbnailImage = SBUCacheManager.Image.get(fileName: thumbnailFileName, subPath: subPath) {
            let image = thumbnailImage.isAnimatedImage() ? thumbnailImage.images?.first : thumbnailImage
            self.setImage(image, tintColor: tintColor, completion: completion)
            return nil
        }
        
        // Load or Download image
        guard let url = URL(string: urlString) else {
            self.setImage(errorImage, tintColor: tintColor) { _ in
                completion?(false)
            }
            return nil
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil, let image = UIImage.createImage(from: data) else {
                self.setImage(errorImage, tintColor: tintColor) { _ in completion?(false) }
                return
            }
            
            if image.isAnimatedImage() {
                SBUCacheManager.Image.save(data: data, fileName: fileName, subPath: subPath)
                SBUCacheManager.Image.save(data: data, fileName: thumbnailFileName, subPath: subPath)
                
                self.setImage(image.images?.first ?? image, tintColor: tintColor, completion: completion)
            } else {
                let thumbnailSize: CGSize = thumbnailSize ?? SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize
                let thumbnailImage = image.resize(with: thumbnailSize)
                SBUCacheManager.Image.save(image: image, fileName: fileName, subPath: subPath)
                SBUCacheManager.Image.save(image: thumbnailImage, fileName: thumbnailFileName, subPath: subPath)
                
                self.setImage(thumbnailImage, tintColor: tintColor, completion: completion)
            }
        }
        task.resume()
        return task
    }
    
    private func setImage(_ image: UIImage?,
                          tintColor: UIColor? = nil,
                          contentMode: ContentMode = .scaleAspectFill,
                          completion: ((Bool) -> Void)? = nil) {
        if let image = image {
            if Thread.isMainThread {
                self.contentMode = contentMode
                if tintColor != nil {
                    self.image = image.sbu_with(tintColor: tintColor)
                } else {
                    self.image = image
                }
                completion?(true)
            } else {
                DispatchQueue.main.async {
                    self.contentMode = contentMode
                    if tintColor != nil {
                        self.image = image.sbu_with(tintColor: tintColor)
                    } else {
                        self.image = image
                    }
                    completion?(true)
                }
            }
        } else {
            completion?(false)
        }
    }
}
