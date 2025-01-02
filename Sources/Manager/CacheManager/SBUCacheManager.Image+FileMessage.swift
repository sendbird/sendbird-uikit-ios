//
//  SBUCacheManager.Image+FileMessage.swift
//  SendbirdUIKitCommon
//
//  Created by Damon Park on 10/30/24.
//

import UIKit
import AVFoundation
import SendbirdChatSDK

extension SBUCacheManager.Image {
    static func preSave(
        fileMessage: FileMessage,
        isQuotedImage: Bool? = false,
        completionHandler: SBUImageCacheCompletionHandler? = nil
    ) {
        if let messageParams = fileMessage.messageParams as? FileMessageCreateParams {
            var fileName = self.createCacheFileName(
                urlString: fileMessage.url,
                cacheKey: fileMessage.cacheKey,
                fileNameForExtension: fileMessage.name,
                needPathExtension: true
            )
            if isQuotedImage == true { fileName = "quoted_\(fileName)" }
            
            switch SBUUtils.getFileType(by: fileMessage) {
            case .image:
                self.save(
                    data: messageParams.file,
                    fileName: fileName,
                    subPath: fileMessage.channelURL,
                    completionHandler: completionHandler
                )
            case .video:
                guard let asset = messageParams.file?.getAVAsset() else { break }
                
                let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                avAssetImageGenerator.appliesPreferredTrackTransform = true
                let cmTime = CMTimeMake(value: 2, timescale: 1)
                guard let cgImage = try? avAssetImageGenerator
                    .copyCGImage(at: cmTime, actualTime: nil) else {
                    break
                }
                
                let image = UIImage(cgImage: cgImage)
                self.save(
                    image: image,
                    fileName: fileName,
                    subPath: fileMessage.channelURL,
                    completionHandler: completionHandler
                )
            default:
                break
            }
        }
    }
    
    static func preSave(
        multipleFilesMessage: MultipleFilesMessage,
        uploadableFileInfo: UploadableFileInfo,
        index: Int,
        isQuotedImage: Bool,
        completionHandler: SBUImageCacheCompletionHandler?
    ) {
        var fileName = self.createCacheFileName(
            urlString: uploadableFileInfo.fileURL ?? "",
            cacheKey: multipleFilesMessage.cacheKey + "_\(index)",
            fileNameForExtension: uploadableFileInfo.fileName,
            needPathExtension: true
        )
        if isQuotedImage == true { fileName = "quoted_\(fileName)" }

        self.save(
            data: uploadableFileInfo.file,
            fileName: fileName,
            subPath: multipleFilesMessage.channelURL,
            completionHandler: completionHandler
        )
    }
}
