//
//  SBUFileViewController.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import AssetsLibrary

@available(*, deprecated, renamed: "SBUFileViewController")
public typealias SBUFileViewer = SBUFileViewController

@available(*, deprecated, renamed: "SBUFileViewControllerDelegate")
public typealias SBUFileViewerDelegate = SBUFileViewControllerDelegate

public protocol SBUFileViewControllerDelegate: AnyObject {
    func didSelectDeleteImage(message: FileMessage)
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
                with: SBUColorSet.ondark01,
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
    
    private var bottomViewHeightAnchor: NSLayoutConstraint!

    // for logic
    private var urlString: String?
    private weak var delegate: SBUFileViewControllerDelegate?
    private var fileMessage: FileMessage?
    
    // MARK: - Lifecycle
    required public init(fileMessage: FileMessage, delegate: SBUFileViewControllerDelegate?) {
        self.fileMessage = fileMessage
        self.urlString = fileMessage.url
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
     }
     
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
         
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(self.onClickImage(sender:)))
        self.view.addGestureRecognizer(gesture)

        self.view.bringSubviewToFront(self.bottomView)

        // Title View
        if let titleView = self.navigationItem.titleView as? TitleView {
            if let sender = fileMessage?.sender {
                titleView.titleLabel.text = SBUUser(user: sender).refinedNickname()
            } else {
                titleView.titleLabel.text = SBUStringSet.User_No_Name
            }
            if let timestamp = fileMessage?.createdAt {
                titleView.dateTimeLabel.text = Date
                    .sbu_from(timestamp)
                    .sbu_toString(dateFormat: SBUDateFormatSet.Message.fileViewControllerTimeFormat)
            } else {
                titleView.dateTimeLabel.text = ""
            }
            
            titleView.updateConstraints()
        }
        
        // Bottom View
        if let bottomView = self.bottomView as? BottomView {

            let isCurrnetUser = self.fileMessage?.sender?.userId == SBUGlobals.currentUser?.userId
            bottomView.deleteButton.isHidden = !isCurrnetUser

            bottomView.downloadButton.addTarget(self,
                                                action: #selector(onClickDownload(sender:)),
                                                for: .touchUpInside)
            if let fileMessage = fileMessage, fileMessage.threadInfo.replyCount > 0 {
                bottomView.deleteButton.isHidden = true
            } else {
                bottomView.deleteButton.addTarget(self,
                                                  action: #selector(onClickDelete(sender:)),
                                                  for: .touchUpInside)
            }
                
        }
        
        guard let urlString = urlString else { return }
        self.imageView.loadImage(
            urlString: urlString,
            cacheKey: self.fileMessage?.cacheKey,
            subPath: self.fileMessage?.channelURL ?? ""
        )
        
        if let fileMessage = fileMessage {
            SBUCacheManager.Image.preSave(fileMessage: fileMessage)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupStyles()
    }
    
    open override func updateViewConstraints() {
        super.updateViewConstraints()
        bottomViewHeightAnchor.constant = 56 + view.safeAreaInsets.bottom
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
        self.bottomViewHeightAnchor = self.bottomView.heightAnchor.constraint(equalToConstant: 56)
        
        let constraints: [NSLayoutConstraint] = [
            self.bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            self.bottomView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            self.bottomView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            self.bottomViewHeightAnchor,
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    open override func updateLayouts() {
        self.scrollView.frame = self.view.bounds
        self.scrollView.setZoomScale(1, animated: true)
        self.imageView.frame = self.scrollView.bounds
    }

    open override func setupStyles() {
        self.view.backgroundColor = SBUColorSet.background600
        
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = SBUColorSet.overlay01

        self.scrollView.backgroundColor = .clear
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.imageView.backgroundColor = SBUColorSet.background600
        
        self.leftBarButton?.tintColor = SBUColorSet.ondark01
    }
    
    // MARK: - Actions
    open override func onClickBack() {
        self.dismiss(animated: true)
    }
    
    @objc
    open func onClickDelete(sender: UIButton) {
        let deleteButton = SBUAlertButtonItem(title: SBUStringSet.Delete,
                                              color: SBUColorSet.error300) { [weak self] _ in
            guard let self = self else { return }
            guard let fileMessage = self.fileMessage else { return }
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
        guard let fileMessage = self.fileMessage else { return }
        
        SBUDownloadManager.saveImage(with: fileMessage, parent: self)
    }
    
    @objc
    open func onClickImage(sender: UITapGestureRecognizer) {

        self.showBar(self.bottomView.isHidden)
    }

    open func showBar(_ shouldShow: Bool) {
        if shouldShow {
            self.bottomView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationController?.navigationBar.alpha = 1
                self.bottomView.alpha = 1
                self.scrollView.setZoomScale(1, animated: true)
                self.imageView.frame = self.scrollView.bounds
            }) { _ in
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationController?.navigationBar.alpha = 0
                self.bottomView.alpha = 0
            }) { _ in
                self.bottomView.isHidden = true
            }
        }
    }
    
    @objc
    open func onSaveImage(_ image: UIImage,
                           didFinishSavingWithError error: NSError?,
                           contextInfo: UnsafeRawPointer) {
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
            self.stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let constraints = [
                self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                self.stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
                self.stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            ]
            
            NSLayoutConstraint.activate(constraints)
        }
        
        func setupStyles() {
            self.backgroundColor = .clear
            
            self.titleLabel.font = SBUFontSet.subtitle1
            self.titleLabel.textColor = SBUColorSet.ondark01
            
            self.dateTimeLabel.font = SBUFontSet.caption2
            self.dateTimeLabel.textColor = SBUColorSet.ondark01
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
            self.stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let constraints = [
                self.stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
                self.stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12),
                self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
                self.stackView.heightAnchor.constraint(equalToConstant: 32),
                self.deleteButton.widthAnchor.constraint(equalToConstant: 32),
                self.downloadButton.widthAnchor.constraint(equalToConstant: 32),
            ]
            
            NSLayoutConstraint.activate(constraints)
        }
        
        func setupStyles() {
            self.backgroundColor = SBUColorSet.overlay01
            self.downloadButton.setImage(
                SBUIconSetType.iconDownload.image(
                    with: SBUColorSet.ondark01,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
            self.deleteButton.setImage(
                SBUIconSetType.iconDelete.image(with: SBUColorSet.ondark01,
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
