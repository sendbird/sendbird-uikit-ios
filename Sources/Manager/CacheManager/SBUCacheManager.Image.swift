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
        
        @discardableResult
        static func save(
            image: UIImage,
            fileName: String,
            subPath: String,
            completionHandler: SBUCacheCompletionHandler? = nil
        ) -> UIImage? {
            guard let data = image.jpegData(compressionQuality: 1.0) else { return image }
            
            let key = key(fileName: fileName, subPath: subPath)
            self.memoryCache.set(key: key, image: image)
            self.diskCache.set(key: key, data: data as NSData, completionHandler: completionHandler)
            return image
        }
        
        @discardableResult
        static func save(
            data: Data?,
            fileName: String,
            subPath: String,
            completionHandler: SBUCacheCompletionHandler? = nil
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
            completionHandler: SBUCacheCompletionHandler? = nil
        ) -> UIImage? {
            guard let data = nsdata else { return nil }
            guard let image = UIImage.createImage(from: data as Data) else { return nil }

            let key = key(fileName: fileName, subPath: subPath)
            self.memoryCache.set(key: key, image: image)
            self.diskCache.set(key: key, data: data, completionHandler: completionHandler)
            return image
        }
        
        static func preSave(
            fileMessage: FileMessage,
            isQuotedImage: Bool? = false,
            completionHandler: SBUCacheCompletionHandler? = nil
        ) {
            if let messageParams = fileMessage.messageParams as? FileMessageCreateParams {
                var fileName = self.createCacheFileName(
                    urlString: fileMessage.url,
                    cacheKey: fileMessage.cacheKey,
                    fileNameForExtension: fileMessage.name
                )
                if isQuotedImage == true { fileName = "quoted_\(fileName)" }
                
                switch SBUUtils.getFileType(by: fileMessage) {
                case .image:
                    self.save(
                        data: messageParams.file,
                        fileName: fileName,
                        subPath: fileMessage.channelURL,
                        completionHandler: completionHandler
                    )
                case .video:
                    guard let asset = messageParams.file?.getAVAsset() else { break }
                    
                    let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                    avAssetImageGenerator.appliesPreferredTrackTransform = true
                    let cmTime = CMTimeMake(value: 2, timescale: 1)
                    guard let cgImage = try? avAssetImageGenerator
                        .copyCGImage(at: cmTime, actualTime: nil) else {
                        break
                    }
                    
                    let image = UIImage(cgImage: cgImage)
                    self.save(
                        image: image,
                        fileName: fileName,
                        subPath: fileMessage.channelURL,
                        completionHandler: completionHandler
                    )
                default:
                    break
                }
            }
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
                    self.memoryCache.set(key: key, image: image)
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
    }
}
