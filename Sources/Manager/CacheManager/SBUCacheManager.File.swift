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
        static let session = URLSession(configuration: .default)
        
        @discardableResult 
        static func loadFile(
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
                // 큰 영상, 문서를 통째로 읽으면 메모리 부족으로 종료될 수 있어 경로만 넘긴다. 부르는 쪽은 모두 경로만 쓴다.
                DispatchQueue.main.async {
                    completionHandler?(filePath, nil)
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
            
            // 파일 전체를 메모리에 받지 않고 임시 파일로 받아 캐시 경로로 옮긴다.
            let task = self.session.downloadTask(with: url) { location, _, error in
                // 임시 파일은 이 클로저가 끝나면 지워지므로 여기서 바로 옮긴다.
                guard let location = location, error == nil,
                      let filePath = self.diskCache.moveItem(at: location, key: fileName) else {
                    DispatchQueue.main.async {
                        completionHandler?(nil, nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler?(filePath, nil)
                }
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
