//
//  SBUCacheManager.MemoryyCache.swift
//  SendbirdUIKitCommon
//
//  Created by Damon Park on 10/18/24.
//

import UIKit
import AVFoundation

extension SBUCacheManager {
    // MARK: - MemoryCache (for Image)
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
                self.memoryCache.setObject(image, forKey: key as NSString)
            }
        }
        
        func get(key: String) -> UIImage? {
            memoryQueue.sync {
                self.memoryCache.object(forKey: key as NSString)
            }
        }
        
        func remove(key: String) {
            memoryQueue.async {
                self.memoryCache.removeObject(forKey: key as NSString)
            }
        }
        
        func cacheExists(key: String) -> Bool {
            memoryQueue.sync {
                self.memoryCache.object(forKey: key as NSString) != nil
            }
        }
        
        // MARK: - Reset
        func resetCache() {
            memoryQueue.async {
                self.memoryCache.removeAllObjects()
            }
        }
    }
}
