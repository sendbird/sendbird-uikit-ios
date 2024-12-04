//
//  SBUActionSheet.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 16/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This is a typealias for a closure that handles actions in an action sheet.
public typealias SBUActionSheetHandler = () -> Void

/// SBUActionSheetDelegate is a delegate that defines methods for handling action sheet events.
public protocol SBUActionSheetDelegate: NSObjectProtocol {
    func didSelectActionSheetItem(index: Int, identifier: Int)
    func didDismissActionSheet()
}

extension SBUActionSheetDelegate {
    /// This function is called when the action sheet is dismissed.
    public func didDismissActionSheet() {}
}

/// This class is used to create and manage action sheets in the application.
open class SBUActionSheet: NSObject, SBUViewLifeCycle {
    // Public
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme

    public private(set) weak var delegate: SBUActionSheetDelegate?
    
    public private(set) var isShowing: Bool = false
    public private(set) var identifier: Int = -1
    public private(set) var items: [SBUActionSheetItem] = []
    public private(set) var cancelItem = SBUActionSheetItem()

    /// The parent view where the action sheet will be presented. By default, it is set to the application's current window.
    public var parentView: UIView? = UIApplication.shared.currentWindow
    public private(set) var backgroundView = UIButton()
    public private(set) var containerView = UIView()
    public private(set) var itemButtons: [UIButton] = []
    public private(set) var cancelItemButton: UIButton?
    
    public var itemHeight: CGFloat = 56.0
    public var containerCornerRadius: CGFloat = 10.0
    
    // Private
    static private var shared = SBUModuleSet.CommonModule.ActionSheet.init()
    
    static func resetInstance() {
        shared.dismiss()
        shared = SBUModuleSet.CommonModule.ActionSheet.init()
    }
    
    private var dismissHandler: (() -> Void)?
    
    private var safeAreaInset: UIEdgeInsets {
        self.parentView?.safeAreaInsets ?? .zero
    }
    
    let bottomMargin: CGFloat = 48.0
    let sideMargin: CGFloat = 8.0
    let insideMargin: CGFloat = 16.0

    var prevOrientation: UIDeviceOrientation = .unknown
    
    required public override init() {
        super.init()
        self.setupViews()
        self.setupStyles()
        self.setupLayouts()
        self.setupActions()
    }
    
    /// This static function shows the actionSheet.
    ///
    /// - Order
    ///   - item1
    ///   - item2
    ///   - item3
    ///   - cancel
    ///
    /// See the example below for params generation.
    /// ```
    /// SBUActionSheet.show(
    ///     items: [
    ///         SBUActionSheetItem(title: TITLE1, image: IMAGE1),
    ///         SBUActionSheetItem(title: TITLE2, image: IMAGE2),
    ///     ],
    ///     cancelItem: SBUActionSheetItem(title: CANCEL_TITLE)
    /// )
    /// ```
    /// - Parameters:
    ///   - items: Item array
    ///   - cancelItem: Cancel item
    ///   - identifier: ActionSheet identifier
    ///   - oneTimetheme: One-time theme setting
    ///   - delegate: ActionSheet delegate
    open class func show(
        items: [SBUActionSheetItem],
        cancelItem: SBUActionSheetItem,
        identifier: Int = -1,
        oneTimetheme: SBUComponentTheme? = nil,
        delegate: SBUActionSheetDelegate? = nil,
        dismissHandler: (() -> Void)? = nil
    ) {
        Thread.executeOnMain {
            if !cancelItem.isTextAlignmentSet {
                cancelItem.textAlignment = .center
            }
            
            self.shared.show(
                items: items,
                cancelItem: cancelItem,
                identifier: identifier,
                oneTimetheme: oneTimetheme,
                delegate: delegate,
                dismissHandler: dismissHandler
            )
        }
    }
    
    /// This static function dismissed the actionSheet.
    open class func dismiss() {
        Thread.executeOnMain {
            self.shared.dismiss()
        }
    }
    
    // MARK: Lifecycle
    /// Configures the view with necessary actionSheet buttons and layout.
    ///
    /// - Note: If you configure the button customly, please set the tag of the button to item.tag.
    open func configureView() {
        var itemOriginY: CGFloat = 0.0
        for index in 0..<items.count {
            let button = self.createItem(
                item: items[index],
                includesSeparator: (index != items.count-1),
                isTopItem: (index == 0),
                isBottomItem: (index == items.count-1)
            )
            if let tag = items[index].tag {
                button.tag = tag
            } else {
                items[index].tag = index
                button.tag = index
            }
            var buttonFrame = button.frame
            buttonFrame.origin = CGPoint(x: 0, y: itemOriginY)
            button.frame = buttonFrame
            self.itemButtons.append(button)
            self.containerView.addSubview(button)
            
            itemOriginY += button.frame.height
        }

        itemOriginY += sideMargin

        let cancelButton = self.createItem(item: cancelItem, isCancelButton: true)
        cancelButton.frame = CGRect(
            origin: CGPoint(x: 0, y: itemOriginY),
            size: cancelButton.frame.size
        )
        self.cancelItemButton = cancelButton
        self.containerView.addSubview(cancelButton)
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
        self.prevOrientation = UIDevice.current.orientation
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
    }
    
