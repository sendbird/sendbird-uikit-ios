//
//  SBUCacheManager.File.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/06/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// File cache path: {cachesDirectory}/file/{REQ_ID}/{FILENAME}.{EXT}

/// cacheKey policy:
///     - If there is a cacheKey, we use cacheKey as a key,
///     - if there is no, we create hash with fileURL and use it as a key.
///     - (In the case of a file, the key value is used as the path to keep the filename.)
///     - File cache path: {cachesDirectory}/file/{REQ_ID}/{FILENAME}.{EXT}
extension SBUCacheManager {
    class File {
        static let diskCache = DiskCache(cacheType: "file")
        
        @discardableResult static func loadFile(
            urlString: String,
            cacheKey: String? = nil,
            fileName: String? = nil,
            completionHandler: SBUCacheCompletionHandler? = nil
        ) -> URLSessionTask? {
            let fileName = self.createCacheFileName(
                urlString: urlString,
                cacheKey: cacheKey,
                fileName: fileName
            )
            
            // Load cached file
            if self.cacheExists(fileName: fileName) {
                let filePath = URL(fileURLWithPath: diskCache.pathForKey(fileName))
                let data = diskCache.get(key: fileName)
                DispatchQueue.main.async {
                    completionHandler?(filePath, data)
                }
                return nil
            }
            
            // Load or Download file
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completionHandler?(nil, nil)
                }
                return nil
            }
            
            let task = URLSession(configuration: .default).dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completionHandler?(nil, nil)
                    }
                    return
                }
                
                SBUCacheManager.File.save(data: data, fileName: fileName, completionHandler: completionHandler)
            }
            task.resume()
            return task
        }
        
        static func save(data: Data?, fileName: String, completionHandler: SBUCacheCompletionHandler? = nil) {
            return self.save(
                nsdata: data as NSData?,
                fileName: fileName,
                completionHandler: completionHandler
            )
        }
        
        static func save(nsdata: NSData?, fileName: String, completionHandler: SBUCacheCompletionHandler? = nil) {
            guard let data = nsdata else {
                DispatchQueue.main.async {
                    completionHandler?(nil, nil)
                }
                return
            }
            
            self.diskCache.set(key: fileName, data: data, completionHandler: completionHandler)
        }

        static func get(fileName: String) -> Data? {
            let diskData = self.diskCache.get(key: fileName)
            return diskData as Data?
        }
        
        static func preSave(fileMessage: FileMessage, fileName: String?, completionHandler: SBUCacheCompletionHandler? = nil) {
            if let messageParams = fileMessage.messageParams as? FileMessageCreateParams {
                let fileName = self.createCacheFileName(
                    urlString: fileMessage.url,
                    cacheKey: fileMessage.cacheKey,
                    fileName: fileName
                )
                
                self.save(
                    data: messageParams.file,
                    fileName: fileName,
                    completionHandler: completionHandler
                )
            }
        }
        
        static func createCacheFileName(urlString: String, cacheKey: String?, fileName: String?) -> String {
            var filePath = SBUCacheManager.createHashName(urlString: urlString)
            let pathExtension = SBUCacheManager.fileExtension(urlString: urlString)
            if let cacheKey = cacheKey, !cacheKey.isEmpty {
                self.renameIfNeeded(key: filePath, newKey: cacheKey)
                filePath = cacheKey
            }
            
            if let fileName = fileName {
                return "\(filePath)/\(fileName)"
            } else {
                return "\(filePath)/File.\(pathExtension)"
            }
        }
        
        static func renameIfNeeded(key: String, newKey: String) {
            if self.cacheExists(fileName: key),
               !self.cacheExists(fileName: newKey) {
                
                self.diskCache.rename(key: key, newKey: newKey)
            }
        }
        
        static func removeVoiceTemp(fileName: String?) {
            self.diskCache.removeVoiceTemp(fileName: fileName)
        }
        
        static func cacheExists(fileName: String) -> Bool {
            return self.diskCache.cacheExists(key: fileName)
        }
    }
}
