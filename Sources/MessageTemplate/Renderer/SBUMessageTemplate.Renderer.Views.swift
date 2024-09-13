//
//  SBUMessageTemplate.Renderer.Views.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate.Renderer {
    // MARK: - BaseView Wrapper class (for debugging, update each item)
    class ContentView: UIView {}
    
    class BodyView: UIView {}
    
    // MARK: - base views
    
    class BaseView: UIView {
        var item: SBUMessageTemplate.Syntax.View
        var layout: SBUMessageTemplate.Syntax.LayoutType
        
        var width: SBUMessageTemplate.Syntax.SizeSpec { self.item.width }
        var height: SBUMessageTemplate.Syntax.SizeSpec { self.item.height }
        
        var viewStyle: SBUMessageTemplate.Syntax.ViewStyle { self.item.viewStyle }
        
        lazy var backgroundImageURLView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            view.backgroundColor = .clear
            return view
        }()
        
        weak var rightPaddingConstraint: NSLayoutConstraint?
        
        init(item: SBUMessageTemplate.Syntax.View, layout: SBUMessageTemplate.Syntax.LayoutType) {
            self.item = item
            self.layout = layout
            
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class BoxBaseView: SBUMessageTemplate.Renderer.BaseView {}
    
    class TextBaseView: SBUMessageTemplate.Renderer.BaseView {}
    
    class ImageBaseView: SBUMessageTemplate.Renderer.BaseView {}
    
    class TextButtonBaseView: SBUMessageTemplate.Renderer.TextBaseView {}
    
    class ImageButtonBaseView: SBUMessageTemplate.Renderer.BaseView {}
    
    class CarouselBaseView: SBUMessageTemplate.Renderer.BaseView {}
    
    // MARK: - item views
    
    class BoxView: UIView {
        var layout: SBUMessageTemplate.Syntax.LayoutType = .column
    }
    
    class TextButton: Label {}
    
    class ActionItemButton: SBUMessageTemplate.Renderer.Button {
        var action: SBUMessageTemplate.Action?
    }
    
    class ImageButton: SBUMessageTemplate.Renderer.ActionItemButton {}
    
    class ImageView: UIImageView {
        var originalImage: UIImage? {
            didSet { self.image = self.originalImage }
        }
        var identifier: SBUMessageTemplate.Syntax.Identifier?
        var needResizeImage: Bool = false
    }
    
    class ImageViewForAspect: UIImageView {}
    
    class ImageButtonForAspectFit: SBUMessageTemplate.Renderer.ImageButton {}
    
    // MARK: - base customize views
    
    class Button: UIButton {
        private var animationImageView: UIImageView?
    }
    
    class ActionTapGesture: UITapGestureRecognizer {
        var action: SBUMessageTemplate.Action?
    }
    
    class Label: UILabel {
        var padding: SBUMessageTemplate.Syntax.Padding?
        var updateLayoutHandler: (([NSLayoutConstraint], [NSLayoutConstraint]) -> Void)?
        var boxWidth: CGFloat = 0.0
    }
}

// MARK: - extension for detail customize flows.

extension SBUMessageTemplate.Renderer.BaseView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyRoundCorners()
        self.sizeToFitForBackgroundImageUrlView()
    }
    
    func applyRoundCorners() {
        guard let borderRadius = viewStyle.radius else { return }
        
        let width = item.width
        let height = item.height
        
        var maxRadius = borderRadius
        if width.type == .fixed {
            maxRadius = min(maxRadius, width.value / 2)
        } else {
            maxRadius = min(maxRadius, Int(self.frame.width / 2))
        }
        
        if height.type == .fixed {
            maxRadius = min(maxRadius, height.value / 2)
        } else {
            maxRadius = min(maxRadius, Int(self.frame.height / 2))
        }
        
        self.roundCorners(corners: .allCorners, radius: CGFloat(maxRadius))
    }
    
    func sizeToFitForBackgroundImageUrlView() {
        if self.backgroundImageURLView.superview == nil {
            self.addSubview(self.backgroundImageURLView)
            self.backgroundImageURLView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        self.backgroundImageURLView.isHidden = (self.backgroundImageURLView.image == nil)
        
        self.sendSubviewToBack(self.backgroundImageURLView)
    }
}

extension SBUMessageTemplate.Renderer {
    class CarouselRenderer: SBUBaseCarouselCellRenderer {
        let data: SBUMessageTemplate.Syntax.TemplateView
        let renderer: SBUMessageTemplate.Renderer
        let expectedWidth: CGFloat
        
        init?(
            data: SBUMessageTemplate.Syntax.TemplateView,
            maxWidth: CGFloat,
            actionHandler: ((SBUMessageTemplate.Action) -> Void)?
        ) {
            guard let renderer = SBUMessageTemplate.Renderer.generate(
                template: data,
                maxWidth: maxWidth,
                actionHandler: { actionHandler?($0) }
            ) else { return nil }
            self.data = data
            self.renderer = renderer
            self.expectedWidth = data.itemsMaxWidth(with: maxWidth)
        }
        
