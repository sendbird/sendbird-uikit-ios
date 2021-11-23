//
//  SBUFileViewer.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/06.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK
import AssetsLibrary

@objc protocol SBUFileViewerDelegate: NSObjectProtocol {
    func didSelectDeleteImage(message: SBDFileMessage)
}

@objcMembers
class SBUFileViewer: SBUBaseViewController, UIScrollViewDelegate {
    
    // MARK: - Public property
    public var leftBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        }
    }
    public var rightBarButton: UIBarButtonItem? = nil {
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
            action: #selector(SBUFileViewer.onClickBack)
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
    private weak var delegate: SBUFileViewerDelegate?
    private var fileMessage: SBDFileMessage?
  
    
    // MARK: - Lifecycle
    public init(fileMessage: SBDFileMessage, delegate: SBUFileViewerDelegate?) {
        self.fileMessage = fileMessage
        self.urlString = fileMessage.url
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
     }
     
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func loadView() {
        super.loadView()
        
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
        
        // autolayout
        self.setupAutolayout()
        
        // Styles
        self.setupStyles()
    }

    override func setupAutolayout() {
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

    override func setupStyles() {
        self.view.backgroundColor = SBUColorSet.background600
        
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = SBUColorSet.overlay01

        self.scrollView.backgroundColor = .clear
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.imageView.backgroundColor = SBUColorSet.background600
        
        self.leftBarButton?.tintColor = SBUColorSet.ondark01
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
                titleView.dateTimeLabel.text = Date.sbu_from(timestamp).sbu_toString(format: .hhmma)
            } else {
                titleView.dateTimeLabel.text = ""
            }
            
            titleView.updateConstraints()
        }
        
        // Bottom View
        if let bottomView = self.bottomView as? BottomView {

            let isCurrnetUser = self.fileMessage?.sender?.userId == SBUGlobals.CurrentUser?.userId
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
        self.imageView.loadImage(urlString: urlString)
        
        if let url = URL(string: urlString), let fileMessage = fileMessage {
            SBUCacheManager.saveAndLoadFileToLocal(url: url, fileName: fileMessage.name)
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
        super.viewDidLayoutSubviews()

        self.scrollView.frame = self.view.bounds
        self.scrollView.setZoomScale(1, animated: true)
        self.imageView.frame = self.scrollView.bounds

        self.setupStyles()
    }
     
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Actions
    
    override func onClickBack() {
        self.dismiss(animated: true)
    }
    
    @objc func onClickDelete(sender: UIButton) {
        let deleteButton = SBUAlertButtonItem(title: SBUStringSet.Delete,
                                              color: SBUColorSet.error300) { [weak self] _ in
            guard let self = self else { return }
            guard let fileMessage = self.fileMessage else { return }
            self.delegate?.didSelectDeleteImage(message: fileMessage)
            self.dismiss(animated: true, completion: nil)
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        
        SBUAlertView.show(title: SBUStringSet.Alert_Delete,
                          confirmButtonItem: deleteButton,
                          cancelButtonItem: cancelButton)
    }
    
    @objc func onClickDownload(sender: UIButton) {
        guard let fileMessage = self.fileMessage,
              let url = URL(string: fileMessage.url) else { return }
        
        SBUDownloadManager.saveImage(parent: self, url: url, fileName: fileMessage.name)
    }
    
    @objc func onClickImage(sender : UITapGestureRecognizer) {

        self.showBar(self.bottomView.isHidden)
    }

    func showBar(_ shouldShow: Bool) {
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
    
    @objc func onSaveImage(_ image: UIImage,
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
    
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBDError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    @available(*, deprecated, renamed: "errorHandler") // 2.1.12
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}

extension SBUFileViewer {
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
            self.setupAutolayout()
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
        
        func setupAutolayout() {
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
            self.setupAutolayout()
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
        
        func setupAutolayout() {
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
