//
//  SBUSelectablePhotoViewController.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2022/03/24.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import Photos

@objc
public protocol SBUSelectablePhotoViewDelegate: AnyObject {
    @objc func didTapSendImageData(_ data: Data)
    
    @objc func didTapSendVideoURL(_ url: URL)
}

@objcMembers
open class SBUSelectablePhotoViewController: UIViewController, SBUViewLifeCycle {
    // MARK: - Views
    /// The collection view that shows the preselected photos and videos.
    public private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    /// The right bar button item on the navigation bar. The default action is showing up the limited library picker to select accessible photos and videos.
    public var rightBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        }
    }
    
    private lazy var editButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            title: SBUStringSet.ViewLibrary,
            style: .plain,
            target: self,
            action: #selector(didTapRightBarButton)
        )
        barButton.tintColor = theme.barItemTintColor
        return barButton
    }()
    
    /// The object that is used as a theme. The theme inherits from `SBUComponentTheme`.
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    
    // MARK: Data
    public weak var delegate: SBUSelectablePhotoViewDelegate?
    
    public var fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: nil)
    
    // MARK: Layouts
    /// If it's `nil`, it returns the size that has 1/3 length of the collection view ‘s horizontal length
    public var columnSize: CGSize {
        customColumnSize ?? defaultColumnSize
    }
    
    private var customColumnSize: CGSize?
    
    private var defaultColumnSize: CGSize {
        let isPortrait = view.frame.height > view.frame.width
        return CGSize(
            value: isPortrait ? (view.frame.width - 2) / 3 : (view.frame.height - 2) / 3
        )
    }
    
    open override func loadView() {
        super.loadView()
        
        self.setupViews()
        self.setupAutolayout()
        self.setupStyles()
        
        PHPhotoLibrary.shared().register(self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
        if #available(iOS 14, *), self.rightBarButton == nil {
            self.rightBarButton = self.editButton
        }

        // Navigation Bar
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        
        
        self.register(photoCell: SBUPhotoCollectionViewCell(), nib: nil)
        self.view.addSubview(collectionView)
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.collectionView
            .sbu_constraint(equalTo: self.view, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    /// This function handles the initialization of actions.
    open func setupActions() { }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.view.backgroundColor = SBUColorSet.background100
    }
    
    /// Used to register a custom cell as a base cell based on `SBUPhotoCollectionViewCell`.
    /// - Parameters:
    ///   - channelCell: Customized channel cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(photoCell: SBUPhotoCollectionViewCell, nib: UINib? = nil) {
        if let nib = nib {
            self.collectionView.register(nib, forCellWithReuseIdentifier: photoCell.sbu_className)
        } else {
            self.collectionView.register(type(of: photoCell), forCellWithReuseIdentifier: photoCell.sbu_className)
        }
    }
    
    @objc
    open func didTapRightBarButton() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        }
    }
}

extension SBUSelectablePhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.fetchResult.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SBUPhotoCollectionViewCell.sbu_className, for: indexPath) as! SBUPhotoCollectionViewCell
        let asset = self.fetchResult[indexPath.item]
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        PHImageManager().requestImage(for: asset, targetSize: self.columnSize, contentMode: .aspectFill, options: requestOptions) { [asset] (image, _) in
            cell.configure(image: image, forMediaType: asset.mediaType)
        }
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width/3 - 2), height: (collectionView.bounds.width/3))
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.fetchResult[indexPath.item]
        
        switch asset.mediaType {
        case .image:
            // send data with media type
            let requestOptions = PHImageRequestOptions()
            PHImageManager().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                guard let data = image?.jpegData(compressionQuality: SBUGlobals.UsingImageCompression ? SBUGlobals.imageCompressionRate : 1.0) else {
                    SBULog.error("No image data")
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didTapSendImageData(data)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        case .video:
            // send url or data with media type
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, info) in
                guard let urlAsset = asset as? AVURLAsset else { return }
                let videoURL = urlAsset.url as URL
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didTapSendVideoURL(videoURL)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            // not supported
            print("not supported")
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
}

extension SBUSelectablePhotoViewController: PHPhotoLibraryChangeObserver {
    /// The `PHPhotoLibraryChangeObserver` delegate method that tells your observer that a set of changes has occurred in the Photos library.
    /// Override this method to handle action when there's any change on the accessible media in photo library.
    /// It reloads the collection view with the changes of preselected photos videos.
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let details = changeInstance.changeDetails(for: self.fetchResult) else { return }
        self.fetchResult = details.fetchResultAfterChanges
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }
}

