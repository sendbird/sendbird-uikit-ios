//
//  SBUFileViewController.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// `SBUFileViewer` is a typealias for `SBUFileViewController`.
/// It is deprecated and should be replaced with `SBUFileViewController`.
@available(*, deprecated, renamed: "SBUFileViewController")
public typealias SBUFileViewer = SBUFileViewController

/// `SBUFileViewerDelegate` is a typealias for `SBUFileViewControllerDelegate`.
/// It is deprecated and should be replaced with ``SBUFileViewControllerDelegate``.
@available(*, deprecated, renamed: "SBUFileViewControllerDelegate")
public typealias SBUFileViewerDelegate = SBUFileViewControllerDelegate

/// `SBUFileViewControllerDelegate` is a protocol that defines the delegate methods for `SBUFileViewController`.
/// The delegate methods provide information about the interactions with the file view controller.
public protocol SBUFileViewControllerDelegate: AnyObject {
    func didSelectDeleteImage(message: FileMessage)
}

/// The main information about file used in views.
///
/// - **Example usage:**
/// ```swift
/// let file = SBUFileData(fileMessage: fileMessage)
/// ```
/// ```swift
/// // multiple files message case
/// let fileInfo = multipleFilesMessage.files[index]
/// let file = SBUFileData(
///     urlString: fileInfo.url,
///     message: multipleFilesMessage,
///     cacheKey: multipleFilesMessage.cacheKey + "_\(index)",
///     fileType: SBUUtils.getFileType(by: fileInfo.mimeType!)
///     name: fileInfo.fileName!
/// )
/// ```
public struct SBUFileData {
    /// The string value of the file URL
    let urlString: String
    /// The message that contains the file.
    let message: BaseMessage
    /// The key that is used for caching
    let cacheKey: String?
    /// The type of file. See ``SBUMessageFileType`` for more information.
    let fileType: SBUMessageFileType
    /// The name of the file
    let name: String
    
    /// The value is same as channel URL.
    var subPath: String {
        self.message.channelURL
    }
    
    init(urlString: String, message: BaseMessage, cacheKey: String?, fileType: SBUMessageFileType, name: String) {
        self.urlString = urlString
        self.message = message
        self.cacheKey = cacheKey
        self.fileType = fileType
        self.name = name
    }
    
    init(fileMessage: FileMessage) {
        self.init(
            urlString: fileMessage.url,
            message: fileMessage,
            cacheKey: fileMessage.cacheKey,
            fileType: SBUUtils.getFileType(by: fileMessage),
            name: fileMessage.name
        )
    }
}

/// The ``SBUBaseViewController`` that displays file content on `FileMessage`
///
/// **Customization Guide**
/// ```swift
/// SBUCommonViewControllerSet.FileViewController = MyAppFileViewController.self
/// ```
open class SBUFileViewController: SBUBaseViewController, UIScrollViewDelegate, SBUAlertViewDelegate {
    // MARK: - Public property
    public var leftBarButton: UIBarButtonItem? {
        didSet {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        }
    }
    public var rightBarButton: UIBarButtonItem? {
        didSet {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        }
    }
    
    public var titleView: UIView! = nil {
        didSet {
            self.navigationItem.titleView = self.titleView
        }
    }
    public lazy var imageView = UIImageView(frame: view.bounds)
    public lazy var scrollView: UIScrollView = UIScrollView(frame: view.bounds)
    
    public var bottomView: UIView = BottomView()
    
