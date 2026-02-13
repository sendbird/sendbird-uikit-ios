//
//  SBUMenuView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 16/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This typealias is deprecated and has been renamed to `SBUMenuHandler`
@available(*, deprecated, renamed: "SBUMenuHandler")
public typealias SBUMenunHandler = SBUMenuHandler

/// This typealias is used to define a closure that takes no parameters and returns no value.
/// It is typically used as a completion handler for various operations in the `SBUMenuItem` class.
/// - Since: 3.19.0
public typealias SBUMenuHandler = () -> Void

/// `SBUMenuItem` is a class that inherits from `SBUCommonItem`. It is used to create menu items in the application.
public class SBUMenuItem: SBUCommonItem {
    var completionHandler: SBUMenuHandler?
    
    /// A Boolean value that determines whether the `SBUMenuItem` is enabled.
    ///
    /// When the value of this property is `false`, the `completionHandler` is set to `nil`.
    /// When the value of this property is `true`, the `completionHandler` retains its value.
    public var isEnabled: Bool = true {
        didSet {
            guard isEnabled == false else { return }
            completionHandler = nil
        }
    }
    
    /// Indicates whether selecting this item will trigger a transition to another view controller.
    ///
    /// Set to `true` if the menu's actions will cause the ViewController that uses the `SBUMenuSheetController` to disappear
    ///
    /// - Since: 3.9.1
    public var transitionsWhenSelected: Bool = false
    
    /// - Parameters:
    ///    - font: The default is `nil`.  If `nil`, the menu text label will set it's font to ``SBUComponentTheme/menuTitleFont``
    public init(
        title: String? = nil,
        color: UIColor? = SBUColorSet.onLightTextHighEmphasis,
        image: UIImage? = nil,
        font: UIFont? = nil,
        tintColor: UIColor? = nil,
        textAlignment: NSTextAlignment = .left,
        tag: Int? = nil,
        completionHandler: SBUMenuHandler? = nil
    ) {
        super.init(
            title: title,
            color: color,
            image: image,
            font: font,
            tintColor: tintColor,
            textAlignment: textAlignment,
            tag: tag
        )
        self.completionHandler = completionHandler
    }
}

// MOD TODO: Need to make module and components
// MOD TODO: Need to add CustomComponent sample
// If the reaction feature is enabled, the `SBUMenuSheetViewController` is used; if it is disabled, the `SBUMenuView` is used.
class SBUMenuView: NSObject {
    static private let shared = SBUMenuView()
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    private var items: [SBUMenuItem] = []
    
    var window: UIWindow?
    var baseView = UIView()
    var glassEffectView = UIVisualEffectView() // 3.34.0
    var backgroundView = UIButton()
    
    @SBUAdaptive(base: 10.0, liquidGlass: 22.0)
    var cornerRadius: CGFloat
    
    @SBUAdaptive(base: 180.0, liquidGlass: 198.0)
    var itemWidth: CGFloat
    
    let itemHeight: CGFloat = 40.0
    
    @SBUAdaptive(base: 14.0, liquidGlass: 24.0)
    var leftMargin: CGFloat
    
    @SBUAdaptive(base: 8.0, liquidGlass: 14.0)
    var midMargin: CGFloat
    
    @SBUAdaptive(base: 18.0, liquidGlass: 24.0)
    var rightMargin: CGFloat
    
    @SBUAdaptive(base: 8.0, liquidGlass: 10.0)
    var imageTopBottomMargin: CGFloat
    
    @SBUAdaptive(base: 0.0, liquidGlass: 10.0)
    var topBottomMargin: CGFloat
    
    @SBUAdaptive(base: 24.0, liquidGlass: 16.0)
    var iconSize: CGFloat
    
    let bufferVerticalMargin: CGFloat = 15.0
    let bufferHorizontalMargin: CGFloat = 36.0

    var dismissHandler: (() -> Void)?
    
    var prevOrientation: UIDeviceOrientation = .unknown
    
    var isShowing: Bool = false
    
    private override init() {
        super.init()
    }
    
    /**
     [Order]
     - item1
     - item2
     - item3
     */
    public static func show(items: [SBUMenuItem],
                            point: CGPoint,
                            oneTimetheme: SBUComponentTheme? = nil,
                            dismissHandler: (() -> Void)? = nil) {
        SBUMenuView.shared.show(
            items: items,
            point: point,
            oneTimetheme: oneTimetheme,
            dismissHandler: dismissHandler
        )
    }
    
    public static func dismiss() {
        SBUMenuView.shared.dismiss()
    }
    
