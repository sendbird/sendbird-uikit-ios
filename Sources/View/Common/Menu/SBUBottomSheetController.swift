//
//  SBUBottomSheetController.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/26.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Represents the snap points for the bottom sheet.
/// - Since: 3.28.0
public enum SBUBottomSheetSnapPoint {
    /// The top position of the bottom sheet.
    case top
    /// The middle position of the bottom sheet.
    case middle
    /// The closed position of the bottom sheet.
    case close
}

public protocol SBUBottomSheetControllerDelegate: AnyObject {
    func bottomSheet(moveTo position: SBUBottomSheetSnapPoint)
}

/// A controller that manages the presentation of a bottom sheet.
/// - Since: 3.28.0
public class SBUBottomSheetController: UIPresentationController {

    /// The delegate that receives updates on the bottom sheet's position.
    public weak var bottomSheetDelegate: SBUBottomSheetControllerDelegate?

    /// The blur effect style.
    public var blurEffectStyle: UIBlurEffect.Style?

    /// The gap of the modal.
    private let gap: CGFloat = 30
    /// The top margin of the modal.
    private var topMargin: CGFloat {
        20 + UIApplication.shared.statusBarFrame.height
    }

    /// The content height of the modal.
    public lazy var contentHeight: CGFloat = self.presentingViewController.view.frame.height / 2

    /// Toggle the top value to allow the modal to be dragged to the top.
    public var isEnableTop: Bool = true
    
    /// Toggle the middle value to allow the modal to be dragged to the middle
    public var isEnableMiddle: Bool = true

    /// Toggle the bounce value to allow the modal to bounce when it's being
    /// dragged top, over the max width (add the top gap).
    public var bounce: Bool = false

    /// The modal corners radius.
    /// The default value is 20 for a minimal yet elegant radius.
    public var cornerRadius: CGFloat = 20

    /// Set the modal's corners that should be rounded.
    /// Defaults are the two top corners.
    public var roundedCorners: UIRectCorner = [.topLeft, .topRight]

    /// The current snap point of the bottom sheet.
    public private(set) var currentSnapPoint: SBUBottomSheetSnapPoint = .middle
    