    /// This function updates styles.
    open func updateStyles() {
        self.backgroundView.backgroundColor = theme.overlayColor
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupLayouts() {
    }
    
    /// This function updates layouts.
    open func updateLayouts() {
        guard let parentView = self.parentView else { return }

        self.backgroundView.frame = parentView.bounds
        
        // Set items
        let totalHeight = CGFloat(items.count + 1) * itemHeight + sideMargin + bottomMargin
        let itemWidth = parentView.frame.width
                        - (sideMargin * 2)
                        - (self.safeAreaInset.left + self.safeAreaInset.right)
        self.containerView.frame = CGRect(
            origin: CGPoint(
                x: sideMargin + self.safeAreaInset.left,
                y: parentView.frame.height - totalHeight
            ),
            size: CGSize(width: itemWidth, height: totalHeight)
        )
    }
    
    /// This function handles the initialization of actions.
    open func setupActions() {
        self.backgroundView.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
}

// MARK: - Public
extension SBUActionSheet {
    /// Dismiss the action sheet.
    @objc
    public func dismiss() {
        guard !isShowing else { return }

        self.handleDismiss(isUserInitiated: true)
    }
    
    /// Called when an action sheet button is clicked.
    ///
    /// - Parameter sender: The button that was clicked.
    @objc
    public func onClickActionSheetButton(sender: UIButton) {
        self.dismiss()
        self.delegate?.didSelectActionSheetItem(
            index: sender.tag,
            identifier: self.identifier
        )
        
        let item = self.items.first(where: { $0.tag == sender.tag })
        item?.completionHandler?()
        
        self.items = []
        self.cancelItem = SBUActionSheetItem()
        self.itemButtons = []
        self.cancelItemButton = nil
    }
}

// MARK: - Private
extension SBUActionSheet {
    private func show(
        items: [SBUActionSheetItem],
        cancelItem: SBUActionSheetItem,
        identifier: Int = -1,
        oneTimetheme: SBUComponentTheme? = nil,
        delegate: SBUActionSheetDelegate?,
        dismissHandler: (() -> Void)?
    ) {
        self.storeProperties(
            items: items,
            cancelItem: cancelItem,
            identifier: identifier,
            oneTimetheme: oneTimetheme,
            delegate: delegate,
            dismissHandler: dismissHandler
        )
        self.prepareForDisplay()
        self.configureView()
        self.updateStyles()
        self.updateLayouts()
        self.presentView()
    }
    
    /// Stores properties for the toast view.
    private func storeProperties(
        items: [SBUActionSheetItem],
        cancelItem: SBUActionSheetItem,
        identifier: Int,
        oneTimetheme: SBUComponentTheme?,
        delegate: SBUActionSheetDelegate?,
        dismissHandler: (() -> Void)?
    ) {
        if let oneTimetheme = oneTimetheme {
            self.theme = oneTimetheme
        }
        
        self.identifier = identifier
        self.delegate = delegate
        self.items = items
        self.cancelItem = cancelItem
        self.dismissHandler = dismissHandler
    }

    private func prepareForDisplay() {
        self.parentView = UIApplication.shared.currentWindow
        
        self.handleDismiss(isUserInitiated: false)
        self.addObserverForOrientation()
        
        self.parentView?.addSubview(self.backgroundView)
        self.parentView?.addSubview(self.containerView)
    }

    private func presentView() {
        guard let parentView = self.parentView else { return }
        
        let baseFrame = self.containerView.frame
        self.containerView.frame = CGRect(
            origin: CGPoint(x: baseFrame.origin.x, y: parentView.frame.height),
            size: baseFrame.size
        )
        self.backgroundView.alpha = 0.0
        self.isShowing = true
        UIView.animate(withDuration: 0.1) {
            self.backgroundView.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.containerView.frame = baseFrame
                self.isShowing = false
            })
        }
    }
    
    // MARK: Common
    func addObserverForOrientation() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    func removeObserverForOrientation() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    // MARK: Action
    @objc
    private func handleDismiss(isUserInitiated: Bool = true) {
        for subView in self.containerView.subviews {
            subView.removeFromSuperview()
        }
        
        self.backgroundView.removeFromSuperview()
        self.containerView.removeFromSuperview()
        
        self.removeObserverForOrientation()
        
        if isUserInitiated {
            self.delegate?.didDismissActionSheet()
            let handler = self.dismissHandler
            self.dismissHandler = nil
            self.theme = SBUTheme.componentTheme
            handler?()
        }
    }
    
