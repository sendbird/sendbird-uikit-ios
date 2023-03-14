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
    
    static func saveImage(parent: UIViewController?, url: URL, fileName: String) {
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
            
            let pathExtension = SBUCacheManager.fileExtension(urlString: url.absoluteString)
            let fileName = "\(fileName).\(pathExtension)"
            if SBUCacheManager.Image.diskCache.cacheExists(key: fileName) {
                let filePath = URL(string: SBUCacheManager.Image.diskCache.pathForKey(fileName))
                    ?? URL(fileURLWithPath: SBUCacheManager.Image.diskCache.pathForKey(fileName))
                downloadHandler(filePath)
            } else {
                DispatchQueue.main.async {
                    let _ = UIImageView().loadOriginalImage(urlString: url.absoluteString, errorImage: nil, cacheKey: fileName) { success in
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
                    
                    activityVC.completionWithItemsHandler = { [weak parent] type, completed, _, _ in
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
                cacheKey: fileMessage.requestId,
                fileName: fileMessage.name
            ) { fileURL, fileData in
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
            guard let url = URL(string: fileMessage.url) else { return }
            SBUDownloadManager.saveImage(parent: parent, url: url, fileName: fileMessage.requestId)
        default:
            SBUDownloadManager.saveFile(with: fileMessage, parent: parent)
        }
    }
}
