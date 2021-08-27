//
//  SBUSelectableStackView.swift
//  SendBirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUSelectableStackView: UIView, Selectable {
    var isSelected: Bool = false {
        didSet {
            self.stackView.subviews.forEach { (view) in
                if var view = view as? Selectable {
                    view.isSelected = self.isSelected
                }
            }
            self.setupStyles()
        }
    }
    
    var position: MessagePosition = .right
    
    var rightPressedBackgroundColor: UIColor?
    var rightBackgroundColor: UIColor?
    var leftPressedBackgroundColor: UIColor?
    var leftBackgroundColor: UIColor?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
        self.setupStyles()
    }
    
    @available(*, unavailable, renamed: "MessageContentDetailView()")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    func setupViews() {
        self.addSubview(self.stackView)
    }
    
    func setupAutolayout() {
        self.stackView.setConstraint(from: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
    
    func setupStyles() {
        switch self.position {
        case .left:
            self.backgroundColor = self.isSelected
                ? self.leftPressedBackgroundColor
                : self.leftBackgroundColor
        case .right:
            self.backgroundColor = self.isSelected
                ? self.rightPressedBackgroundColor
                : self.rightBackgroundColor
        case .center:
            self.backgroundColor = nil
            break
        }
    }
    
    func setAxis(_ axis: NSLayoutConstraint.Axis) {
        self.stackView.axis = axis
    }
    
    func addArrangedSubview(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubview(_ view: UIView) {
        self.stackView.removeArrangedSubview(view)
    }
    
    func insertArrangedSubview(_ view: UIView, at index: Int) {
        self.stackView.insertArrangedSubview(view, at: index)
    }
}
