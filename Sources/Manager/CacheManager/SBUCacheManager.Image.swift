//
//  SBUCacheManager.Image.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/01/15.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SendbirdChatSDK

// File cache path: {cachesDirectory}/image/{REQ_ID}.{EXT}

extension SBUCacheManager {
    class Image {
        static let diskCache = DiskCache(cacheType: "image")
        static let memoryCache = MemoryCache()
        
        /// - Parameter preservesTransparency: `true` 이면 디스크에 PNG 로 저장한다. JPEG 는 투명 영역을
        ///   불투명하게 바꾸므로 투명도가 있을 수 있는 이미지(GIF 첫 프레임 등)에 쓴다.
        @discardableResult
        static func save(
            image: UIImage,
            fileName: String,
            subPath: String,
            preservesTransparency: Bool = false,
            completionHandler: SBUImageCacheCompletionHandler? = nil
        ) -> UIImage? {
            let encoded = preservesTransparency ? image.pngData() : image.jpegData(compressionQuality: 1.0)
            guard let data = encoded else {
                completionHandler?(nil, nil, image)
                return image
            }
            
            let key = key(fileName: fileName, subPath: subPath)
            self.memoryCache.set(key: key, image: image)
            self.diskCache.set(key: key, data: data as NSData, image: image, completionHandler: completionHandler)
            return image
        }
        
        @discardableResult
        static func save(
            data: Data?,
            fileName: String,
            subPath: String,
            completionHandler: SBUImageCacheCompletionHandler? = nil
        ) -> UIImage? {
            return save(
                nsdata: data as NSData?,
                fileName: fileName,
                subPath: subPath,
                completionHandler: completionHandler
            )
        }
        
        static func save(
            nsdata: NSData?,
            fileName: String,
            subPath: String,
            completionHandler: SBUImageCacheCompletionHandler? = nil
        ) -> UIImage? {
            guard let data = nsdata else { return nil }
            guard let image = UIImage.createImage(from: data as Data) else {
                completionHandler?(nil, data, nil)
                return nil
            }

            let key = key(fileName: fileName, subPath: subPath)
            self.memoryCache.set(key: key, image: image)
            self.diskCache.set(key: key, data: data, image: image, completionHandler: completionHandler)
            return image
        }
        
        static func get(fileName: String, subPath: String) -> UIImage? {
            let key = key(fileName: fileName, subPath: subPath)
            if let memoryImage = self.memoryCache.get(key: key) {
                return memoryImage
            } else if let diskData = self.diskCache.get(key: key) {
                self.memoryCache.set(key: key, data: diskData)
                return UIImage.createImage(from: diskData as Data)
            } else {
                /**
                 2022.11.15 - 3.3.0
                 Added internal processing logic to fix image cache issue caused by using same key value when caching original message image and quoted message image.
                 */
                if fileName.contains("quoted_") {
                    let removedPrefix = fileName.replacingOccurrences(of: "quoted_", with: "")
                    let removedThumbnailPrefix = removedPrefix.replacingOccurrences(of: "thumb_", with: "")
                    let original = self.diskCache.get(key: removedPrefix)
                    let quoted = self.diskCache.get(key: fileName)
                    if quoted == nil {
                        if original != nil {
                            self.diskCache.remove(key: removedPrefix)
                            self.diskCache.remove(key: removedThumbnailPrefix)
                            return nil
                        }
                    }
                }
                
                return nil
            }
        }
        
        /// 썸네일 조회. 디스크에 여러 프레임 이미지가 있으면(예전 버전이 GIF 원본을 썸네일로 저장한 경우)
        /// 전체 animation 을 만들지 않고 첫 프레임만 `size` 안에 들어가게 디코드한다.
        /// 그 밖에는 `get(fileName:subPath:)` 과 같다.
        static func getThumbnail(fileName: String, subPath: String, fitting size: CGSize, scale: CGFloat) -> UIImage? {
            let key = key(fileName: fileName, subPath: subPath)
            if let memoryImage = self.memoryCache.get(key: key) {
                return memoryImage
            }
            // 디스크에 없을 때만 `get` 으로 넘긴다(quoted 캐시 정리). 읽은 데이터는 다시 읽지 않고 한 번만 디코드한다.
            guard let diskData = self.diskCache.get(key: key) else {
                return self.get(fileName: fileName, subPath: subPath)
            }
            let decoded: UIImage?
            if let source = CGImageSourceCreateWithData(diskData as CFData, nil), CGImageSourceGetCount(source) > 1 {
                decoded = UIImage.firstFrameThumbnail(source: source, fitting: size, scale: scale)
            } else {
                decoded = UIImage.createImage(from: diskData as Data)
            }
            guard let image = decoded else { return nil }
            self.memoryCache.set(key: key, image: image)
            return image
        }
        
        static func createCacheFileName(
            urlString: String,
            cacheKey: String?,
            fileNameForExtension: String? = nil,
            needPathExtension: Bool = true
        ) -> String {
            var fileName = SBUCacheManager.createHashName(urlString: urlString)
            var pathExtension = SBUCacheManager.fileExtension(urlString: urlString)
            if pathExtension.isEmpty {
                pathExtension = SBUCacheManager.fileExtension(urlString: fileNameForExtension ?? "")
            }
            if let cacheKey = cacheKey, !cacheKey.isEmpty {
                self.renameIfNeeded(key: fileName, newKey: cacheKey)
                fileName = cacheKey
            }
            
            if needPathExtension {
                return "\(fileName).\(pathExtension)"
            } else {
                return "\(fileName)"
            }
        }
        
        static func renameIfNeeded(key: String, newKey: String) {
            if self.cacheExists(fileName: key),
               !self.cacheExists(fileName: newKey) {
                
                self.diskCache.rename(key: key, newKey: newKey)
                
                if let image = self.memoryCache.get(key: key) {
                    self.memoryCache.set(key: newKey, image: image)
                    self.memoryCache.remove(key: key)
                }
            }
        }
        
        static func cacheExists(fileName: String) -> Bool {
            return self.memoryCache.cacheExists(key: fileName)
            ? true
            : self.diskCache.cacheExists(key: fileName)
        }
        
        static func key(fileName: String, subPath: String) -> String {
            let key = "\(subPath)\(!subPath.isEmpty ? "/" : "")\(fileName)"
            return key
        }
        
        // MARK: - Reset
        static func resetCache() {
            self.memoryCache.resetCache()
            self.diskCache.resetCache()
        }
    }
}
