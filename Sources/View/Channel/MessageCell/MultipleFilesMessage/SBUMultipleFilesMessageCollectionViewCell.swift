//
//  SBUMultipleFilesMessageCollectionViewCell.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/09/07.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// swiftlint:disable type_name
/// CollectionView Cell used in SBUMultipleFilesMessageCollectionView to show the files of a multiple files message.
/// - Since: 3.10.0
open class SBUMultipleFilesMessageCollectionViewCell: SBUCollectionViewCell {
    // swiftlint:enable type_name

    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public var overlayView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    public var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.isHidden = false
        return imageView
    }()
    
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    public var imageCornerRadius: CGFloat = 1
    
    private(set) var uploadableFileInfo: UploadableFileInfo?
    private(set) var uploadedFileInfo: UploadedFileInfo?
    
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    /// 지금 셀에 묶인 미리보기의 데이터와 크기. 늦게 끝난 디코드 결과가 다른 첨부에 들어가지 않게 비교한다.
    private var previewSource: DecodedPreview.Source?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func configure(
        uploadableFileInfo: UploadableFileInfo? = nil,
        uploadedFileInfo: UploadedFileInfo? = nil,
        requestId: String,
        index: Int,
        imageCornerRadius: CGFloat,
        showOverlay: Bool
    ) {
        self.uploadableFileInfo = uploadableFileInfo
        self.uploadedFileInfo = uploadedFileInfo
        self.imageCornerRadius = imageCornerRadius
        self.previewSource = nil
        
        setupViews()
        setupStyles()
        setupLayouts()
        
        // Image data setup.
        guard let uploadedFileInfo = uploadedFileInfo else {
            // Set image with local image
            // when message.sendingStatus is pending or failed.
            guard let uploadableFileInfo = uploadableFileInfo,
                  let imageData = uploadableFileInfo.file else {
                Log.error("Multiple files message has no files")
                return
            }
            
            // 원본 사진을 main 에서 원본 크기로 풀지 않는다. 백그라운드에서 썸네일 크기로 줄여 디코드한다.
            // 업로드가 하나 끝날 때마다 reload 로 셀이 다시 구성되므로, 결과와 진행 중 디코드를 파일 정보 객체에 붙여 두고
            // 같은 파일이면 그대로 쓴다. 결과는 지금 셀에 묶인 첨부가 같을 때만 넣는다.
            let thumbnailSize = SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize
            let displayScale = UIGraphicsImageRendererFormat.default().scale
            let source = DecodedPreview.Source(data: imageData, size: thumbnailSize, scale: displayScale)
            let preview: DecodedPreview
            if let cached = uploadableFileInfo.decodedPreview, cached.source == source {
                preview = cached
            } else {
                preview = DecodedPreview(source: source)
                uploadableFileInfo.decodedPreview = preview
            }
            self.previewSource = source
            self.imageView.image = nil
            preview.load { [weak self] image in
                // configure 마다 previewSource 를 새로 넣거나 비우므로, 다른 파일 정보, 파일 없이 비운 셀,
                // 같은 객체의 데이터 변경이 모두 이 비교에서 걸린다.
                guard let self = self, self.previewSource == source else { return }
                self.imageView.image = image
            }

            DispatchQueue.main.async { [weak self, uploadableFileInfo] in
                guard let self = self else { return }
                self.overlayView.isHidden = !showOverlay
                if let mimeType = uploadableFileInfo.mimeType, mimeType.hasPrefix("image/gif") {
                    self.setGIFIcon()
                } else {
                    self.iconImageView.isHidden = true
                }
            }
            return
        }
        
        // Set image from server URL
        // when message.sendingStatus is succeeded.
        let fileURL = uploadedFileInfo.url
        self.loadImageSession = self.imageView.loadImage(
            urlString: fileURL,
            option: .imageToThumbnail,
            cacheKey: requestId + "_\(index)"
        ) { _ in
            DispatchQueue.main.async { [weak self, uploadedFileInfo] in
                guard let self = self else { return }
                self.overlayView.isHidden = true
                if let mimeType = uploadedFileInfo.mimeType, mimeType.hasPrefix("image/gif") {
                    self.setGIFIcon()
                } else {
                    self.iconImageView.isHidden = true
                }
            }
        }
        
        self.layoutIfNeeded()
    }
    
    override open func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
        contentView.addSubview(iconImageView)
    }
    
    override open func setupStyles() {
        // contentView
        self.contentView.layer.cornerRadius = self.imageCornerRadius
        self.contentView.layer.masksToBounds = true
        
        self.overlayView.backgroundColor = theme.multipleFilesMessageFileOverlayColor
    }
    
    override open func setupLayouts() {
        // imageView
        self.imageView
            .sbu_constraint(
                equalTo: contentView,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        
        // overlayView
        self.overlayView
            .sbu_constraint(
                equalTo: contentView,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        
        // iconImageView
        self.iconImageView
            .sbu_constraint(equalTo: contentView, centerX: 0, centerY: 0)
            .sbu_constraint(width: 32, height: 32)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.overlayView.isHidden = true
        self.iconImageView.isHidden = true
        self.loadImageSession?.cancel()
        self.previewSource = nil
    }
    
    public func setGIFIcon() {
        self.iconImageView.isHidden = false
        self.iconImageView.image = SBUIconSetType.iconGif.image(
            with: theme.fileImageIconColor,
            to: SBUIconSetType.Metric.iconGifPlay
        )
        
        self.iconImageView.backgroundColor = theme.fileImageBackgroundColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
    }
}

/// 보내는 중인 파일의 미리보기 디코드 결과와 진행 중 디코드. 파일 정보 객체에 붙여 그 객체와 함께 사라진다. main 에서만 쓴다.
final class DecodedPreview: NSObject {
    struct Source: Equatable {
        // 포인터 대신 Data 값을 들고 있는다. 같은 저장소를 공유하므로 따로 메모리를 더 쓰지 않는다.
        let data: Data
        let size: CGSize
        let scale: CGFloat

        static func == (lhs: Source, rhs: Source) -> Bool {
            lhs.size == rhs.size && lhs.scale == rhs.scale && lhs.data.hasSameBytes(as: rhs.data)
        }
    }

    let source: Source
    private var image: UIImage?
    private var isLoading = false
    private var isComplete = false
    private var completionHandlers: [(UIImage?) -> Void] = []

    init(source: Source) {
        self.source = source
    }

    func load(completionHandler: @escaping (UIImage?) -> Void) {
        if self.isComplete {
            completionHandler(self.image)
            return
        }
        self.completionHandlers.append(completionHandler)
        guard self.isLoading == false else { return }
        self.isLoading = true
        let source = self.source
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let image = CGImageSourceCreateWithData(source.data as CFData, nil)
                .flatMap { UIImage.firstFrameThumbnail(source: $0, fitting: source.size, scale: source.scale) }
            Thread.executeOnMain { [weak self] in
                guard let self = self else { return }
                self.image = image
                self.isComplete = true
                let handlers = self.completionHandlers
                self.completionHandlers.removeAll()
                handlers.forEach { $0(image) }
            }
        }
    }
}

private extension Data {
    /// 미리보기를 구성할 때마다 main 에서 원본 사진 전체를 비교하지 않는다.
    /// 둘 다 살아 있는 동안 같은 저장소를 가리키면 같은 바이트다. 저장소가 다르면 값 전체를 비교한다.
    func hasSameBytes(as other: Data) -> Bool {
        guard self.count == other.count else { return false }
        let sharesStorage = self.withUnsafeBytes { lhs in
            other.withUnsafeBytes { rhs in lhs.baseAddress == rhs.baseAddress }
        }
        return sharesStorage || self == other
    }
}

private var decodedPreviewKey: UInt8 = 0

extension UploadableFileInfo {
    var decodedPreview: DecodedPreview? {
        get { objc_getAssociatedObject(self, &decodedPreviewKey) as? DecodedPreview }
        set { objc_setAssociatedObject(self, &decodedPreviewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