    public lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
        return pan
    }()

    // MARK: - Private

    private lazy var blurEffectView: UIVisualEffectView = {
        let effectView: UIVisualEffectView
        if let effectStyle = self.blurEffectStyle {
            effectView = UIVisualEffectView(effect: UIBlurEffect(style: effectStyle))
        } else {
            effectView = UIVisualEffectView(effect: nil)
        }

        effectView.backgroundColor = SBUColorSet.background700.withAlphaComponent(0.4)
        effectView.isUserInteractionEnabled = true
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.addGestureRecognizer(self.tapGestureRecognizer)
        return effectView
    }()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
    }()

    /// Initializers
    /// Init with non required values - defaults are provided.
    convenience init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        delegate: SBUBottomSheetControllerDelegate? = nil,
        blurEffectStyle: UIBlurEffect.Style? = nil,
        cornerRadius: CGFloat = 20
    ) {
        self.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        self.bottomSheetDelegate = delegate
        self.blurEffectStyle = blurEffectStyle
        self.cornerRadius = cornerRadius
    }

    /// Regular init.
    public override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }

    // MARK: - UIPresentationController method override
    open override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { (_) in
                self.blurEffectView.alpha = 0
        }, completion: { (_) in
            self.blurEffectView.removeFromSuperview()
        })
    }

    open override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        let safeAreaFrame = containerView.bounds.insetBy(
            dx: (containerView.safeAreaInsets.left + containerView.safeAreaInsets.right)/2,
            dy: self.topMargin/2
        )
        return safeAreaFrame
    }

    open override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        // Add the blur effect view
        guard let presenterView = self.containerView else { return }
        presenterView.addSubview(self.blurEffectView)

        presenterView.layer.shadowColor = SBUColorSet.onLightTextMidEmphasis.cgColor
        presenterView.layer.shadowRadius = 2
        presenterView.layer.shadowOpacity = 0.5
        presenterView.layer.shadowOffset = .init(width: 0, height: 2)

        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { (_) in
                self.blurEffectView.alpha = 1
        }, completion: { (_) in
        })
    }

    open override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }

    open override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let presentedView = self.presentedView else { return }

        presentedView.layer.masksToBounds = true
        presentedView.roundCorners(corners: self.roundedCorners, radius: self.cornerRadius)
        presentedView.addGestureRecognizer(self.panGesture)
    }

    open override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        guard let presenterView = self.containerView else { return }
        guard let presentedView = self.presentedView else { return }

        // Set the frame and position of the modal
        presentedView.frame = self.frameOfPresentedViewInContainerView
        presentedView.frame.origin.x = (presenterView.frame.width - presentedView.frame.width) / 2
        presentedView.frame.origin.y = presenterView.frame.height - contentHeight

        // Set the blur effect frame, behind the modal
        self.blurEffectView.frame = presenterView.bounds
    }

    open override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        self.sendToMiddle()
    }

    // MARK: - Common
    
    /// Dismisses the presented view controller and notifies the delegate.
    @objc
    public func dismiss() {
        self.currentSnapPoint = .close
        self.bottomSheetDelegate?.bottomSheet(moveTo: self.currentSnapPoint)
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }

    /// Handles the drag gesture for the presented view.
    @objc
    public func drag(_ gesture: UIPanGestureRecognizer) {
        guard let presenterView = self.containerView else { return }
        guard let presentedView = self.presentedView else { return }

        switch gesture.state {
        case .changed:
            self.presentingViewController.view.bringSubviewToFront(presentedView)
            let translation = gesture.translation(in: self.presentingViewController.view)
            let pointY = presentedView.frame.origin.y + translation.y

            if self.isEnableTop {
                // If bounce enabled or view went over the maximum y postion.
                if self.bounce || self.topMargin - self.gap < pointY {
                    presentedView.frame.origin.y = pointY
                }
            } else {
                let middle = presenterView.frame.height - contentHeight
                if middle - self.gap < pointY {
                    presentedView.frame.origin.y = pointY
                }
            }
            gesture.setTranslation(CGPoint.zero, in: self.presentingViewController.view)

        case .ended:
            let middle = presenterView.frame.height - contentHeight
            let position = presentedView.convert(
                self.presentingViewController.view.frame,
                to: nil
            ).origin.y

            switch self.currentSnapPoint {
            case .top:
                if position < topMargin + gap {
                    self.sendToTop()
                } else if position <= middle, isEnableMiddle {
                    self.sendToMiddle()
                } else {
                    self.dismiss()
                }

            case .middle:
                if position < middle - gap, isEnableTop {
                    self.sendToTop()
                } else if position < middle + gap {
                    self.sendToMiddle()
                } else {
                    self.dismiss()
                }
            case .close:
                self.dismiss()
            }
            
            gesture.setTranslation(CGPoint.zero, in: self.presentingViewController.view)
        default:
            return
        }
    }

    /// Sends the bottom sheet to the top position.
    public func sendToTop() {
        self.currentSnapPoint = .top
        self.bottomSheetDelegate?.bottomSheet(moveTo: self.currentSnapPoint)
        guard let presentedView = presentedView else { return }
        UIView.animate(withDuration: 0.25) {
            presentedView.frame.origin.y = self.topMargin
        }
    }

    /// Sends the bottom sheet to the middle position.
    public func sendToMiddle() {
        self.currentSnapPoint = .middle
        self.bottomSheetDelegate?.bottomSheet(moveTo: self.currentSnapPoint)
        guard let presenterView = containerView else { return }
        guard let presentedView = presentedView else { return }
        UIView.animate(withDuration: 0.25) {
            presentedView.frame.origin.y = presenterView.frame.height - self.contentHeight
        }
    }
}
