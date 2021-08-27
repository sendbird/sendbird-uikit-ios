//
//  UIImageView+Ext.swift
//  SendBirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/23.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UIImageView {
    func updateImage(urlString: String?) {
        guard let urlString = urlString, !urlString.isEmpty else {
            self.image = UIImage(named: "iconAvatar")
            return
        }
        guard let profileURL = URL(string: urlString) else { return }
        
        ImageCache.shared.load(url: profileURL) { image, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Failed to load image")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // If returned image is same as current image
                guard self.image != image else { return }
                self.image = image
                self.layoutIfNeeded()
            }
        }
    }
}

class ImageCache {
    typealias ImageHandler = ((UIImage?, Error?) -> Void)
    
    static let shared = ImageCache()
    
    enum ImageCacheError: Error {
        case failedToLoadImage
    }
    
    private func cachedImage(for imageRequest: URLRequest) -> UIImage? {
        // If there is no cached response for the image request, return immediately.
        guard let data = URLCache.shared.cachedResponse(for: imageRequest)?.data else { return nil }
        return UIImage(data: data)
    }
    
    func load(url: URL, completion: @escaping ImageHandler) {
        DispatchQueue.global(qos: .userInitiated).async {
            // useProtocolCachePolicy: A default policy for URL load requests.
            let imageRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
            
            // If there is cached image, return immediately.
            if let cachedImage = self.cachedImage(for: imageRequest) {
                completion(cachedImage, nil)
                return
            }
            
            URLSession.shared.dataTask(with: imageRequest) { data, response, error in
                // If image is invalid, return immediately.
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, let image = UIImage(data: data),
                    error == nil else {
                        completion(nil, ImageCacheError.failedToLoadImage)
                        return
                }
                
                // Cache response and return loaded image
                let cacheData = CachedURLResponse(response: httpURLResponse, data: data)
                URLCache.shared.storeCachedResponse(cacheData, for: imageRequest)
                
                completion(image, nil)
                
            }
            .resume()
        }
    }
}
