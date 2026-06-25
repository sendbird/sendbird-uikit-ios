//
//  SBUBaseViewController.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/05.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// TODO: SBUBaseViewController -> SBUViewController

@objcMembers
open class SBUBaseViewController: UIViewController, UINavigationControllerDelegate, SBULoadingIndicatorProtocol, SBUCommonViewModelDelegate {
    open func didReceiveError(_ error: SendbirdChatSDK.SBError?, isBlocker: Bool) {
        
    }
    
    public func shouldUpdateLoadingState(_ isLoading: Bool) {
        
    }
    
    public func baseViewModel(_ viewModel: SBUBaseViewModel, retryAfter: UInt) {
        self.showBusyServerCountdownAlert(retryAfter: retryAfter)
    }
    
    public func baseViewModelDidSucceedReconnection(_ viewModel: SBUBaseViewModel) {
        self.dismissBusyServerCountdownAlert()
    }
    
    public func baseViewModelDidFailReconnection(_ viewModel: SBUBaseViewModel) {
        self.dismissBusyServerCountdownAlert()
    }

    /// - Since: 3.8.0
    var prevNavigationBarSettings: SBUPrevNavigationBarSettings? = SBUPrevNavigationBarSettings()
    
    /// This value is used to check if the properties of the navigationBar need to be initialized. The default value is `true`.
    ///
    /// - NOTE: If you are presenting a ViewController with the `modalPresentationStyle` set to `.fullScreen` within a Sendbird function, please set this value to `false` before presenting.
    /// - Since: 3.11.2
    public var needRollbackNavigationBarSetting: Bool = true
    
    /// Caches previous navigation bar background color.
    /// Used to check if navigation bar update is needed.
    /// - Since: 3.33.1
    var previousNavBarBackgroundColor = UIColor()
    /// Caches previous navigation bar shadow color.
    /// Used to check if navigation bar update is needed.
    /// - Since: 3.33.1
    var previousNavBarShadowColor = UIColor()
    /// Caches previous liquid glass navigation bar background tint color.
    /// Used to check if navigation bar update is needed.
    /// - Since: 3.34.0
    var previousLiquidGlassNavBarBackgroundTint = UIColor()

    // MARK: - Lifecycle
    open override func loadView() {
        super.loadView()
        
        self.setupViews()
        self.setupLayouts()
        
        self.needRollbackNavigationBarSetting = false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = self.navigationController, needRollbackNavigationBarSetting {
            self.prevNavigationBarSettings?.rollback(to: navigationController)
        }
        SBUUtils.dismissPresentedOnDisappear(presentedViewController: self.presentedViewController)
        
        if self is SBUMenuSheetViewController == false {
            SBULoading.stop()
            SBUMenuView.dismiss()
            SBUAlertView.dismiss()
            SBUActionSheet.dismiss()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }
    
    // MARK: - Sendbird UIKit Life cycle
    
    /// This function setups views.
    open func setupViews() { }
    
    /// This function setups layouts.
    open func setupLayouts() { }
    
    /// This function updates layouts.
    open func updateLayouts() { }
    
    /// This function setups styles.
    open func setupStyles() { }
    
    /// This function updates styles.
    open func updateStyles() { }
    
    /// This function updates styles with boolean parameter value that represents whether layout or not
    open func updateStyles(needsToLayout: Bool) { }

    /// Checks if non-liquid glass navigation bar update is needed.
    /// - Since: 3.34.0
    func shouldUpdateNonLiquidGlassNavigationBar(
        backgroundColor: UIColor,
        shadowColor: UIColor
    ) -> Bool {
        backgroundColor != previousNavBarBackgroundColor || shadowColor != previousNavBarShadowColor
    }
    
    /// Checks if liquid glass navigation bar update is needed.
    /// - Since: 3.34.0
    func shouldUpdateLiquidGlassNavigationBar(gradientBackgroundTint: UIColor) -> Bool {
        gradientBackgroundTint != previousLiquidGlassNavBarBackgroundTint
    }
    
    /// This function setups navigationBar's background color and shadow color.
    /// - Parameters:
    ///   - backgroundColor: background color
    ///   - shadowColor: shadow color
    open func setupNavigationBar(backgroundColor: UIColor, shadowColor: UIColor) {
        self.setupNavigationBar(
            backgroundColor: backgroundColor,
            gradientBackgroundTint: backgroundColor,
            shadowColor: shadowColor
        )
    }
    
    open func setupNavigationBar(
        backgroundColor: UIColor,
        gradientBackgroundTint: UIColor,
        shadowColor: UIColor
    ) {
        if let navigationController = self.navigationController {
            self.prevNavigationBarSettings?.save(with: navigationController)
        }

        if SendbirdUI.config.common.shouldApplyLiquidGlass {
            guard self.shouldUpdateLiquidGlassNavigationBar(
                gradientBackgroundTint: gradientBackgroundTint
            ) else { return }
            
            #if compiler(>=6.2)
            if #available(iOS 26.0, *) {
                // update
                self.previousLiquidGlassNavBarBackgroundTint = gradientBackgroundTint
                
                self.setupLiquidGlassNavigationBar(gradientBackgroundTint: gradientBackgroundTint)
            }
            #endif
            return
        }
        
        guard self.shouldUpdateNonLiquidGlassNavigationBar(
            backgroundColor: backgroundColor,
            shadowColor: shadowColor
        ) else { return }

        // update
        self.previousNavBarBackgroundColor = backgroundColor
        self.previousNavBarShadowColor = shadowColor
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: backgroundColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: shadowColor
        )

