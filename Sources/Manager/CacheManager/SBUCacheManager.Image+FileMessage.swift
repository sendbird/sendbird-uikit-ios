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
                guard let file = messageParams.file else { break }
                let subPath = fileMessage.channelURL
                // 보내기 버튼을 누른 main 에서 불린다. 영상을 파일로 쓰고 프레임을 뽑는 일은 백그라운드에서 한다.
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let image = file.videoThumbnail() else { return }
                    self.save(
                        image: image,
                        fileName: fileName,
                        subPath: subPath,
                        completionHandler: completionHandler
                    )
                }
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
