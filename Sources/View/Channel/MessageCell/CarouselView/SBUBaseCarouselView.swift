//
//  BaseCarouselView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/08.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol SBUBaseCarouselCellRenderer {
    func render() -> UIView
    func getExpectedWidth() -> CGFloat
}

struct SBUBaseCarouselViewParams {
    let padding: UIEdgeInsets
    let spacing: CGFloat
    let profileArea: CGFloat
    let renderers: [SBUBaseCarouselCellRenderer]
}

protocol SBUCarouselCacheKey {
    func isEqualCacheKey(_ other: Any?) -> Bool
}

extension SBUCarouselCacheKey where Self: Equatable {
    func isEqualCacheKey(_ other: Any?) -> Bool {
        guard let otherSelf = other as? Self else { return false }
        return self == otherSelf
    }
}

class SBUBaseCarouselView: UIView, UIScrollViewDelegate {
    var cacheKey: SBUCarouselCacheKey?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    
    var params = SBUBaseCarouselViewParams(padding: .zero, spacing: 0, profileArea: 0, renderers: [])
    var contentViews = [UIView]()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // UIScrollView와 UIStackView 설정 코드를 여기에 추가
        self.scrollView.addSubview(self.stackView)
        self.addSubview(self.scrollView)
    }
    
    // MARK: - Public Methods
    
    func configure(with params: SBUBaseCarouselViewParams) {
        self.params = params
        self.stackView.spacing = self.params.spacing
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            self.scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            self.scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.stackView.leftAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leftAnchor, constant: self.params.profileArea),
            self.stackView.rightAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.rightAnchor),
            self.stackView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        ])

        self.stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
            stackView.removeArrangedSubview($0)
        }
        
        self.contentViews.removeAll()
        
        for renderer in params.renderers {
            let contentView = renderer.render()
            
            contentView.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.addArrangedSubview(contentView)
            self.contentViews.append(contentView)
        }
    }
    
    func adjustScrollView(_ scrollView: UIScrollView, velocityX: CGFloat = .zero) {
        let offsetX = UIScrollView.SBUScrollAdjustPosition.adjustContentOffsetX(
            in: scrollView,
            items: self.contentViews,
            offset: self.params.profileArea,
            velocityX: velocityX
        )
        
        let contentOffset = CGPoint(x: offsetX, y: 0)
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: self).x / CGFloat(-1_000)
        adjustScrollView(scrollView, velocityX: velocity)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        adjustScrollView(scrollView, velocityX: velocity.x)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self.scrollView { return HitPassView() }
        
        return view
    }
}
