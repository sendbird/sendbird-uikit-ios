//
//  SBUCacheManager.Image.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/01/15.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SendbirdChatSDK

// File cache path: {cachesDirectory}/image/{REQ_ID}.{EXT}

/// main 에서 부르는 이미지 캐시 조회(`SBUCacheManager.Image.loadCachedImage`)의 결과.
enum SBUCachedImageLookup {
    /// 바로 쓸 이미지. 메모리 적중이거나, 만들기가 짧은 디스크 적중이다.
    case image(UIImage)
    /// 프레임 비트맵 합이 상한을 넘는 GIF 의 디스크 적중. 모든 프레임은 main 밖에서 만들고, 그동안 넣을 첫 프레임(GIF 와 같은 크기)이다.
    /// 다 만든 GIF 는 `SBUCacheManager.Image.whenAllFramesDecoded(for:completion:)` 로 받는다.
    case firstFrame(UIImage)
    /// 캐시에 없거나 이미지로 읽히지 않는다.
    case miss
}

/// 상한을 넘는 GIF 의 모든 프레임을 만드는 main 밖 디코드 하나. 같은 키의 요청은 이 디코드 하나에 합류해 같은 인스턴스를 받는다.
final class SBUAllFramesDecode {
    private let lock = NSLock()
    /// 디코드 중 합류한 요청에 줄 첫 프레임. 끝나면 놓는다(첫 프레임이 이 객체를 들고 있어 순환을 끊는다).
    private var firstFrame: UIImage?
    private var isFinished = false
    /// 끝난 결과. 메모리 캐시와 뷰가 들고 있으므로 여기서는 붙잡지 않는다.
    private weak var result: UIImage?
    private var waiters: [(UIImage?) -> Void] = []

    init(firstFrame: UIImage) {
        self.firstFrame = firstFrame
    }

    /// 합류한 요청마다 따로 넣을 첫 프레임. 비트맵은 같이 쓰고 인스턴스만 새로 만들어, 뷰가 그 요청이 넣은 이미지를 보여 주는지 `===` 로 가른다.
    func newFirstFrameInstance() -> UIImage? {
        self.lock.lock()
        defer { self.lock.unlock() }
        guard let firstFrame = self.firstFrame, let cgImage = firstFrame.cgImage else { return nil }
        let image = UIImage(cgImage: cgImage, scale: firstFrame.scale, orientation: firstFrame.imageOrientation)
        image.isFromOversizedGIF = true
        image.allFramesDecode = self
        return image
    }

    func finish(_ image: UIImage?) {
        self.lock.lock()
        self.isFinished = true
        self.result = image
        self.firstFrame = nil
        let waiters = self.waiters
        self.waiters = []
        self.lock.unlock()
        DispatchQueue.main.async { waiters.forEach { $0(image) } }
    }

    /// 다 만든 GIF 를 main 에서 받는다. 이미 끝났어도 지금 바로 부르지 않고 main 의 다음 차례에 부른다.
    func notify(_ completion: @escaping (UIImage?) -> Void) {
        self.lock.lock()
        if self.isFinished {
            let image = self.result
            self.lock.unlock()
            DispatchQueue.main.async { completion(image) }
            return
        }
        self.waiters.append(completion)
        self.lock.unlock()
    }
}

private var allFramesDecodeKey: UInt8 = 0

