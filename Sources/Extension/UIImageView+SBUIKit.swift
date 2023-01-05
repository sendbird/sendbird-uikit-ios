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
                   cacheKey: String? = nil,
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
            self.setImage(placeholder, contentMode: .center)
        } else {
            self.setImage(nil, contentMode: self.contentMode)
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
                cacheKey: cacheKey,
                completion: onCompletion
            )
        case .imageToThumbnail:
            return self.loadThumbnailImage(
                urlString: urlString,
                errorImage: errorImage,
                thumbnailSize: thumbnailSize,
                cacheKey: cacheKey,
                completion: onCompletion
            )
        case .videoURLToImage:
            return self.loadVideoThumbnailImage(
                urlString: urlString,
                errorImage: errorImage,
                cacheKey: cacheKey,
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
                           cacheKey: String? = nil,
                           completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        var fileName = SBUCacheManager.createHashName(urlString: urlString)
        if let cacheKey = cacheKey {
            SBUCacheManager.renameIfNeeded(key: fileName, newKey: cacheKey)
            fileName = cacheKey
        }
        
        if let image = SBUCacheManager.getImage(fileName: fileName) {
            self.setImage(image, completion: completion)
            return nil
        }
        
        guard let url = URL(string: urlString), url.absoluteURL.host != nil else {
            self.setImage(errorImage) { _ in
                completion?(false)
            }
            return nil
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {
                completion?(false)
                return
            }
            
            guard let data = data, error == nil else {
                self.setImage(errorImage) { _ in
                    completion?(false)
                }
                return
            }
            
            let image = SBUCacheManager.savedImage(fileName: fileName, data: data)
            self.setImage(image, completion: completion)
        }
        task.resume()
        return task
    }
    
    func loadVideoThumbnailImage(urlString: String,
                                 errorImage: UIImage? = nil,
                                 cacheKey: String? = nil,
                                 completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        var fileName = SBUCacheManager.createHashName(urlString: urlString)
        if let cacheKey = cacheKey {
            SBUCacheManager.renameIfNeeded(key: fileName, newKey: cacheKey)
            fileName = cacheKey
        }
        
        if let image = SBUCacheManager.getImage(fileName: fileName) {
            self.setImage(image, completion: completion)
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            self.setImage(errorImage) { _ in
                completion?(false)
            }
            return nil
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, response, error in
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
            if let data = image.pngData() {
                SBUCacheManager.savedImage(fileName: fileName, data: data)
            }
            self.setImage(image, completion: completion)
        }
        
        task.resume()
        return task
    }
    
    
    func loadThumbnailImage(urlString: String,
                            errorImage: UIImage? = nil,
                            thumbnailSize: CGSize? = SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize,
                            cacheKey: String? = nil,
                            completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        var fileName = SBUCacheManager.createHashName(urlString: urlString)
        if let cacheKey = cacheKey {
            SBUCacheManager.renameIfNeeded(key: fileName, newKey: cacheKey)
            fileName = cacheKey
        }
        let thumbnailFileName = "thumb_" + fileName
        
        // Load thumbnail cacheImage
        if let thumbnailImage = SBUCacheManager.getImage(fileName: thumbnailFileName) {
            let image = thumbnailImage.isAnimatedImage() ? thumbnailImage.images?.first : thumbnailImage
            self.setImage(image, completion: completion)
            return nil
        }
        
        // Load or Download image
        guard let url = URL(string: urlString) else {
            self.setImage(errorImage) { _ in
                completion?(false)
            }
            return nil
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, error == nil, let image = UIImage.createImage(from: data) else {
                self.setImage(errorImage) { _ in completion?(false) }
                return
            }
            
            if image.isAnimatedImage() {
                SBUCacheManager.savedImage(fileName: fileName, data: data)
                SBUCacheManager.savedImage(fileName: thumbnailFileName, data: data)
                
                self.setImage(image.images?.first ?? image, completion: completion)
            } else {
                let thumbnailSize: CGSize = thumbnailSize ?? SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize
                let thumbnailImage = image.resize(with: thumbnailSize)
                SBUCacheManager.savedImage(fileName: fileName, image: image)
                SBUCacheManager.savedImage(fileName: thumbnailFileName, image: thumbnailImage)
                
                self.setImage(thumbnailImage, completion: completion)
            }
        }
        task.resume()
        return task
    }
    
    private func setImage(_ image: UIImage?, contentMode: ContentMode = .scaleAspectFill, completion: ((Bool) -> Void)? = nil) {
        if let image = image {
            if Thread.isMainThread {
                self.contentMode = contentMode
                self.image = image
            } else {
                DispatchQueue.main.async {
                    self.contentMode = contentMode
                    self.image = image
                }
            }
        }
        completion?(image != nil)
    }
}
