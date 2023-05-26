//
//  SBUMenuView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 16/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public typealias SBUMenunHandler = () -> Void

public class SBUMenuItem: SBUCommonItem {
    var completionHandler: SBUMenunHandler?
    
    public var isEnabled: Bool = true {
        didSet {
            guard isEnabled == false else { return }
            completionHandler = nil
        }
    }
    
    /// - Parameters:
    ///    - font: The default is `nil`.  If `nil`, the menu text label will set it's font to ``SBUComponentTheme/menuTitleFont``
    public init(
        title: String? = nil,
        color: UIColor? = SBUColorSet.onlight01,
        image: UIImage? = nil,
        font: UIFont? = nil,
        tintColor: UIColor? = nil,
        textAlignment: NSTextAlignment = .left,
        tag: Int? = nil,
        completionHandler: SBUMenunHandler? = nil
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

class SBUMenuView: NSObject {
    static private let shared = SBUMenuView()
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    private var items: [SBUMenuItem] = []
    
    var window: UIWindow?
    var baseView = UIView()
    var backgroundView = UIButton()
    
    let itemWidth: CGFloat = 180.0
    let itemHeight: CGFloat = 40.0
    let leftMargin: CGFloat = 14.0
    let midMargin: CGFloat = 8.0
    let rightMargin: CGFloat = 18.0
    let topBottomMargin: CGFloat = 8.0
    
    let bufferVerticalMargin: CGFloat = 15.0
    let bufferHorizontalMargin: CGFloat = 36.0

    var dismissHandler: (() -> Void)?
    
    var prevOrientation: UIDeviceOrientation = .unknown
    
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
        
        let totalHeight = CGFloat(items.count) * itemHeight
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
        
        var itemOriginY: CGFloat = 0.0
        for index in 0..<items.count {
            let button = self.makeItems(
                item: items[index],
                separator: (index != items.count-1),
                isTop: (index == 0),
                isBottom: (index == items.count-1),
                theme: oneTimetheme ?? self.theme
            )
            button.tag = index
            var buttonFrame = button.frame
            buttonFrame.origin = CGPoint(x: 0, y: itemOriginY)
            button.frame = buttonFrame
            button.backgroundColor = oneTimetheme?.backgroundColor ?? theme.backgroundColor
            
            self.baseView.addSubview(button)
            
            itemOriginY += button.frame.height
        }
        
        self.addShadow(theme: oneTimetheme ?? theme)

        window.addSubview(self.backgroundView)
        window.addSubview(self.baseView)
        
        self.baseView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.baseView.alpha = 1.0
        })
    }
    
    @objc private func dismiss() {
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
                size: CGSize(width: self.itemWidth, height: self.itemHeight)
            )
        )
        
        itemButton.setBackgroundImage(UIImage.from(color: theme.backgroundColor), for: .normal)
        itemButton.setBackgroundImage(UIImage.from(color: theme.highlightedColor), for: .highlighted)
        itemButton.addTarget(self, action: #selector(onClickMenuButton), for: .touchUpInside)
        let imageSize: CGFloat = 24.0
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(
            origin: CGPoint(x: leftMargin, y: 0),
            size: CGSize(
                width: itemWidth - leftMargin - midMargin - imageSize - rightMargin,
                height: itemHeight
            )
        )
        titleLabel.text = item.title
        titleLabel.font = item.font ?? theme.menuTitleFont
        titleLabel.textColor = item.color
        titleLabel.textAlignment = item.textAlignment
        
        let imageView = UIImageView()
        if let image = item.image {
            imageView.frame = CGRect(
                origin: CGPoint(x: titleLabel.frame.maxX + midMargin, y: topBottomMargin),
                size: CGSize(width: imageSize, height: imageSize)
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
            cornerRadii: CGSize(width: 10, height: 10)
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
        self.baseView.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
        self.baseView.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.baseView.layer.shadowOpacity = 0.5
        self.baseView.layer.shadowRadius = 5
        self.baseView.layer.masksToBounds = false
    }
    
    // MARK: Button action
    @objc private func onClickMenuButton(sender: UIButton) {
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