extension UIImage {
    /// 상한을 넘는 GIF 의 첫 프레임이면, 그 GIF 의 모든 프레임을 만드는 디코드.
    fileprivate(set) var allFramesDecode: SBUAllFramesDecode? {
        get { objc_getAssociatedObject(self, &allFramesDecodeKey) as? SBUAllFramesDecode }
        set { objc_setAssociatedObject(self, &allFramesDecodeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension SBUCacheManager {
    class Image {
        static let diskCache = DiskCache(cacheType: "image")
        static let memoryCache = MemoryCache()
        
        /// - Parameter preservesTransparency: `true` 이면 디스크에 PNG 로 저장한다. JPEG 는 투명 영역을
        ///   불투명하게 바꾸므로 투명도가 있을 수 있는 이미지(GIF 첫 프레임 등)에 쓴다.
        @discardableResult
        static func save(
            image: UIImage,
            fileName: String,
            subPath: String,
            preservesTransparency: Bool = false,
            completionHandler: SBUImageCacheCompletionHandler? = nil
        ) -> UIImage? {
            let encoded = preservesTransparency ? image.pngData() : image.jpegData(compressionQuality: 1.0)
            guard let data = encoded else {
                completionHandler?(nil, nil, image)
                return image
            }
            
            let key = key(fileName: fileName, subPath: subPath)
            self.memoryCache.set(key: key, image: image)
            self.diskCache.set(key: key, data: data as NSData, image: image, completionHandler: completionHandler)
            return image
        }
        
        @discardableResult
        static func save(
            data: Data?,
            fileName: String,
            subPath: String,
            completionHandler: SBUImageCacheCompletionHandler? = nil
        ) -> UIImage? {
            return save(
                nsdata: data as NSData?,
                fileName: fileName,
                subPath: subPath,
                completionHandler: completionHandler
            )
        }
        
        static func save(
            nsdata: NSData?,
            fileName: String,
            subPath: String,
            completionHandler: SBUImageCacheCompletionHandler? = nil
        ) -> UIImage? {
            guard let data = nsdata else { return nil }
            guard let image = UIImage.createImage(from: data as Data) else {
                completionHandler?(nil, data, nil)
                return nil
            }

            let key = key(fileName: fileName, subPath: subPath)
            self.memoryCache.set(key: key, image: image)
            self.diskCache.set(key: key, data: data, image: image, completionHandler: completionHandler)
            return image
        }
        
        static func get(fileName: String, subPath: String) -> UIImage? {
            let key = key(fileName: fileName, subPath: subPath)
            if let memoryImage = self.memoryCache.get(key: key) {
                return memoryImage
            } else if let diskData = self.diskCache.get(key: key) {
                return self.image(fromDiskData: diskData as Data, fileName: fileName, subPath: subPath)
            } else {
                /**
                 2022.11.15 - 3.3.0
                 Added internal processing logic to fix image cache issue caused by using same key value when caching original message image and quoted message image.
                 */
                if fileName.contains("quoted_") {
                    let removedPrefix = fileName.replacingOccurrences(of: "quoted_", with: "")
                    let removedThumbnailPrefix = removedPrefix.replacingOccurrences(of: "thumb_", with: "")
                    let original = self.diskCache.get(key: removedPrefix)
                    let quoted = self.diskCache.get(key: fileName)
                    if quoted == nil {
                        if original != nil {
                            self.diskCache.remove(key: removedPrefix)
                            self.diskCache.remove(key: removedThumbnailPrefix)
                            return nil
                        }
                    }
                }
                
                return nil
            }
        }
        
        /// 상한을 넘는 GIF 의 모든 프레임을 만드는 큐. 테스트가 멈춘 큐를 넣어 디코드가 끝나는 때를 정한다.
        static var allFramesDecodeQueue: DispatchQueue = .global(qos: .userInitiated)
        
        private static let offMainLock = NSLock()
        /// 진행 중인 main 밖 디코드. 같은 키는 디코드 하나로 묶어 같은 인스턴스를 나눠 준다.
        private static var decodesInFlight: [String: SBUAllFramesDecode] = [:]
        /// 상한을 넘는 GIF 로 판정한 키. 셀을 그리는 조회가 디스크를 다시 읽지 않게 한다.
        private static var offMainKeys: Set<String> = []
        
        /// `get` 과 같지만, 디스크 데이터가 만들 때 모든 프레임을 디코드하는 GIF(프레임 비트맵 합이 상한을 넘음)면 모든 프레임은
        /// main 밖에서 만들고, 지금은 그 GIF 와 같은 크기의 첫 프레임만 돌려준다(`.firstFrame`). develop 처럼 부른 자리에서 이미지를
        /// 넣고 completion 을 부를 수 있게 한다. 같은 키를 이미 만드는 중이면 그 디코드에 합류한다.
        /// 그 밖의 이미지는 `get` 처럼 바로 만든다(만들기가 짧다).
        static func loadCachedImage(fileName: String, subPath: String) -> SBUCachedImageLookup {
            let key = key(fileName: fileName, subPath: subPath)
            if let memoryImage = self.memoryCache.get(key: key) {
                return .image(memoryImage)
            }
            if let firstFrame = self.firstFrameOfDecodeInFlight(key: key) {
                return .firstFrame(firstFrame)
            }
            // 디스크에 없을 때만 `get` 으로 넘긴다(quoted 캐시 정리).
            guard let diskData = self.diskCache.get(key: key) as Data? else {
                return self.get(fileName: fileName, subPath: subPath).map { .image($0) } ?? .miss
            }
            if let (firstFrame, index) = UIImage.firstFrameOfOversizedAnimation(data: diskData) {
                return self.decodeAllFramesOffMain(diskData, key: key, firstFrame: firstFrame, index: index)
            }
            return self.image(fromDiskData: diskData, fileName: fileName, subPath: subPath).map { .image($0) } ?? .miss
        }
        
        /// `get` 과 같지만(메모리 적중, 디스크 적중, 없음), 상한을 넘는 GIF 의 디스크 적중이면 develop 처럼 부른 자리에서
        /// 원본 크기 lazy 프레임 GIF 를 만들어 돌려준다. main 밖 디코드를 시작하지도, 진행 중인 디코드에 합류하지도 않는다.
        /// 결과를 넣을 뷰를 부른 쪽이 정하는 `loadImage(autoset: false)` 용이다. 첫 프레임을 넘긴 뒤 바꿀 수 없고, completion 을
        /// 디코드 뒤로 미루면 같은 loader 로 연달아 부를 때 순서가 develop 과 달라진다.
        /// 그 GIF 는 develop 처럼 메모리 캐시에 넣어 같은 키를 다시 부를 때 디스크를 읽지 않고 같은 인스턴스를 준다.
        /// 다만 셀이 같은 키로 원본 크기 프레임 GIF 를 받아 그리지 않게 다른 키(`lazyFramesKey(_:)`)에 넣는다.
        static func getKeepingLazyFrames(fileName: String, subPath: String) -> UIImage? {
            let key = key(fileName: fileName, subPath: subPath)
            if let memoryImage = self.memoryCache.get(key: key) {
                return memoryImage
            }
            if let lazyFramesImage = self.memoryCache.get(key: self.lazyFramesKey(key)) {
                return lazyFramesImage
            }
            // 디스크에 없을 때만 `get` 으로 넘긴다(quoted 캐시 정리).
            guard let diskData = self.diskCache.get(key: key) as Data? else {
                return self.get(fileName: fileName, subPath: subPath)
            }
            // 이미지 소스는 한 번만 만들어 상한 판정과 만들기에 같이 쓴다.
            guard let (image, exceedsBudget) = UIImage.createImageKeepingLazyFrames(from: diskData) else { return nil }
            // 넘긴 인스턴스는 lazy 프레임이라 그려지면 디코드된 비트맵을 들고, 캐시에 그대로 넣으면 보여 준 뒤에도 남는다.
            // develop 처럼 캐시용 인스턴스는 메모리 큐에서 따로 만든다. lazy 키에 넣을 때는 그 사이 셀 디코드가 끝나
            // 일반 키에 줄인 GIF 가 들어갔으면 넣지 않는다(줄인 GIF 저장, lazy 삭제 뒤에 lazy 저장이 오는 경합).
            self.memoryCache.set(
                key: exceedsBudget ? self.lazyFramesKey(key) : key,
                skipIfCached: exceedsBudget ? key : nil
            ) {
                UIImage.createImageKeepingLazyFrames(from: diskData)?.image
            }
            return image
        }
        
        /// 상한을 넘는 GIF 를 원본 크기 lazy 프레임으로 만든 이미지(`getKeepingLazyFrames`)의 메모리 캐시 키. 셀이 조회하는 키와 겹치지 않는다.
        static func lazyFramesKey(_ key: String) -> String {
            "\(key)#lazy-frames"
        }
        
        /// `loadCachedImage` 가 돌려준 첫 프레임의 GIF 를 다 만들면 main 에서 넘긴다(만들지 못하면 nil).
        /// 이미 끝났어도 main 의 다음 차례에 부르므로, 첫 프레임을 넣은 뒤 등록하면 넣기보다 늦게 온다.
        static func whenAllFramesDecoded(for firstFrame: UIImage, completion: @escaping (UIImage?) -> Void) {
            guard let decode = firstFrame.allFramesDecode else { return }
            decode.notify(completion)
        }
        
        /// 셀을 그리는 중(main) 부르는 조회. 상한을 넘는 GIF 는 만들지 않고 nil 을 돌려, 부르는 쪽이 비동기 경로로 넘기게 한다.
        /// 한 번 그렇게 판정한 키는 디스크를 다시 읽지 않는다. 그 밖의 이미지는 `get` 처럼 바로 만든다.
        static func getUnlessDecodingAllFrames(fileName: String, subPath: String) -> UIImage? {
            let key = key(fileName: fileName, subPath: subPath)
            if let memoryImage = self.memoryCache.get(key: key) {
                return memoryImage
            }
            self.offMainLock.lock()
            let isKnownOffMain = self.offMainKeys.contains(key)
            self.offMainLock.unlock()
            if isKnownOffMain { return nil }
            guard let diskData = self.diskCache.get(key: key) as Data? else {
                return self.get(fileName: fileName, subPath: subPath)
            }
            if UIImage.decodesAllFramesOnCreate(data: diskData) {
                self.offMainLock.lock()
                self.offMainKeys.insert(key)
                self.offMainLock.unlock()
                return nil
            }
            return self.image(fromDiskData: diskData, fileName: fileName, subPath: subPath)
        }
        
        private static func firstFrameOfDecodeInFlight(key: String) -> UIImage? {
            self.offMainLock.lock()
            let decode = self.decodesInFlight[key]
            self.offMainLock.unlock()
            return decode?.newFirstFrameInstance()
        }
        
        private static func decodeAllFramesOffMain(
            _ data: Data,
            key: String,
            firstFrame: UIImage,
            index: Int
        ) -> SBUCachedImageLookup {
            self.offMainLock.lock()
            self.offMainKeys.insert(key)
            if let joined = self.decodesInFlight[key]?.newFirstFrameInstance() {
                self.offMainLock.unlock()
                return .firstFrame(joined)
            }
            // 메모리를 본 뒤 그 사이 같은 키의 디코드가 끝났으면 그 결과를 쓴다. 끝난 디코드는 메모리 캐시 쓰기를 예약한 뒤
            // 진행 목록에서 빠지고, 메모리 캐시 조회는 같은 직렬 큐라 그 쓰기 뒤에 온다.
            if let cached = self.memoryCache.get(key: key) {
                self.offMainLock.unlock()
                return .image(cached)
            }
            let decode = SBUAllFramesDecode(firstFrame: firstFrame)
            firstFrame.allFramesDecode = decode
            self.decodesInFlight[key] = decode
            self.offMainLock.unlock()
            
            let reusedFrame = firstFrame.cgImage.map { (index: index, image: $0) }
            self.allFramesDecodeQueue.async {
                let image = UIImage.createImage(from: data, reusedFrame: reusedFrame)
                self.offMainLock.lock()
                if let image = image {
                    self.memoryCache.set(key: key, image: image)
                    // 줄인 GIF 가 들어가면 `getKeepingLazyFrames` 도 그것을 받으므로, 원본 크기 lazy 프레임 GIF 는 캐시에서 놓는다.
                    self.memoryCache.remove(key: self.lazyFramesKey(key))
                }
                self.decodesInFlight.removeValue(forKey: key)
                self.offMainLock.unlock()
                decode.finish(image)
            }
            return .firstFrame(firstFrame)
        }
        
        /// 디스크에서 읽은 데이터로 이미지를 만들어 돌려주고 메모리 캐시에 넣는다. 줄여 디코드한 GIF 만 같은 인스턴스를 넣는다.
        /// 상한을 넘는 GIF 는 만들 때 모든 프레임을 디코드하므로, 메모리 캐시용으로 `set(key:data:)` 에서 한 번 더 만들면
        /// 디코드 시간과 메모리가 두 배가 된다.
        static func image(fromDiskData data: Data, fileName: String, subPath: String) -> UIImage? {
            guard let image = UIImage.createImage(from: data) else { return nil }
            let key = key(fileName: fileName, subPath: subPath)
            if image.isFromOversizedGIF {
                // 이미 줄여 디코드한 GIF 는 같은 인스턴스를 넣는다. 한 번 더 만들면 디코드 시간과 메모리가 두 배가 된다.
                self.memoryCache.set(key: key, image: image)
            } else {
                // 일반 사진과 상한 안 GIF 는 lazy 라, 넘긴 인스턴스가 그려지면 디코드된 비트맵을 든다. 그대로 캐시에 넣으면
                // 보여 준 뒤에도 남으므로, develop 처럼 캐시용 인스턴스를 메모리 큐에서 따로 만든다(lazy 라 만들기가 짧다).
                self.memoryCache.set(key: key, data: data as NSData)
            }
            return image
        }
        
        /// 썸네일 조회. 디스크에 여러 프레임 이미지가 있으면(예전 버전이 GIF 원본을 썸네일로 저장한 경우)
        /// 전체 animation 을 만들지 않고 첫 프레임만 `size` 안에 들어가게 디코드한다.
        /// 그 밖에는 `get(fileName:subPath:)` 과 같다.
        static func getThumbnail(fileName: String, subPath: String, fitting size: CGSize, scale: CGFloat) -> UIImage? {
            let key = key(fileName: fileName, subPath: subPath)
            if let memoryImage = self.memoryCache.get(key: key) {
                return memoryImage
            }
            // 디스크에 없을 때만 `get` 으로 넘긴다(quoted 캐시 정리). 읽은 데이터는 다시 읽지 않고 한 번만 디코드한다.
            guard let diskData = self.diskCache.get(key: key) else {
                return self.get(fileName: fileName, subPath: subPath)
            }
            let decoded: UIImage?
            if let source = CGImageSourceCreateWithData(diskData as CFData, nil), CGImageSourceGetCount(source) > 1 {
                decoded = UIImage.firstFrameThumbnail(source: source, fitting: size, scale: scale)
            } else {
                decoded = UIImage.createImage(from: diskData as Data)
            }
            guard let image = decoded else { return nil }
            self.memoryCache.set(key: key, image: image)
            return image
        }
        
        /// 캐시에 이미지로 읽히는 데이터가 있는지만 본다. `get` 과 달리 이미지를 만들지 않는다.
        /// 디스크 데이터가 이미지로 읽히지 않으면 `get` 처럼 없는 것으로 본다(호출부가 다시 받게).
        static func cachedImageExists(fileName: String, subPath: String) -> Bool {
            let key = key(fileName: fileName, subPath: subPath)
            if self.memoryCache.cacheExists(key: key) { return true }
            guard let diskData = self.diskCache.get(key: key),
                  let source = CGImageSourceCreateWithData(diskData as CFData, nil) else {
                return false
            }
            // 형식과 프레임 수만 읽고 픽셀은 풀지 않는다.
            return CGImageSourceGetType(source) != nil && CGImageSourceGetCount(source) > 0
        }
        
        static func createCacheFileName(
            urlString: String,
            cacheKey: String?,
            fileNameForExtension: String? = nil,
            needPathExtension: Bool = true
        ) -> String {
            var fileName = SBUCacheManager.createHashName(urlString: urlString)
            var pathExtension = SBUCacheManager.fileExtension(urlString: urlString)
            if pathExtension.isEmpty {
                pathExtension = SBUCacheManager.fileExtension(urlString: fileNameForExtension ?? "")
            }
            if let cacheKey = cacheKey, !cacheKey.isEmpty {
                self.renameIfNeeded(key: fileName, newKey: cacheKey)
                fileName = cacheKey
            }
            
            if needPathExtension {
                return "\(fileName).\(pathExtension)"
            } else {
                return "\(fileName)"
            }
        }
        
        static func renameIfNeeded(key: String, newKey: String) {
            if self.cacheExists(fileName: key),
               !self.cacheExists(fileName: newKey) {
                
                self.diskCache.rename(key: key, newKey: newKey)
                
                if let image = self.memoryCache.get(key: key) {
                    self.memoryCache.set(key: newKey, image: image)
                    self.memoryCache.remove(key: key)
                }
            }
        }
        
        static func cacheExists(fileName: String) -> Bool {
            return self.memoryCache.cacheExists(key: fileName)
            ? true
            : self.diskCache.cacheExists(key: fileName)
        }
        
        static func key(fileName: String, subPath: String) -> String {
            let key = "\(subPath)\(!subPath.isEmpty ? "/" : "")\(fileName)"
            return key
        }
        
        // MARK: - Reset
        static func resetCache() {
            self.offMainLock.lock()
            self.offMainKeys.removeAll()
            self.offMainLock.unlock()
            self.memoryCache.resetCache()
            self.diskCache.resetCache()
        }
    }
}
