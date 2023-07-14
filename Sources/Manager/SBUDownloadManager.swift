//
//  SBUDownloadManager.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/03/05.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Photos

class SBUDownloadManager {
    
    static func saveImage(with fileMessage: FileMessage, parent: UIViewController?) {
        guard let parent = parent else {
            SBULog.error("[Failed] Save image")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let downloadHandler: ((URL) -> Void) = { fileURL in
                DispatchQueue.main.async {
                    SBULoading.stop()
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCreationRequest.forAsset()
                            .addResource(with: .photo, fileURL: fileURL, options: nil)
                    }) { [weak parent] completed, error in
                        guard error == nil else {
                            SBULog.error("[Failed] Save image: \(String(describing: error))")
                            SBUToastManager.showToast(parentVC: parent, type: .fileDownloadFailed)
                            return
                        }
                        
                        if completed {
                            SBULog.info("[Succeed] Image saved.")
                            SBUToastManager.showToast(parentVC: parent, type: .fileDownloadSuccess)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async { SBULoading.start() }
            
            let fileName = SBUCacheManager.Image.createCacheFileName(
                urlString: fileMessage.url,
                cacheKey: fileMessage.cacheKey,
                needPathExtension: true
            )
            
            let key = SBUCacheManager.Image.key(fileName: fileName, subPath: fileMessage.channelURL)
            if SBUCacheManager.Image.diskCache.cacheExists(key: key) {
                let filePath = URL(string: SBUCacheManager.Image.diskCache.pathForKey(key))
                    ?? URL(fileURLWithPath: SBUCacheManager.Image.diskCache.pathForKey(key))
                downloadHandler(filePath)
            } else {
                DispatchQueue.main.async {
                    _ = UIImageView().loadOriginalImage(
                        urlString: fileMessage.url,
                        errorImage: nil,
                        cacheKey: key,
                        subPath: fileMessage.channelURL
                    ) { success in
                        if success {
                            let filePath = URL(string: SBUCacheManager.Image.diskCache.pathForKey(fileName))
                                ?? URL(fileURLWithPath: SBUCacheManager.Image.diskCache.pathForKey(fileName))
                            downloadHandler(filePath)
                        } else {
                            DispatchQueue.main.async { SBULoading.stop() }
                        }
                    }
                }
            }
        }
    }
    
    static func saveFile(with fileMessage: FileMessage, parent: UIViewController?) {
        guard let parent = parent else {
            SBULog.error("[Failed] Save file")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let downloadHandler: ((URL) -> Void) = { fileURL in
                DispatchQueue.main.async { [weak parent] in
                    let activityVC = UIActivityViewController(
                        activityItems: [fileURL],
                        applicationActivities: nil
                    )
                    let transparentVC = UIViewController()
                    transparentVC.view.isOpaque = true
                    transparentVC.modalPresentationStyle = .overFullScreen
                    
                    activityVC.completionWithItemsHandler = { [weak parent] _, completed, _, _ in
                        // For iOS 13 issue
                        transparentVC.dismiss(animated: true, completion: nil)
                        parent?.presentedViewController?.dismiss(animated: true, completion: {
                            if completed {
                                SBULog.info("[Succeed] File is saved.")
                                SBUToastManager.showToast(parentVC: parent, type: .fileDownloadSuccess)
                            }
                        })
                    }
                    
                    if #available(iOS 13.0, *) {
                        // For iOS 13 issue
                        parent?.present(transparentVC, animated: true) { [weak transparentVC] in
                            transparentVC?.present(activityVC, animated: true)
                        }
                    } else {
                        parent?.present(activityVC, animated: true)
                    }
                    
                    SBULoading.stop()
                }
            }
            
            DispatchQueue.main.async { SBULoading.start() }
            
            SBUCacheManager.File.loadFile(
                urlString: fileMessage.url,
                cacheKey: fileMessage.cacheKey,
                fileName: fileMessage.name
            ) { fileURL, _ in
                if let fileURL = fileURL {
                    downloadHandler(fileURL)
                } else {
                    DispatchQueue.main.async { SBULoading.stop() }
                }
            }
        }
    }
    
    static func save(fileMessage: FileMessage, parent: UIViewController?) {
        switch SBUUtils.getFileType(by: fileMessage) {
        case .image:
            guard !fileMessage.url.isEmpty else { return }
            SBUDownloadManager.saveImage(with: fileMessage, parent: parent)
        default:
            SBUDownloadManager.saveFile(with: fileMessage, parent: parent)
        }
    }
}