        // For iOS 13
        self.navigationController?.sbu_setupNavigationBarAppearance(
            tintColor: backgroundColor,
            shadowColor: shadowColor
        )
    }
    
    /// Checks if navigation bar update is needed.
    /// - Since: 3.33.1
    func shouldUpdateNavigationBar(
        backgroundColor: UIColor,
        shadowColor: UIColor
    ) -> Bool {
        backgroundColor != previousNavBarBackgroundColor || shadowColor != previousNavBarShadowColor
    }
    
    // MARK: - Actions
    var dismissAction: (() -> Void)?

    /// This is to pop or dismiss (depending on current view controller) the search view controller.
    open func onClickBack() {
        if dismissAction != nil {
            dismissAction?()
        } else {
            if let navigationController = self.navigationController,
               navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Error handling
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        Log.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: UINavigationController
    func isLastInNavigationStack() -> Bool {
        if self.navigationController?.viewControllers.last == self {
            return true
        }
        #if SWIFTUI
        // In SwiftUI, a UIViewController is wrapped inside a UIHostingController.
        // The navigationController has access to the UIHostingController and not the UIViewController.
        if self.navigationController?.viewControllers.last == self.parent {
            return true
        }
        #endif
        return false
    }
    
    // MARK: - UINavigationControllerDelegate
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // prevent swipe to pop if current vc is the first one. App freezes (https://sendbird.atlassian.net/browse/QU-234)
        if navigationController.viewControllers.count > 1 {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    // MARK: - SBULoadingIndicatorProtocol
    open func showLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                SBULoading.start()
            } else {
                SBULoading.stop()
            }
        }
    }
    
    // MARK: - Liquid Glass (iOS 26+)

    /// Accessibility identifier used to find/remove the progressive-blur overlay
    /// installed by `setupLiquidGlassNavigationBar(gradientBackgroundTint:)`.
    /// - Since: 3.35.4
    private static let liquidGlassBlurOverlayID = "sbu.liquidGlassNavBar.blurOverlay"

    /// Alpha applied to the `UIVisualEffectView` rendering the glass material.
    /// Set on the blur view itself (not the container) so the gradient mask
    /// keeps its own opacity profile intact regardless of this value.
    /// `UIGlassEffect`'s blur strength is system-fixed; lowering this dial only
    /// softens the tint film, it does not reduce blur.
    /// - Since: 3.35.4
    private static let liquidGlassBlurIntensity: CGFloat = 0.93

    /// Vertical distance the blur overlay extends past the nav-bar's bottom
    /// edge. `0` keeps the overlay flush with the bar so it doesn't visually
    /// overlap the first row of underlying content; the gradient mask still
    /// fades its bottom edge for a soft transition inside the bar's own area.
    /// - Since: 3.35.4
    private static let liquidGlassBlurFadeExtension: CGFloat = 0

    @available(iOS 26.0, *)
    open func setupLiquidGlassNavigationBar(gradientBackgroundTint: UIColor) {
        Log.info("gradientBackgroundTint: \(gradientBackgroundTint)")

        // `gradientBackgroundTint` flows into `UIGlassEffect.tintColor`, so
        // apps that customized `theme.navigationBarGradientTint` see their
        // color picked up by the Liquid Glass material. Bail before mutating
        // nav-bar/overlay state if the factory returns nil (Liquid Glass
        // disabled, or compile-/runtime-unavailable — `UIGlassEffect` is iOS
        // 26 / Swift 6.2 only).
        guard let blurView = SBULiquidGlassUtils.createGlassEffectView(
            tintColor: gradientBackgroundTint
        ) else { return }

        guard let bar = self.navigationController?.navigationBar else { return }
        Self.resetNavigationBarToTransparent(bar)
        Self.installLiquidGlassBlurOverlay(on: self.view, blurView: blurView, navigationBar: bar)
    }

    /// Clears `UINavigationBar`'s `standardAppearance` and `scrollEdgeAppearance`
    /// to transparent so the progressive-blur overlay is the sole visible chrome.
    /// `compactAppearance` is deliberately left untouched: it defaults to `nil`,
    /// which falls back to `standardAppearance` — covering 99% of cases without
    /// growing `SBUPrevNavigationBarSettings`' save/rollback surface.
    /// - Since: 3.35.4
    @available(iOS 26.0, *)
    private static func resetNavigationBarToTransparent(_ bar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
    }

    /// Installs (or replaces) the progressive-blur overlay on the given view's top
    /// edge by wrapping the caller-supplied `blurView` in a multi-stop
    /// gradient-masked container. The caller is responsible for creating
    /// `blurView` (via `SBULiquidGlassUtils.createGlassEffectView(tintColor:)`)
    /// and bailing if that returns `nil`, so this method never tears down the
    /// existing overlay or nav-bar appearance when LG would silently no-op.
    /// - Since: 3.35.4
    @available(iOS 26.0, *)
    private static func installLiquidGlassBlurOverlay(
        on view: UIView,
        blurView: UIVisualEffectView,
        navigationBar: UINavigationBar
    ) {
        view.subviews
            .filter { $0.accessibilityIdentifier == liquidGlassBlurOverlayID }
            .forEach { $0.removeFromSuperview() }

        // Wrapper container — the mask is applied here, not on the visual-effect
        // view directly. UIVisualEffectView's internal backdrop layer doesn't
        // always respect a layer-level mask reliably; masking the container does.
        // The container subclass keeps `maskLayer.frame` in sync with `bounds` on
        // every layout pass, so rotation / split-view resize doesn't clip the
        // overlay to the original width.
        let container = LiquidGlassBlurOverlayContainer(
            navigationBar: navigationBar,
            fadeExtension: liquidGlassBlurFadeExtension
        )
        container.accessibilityIdentifier = liquidGlassBlurOverlayID
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isUserInteractionEnabled = false
        view.addSubview(container)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(blurView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: container.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        blurView.alpha = liquidGlassBlurIntensity
    }
    
    func showBusyServerCountdownAlert(retryAfter: UInt) {
        SBUAlertView.show(
            title: SBUStringSet.Alert_Busy_Server_Title,
            message: SBUStringSet.Alert_Busy_Server_Message,
            cancelButtonItem: nil,
            delegate: nil,
            countDownSeconds: retryAfter,
            enableBackgroundTapToDismiss: false
        )
    }
    
    func dismissBusyServerCountdownAlert() {
        SBUAlertView.dismiss()
    }
}