        func render() -> UIView {
            self.renderer.backgroundColor = .clear
            self.renderer.sbu_constraint_lessThan(width: self.expectedWidth, priority: .required)
            return renderer
        }
        
        func getExpectedWidth() -> CGFloat { self.expectedWidth }
    }
}

/// https://stackoverflow.com/a/32368958

/// This class supports padding and 9 direction Align.
///
/// How to use
/// - Padding : `label.padding = edgeInsets`
/// - Align:
///     - horizontal: `label.textAlignment`
///     - vertical: `label.contentMode`
extension SBUMessageTemplate.Renderer.Label {
    var fullTextViewWidth: CGFloat {
        (self.padding?.left ?? 0)
        + (self.padding?.right ?? 0)
        + self.textWidth()
    }
    
    var fullTextViewHeight: CGFloat {
        (self.padding?.top ?? 0)
        + (self.padding?.bottom ?? 0)
        + self.textHeight(with: boxWidth, numberOfLines: self.numberOfLines)
    }
    
    var isWrapTypeWidth: Bool {
        let width = (self.superview as? SBUMessageTemplate.Renderer.TextBaseView)?.width
        return (width?.type == .flex &&
                width?.value == SBUMessageTemplate.Syntax.FlexSizeType.wrapContent.rawValue)
    }
    
    var isWrapTypeHeight: Bool {
        let height = (self.superview as? SBUMessageTemplate.Renderer.TextBaseView)?.height
        return (height?.type == .flex &&
                height?.value == SBUMessageTemplate.Syntax.FlexSizeType.wrapContent.rawValue)
    }
    
    var isFixedTypeWidth: Bool {
        let width = (self.superview as? SBUMessageTemplate.Renderer.TextBaseView)?.width
        return width?.type == .fixed
    }
    
    var isFixedTypeHeight: Bool {
        let height = (self.superview as? SBUMessageTemplate.Renderer.TextBaseView)?.height
        return height?.type == .fixed
    }
    
    override func drawText(in rect: CGRect) {
        var newRect = rect
        switch contentMode {
        case .top:
            newRect.size.height = sizeThatFits(rect.size).height
        case .bottom:
            let height = sizeThatFits(rect.size).height
            newRect.origin.y += rect.size.height - height
            newRect.size.height = height
        default:
            ()
        }
        
        super.drawText(in: newRect.inset(by: .zero))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // INFO: Edge case - text wrap issue: width
        guard let baseView = self.superview as? SBUMessageTemplate.Renderer.TextBaseView,
              let boxView = baseView.superview as? SBUMessageTemplate.Renderer.BoxView,
              let currentIndex = boxView.subviews.firstIndex(of: baseView) else { return }
        
        if baseView.layout == .row {
            if isWrapTypeWidth {
                var constraints: [NSLayoutConstraint] = []
                var deactivatedConstraints: [NSLayoutConstraint] = []
                
                boxWidth = boxView.frame.width
                let isOverSize = (baseView.frame.origin.x + fullTextViewWidth) > boxWidth
                
                constraints += self.sbu_constraint_v2(width: self.textWidth(), priority: .defaultLow)
                
                if isOverSize {
                    constraints += baseView.sbu_constraint_v2(
                        greaterThanOrEqualTo: boxView,
                        right: 0,
                        priority: .required
                    )
                    
                    for (index, baseView) in boxView.subviews.enumerated() {
                        if index <= currentIndex { continue }
                        deactivatedConstraints += baseView.constraints
                        baseView.isHidden = true
                    }
                    
                    for (index, baseView) in boxView.subviews.enumerated() {
                        if index >= currentIndex { continue }
                        if let width = (baseView as? SBUMessageTemplate.Renderer.BaseView)?.width,
                           (width.type == .flex && width.value == SBUMessageTemplate.Syntax.FlexSizeType.fillParent.rawValue) {
                            deactivatedConstraints += baseView.constraints
                            baseView.isHidden = true
                        }
                    }
                }
                
                updateLayoutHandler?(constraints, deactivatedConstraints)
            } else if isFixedTypeWidth {
                // INFO: Edge case - If all items are fixed, the last fixed label should not pad the text when over the box area
                
                boxWidth = boxView.frame.width
                let isOverSize = (baseView.frame.origin.x + fullTextViewWidth) > boxWidth
                
                let itemCount: Int = boxView.subviews.count - 2
                if let index = boxView.subviews.firstIndex(of: baseView),
                   index == (boxView.subviews.count - 2), // check last item
                   isOverSize { // when only over size
                    
                    let fixedWidthItems = boxView
                        .subviews
                        .compactMap { $0.subviews.first as? SBUMessageTemplate.Renderer.Label }
                        .filter { $0.isFixedTypeWidth }
                    if fixedWidthItems.count == itemCount {
                        baseView.rightPaddingConstraint?.priority = .defaultLow
                    }
                }
            }
        } else if baseView.layout == .column,
                  let boxBaseView = boxView.superview as? SBUMessageTemplate.Renderer.BoxBaseView,
                  boxBaseView.height.type == .fixed {
            // INFO: Edge case - text wrap/fixed issue: height
            
            if !isWrapTypeHeight { return }
            var constraints: [NSLayoutConstraint] = []
            var deactivatedConstraints: [NSLayoutConstraint] = []
            
            self.boxWidth = boxView.frame.width - ((self.padding?.left ?? 0)
                                                   + (self.padding?.right ?? 0))
            let boxHeight = boxView.frame.height - ((self.padding?.top ?? 0)
                                                    + (self.padding?.bottom ?? 0))
            
            let isOverSize = (baseView.frame.origin.y + fullTextViewHeight) >= boxHeight
            
            let totalTextHeight = boxView
                .subviews
                .compactMap { $0.subviews.first as? SBUMessageTemplate.Renderer.Label }
                .filter { $0.isWrapTypeHeight || $0.isFixedTypeHeight }
                .reduce(0) { $0 + $1.fullTextViewHeight }
            let needToRemoveFillTypes = totalTextHeight >= boxHeight
            
            constraints += self.sbu_constraint_v2(height: self.textHeight(with: boxWidth, numberOfLines: self.numberOfLines), priority: .defaultLow)
            
            if isOverSize {
                constraints += baseView.sbu_constraint_v2(
                    greaterThanOrEqualTo: boxView,
                    bottom: 0,
                    priority: .required
                )
                
                for (index, baseView) in boxView.subviews.enumerated() {
                    if currentIndex >= index { continue }
                    deactivatedConstraints += baseView.constraints
                    baseView.isHidden = true
                }
                
                if needToRemoveFillTypes {
                    for (index, baseView) in boxView.subviews.enumerated() {
                        if currentIndex <= index { continue }
                        if let height = (baseView as? SBUMessageTemplate.Renderer.BaseView)?.height,
                           (height.type == .flex && height.value == SBUMessageTemplate.Syntax.FlexSizeType.fillParent.rawValue) {
                            deactivatedConstraints += baseView.constraints
                            baseView.isHidden = true
                        }
                    }
                }
            }
            
            updateLayoutHandler?(constraints, deactivatedConstraints)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width,
                      height: size.height)
    }
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width
        }
    }
}

