//
//  SBUCacheManager.File.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/06/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUCacheManager {
    
    @discardableResult static func saveAndLoadFileToLocal(url: URL, fileName: String) -> URL? {
        // When open the file at first time (not cached file), this function return the original url and cache the file in background.
        if let fileURL = self.loadFileIfExist(url: url, fileName: fileName) {
            return fileURL
        } else {
            self.saveFileIfNeeded(url: url, fileName: fileName)
            return url
        }
    }
    
    static func loadFileIfExist(url: URL, fileName: String) -> URL? {
        if let filePath = self.generateFilePath(url: url, fileName: fileName) {
            if SBUCacheManager.isFileExist(at: filePath) {
                return URL(fileURLWithPath: filePath)
            }
        }
        
        return nil
    }
    
    static func saveFileIfNeeded(url: URL, fileName: String, completionHandler: ((String?) -> Void)? = nil) {
        if let filePath = self.generateFilePath(url: url, fileName: fileName) {
            if SBUCacheManager.isFileExist(at: filePath) == false {
                SBUCacheManager.fileCacheQueue.async {
                    do {
                        let urlData = try Data(contentsOf: url)
                        try urlData.write(to: URL(fileURLWithPath: filePath))
                        SBULog.info("[Succeed] File is saved.")
                        completionHandler?(filePath)
                    } catch {
                        SBULog.error("[Failed] File is saved: \(error)")
                        completionHandler?(nil)
                    }
                }
            } else {
                completionHandler?(filePath)
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    static func generateFilePath(url: URL, fileName: String) -> String? {
        let additionalPath = "\(url.absoluteString.persistantHash)"
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0]
        
        do {
            try FileManager.default.createDirectory(atPath: "\(documentsPath)/\(additionalPath)", withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            SBULog.info("[Failed] Create directory : \(error.localizedDescription)")
            return nil
        }
        
        return "\(documentsPath)/\(additionalPath)/\(fileName)"
    }
    
    static func isFileExist(at filePath: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }

}
