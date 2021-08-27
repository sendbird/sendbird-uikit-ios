//
//  UIImageView+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/25.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation

internal extension UIImageView {
    enum ImageOption {
        case imageToThumbnail
        case original
        case videoUrlToImage
    }

    @discardableResult
    func loadImage(urlString: String,
                   placeholder: UIImage? = nil,
                   errorImage: UIImage? = nil,
                   option: ImageOption = .original,
                   thumbnailSize: CGSize? = SBUConstant.thumbnailSize,
                   completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        self.image = placeholder
        
        if urlString.isEmpty {
            if let errorImage = errorImage {
                self.image = errorImage
            }
            return nil
        }
        
        switch option {
        case .original:
            return self.loadOriginalImage(
                urlString: urlString,
                errorImage: errorImage,
                completion: completion
            )
        case .imageToThumbnail:
            return self.loadThumbnailImage(
                urlString: urlString,
                errorImage: errorImage,
                thumbnailSize: thumbnailSize,
                completion: completion
            )
        case .videoUrlToImage:
            return self.loadVideoThumbnailImage(
                urlString: urlString,
                errorImage: errorImage,
                completion: completion
            )
        }
    }
}

internal extension UIImageView {
    // When failed, return error, like failure?(error)
    static let error = NSError(domain:"com.sendbird.uikit", code: -1, userInfo: nil)

    func createFileName(urlString: String) -> String {
        let filename = "\(urlString.persistantHash)"
        return filename
    }
    
    func loadOriginalImage(urlString: String,
                           errorImage: UIImage? = nil,
                           completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        let fileName = self.createFileName(urlString: urlString)
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
                DispatchQueue.main.async {
                    self.setImage(errorImage) { _ in
                        completion?(false)
                    }
                }
                return
            }
            
            let image = SBUCacheManager.savedImage(fileName: fileName, data: data)
            DispatchQueue.main.async {
                self.setImage(image, completion: completion)
            }
        }
        task.resume()
        return task
    }
    
    func loadVideoThumbnailImage(urlString: String,
                                 errorImage: UIImage? = nil,
                                 completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        let fileName = self.createFileName(urlString: urlString)
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
            DispatchQueue.main.async {
                if let data = image.pngData() {
                    SBUCacheManager.savedImage(fileName: fileName, data: data)
                }
                self.setImage(image, completion: completion)
            }
        }
        
        task.resume()
        return task
    }
    
    
    func loadThumbnailImage(urlString: String,
                            errorImage: UIImage? = nil,
                            thumbnailSize: CGSize? = SBUConstant.thumbnailSize,
                            completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        let fileName = self.createFileName(urlString: urlString)
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
                DispatchQueue.main.async {
                    self.setImage(errorImage) { _ in completion?(false) }
                }
                return
            }
            
            if image.isAnimatedImage() {
                SBUCacheManager.savedImage(fileName: fileName, data: data)
                SBUCacheManager.savedImage(fileName: thumbnailFileName, data: data)
                
                DispatchQueue.main.async {
                    self.setImage(image.images?.first ?? image, completion: completion)
                }
            } else {
                let thumbnailSize: CGSize = thumbnailSize ?? SBUConstant.thumbnailSize
                let thumbnailImage = image.resize(with: thumbnailSize)
                SBUCacheManager.savedImage(fileName: fileName, image: image)
                SBUCacheManager.savedImage(fileName: thumbnailFileName, image: thumbnailImage)
                
                DispatchQueue.main.async {
                    self.setImage(thumbnailImage, completion: completion)
                }
            }
        }
        task.resume()
        return task
    }

    private func setImage(_ image: UIImage?, completion: ((Bool) -> Void)? = nil) {
        if let image = image {
            self.image = image
        }
        completion?(image != nil)
    }
}
