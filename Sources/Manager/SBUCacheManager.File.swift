//
//  SBUCacheManager.File.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2021/06/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUCacheManager {
    
    @discardableResult static func saveAndLoadFileToLocal(url: URL, fileName: String) -> URL? {
        if let filePath = self.generateFilePath(
            fileName: fileName,
            additionalPath: "\(url.absoluteString.persistantHash)"
        ) {
            if SBUCacheManager.isFileExist(at: filePath) {
                SBULog.info("Already have exists cached file")
                return URL(fileURLWithPath: filePath)
            }
            
            guard let urlData = NSData(contentsOf: url) else {
                SBULog.error("[Failed] Save File")
                return nil
            }
            
            urlData.write(toFile: filePath, atomically: true)
            SBULog.info("[Succeed] File is saved.")
            return URL(fileURLWithPath: filePath)
        }
        
        return url
    }
    
    // Not used now
    static func loadFileIfExist(url: URL, fileName: String) -> URL? {
        if let filePath = self.generateFilePath(
            fileName: fileName,
            additionalPath: "\(url.absoluteString.persistantHash)"
        ) {
            if SBUCacheManager.isFileExist(at: filePath) {
                return URL(fileURLWithPath: filePath)
            }
        }
        
        return url
    }
    
    static fileprivate func generateFilePath(fileName: String, additionalPath: String) -> String? {
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