    // MARK: Make Buttons
    private func createItem(
        item: SBUActionSheetItem,
        includesSeparator: Bool = false,
        isTopItem: Bool = false,
        isBottomItem: Bool = false,
        isCancelButton: Bool = false
    ) -> UIButton {
        let width: CGFloat = (self.parentView?.bounds.width ?? self.containerView.frame.width)
        let itemWidth: CGFloat = width - (self.sideMargin * 2) - (self.safeAreaInset.left + self.safeAreaInset.right)
        let itemButton = UIButton(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: itemWidth, height: self.itemHeight)
            )
        )
        
        itemButton.setBackgroundImage(
            UIImage.from(color: theme.backgroundColor),
            for: .normal
        )
        
        itemButton.setBackgroundImage(
            UIImage.from(color: theme.highlightedColor),
            for: .highlighted
        )
        
        if isCancelButton {
            itemButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        } else {
            itemButton.addTarget(self, action: #selector(onClickActionSheetButton), for: .touchUpInside)
        }

        // Image
        let imageView = UIImageView()
        var isImageSet = false

        // LTR
        // |-----------------------------------itemWidth------------------------------------|
        // |-self.insideMargin-|imageView|-self.insideMargin-|titleLabel|-self.insideMargin-|
        // titleLabel.width = itemWidth - self.insideMargin - imageView.width - self.insideMargin - self.insideMargin
        
        // RTL
        // |-----------------------------------itemWidth------------------------------------|
        // |-self.insideMargin-|titleLabel|-self.insideMargin-|imageView|-self.insideMargin-|
        
        let imageSize: CGFloat = 24.0
        
        var imageViewPosX: CGFloat = 0
        var titleLabelPosX: CGFloat = 0
        var titleLabelWidth: CGFloat = 0
        var textAlignment: NSTextAlignment = .left
        if UIView.getCurrentLayoutDirection().isLTR == true {
            textAlignment = .left
            titleLabelPosX = self.insideMargin
            if item.image != nil {
                imageViewPosX = itemWidth - self.insideMargin - imageSize
                titleLabelWidth = itemWidth - self.insideMargin - imageSize - self.insideMargin - self.insideMargin
            } else {
                titleLabelWidth = itemWidth - self.insideMargin - self.insideMargin
            }
        } else {
            textAlignment = .right
            imageViewPosX = self.insideMargin
            if item.image != nil {
                titleLabelPosX = self.insideMargin + imageSize + self.insideMargin
                titleLabelWidth = itemWidth - self.insideMargin - self.insideMargin - imageSize - self.insideMargin
            } else {
                titleLabelWidth = itemWidth - self.insideMargin - self.insideMargin
            }
        }

        if let image = item.image {
            imageView.frame = CGRect(
                origin: CGPoint(x: imageViewPosX, y: self.insideMargin),
                size: CGSize(width: imageSize, height: imageSize)
            )

            imageView.image = image
            itemButton.addSubview(imageView)
            isImageSet = true
        }
        
        let textImageMargin: CGFloat = (item.textAlignment == .right && isImageSet) ? self.insideMargin : 0.0
        
        // Text
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(
            origin: CGPoint(x: self.insideMargin, y: 0),
            size: CGSize(
                width: itemWidth - (self.insideMargin * 2)
                        - textImageMargin
                        - imageView.frame.width,
                height: self.itemHeight
            )
        )
        titleLabel.text = item.title
        titleLabel.font = item.font ?? theme.actionSheetTextFont
        titleLabel.textColor = item.color ?? theme.actionSheetTextColor
        titleLabel.textAlignment = textAlignment
        
        titleLabel.frame = CGRect(
            origin: CGPoint(x: titleLabelPosX, y: 0),
            size: CGSize(width: titleLabelWidth, height: self.itemHeight)
        )
        
        itemButton.addSubview(titleLabel)
        
        if includesSeparator && !isCancelButton {
            let separatorLine = UIView(
                frame: CGRect(
                    origin: CGPoint(x: 0.0, y: itemHeight - 0.5),
                    size: CGSize(width: itemWidth, height: 0.5)
                )
            )
            separatorLine.backgroundColor = theme.separatorColor
            itemButton.addSubview(separatorLine)
        }

        var corners: UIRectCorner = []
        if isCancelButton {
            corners.update(with: [.allCorners])
        } else {
            if isTopItem { corners.update(with: [.topLeft, .topRight]) }
            if isBottomItem { corners.update(with: [.bottomLeft, .bottomRight]) }
        }

        let rectShape = CAShapeLayer()
        rectShape.bounds = itemButton.frame
        rectShape.position = itemButton.center
        rectShape.path = UIBezierPath(
            roundedRect: itemButton.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: containerCornerRadius, height: containerCornerRadius)
        ).cgPath
        itemButton.layer.mask = rectShape
        
        return itemButton
    }
    
    // MARK: Orientation
    @objc
    func orientationChanged(_ notification: NSNotification) {
        let currentOrientation = UIDevice.current.orientation
        
        if prevOrientation.isPortrait && currentOrientation.isLandscape ||
            prevOrientation.isLandscape && currentOrientation.isPortrait {
            dismiss()
        }

        self.prevOrientation = currentOrientation
    }
}
