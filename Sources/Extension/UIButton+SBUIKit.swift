//
//  UIButton+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/23.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

import AVFoundation

public extension UIButton {
    /// Loads an image from a given URL string.
    /// - Parameters:
    ///   - urlString: The URL string where the image is located.
    ///   - placeholder: An optional placeholder image to display while the image is loading.
    ///   - errorImage: An optional image to display if there was an error loading the image.
    ///   - tintColor: An optional tint color to apply to the image.
    ///   - state: The button state that uses the specified image.
    ///   - cacheKey: An optional key used to cache the image.
    ///   - subPath: The subpath of the image.
    ///   - completion: An optional completion handler to call when the load operation is complete.
    /// - Returns: An optional URLSessionTask that you can use to track the progress of the load operation.
    @discardableResult
    func loadImage(
        urlString: String,
        placeholder: UIImage? = nil,
        errorImage: UIImage? = nil,
        tintColor: UIColor? = nil,
        for state: UIButton.State,
        cacheKey: String? = nil,
        subPath: String,
        completion: ((Bool) -> Void)? = nil
    ) -> URLSessionTask? {
        self.setImage(placeholder, tintColor: tintColor, for: .normal, completion: nil)
        
        if urlString.isEmpty {
            if let errorImage = errorImage {
                self.setImage(errorImage, tintColor: tintColor, for: .normal, completion: nil)
            }
            return nil
        }
        
        return self.loadOriginalImage(
            urlString: urlString,
            errorImage: errorImage,
            for: state,
            tintColor: tintColor,
            cacheKey: cacheKey,
            subPath: subPath,
            completion: completion
        )
    }
}

internal extension UIButton {
    // When failed, return error, like failure?(error)
    static let error = NSError(
        domain: SBUConstant.bundleIdentifier,
        code: -1,
        userInfo: nil
    )

    func loadOriginalImage(urlString: String,
                           errorImage: UIImage? = nil,
                           for state: UIButton.State,
                           tintColor: UIColor? = nil,
                           cacheKey: String? = nil,
                           subPath: String,
                           completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        let fileName = SBUCacheManager.Image.createCacheFileName(
            urlString: urlString,
            cacheKey: cacheKey
        )
        
        switch SBUCacheManager.Image.loadCachedImage(fileName: fileName, subPath: subPath) {
        case .image(let image):
            self.setImage(image, tintColor: tintColor, for: state, completion: completion)
            return nil
        case .firstFrame(let firstFrame):
            // 상한을 넘는 GIF 는 모든 프레임을 main 밖에서 만든다. develop 처럼 부른 자리에서 GIF 와 같은 크기의 첫 프레임을 넣고
            // completion 도 지금 부른다.
            let shown = firstFrame.sbu_with(tintColor: tintColor)
            self.setImage(shown, tintColor: nil, for: state, completion: completion)
            // 다 만든 뒤 이 상태가 아직 그 첫 프레임을 보여 줄 때만 GIF 로 바꾼다. 그 사이 `setImage` 로 직접 넣었거나(가로챌 수 없는
            // UIKit 메서드) 다른 요청이 넣은 이미지가 남는다. 첫 프레임은 요청마다 다른 인스턴스라, 이 상태 이미지를 지워 `.normal`
            // 이미지가 보여도 다른 요청의 첫 프레임과 섞이지 않는다.
            SBUCacheManager.Image.whenAllFramesDecoded(for: firstFrame) { [weak self] image in
                guard let self = self, let image = image, self.image(for: state) === shown else { return }
                self.setImage(image.sbu_with(tintColor: tintColor), for: state)
            }
            return nil
        case .miss:
            return self.downloadOriginalImage(
                url: urlString,
                errorImage: errorImage,
                for: state,
                tintColor: tintColor,
                fileName: fileName,
                subPath: subPath,
                completion: completion
            )
        }
    }

    private func downloadOriginalImage(url urlString: String,
                                       errorImage: UIImage? = nil,
                                       for state: UIButton.State,
                                       tintColor: UIColor? = nil,
                                       fileName: String,
                                       subPath: String,
                                       completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        guard
            let url = UIImage.sbu_imageDownloader.url(string: urlString),
            url.absoluteURL.host != nil else {
            self.setImage(errorImage, tintColor: tintColor, for: state) { _ in
                completion?(false)
            }
            return nil
        }
        
        let task = UIImage.sbu_imageDownloader.downloadImage(from: url) { [weak self] data, error in
            guard let self = self else {
                completion?(false)
                return
            }
            
            guard let data = data, error == nil else {
                self.setImage(errorImage, tintColor: tintColor, for: state) { _ in
                    completion?(false)
                }
                return
            }
            
            let image = SBUCacheManager.Image.save(data: data, fileName: fileName, subPath: subPath)
            self.setImage(image, tintColor: tintColor, for: state, completion: completion)
        }
        task?.resume()
        return task
    }
    
    private func setImage(
        _ image: UIImage?,
        tintColor: UIColor? = nil,
        for state: UIButton.State,
        completion: ((Bool) -> Void)?
    ) {
        guard let image = image else {
            completion?(false)
            return
        }
        
        Thread.executeOnMain {
            if tintColor != nil {
                self.setImage(image.sbu_with(tintColor: tintColor), for: state)
            } else {
                self.setImage(image, for: state)
            }
            completion?(true)
        }
    }
}
