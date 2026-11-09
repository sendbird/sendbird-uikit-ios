//
//  Data+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 5/5/21.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation

extension Data {
    /// 영상 데이터의 2초 지점 프레임. 임시 파일을 쓰고, 프레임을 뽑은 뒤 지운다.
    /// - Important: 영상 전체를 파일로 쓰고 프레임을 디코드하므로 main 에서 부르지 않는다.
    func videoThumbnail() -> UIImage? {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        guard (try? self.write(to: fileURL)) != nil else { return nil }
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        let avAssetImageGenerator = AVAssetImageGenerator(asset: AVURLAsset(url: fileURL))
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let cmTime = CMTimeMake(value: 2, timescale: 1)
        guard let cgImage = try? avAssetImageGenerator.copyCGImage(at: cmTime, actualTime: nil) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    /// 영상의 화면 크기(회전 반영). 프레임을 디코드하지 않고 트랙 정보만 읽는다. 임시 파일은 읽은 뒤 지운다.
    func videoNaturalSize() -> CGSize? {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        guard (try? self.write(to: fileURL)) != nil else { return nil }
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        guard let track = AVURLAsset(url: fileURL).tracks(withMediaType: .video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        guard size.width != 0, size.height != 0 else { return nil }
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
