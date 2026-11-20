//
//  SBUCacheManager.DiskCache.swift
//  SendbirdUIKitCommon
//
//  Created by Damon Park on 10/18/24.
//

import UIKit
import AVFoundation

extension SBUCacheManager {
    // MARK: - DiskCache
    struct DiskCache {
        // MARK: - Properties
        private let fileManager = FileManager.default
        private let cacheType: String
        private let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache", qos: .background)
        
        // MARK: - Initializers
        init(cacheType: String) {
            self.cacheType = cacheType
            
            do {
                try self.createDirectoryIfNeeded()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        
        func createDirectoryIfNeeded() throws {
            let cachePath = self.cachePathURL().path
            
            if self.fileManager.fileExists(atPath: cachePath) {
                return
            }
            
            try self.fileManager.createDirectory(
                atPath: cachePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        func cacheExists(key: String) -> Bool {
            return fileManager.fileExists(atPath: self.pathForKey(key))
        }

        func get(fullPath: URL) -> Data? {
            do {
                let data = try Data(contentsOf: fullPath)
                return data
            } catch {
                Log.info(error.localizedDescription)
            }
            return nil
        }
        
        func get(key: String) -> NSData? {
            guard cacheExists(key: key) else { return nil }
            
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            
            do {
                let data = try Data(contentsOf: filePath)
                return data as NSData
            } catch {
                Log.info(error.localizedDescription)
            }
            return nil
        }
        
        // FIXME: Seperate image / file handling logic
        func set<T>(key: String, data: NSData, image: UIImage? = nil, completionHandler: T? = nil) {
            diskQueue.async { [weak image] in
                let filePath = URL(fileURLWithPath: self.pathForKey(key))

                do {
                    let subPath = filePath.deletingLastPathComponent()
                    try self.fileManager.createDirectory(
                        atPath: subPath.path,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                } catch {
                    Log.error(error.localizedDescription)
                    DispatchQueue.main.async {
                        switch completionHandler {
                        case let cacheHandler as SBUCacheCompletionHandler:
                            cacheHandler(nil, nil)
                        case let imageCacheHandler as SBUImageCacheCompletionHandler:
                            imageCacheHandler(nil, nil, image)
                        default:
                            Log.error("Invalid cacheHandler type")
                        }
                    }
                    return
                }
                
                data.write(to: filePath, atomically: true)
                DispatchQueue.main.async {
                    switch completionHandler {
                    case let cacheHandler as SBUCacheCompletionHandler:
                        cacheHandler(filePath, data)
                    case let imageCacheHandler as SBUImageCacheCompletionHandler:
                        imageCacheHandler(filePath, data, image)
                    default:
                        Log.error("Invalid cacheHandler type")
                    }
                }
            }
        }
        
        /// 받은 임시 파일을 캐시 경로로 옮기고 그 경로를 돌려준다. 같은 경로에 파일이 있으면 바꾼다. 실패하면 nil.
        ///
        /// 임시 파일은 받기 콜백이 끝나면 지워지므로 기다려서 옮긴다. `set`, `rename`, `removeAll` 과 순서가 섞이지 않게 같은 큐에서 한다.
        func moveItem(at location: URL, key: String) -> URL? {
            diskQueue.sync {
                let filePath = URL(fileURLWithPath: self.pathForKey(key))
                do {
                    try self.fileManager.createDirectory(
                        at: filePath.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    if self.fileManager.fileExists(atPath: filePath.path) {
                        _ = try self.fileManager.replaceItemAt(filePath, withItemAt: location)
                    } else {
                        try self.fileManager.moveItem(at: location, to: filePath)
                    }
                    return filePath
                } catch {
                    Log.error(error.localizedDescription)
                    return nil
                }
            }
        }
        
        /// 이미 예약한 디스크 작업이 끝날 때까지 기다린다. 큐는 `.background` 라 디스크가 바쁘면 쓰기가 크게 밀리는데,
        /// 부른 스레드의 우선순위로 큐를 올려 끝낸다. 테스트가 쓰기 결과를 확인할 때 쓴다.
        func waitForPendingWork() {
            diskQueue.sync {}
        }
        
        func rename(key: String, newKey: String) {
            diskQueue.async {
                let fileManager = self.fileManager
                let atPath = self.pathForKey(key)
                let toPath = self.pathForKey(newKey)
                try? fileManager.moveItem(atPath: atPath, toPath: toPath)
            }
        }
        
        func remove(key: String) {
            diskQueue.async {
                let path = self.pathForKey(key)
                let fileManager = self.fileManager
                
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    Log.error("Could not remove file: \(error)")
                }
            }
        }
        
        func removeAll() {
            diskQueue.async {
                let fileManager = self.fileManager
                let cachePath = self.cachePathURL().path
                
                do {
                    try fileManager.removeItem(atPath: cachePath)
                } catch {
                    Log.error("Could not remove cache path: \(error)")
                }
            }
        }
        
        func cachePathURL() -> URL {
            guard let cacheDirectoryURL = try? FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true) else { return URL(fileURLWithPath: "") }
            
            let cachePathURL = cacheDirectoryURL.appendingPathComponent("\(self.cacheType)/")
            return cachePathURL
        }
        
        func pathForKey(_ key: String) -> String {
            let cachePathURL = cachePathURL()
            let fullPath = cachePathURL.appendingPathComponent(key)
            return fullPath.path
        }
        
        // swiftlint:disable missing_docs
        @available(*, deprecated, renamed: "cacheExists(key:)")
        public func hasImage(key: String) -> Bool {
            self.cacheExists(key: key)
        }
        // swiftlint:enable missing_docs
        
        // Voice
        func voiceTempPath(fileName: String) -> URL? {
            let documentPath = URL(fileURLWithPath: self.pathForKey("voice_temp"))
            
            if !FileManager.default.fileExists(atPath: documentPath.path) {
                do {
                    try FileManager.default.createDirectory(at: documentPath, withIntermediateDirectories: true)
                    return documentPath.appendingPathComponent(fileName)
                } catch {
                    Log.error("[Failed] Create directory : \(error.localizedDescription)")
                    return nil
                }
            }
            return documentPath.appendingPathComponent(fileName)
        }
        
        func removeVoiceTemp(fileName: String?) {
            guard let fileName = fileName,
                  let path = self.voiceTempPath(fileName: fileName)?.path else { return }
            
            diskQueue.async {
                let fileManager = self.fileManager
                
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    Log.error("Could not remove file: \(error)")
                }
            }
        }
        
        // MARK: - Reset
        func resetCache() {
            self.removeAll()
        }
        
        private func executeCompletion<T>(
            _ image: UIImage? = nil,
            handler: T?
        ) {
            Thread.executeOnMain {
                switch handler {
                case let cacheHandler as SBUCacheCompletionHandler:
                    cacheHandler(nil, nil)
                case let imageCacheHandler as SBUImageCacheCompletionHandler:
                    imageCacheHandler(nil, nil, image)
                default:
                    Log.error("Invalid cacheHandler type")
                }
            }
        }
    }
}
