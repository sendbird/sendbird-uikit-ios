//
//  SBUCacheManager.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/03/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUCacheManager {
    
    static private let diskCache = DiskCache()
    static private let memoryCache = MemoryCache()
    static internal let fileCacheQueue = DispatchQueue(label: "com.sendbird.cache.file", qos: .background)

    @discardableResult
    static func savedImage(fileName: String, image: UIImage) -> UIImage? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return image }
        self.memoryCache.set(key: fileName, image: image)
        self.diskCache.set(key: fileName, data: data as NSData)
        return image
    }

    @discardableResult
    static func savedImage(fileName: String, data: Data?) -> UIImage? {
        return savedImage(fileName: fileName, data: data as NSData?)
    }

    static func savedImage(fileName: String, data: NSData?) -> UIImage? {
        guard let data = data else { return nil }
        guard let image = UIImage.createImage(from: data as Data) else { return nil }
        self.memoryCache.set(key: fileName, image: image)
        self.diskCache.set(key: fileName, data: data)
        return image
    }

    static func getImage(fileName: String) -> UIImage? {
        if let memoryImage = self.memoryCache.getImage(key: fileName) {
            return memoryImage
        } else if let diskData = self.diskCache.get(key: fileName) {
            self.memoryCache.set(key: fileName, data: diskData)
            return UIImage.createImage(from: diskData as Data)
        } else {
            return nil
        }
    }

    static func hasImage(fileName: String) -> Bool {
        return memoryCache.hasImage(key: fileName) ? true : diskCache.hasImage(key: fileName)
    }
    
    static func createHashName(urlString: String) -> String {
        return "\(urlString.persistantHash)"
    }
}

public struct DiskCache {

    // MARK: - Properties
    private let fileManager = FileManager.default
    private let directory = "image/"
    private let diskQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.diskcache", qos: .background)
    
    // MARK: - Initializers
    public init() {
        let imageCachePath = self.imageCacheURL().path
        
        if self.fileManager.fileExists(atPath: imageCachePath) {
            return
        }
        
        do {
            try self.fileManager.createDirectory(
                atPath: imageCachePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            SBULog.error(error.localizedDescription)
        }
    }

    public func hasImage(key: String) -> Bool {
            return fileManager.fileExists(atPath: self.pathForKey(key))
    }

    public func get(key: String) -> NSData? {
        let filePath = URL(fileURLWithPath: self.pathForKey(key))
        
        do {
            let data = try Data(contentsOf: filePath)//6
            return data as NSData
        } catch {
            SBULog.error(error.localizedDescription)
        }
        return nil
    }

    public func set(key: String, data: NSData) {
        diskQueue.async {
            let filePath = URL(fileURLWithPath: self.pathForKey(key))
            do {
                try data.write(to: filePath)
            } catch {
                SBULog.error(error.localizedDescription)
            }
        }
    }
    
    public func remove(key: String) {
        diskQueue.async {
            let path = self.pathForKey(key)
            let fileManager = self.fileManager
            
            if fileManager.fileExists(atPath: path) {
                try? fileManager.removeItem(atPath: path)
            }
        }
    }

    public func removeAll() {
        diskQueue.async {
            let fileManager = self.fileManager
            let imageCachePath = self.imageCacheURL().path
            
            try? fileManager
                .contentsOfDirectory(atPath: imageCachePath)
                .forEach { try? fileManager.removeItem(atPath: $0) }
        }
    }

    private func imageCacheURL() -> URL {
        guard let cacheDirectoryURL = try? FileManager.default.url(
            for: .cachesDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: true) else { return URL(fileURLWithPath: "") }
        
        let imageCachePath = cacheDirectoryURL.appendingPathComponent(self.directory)
        return imageCachePath
    }
    
    private func pathForKey(_ key: String) -> String {
        let imageCachePath = imageCacheURL()
        let fullPath = imageCachePath.appendingPathComponent(key)
        return fullPath.path
    }
}

struct MemoryCache {

    private let memoryQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.memorycache", qos: .background)
    
    // MARK: - Memory Cache
    private var memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 10 * 1024 * 1024 // Here the size in bytes of data is used as the cost, here 10 MB limit
        cache.countLimit = 30 // 30 url limit
        return cache
    }()

    func set(key: String, image: UIImage) {
        memoryQueue.async {
            self.memoryCache.setObject(image, forKey: key as NSString)
        }
    }

    func set(key: String, data: NSData) {
        memoryQueue.async {
            guard let image = UIImage.createImage(from: data as Data) else { return }
            self.set(key: key, image: image)
        }
    }

    func getImage(key: String) -> UIImage? {
        return self.memoryCache.object(forKey: key as NSString)
    }
    
    func hasImage(key: String) -> Bool {
        return self.memoryCache.object(forKey: key as NSString) != nil
    }
}