    // MARK: - Private property
    private lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSetType.iconClose.image(
                with: SBUColorSet.onDarkTextHighEmphasis,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            style: .plain,
            target: self,
            action: #selector(SBUFileViewController.onClickBack)
        )
    }()
    
    private lazy var defaultTitleView: UIView = {
        if let navigationBar = self.navigationController?.navigationBar {
            return TitleView(frame: CGRect(
                x: 0,
                y: 0,
                width: navigationBar.topItem?.titleView?.frame.width ?? 0.0,
                height: 50)
            )
        }

        return TitleView(frame: CGRect())
    }()
    
    private var bottomViewHeightAnchorConstraint: NSLayoutConstraint?
    private var bottomViewBottomAnchorConstraint: NSLayoutConstraint?
    private var bottomViewLeftAnchorConstraint: NSLayoutConstraint?
    private var bottomViewRightAnchorConstraint: NSLayoutConstraint?

    // for logic
    private var urlString: String? { fileData.urlString }
    private weak var delegate: SBUFileViewControllerDelegate?
    
    private var fileData: SBUFileData
    
    // MARK: - Lifecycle
    /// Initializes ``SBUFileViewController`` with `FileMessage`
    required public convenience init(
        fileMessage: FileMessage,
        delegate: SBUFileViewControllerDelegate?
    ) {
        let fileData = SBUFileData(fileMessage: fileMessage)
        self.init(fileData: fileData, delegate: delegate)
    }
    
    /// Initializes ``SBUFileViewController`` with ``SBUFileData`` and ``SBUFileViewControllerDelegate``
    ///
    /// - File Message Example
    /// ```swift
    /// let file = SBUFileData(fileMessage: fileMessage)
    /// SBUCommonViewControllerSet.FileViewController.init(
    ///     file: file,
    ///     delegate: self
    /// )
    /// ```
    ///
    /// - Multiple Files Message Example
    /// ```swift
    /// let fileInfo = multipleFilesMessage.files[index]
    /// let file = SBUFileData(
    ///     urlString: fileInfo.url,
    ///     message: multipleFilesMessage,
    ///     cacheKey: multipleFilesMessage.cacheKey + "_\(index)",
    ///     fileType: SBUUtils.getFileType(by: fileInfo.mimeType!)
    ///     name: fileInfo.fileName!
    /// )
    /// SBUCommonViewControllerSet.FileViewController.init(
    ///     file: file,
    ///     delegate: self
    /// )
    /// ```
    required public init(fileData: SBUFileData, delegate: SBUFileViewControllerDelegate?) {
        self.fileData = fileData
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, renamed: "init(params:delegate:)")
    required public init?(coder: NSCoder) {
        if let fileMessage = FileMessage.make(["": ""]) {
            self.fileData = SBUFileData(fileMessage: fileMessage)
            super.init(coder: coder)
        } else {
            fatalError("`init?(coder:)` has not been implemented. Use `init(params:delegate:)`")
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
         
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.onClickImage(sender:))
        )
        self.view.addGestureRecognizer(gesture)

        self.view.bringSubviewToFront(self.bottomView)

        // Title View
        if let titleView = self.navigationItem.titleView as? TitleView {
            if let sender = self.fileData.message.sender {
                titleView.titleLabel.text = SBUUser(user: sender).refinedNickname()
            } else {
                titleView.titleLabel.text = SBUStringSet.User_No_Name
            }
            
            titleView.dateTimeLabel.text = Date
                .sbu_from(self.fileData.message.createdAt)
                .sbu_toString(dateFormat: SBUDateFormatSet.Message.fileViewControllerTimeFormat)
            
            titleView.updateConstraints()
        }
        
        // Bottom View
        if let bottomView = self.bottomView as? BottomView {

            let hidesDeleteButton = self.fileData.message.threadInfo.replyCount > 0
            || self.fileData.message.sender?.userId != SBUGlobals.currentUser?.userId
            || self.fileData.message as? MultipleFilesMessage != nil
            
            bottomView.deleteButton.isHidden = hidesDeleteButton
            if !hidesDeleteButton {
                bottomView.deleteButton.addTarget(
                    self,
                    action: #selector(onClickDelete(sender:)),
                    for: .touchUpInside
                )
            }
            bottomView.downloadButton.addTarget(
                self,
                action: #selector(onClickDownload(sender:)),
                for: .touchUpInside
            )
        }
        
        guard let urlString = urlString else { return }
        self.imageView.loadImage(
            urlString: urlString,
            cacheKey: self.fileData.cacheKey,
            subPath: self.fileData.message.channelURL
        )
        
        // TODO: MFM also
        if let fileMessage = self.fileData.message as? FileMessage {
            SBUCacheManager.Image.preSave(fileMessage: fileMessage)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupStyles()
    }
    
    open override func updateViewConstraints() {
        super.updateViewConstraints()
        bottomViewHeightAnchorConstraint?.constant = 56 + view.safeAreaInsets.bottom
    }
    
    open override func viewDidLayoutSubviews() {
        self.updateLayouts()

        super.viewDidLayoutSubviews()
    }
     
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        if self.titleView == nil {
            self.titleView = self.defaultTitleView
        }
        if self.leftBarButton == nil {
            self.leftBarButton = self.closeButton
        }

        // Navigation Bar
        self.navigationItem.titleView = self.titleView
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        
        // Subview
        self.imageView.contentMode = .scaleAspectFit

        self.view.addSubview(self.bottomView)
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.scrollView.delegate = self

        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
    }

    open override func setupLayouts() {
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        self.bottomViewHeightAnchorConstraint?.isActive = false
        self.bottomViewBottomAnchorConstraint?.isActive = false
        self.bottomViewLeftAnchorConstraint?.isActive = false
        self.bottomViewRightAnchorConstraint?.isActive = false
        
        self.bottomViewHeightAnchorConstraint = self.bottomView.heightAnchor.constraint(equalToConstant: 56)
        self.bottomViewBottomAnchorConstraint = self.bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        self.bottomViewLeftAnchorConstraint = self.bottomView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        self.bottomViewRightAnchorConstraint = self.bottomView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)

        self.bottomViewHeightAnchorConstraint?.isActive = true
        self.bottomViewBottomAnchorConstraint?.isActive = true
        self.bottomViewLeftAnchorConstraint?.isActive = true
        self.bottomViewRightAnchorConstraint?.isActive = true
    }
    
    open override func updateLayouts() {
        self.scrollView.frame = self.view.bounds
        self.scrollView.setZoomScale(1, animated: true)
        self.imageView.frame = self.scrollView.bounds
    }

    open override func setupStyles() {
        self.view.backgroundColor = SBUColorSet.background600
        
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = SBUColorSet.overlayDark

        self.scrollView.backgroundColor = .clear
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.imageView.backgroundColor = SBUColorSet.background600
        
        self.leftBarButton?.tintColor = SBUColorSet.onDarkTextHighEmphasis
    }
    
    // MARK: - Actions
    open override func onClickBack() {
        if dismissAction != nil {
            dismissAction?()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc
    open func onClickDelete(sender: UIButton) {
        let deleteButton = SBUAlertButtonItem(title: SBUStringSet.Delete,
                                              color: SBUColorSet.errorMain) { [weak self] _ in
            guard let self = self else { return }
            guard let fileMessage = self.fileData.message as? FileMessage else { return }
            self.delegate?.didSelectDeleteImage(message: fileMessage)
            self.dismiss(animated: true, completion: nil)
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        
        SBUAlertView.show(
            title: SBUStringSet.Alert_Delete,
            confirmButtonItem: deleteButton,
            cancelButtonItem: cancelButton,
            delegate: self
        )
    }
    
    @objc
    open func onClickDownload(sender: UIButton) {
        SBUDownloadManager.save(
            fileData: self.fileData,
            viewController: self
        )
    }
    
    @objc
    open func onClickImage(sender: UITapGestureRecognizer) {
        self.showBar(self.bottomView.isHidden)
    }

    open func showBar(_ shouldShow: Bool) {
        if shouldShow {
            self.bottomView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.navigationController?.navigationBar.alpha = 1
                self.bottomView.alpha = 1
                self.scrollView.setZoomScale(1, animated: true)
                self.imageView.frame = self.scrollView.bounds
            } completion: { _ in
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.navigationController?.navigationBar.alpha = 0
                self.bottomView.alpha = 0
            } completion: { _ in
                self.bottomView.isHidden = true
            }
        }
    }
    
    @objc
    open func onSaveImage(
        _ image: UIImage,
        didFinishSavingWithError error: NSError?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error = error {
            self.errorHandler(error.localizedDescription, error.code)
            return
        }
    }

    // MARK: - UIScrollViewDelegate
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // MARK: - SBUAlertViewDelegate
    open func didDismissAlertView() { }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}

extension SBUFileViewController {
    // MARK: - Default Title View
    fileprivate class TitleView: UIView {
        
        let titleLabel = UILabel()
        let dateTimeLabel = UILabel()
        
        lazy var stackView: SBUStackView = {
            let stackView = SBUStackView(axis: .vertical)
            return stackView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.setupViews()
            self.setupLayouts()
        }
        
        @available(*, unavailable, renamed: "TitleView.init(frame:)")
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        func setupViews() {
            self.addSubview(self.stackView)
            self.stackView.addArrangedSubview(self.titleLabel)
            self.stackView.addArrangedSubview(self.dateTimeLabel)
            
            self.titleLabel.textAlignment = .center
            self.dateTimeLabel.textAlignment = .center
        }
        
        func setupLayouts() {
            self.stackView.sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        }
        
        func setupStyles() {
            self.backgroundColor = .clear
            
            self.titleLabel.font = SBUFontSet.subtitle1
            self.titleLabel.textColor = SBUColorSet.onDarkTextHighEmphasis
            
            self.dateTimeLabel.font = SBUFontSet.caption2
            self.dateTimeLabel.textColor = SBUColorSet.onDarkTextHighEmphasis
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.setupStyles()
        }
    }
    
    // MARK: - Default Bottom View
    fileprivate class BottomView: UIView {
        
        lazy var downloadButton = UIButton()
        lazy var deleteButton = UIButton()
        lazy var stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            return stackView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.setupViews()
            self.setupLayouts()
        }
        
        @available(*, unavailable, renamed: "BottomView.init(frame:)")
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        func setupViews() {
            self.stackView.addArrangedSubview(self.downloadButton)
            self.stackView.addArrangedSubview(UIView())
            self.stackView.addArrangedSubview(self.deleteButton)
            self.addSubview(self.stackView)
        }
        
        func setupLayouts() {
            self.stackView
                .sbu_constraint(equalTo: self, left: 12, right: 12, top: 12)
                .sbu_constraint(height: 32)
            
            self.deleteButton
                .sbu_constraint(height: 32)
            
            self.downloadButton
                .sbu_constraint(height: 32)
        }
        
        func setupStyles() {
            self.backgroundColor = SBUColorSet.overlayDark
            self.downloadButton.setImage(
                SBUIconSetType.iconDownload.image(
                    with: SBUColorSet.onDarkTextHighEmphasis,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
            self.deleteButton.setImage(
                SBUIconSetType.iconDelete.image(with: SBUColorSet.onDarkTextHighEmphasis,
                                                to: SBUIconSetType.Metric.iconActionSheetItem),
                for: .normal
            )
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.setupStyles()
        }
    }
}
