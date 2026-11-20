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
                self.preSaveImage(
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

        self.preSaveImage(
            data: uploadableFileInfo.file,
            fileName: fileName,
            subPath: multipleFilesMessage.channelURL,
            completionHandler: completionHandler
        )
    }
    
    /// 보내기 직전(main)에 보낼 이미지를 캐시에 넣는다.
    /// 프레임 비트맵 합이 상한을 넘는 GIF 는 이미지를 만들면 모든 프레임을 디코드해 main 이 그만큼 멈추므로, 인코딩된 데이터만
    /// 디스크에 저장한다. 프레임은 원본을 요청할 때 디스크 적중 경로가 main 밖에서 만든다(`loadCachedImage`). 메모리 캐시는 미리 채우지 않는다.
    /// 그 밖의 이미지는 develop 처럼 만들어 메모리 캐시도 채운다(lazy 라 만들기가 짧다).
    private static func preSaveImage(
        data: Data?,
        fileName: String,
        subPath: String,
        completionHandler: SBUImageCacheCompletionHandler?
    ) {
        if let data = data, UIImage.decodesAllFramesOnCreate(data: data) {
            let key = self.key(fileName: fileName, subPath: subPath)
            self.diskCache.set(key: key, data: data as NSData, completionHandler: completionHandler)
            return
        }
        self.save(data: data, fileName: fileName, subPath: subPath, completionHandler: completionHandler)
    }
}