extension SBUBaseViewController {
    /// - Since: 3.8.0
    struct SBUPrevNavigationBarSettings {
        var isSet: Bool = false
        
        var backgroundImage: UIImage?
        var shadowImage: UIImage?
        
        var standardAppearanceWrapper: Any?
        var scrollEdgeAppearanceWrapper: Any?

        var standardAppearance: UINavigationBarAppearance? {
            get {
                standardAppearanceWrapper as? UINavigationBarAppearance
            }
            set {
                standardAppearanceWrapper = newValue
            }
        }
        var scrollEdgeAppearance: UINavigationBarAppearance? {
            get {
                scrollEdgeAppearanceWrapper as? UINavigationBarAppearance
            }
            set {
                scrollEdgeAppearanceWrapper = newValue
            }
        }
        
        mutating func save(with navigationController: UINavigationController) {
            guard isSet == false else { return }
            
            self.backgroundImage = navigationController.navigationBar.backgroundImage(for: .default)
            self.shadowImage = navigationController.navigationBar.shadowImage
            
            self.standardAppearance = navigationController.navigationBar.standardAppearance
            self.scrollEdgeAppearance = navigationController.navigationBar.scrollEdgeAppearance
            
            self.isSet = true
        }
        
        func rollback(to navigationController: UINavigationController) {
            guard isSet else { return }
            
            navigationController.navigationBar.setBackgroundImage(self.backgroundImage, for: .default)
            navigationController.navigationBar.shadowImage = self.shadowImage
            
            if let standardAppearance = self.standardAppearance {
                navigationController.navigationBar.standardAppearance = standardAppearance
            }
            navigationController.navigationBar.scrollEdgeAppearance = self.scrollEdgeAppearance
        }
    }
}