extension SBUMessageTemplate.Renderer.ImageView {
    func saveImageCacheSize() {
        guard let image, image.size.width > 0, image.size.height > 0 else { return }
        guard let identifier = self.identifier else { return }

        SBUCacheManager.TemplateImage.save(
            messageId: identifier.messageId,
            viewIndex: identifier.index,
            size: image.size
        )
    }
    
    func resizeImageSize() {
        guard self.needResizeImage == true else { return }
        guard self.frame.width != self.image?.size.width  else { return }
        guard self.frame.width > 0  else { return }
        guard let resizeImage = self.originalImage?.resizeTopAlignedToFill(
            newWidth: self.frame.width
        ) else { return }
        
        self.image = resizeImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.resizeImageSize()
        
        self.saveImageCacheSize()
    }
    
    func updateDownloadTemplate(tintColor: UIColor?) {
        self.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
        
        let image = SBUIconSetType.iconSpinner
            .image(
                to: SBUIconSetType.Metric.iconSpinnerSizeForTemplate
            )
            .sbu_with(
                tintColor: tintColor,
                forTemplate: true
            )
        
        self.image = image
        self.contentMode = .center
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.1
        rotation.repeatCount = Float.infinity
        self.layer.add(rotation, forKey: SBUAnimation.Key.spin.identifier)
    }
}

extension SBUMessageTemplate.Renderer.ImageViewForAspect {
    override var intrinsicContentSize: CGSize {
        if let image = self.image {
            let width = image.size.width
            let height = image.size.height
            
            let ratio = self.frame.size.width / width
            let scaledHeight = height * ratio
            
            return CGSize(width: self.frame.size.width, height: scaledHeight)
        }
        
        return CGSize(width: -1.0, height: -1.0)
    }
}

extension SBUMessageTemplate.Renderer.ImageButtonForAspectFit {
    override var intrinsicContentSize: CGSize {
        if let image = self.imageView?.image {
            let width = image.size.width
            let height = image.size.height
            
            let ratio = self.frame.size.width / width
            let scaledHeight = height * ratio
            
            return CGSize(width: self.frame.size.width, height: scaledHeight)
        }
        
        return CGSize(width: -1.0, height: -1.0)
    }
}

extension SBUMessageTemplate.Renderer.Button {
    private func setupAnimationImageViewIfPossible() {
        if self.animationImageView == nil {
            let imageView = UIImageView(frame: bounds)
            self.addSubview(imageView)
            self.sendSubviewToBack(imageView) // Position the button's text or default image so that it is on top.
            self.animationImageView = imageView
        }
        self.animationImageView?.contentMode = self.contentMode
    }
    
    private func clearAnimationImageView() {
        self.animationImageView?.removeFromSuperview()
        self.animationImageView = nil
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        if let images = image?.images, images.hasElements {
            self.setupAnimationImageViewIfPossible()
            self.animationImageView?.image = image
        } else {
            super.setImage(image, for: state)
        }
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.animationImageView?.frame = bounds
    }
}
