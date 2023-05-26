//
//  SBUBottomSheetController.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/26.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

enum SBUBottomSheetSnapPoint {
    case top
    case middle
    case close
}

protocol SBUBottomSheetControllerDelegate: AnyObject {
    func bottomSheet(moveTo position: SBUBottomSheetSnapPoint)
}

class SBUBottomSheetController: UIPresentationController {

    weak var bottomSheetDelegate: SBUBottomSheetControllerDelegate?

    var blurEffectStyle: UIBlurEffect.Style?

    private let gap: CGFloat = 30
    private var topMargin: CGFloat {
        20 + UIApplication.shared.statusBarFrame.height
    }

    lazy var contentHeight: CGFloat = self.presentingViewController.view.frame.height / 2

    var isEnableTop: Bool = true
    var isEnableMiddle: Bool = true

    /// Toggle the bounce value to allow the modal to bounce when it's being
    /// dragged top, over the max width (add the top gap).
    var bounce: Bool = false

    /// The modal corners radius.
    /// The default value is 20 for a minimal yet elegant radius.
    var cornerRadius: CGFloat = 20

    /// Set the modal's corners that should be rounded.
    /// Defaults are the two top corners.
    var roundedCorners: UIRectCorner = [.topLeft, .topRight]

    /// Attributes
    var currentSnapPoint: SBUBottomSheetSnapPoint = .middle

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

    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
        return pan
    }()

    /// Initializers
    /// Init with non required values - defaults are provided.
    convenience init(presentedViewController: UIViewController,
                     presenting presentingViewController: UIViewController?,
                     delegate: SBUBottomSheetControllerDelegate? = nil,
                     blurEffectStyle: UIBlurEffect.Style? = nil,
                     cornerRadius: CGFloat = 20) {
        self.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        self.bottomSheetDelegate = delegate
        self.blurEffectStyle = blurEffectStyle
        self.cornerRadius = cornerRadius
    }

    /// Regular init.
    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }

    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { (_) in
                self.blurEffectView.alpha = 0
        }, completion: { (_) in
            self.blurEffectView.removeFromSuperview()
        })
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        let safeAreaFrame = containerView.bounds.insetBy(
            dx: (containerView.safeAreaInsets.left + containerView.safeAreaInsets.right)/2,
            dy: self.topMargin/2
        )
        return safeAreaFrame
    }

    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        // Add the blur effect view
        guard let presenterView = self.containerView else { return }
        presenterView.addSubview(self.blurEffectView)

        presenterView.layer.shadowColor = SBUColorSet.onlight02.cgColor
        presenterView.layer.shadowRadius = 2
        presenterView.layer.shadowOpacity = 0.5
        presenterView.layer.shadowOffset = .init(width: 0, height: 2)

        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { (_) in
                self.blurEffectView.alpha = 1
        }, completion: { (_) in
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let presentedView = self.presentedView else { return }

        presentedView.layer.masksToBounds = true
        presentedView.roundCorners(corners: self.roundedCorners, radius: self.cornerRadius)
        presentedView.addGestureRecognizer(self.panGesture)
    }

    override func containerViewDidLayoutSubviews() {
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

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        self.sendToMiddle()
    }

    @objc
    func dismiss() {
        self.currentSnapPoint = .close
        self.bottomSheetDelegate?.bottomSheet(moveTo: self.currentSnapPoint)
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }

    @objc
    func drag(_ gesture: UIPanGestureRecognizer) {

        guard let presenterView = self.containerView else { return }
        guard let presentedView = self.presentedView else { return }

        switch gesture.state {
        case .changed:
            self.presentingViewController.view.bringSubviewToFront(presentedView)
            let translation = gesture.translation(in: self.presentingViewController.view)
            let y = presentedView.frame.origin.y + translation.y

            if self.isEnableTop {
                // If bounce enabled or view went over the maximum y postion.
                if self.bounce || self.topMargin - self.gap < y {
                    presentedView.frame.origin.y = y
                }
            } else {
                let middle = presenterView.frame.height - contentHeight
                if middle - self.gap < y {
                    presentedView.frame.origin.y = y
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

    func sendToTop() {
        self.currentSnapPoint = .top
        self.bottomSheetDelegate?.bottomSheet(moveTo: self.currentSnapPoint)
        guard let presentedView = presentedView else { return }
        UIView.animate(withDuration: 0.25) {
            presentedView.frame.origin.y = self.topMargin
        }
    }

    func sendToMiddle() {
        self.currentSnapPoint = .middle
        self.bottomSheetDelegate?.bottomSheet(moveTo: self.currentSnapPoint)
        guard let presenterView = containerView else { return }
        guard let presentedView = presentedView else { return }
        UIView.animate(withDuration: 0.25) {
            presentedView.frame.origin.y = presenterView.frame.height - self.contentHeight
        }
    }
}