/// Container view that owns the Liquid Glass blur overlay's gradient mask,
/// keeps `maskLayer.frame` in sync with `bounds` on every layout pass, and
/// sizes its own height from the navigation bar's bottom edge plus a fade
/// extension. Height is managed internally (not via a cross-hierarchy
/// constraint to the nav bar) because the bar lives in the nav controller's
/// view hierarchy and may not yet share a common ancestor with the host VC's
/// view at install time. `CALayer.mask` is not autoresized by its host layer,
/// so without `maskLayer.frame = bounds` here the overlay would clip to the
/// original width after a rotation or split-view resize.
fileprivate final class LiquidGlassBlurOverlayContainer: UIView {
    private weak var navigationBar: UINavigationBar?
    private let fadeExtension: CGFloat
    private var heightConstraint: NSLayoutConstraint!

    let maskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        // Single linear fade segment from the opaque cutoff to clear at the
        // bottom. Multi-stop gradients introduce alpha-rate inflection points
        // that the eye reads as edges right where the curve kinks — keeping
        // the alpha rate constant avoids that and gives a uniformly soft
        // transition through the entire fade region.
        layer.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0.0, 0.7, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()

    init(navigationBar: UINavigationBar, fadeExtension: CGFloat) {
        self.navigationBar = navigationBar
        self.fadeExtension = fadeExtension
        super.init(frame: .zero)
        layer.mask = maskLayer
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("LiquidGlassBlurOverlayContainer does not support NSCoder")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateHeightFromNavigationBar()
    }

    override func layoutSubviews() {
        // Re-derive height before super so the layout pass uses the up-to-date
        // value. Rotation reaches the container's layout via its window before
        // (or alongside) the nav bar, so on first pass after rotation
        // `navigationBar.bounds` may still reflect the previous orientation —
        // the post-`super.layoutSubviews` re-check below handles that.
        updateHeightFromNavigationBar()
        super.layoutSubviews()
        updateHeightFromNavigationBar()

        // Disable the implicit 0.25s animation so the mask doesn't trail behind
        // the rotation transition.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.frame = bounds
        CATransaction.commit()
    }

    private func updateHeightFromNavigationBar() {
        guard let bar = navigationBar, let parent = superview else { return }
        let bottomInParent = bar.convert(
            CGPoint(x: 0, y: bar.bounds.maxY),
            to: parent
        ).y
        let desired = max(0, bottomInParent) + fadeExtension
        if abs(heightConstraint.constant - desired) > 0.5 {
            heightConstraint.constant = desired
        }
    }
}
