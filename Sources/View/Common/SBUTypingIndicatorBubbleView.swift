//
//  SBUTypingIndicatorBubbleView.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 11/27/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

/// - Since: 3.12.0
public class SBUTypingIndicatorBubbleView: SBUView {
    private let dotRadius: CGFloat = 4
    let animationActiveDuration: CFTimeInterval = 0.6
    
    private var dotLayers: [CALayer] = []
    private var dotsContainerView = UIView()
    
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func setupViews() {
        super.setupViews()
        
        self.addSubview(dotsContainerView)
        dotsContainerView.backgroundColor = .systemBlue
        
        setupDots()
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        dotsContainerView.sbu_constraint(equalTo: self, centerX: 0, centerY: 0)
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: 60, height: 34)
    }

    private func setupDots() {
        translatesAutoresizingMaskIntoConstraints = false
        for _ in 0..<3 {
            let dot = CALayer()
            dot.backgroundColor = theme.typingMessageDotColor.cgColor
            dot.cornerRadius = dotRadius
            dot.bounds = CGRect(x: 0, y: 0, width: dotRadius * 2, height: dotRadius * 2)
            dotsContainerView.layer.addSublayer(dot)
            dotLayers.append(dot)
        }
        layoutIfNeeded()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        for (index, dot) in dotLayers.enumerated() {
            dot.position = CGPoint(x: CGFloat(index) * dotRadius * 3 - 12, y: 0)
        }
    }

    public func configure() {
        startAnimating()
    }
    
    func startAnimating() {
        let totalDuration = 1.4
        
        for (index, dot) in dotLayers.enumerated() {
            // Scale animation
            let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            scaleAnimation.values = [1.0, 1.2, 1.0]
            scaleAnimation.keyTimes = [0.4, 0.7, 1]
            scaleAnimation.duration = totalDuration

            // Color animation
            let colorAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
            let originalColor = theme.typingMessageDotColor.cgColor
            let transformColor = theme.typingMessageDotTransformColor.cgColor
            colorAnimation.values = [originalColor, transformColor, originalColor]
            colorAnimation.keyTimes = scaleAnimation.keyTimes
            colorAnimation.duration = totalDuration

            let delayBetweenDots: CFTimeInterval = 0.2
            let beginTime = CACurrentMediaTime() + Double(index) * delayBetweenDots

            scaleAnimation.beginTime = beginTime
            colorAnimation.beginTime = beginTime

            scaleAnimation.repeatCount = Float.infinity
            colorAnimation.repeatCount = Float.infinity

            dot.add(scaleAnimation, forKey: "dotPulse")
            dot.add(colorAnimation, forKey: "dotColorChange")
        }
    }
}
