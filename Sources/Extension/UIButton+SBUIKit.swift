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
    @discardableResult
    func loadImage(urlString: String,
                   placeholder: UIImage? = nil,
                   errorImage: UIImage? = nil,
                   for state: UIButton.State,
                   completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        self.setImage(placeholder, for: .normal, completion: nil)
        
        if urlString.isEmpty {
            if let errorImage = errorImage {
                self.setImage(errorImage, for: .normal, completion: nil)
            }
            return nil
        }
        
        return self.loadOriginalImage(
            urlString: urlString,
            errorImage: errorImage,
            for: state,
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
                           completion: ((Bool) -> Void)? = nil) -> URLSessionTask? {
        
        let fileName = SBUCacheManager.createHashName(urlString: urlString)
        if let image = SBUCacheManager.getImage(fileName: fileName) {
            self.setImage(image, for: state, completion: completion)
            return nil
        }
        
        guard let url = URL(string: urlString), url.absoluteURL.host != nil else {
            self.setImage(errorImage, for: state) { _ in
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
                self.setImage(errorImage, for: state) { _ in
                    completion?(false)
                }
                return
            }
            
            let image = SBUCacheManager.savedImage(fileName: fileName, data: data)
            self.setImage(image,for: state, completion: completion)
        }
        task.resume()
        return task
    }
    
    private func setImage(_ image: UIImage?, for state: UIButton.State, completion: ((Bool) -> Void)?) {
        if let image = image {
            if Thread.isMainThread {
                self.setImage(image, for: state)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.setImage(image, for: state)
                }
            }
        }
        completion?(image != nil)
    }
}