    private func show(items: [SBUMenuItem],
                      point: CGPoint,
                      oneTimetheme: SBUComponentTheme? = nil,
                      dismissHandler: (() -> Void)? = nil) {
        self.dismissHandler = nil
        self.dismiss()

        self.dismissHandler = dismissHandler
        
        self.prevOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        self.window = UIApplication.shared.currentWindow
        guard let window = self.window else { return }
        
        self.items = items
        self.backgroundView.frame = self.window?.bounds ?? .zero
        self.backgroundView.backgroundColor = .clear
        self.backgroundView.addTarget(self, action: #selector(dismiss), for: .touchUpInside)

        let totalHeight = CGFloat(items.count) * itemHeight + (topBottomMargin * 2)
        print("++ DEBUG: items.count=\(items.count), itemHeight=\(itemHeight), topBottomMargin=\(topBottomMargin), totalHeight=\(totalHeight)")
        var originY: CGFloat = 0.0
        var originX: CGFloat = 0.0

        if point.y + totalHeight + bufferHorizontalMargin + itemHeight > window.frame.height {
            originY = window.frame.height - totalHeight - bufferHorizontalMargin - itemHeight
        } else if point.y < bufferHorizontalMargin {
            originY = bufferHorizontalMargin
        } else {
            originY = point.y
        }
        originY += itemHeight
        if point.x + itemWidth + bufferVerticalMargin > window.frame.width {
            originX = window.frame.width - itemWidth - bufferVerticalMargin
        } else if point.x < bufferVerticalMargin {
            originX = bufferVerticalMargin
        } else {
            originX = point.x
        }

        self.baseView.frame = CGRect(
            origin: CGPoint(x: originX, y: originY),
            size: CGSize(width: self.itemWidth, height: totalHeight)
        )

        // Liquid glass
        if SendbirdUI.config.common.shouldApplyLiquidGlass,
            let visualEffectView = createGlassEffectView() {
            self.glassEffectView = visualEffectView
            self.baseView.insertSubview(self.glassEffectView, at: 0)
        }
        
        let showSeparator = !SendbirdUI.config.common.shouldApplyLiquidGlass

        var itemOriginY: CGFloat = topBottomMargin
        for index in 0..<items.count {
            let button = self.makeItems(
                item: items[index],
                separator: showSeparator && (index != items.count-1),
                isTop: (index == 0),
                isBottom: (index == items.count-1),
                theme: oneTimetheme ?? self.theme
            )
            button.tag = index
            var buttonFrame = button.frame
            buttonFrame.origin = CGPoint(x: 0, y: itemOriginY)
            button.frame = buttonFrame
            button.backgroundColor = oneTimetheme?.backgroundColorAdaptive ?? theme.backgroundColorAdaptive
            
            self.baseView.addSubview(button)
            
            itemOriginY += button.frame.height
        }
        
        self.addShadow(theme: oneTimetheme ?? theme)

        window.addSubview(self.backgroundView)
        window.addSubview(self.baseView)
        self.baseView.alpha = 0.0
        
        self.isShowing = true
        UIView.animate(withDuration: 0.2, animations: {
            self.baseView.alpha = 1.0
            self.isShowing = false
        })
    }
    
    @objc
    private func dismiss() {
        guard !isShowing else { return }

        for subView in self.baseView.subviews {
            subView.removeFromSuperview()
        }
        
        self.backgroundView.removeTarget(self, action: #selector(dismiss), for: .touchUpInside)
        self.backgroundView.removeFromSuperview()
        self.baseView.removeFromSuperview()
        
        self.items = []
        self.window = nil
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        self.dismissHandler?()
    }
    
    // MARK: Make Buttons
    private func makeItems(
        item: SBUMenuItem,
        separator: Bool,
        isTop: Bool,
        isBottom: Bool,
        theme: SBUComponentTheme
    ) -> UIButton {
        let itemButton = UIButton(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: itemWidth, height: self.itemHeight)
            )
        )

        itemButton.setBackgroundImage(UIImage.from(color: theme.backgroundColorAdaptive), for: .normal)
        itemButton.setBackgroundImage(UIImage.from(color: theme.highlightedColor), for: .highlighted)
        itemButton.addTarget(self, action: #selector(onClickMenuButton), for: .touchUpInside)
        
        let titleLabel = UILabel()
        
        titleLabel.text = item.title
        titleLabel.font = item.font ?? theme.menuTitleFont
        titleLabel.textColor = item.color
        
        // LTR
        // |-------------------------itemWidth-------------------------|
        // |-leftMargin-|titleLabel|-midMargin-|imageView|-rightMargin-|
        
        // RTL
        // |-------------------------itemWidth-------------------------|
        // |-leftMargin-|imageView|-midMargin-|titleLabel|-rightMargin-|
        var imageViewPosX: CGFloat = 0
        var titleLabelPosX: CGFloat = 0
        var titleLabelWidth: CGFloat = 0
        var textAlignment: NSTextAlignment = .left
        if SendbirdUI.config.common.shouldApplyLiquidGlass {
            // Liquid glass: Image on LEFT, Title on RIGHT
            textAlignment = .left
            imageViewPosX = leftMargin
            if item.image != nil {
                titleLabelPosX = leftMargin + iconSize + midMargin
                titleLabelWidth = itemWidth - leftMargin - iconSize - midMargin - rightMargin
            } else {
                titleLabelPosX = leftMargin
                titleLabelWidth = itemWidth - leftMargin - rightMargin
            }
        } else if UIView.getCurrentLayoutDirection().isLTR == true {
            textAlignment = .left
            titleLabelPosX = leftMargin
            if item.image != nil {
                imageViewPosX = itemWidth - rightMargin - iconSize
                titleLabelWidth = itemWidth - leftMargin - midMargin - iconSize - rightMargin
            } else {
                titleLabelWidth = itemWidth - leftMargin - rightMargin
            }
        } else {
            textAlignment = .right
            imageViewPosX = leftMargin
            if item.image != nil {
                titleLabelPosX = leftMargin + iconSize + midMargin
                titleLabelWidth = itemWidth - leftMargin - iconSize - midMargin - rightMargin
            } else {
                titleLabelPosX = leftMargin
                titleLabelWidth = itemWidth - leftMargin - midMargin
            }
        }
        
        titleLabel.textAlignment = textAlignment
        titleLabel.frame = CGRect(
            origin: CGPoint(x: titleLabelPosX, y: 0),
            size: CGSize(
                width: titleLabelWidth,
                height: itemHeight
            )
        )

        let imageView = UIImageView()
        if let image = item.image {
            imageView.frame = CGRect(
                origin: CGPoint(x: imageViewPosX, y: imageTopBottomMargin),
                size: CGSize(width: iconSize, height: iconSize)
            )

            imageView.image = image
        }
        
        itemButton.isEnabled = item.isEnabled
        
        itemButton.addSubview(imageView)
        itemButton.addSubview(titleLabel)
        
        if let tag = item.tag {
            itemButton.tag = tag
        }
        
        if separator {
            let separatorLine = UIView(
                frame: CGRect(
                    origin: CGPoint(x: 0.0, y: itemHeight - 0.5),
                    size: CGSize(width: itemWidth, height: 0.5))
            )
            separatorLine.backgroundColor = theme.separatorColor
            itemButton.addSubview(separatorLine)
        }
        
        var optionSet: UIRectCorner = []
        if isTop, isBottom {
            optionSet = [.allCorners]
        } else if isTop {
            optionSet = [.topLeft, .topRight]
        } else if isBottom {
            optionSet = [.bottomLeft, .bottomRight]
        }
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = itemButton.frame
        rectShape.position = itemButton.center
        rectShape.path = UIBezierPath(
            roundedRect: itemButton.bounds,
            byRoundingCorners: optionSet,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        ).cgPath
        itemButton.layer.mask = rectShape
        return itemButton
    }
    
    // MARK: Shadow
    private func addShadow(theme: SBUComponentTheme) {
        self.baseView.layer.shadowPath = UIBezierPath(
            roundedRect: self.baseView.bounds,
            cornerRadius: self.baseView.layer.cornerRadius
        ).cgPath
        self.baseView.layer.shadowColor = theme.shadowColorAdaptive.cgColor
        self.baseView.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.baseView.layer.shadowOpacity = 0.5
        self.baseView.layer.shadowRadius = 5
        self.baseView.layer.masksToBounds = false
    }
    
    /// - Since: 3.34.0
    private func createGlassEffectView() -> UIVisualEffectView? {
        if let glassEffectView = SBULiquidGlassUtils.createGlassEffectView() {
            glassEffectView.setupLayouts(
                frame: baseView.bounds,
                autoresizingMask: [.flexibleWidth, .flexibleHeight]
            )
            
            glassEffectView.setupStyles(
                cornerRadius: cornerRadius,
                cornerCurve: nil,
                clipsToBounds: true
            )
            
            return glassEffectView
        }
        return nil
    }
    
    // MARK: Button action
    @objc
    private func onClickMenuButton(sender: UIButton) {
        let index = sender.tag
        let item = self.items[index]
        item.completionHandler?()
        self.dismiss()
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
