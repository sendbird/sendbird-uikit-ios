//
//  SBUDownloadManager.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/03/05.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos

class SBUDownloadManager: NSObject {
    
    static func saveImage(parent: UIViewController?, url: URL, fileName: String) {
        DispatchQueue.global(qos: .background).async {
            guard let parent = parent else {
                SBULog.error("[Failed] Save image")
                return
            }
            
            guard let fileURL = SBUCacheManager.saveAndLoadFileToLocal(url: url, fileName: fileName) else {
                SBUToastManager.showToast(parentVC: parent, type: .fileDownloadFailed)
                SBULog.error("[Failed] Save image")
                return
            }
            
            DispatchQueue.main.async {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.forAsset()
                        .addResource(with: .photo, fileURL: fileURL, options: nil)
                }) { completed, error in
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
    }
    
    static func saveFile(with fileMessage: SBDFileMessage, parent: UIViewController?) {
        weak var parent = parent
        
        let channelVC = parent as? SBUBaseChannelViewController
        channelVC?.setLoading(true, true)
        
        DispatchQueue.global(qos: .background).async {
            guard let parent = parent,
                  let url = URL(string: fileMessage.url),
                  let fileURL = SBUCacheManager.saveAndLoadFileToLocal(url: url, fileName: fileMessage.name) else {
                channelVC?.setLoading(false, true)
                SBULog.error("[Failed] Save file")
                SBUToastManager.showToast(parentVC: channelVC, type: .fileDownloadFailed)
                return
            }
            
            DispatchQueue.main.async {
                channelVC?.setLoading(false, true) 
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
                    parent?.presentedViewController?.dismiss(animated: true, completion: nil)
                    if completed {
                        SBULog.info("[Succeed] File is saved.")
                        SBUToastManager.showToast(parentVC: parent, type: .fileDownloadSuccess)
                    }
                }
                
                if #available(iOS 13.0, *) {
                    // For iOS 13 issue
                    parent.present(transparentVC, animated: true) { [weak transparentVC] in
                        transparentVC?.present(activityVC, animated: true)
                    }
                } else {
                    parent.present(activityVC, animated: true)
                }
            }
        }
    }
    
    static func save(fileMessage: SBDFileMessage, parent: UIViewController?) {
        switch SBUUtils.getFileType(by: fileMessage) {
        case .image:
            guard let url = URL(string: fileMessage.url) else { return }
            SBUDownloadManager.saveImage(parent: parent, url: url, fileName: fileMessage.name)
        default:
            SBUDownloadManager.saveFile(with: fileMessage, parent: parent)
        }
    }
}
