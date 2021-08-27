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
}

public struct DiskCache {

    // MARK: - Properties
    private let fileManager = FileManager.default
    private let directory = "image/"
    private let diskQueue = DispatchQueue(label: "com.sendbird.diskcache", qos: .background)
    
    // MARK: - Initializers
    public init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent(self.directory)
        
        if self.fileManager.fileExists(atPath: dataPath.path) {
            return
        }
        
        do {
            try self.fileManager.createDirectory(
                atPath: dataPath.absoluteString,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            SBULog.error(error.localizedDescription)
        }
    }

    public func hasImage(key: String) -> Bool {
        diskQueue.sync {
            return NSKeyedUnarchiver.unarchiveObject(withFile: self.pathForKey(key)) != nil
        }
    }

    public func get(key: String) -> NSData? {
        diskQueue.sync {
            return NSKeyedUnarchiver.unarchiveObject(withFile: self.pathForKey(key)) as? NSData
        }
    }

    public func set(key: String, data: NSData) {
        diskQueue.async {
            let path = self.pathForKey(key)
            if self.fileManager.fileExists(atPath: path) {
                do {
                    try self.fileManager.removeItem(atPath: path)
                } catch {
                    SBULog.error(error.localizedDescription)
                }
            }
            NSKeyedArchiver.archiveRootObject(data, toFile: path)
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
            let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.path
            
            try? fileManager
                .contentsOfDirectory(atPath: directory)
                .forEach { try? fileManager.removeItem(atPath: $0) }
        }
    }

    private func pathForKey(_ key: String) -> String {
        return
            self.fileManager
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(directory)
                .appendingPathComponent(key)
                .path
    }
}

struct MemoryCache {

    // MARK: - Memory Cache
    private var memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 10 * 1024 * 1024 // Here the size in bytes of data is used as the cost, here 10 MB limit
        cache.countLimit = 30 // 30 url limit
        return cache
    }()

    func set(key: String, image: UIImage) {
        self.memoryCache.setObject(image, forKey: key as NSString)
    }

    func set(key: String, data: NSData) {
        guard let image = UIImage.createImage(from: data as Data) else { return }
        self.set(key: key, image: image)
//        SBULog.info("[Succeed] The image was stored in the memory cache.")
    }

    func getImage(key: String) -> UIImage? {
        return self.memoryCache.object(forKey: key as NSString)
    }
    
    func hasImage(key: String) -> Bool {
        return self.memoryCache.object(forKey: key as NSString) != nil
    }
}
