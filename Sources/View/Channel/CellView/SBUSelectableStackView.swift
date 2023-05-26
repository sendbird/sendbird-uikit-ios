//
//  SBUSelectableStackView.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol Selectable {
    var isSelected: Bool { get set }
}

public class SBUSelectableStackView: SBUView, Selectable {
    // MARK: Public properties
    public let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    public var position: MessagePosition = .right
    
    // MARK: Internal properties
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
    
    var rightPressedBackgroundColor: UIColor?
    var rightBackgroundColor: UIColor?
    var leftPressedBackgroundColor: UIColor?
    var leftBackgroundColor: UIColor?
    
    // MARK: SBUView
    public override init() {
        super.init()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: SBUView Life Cycle
    public override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.stackView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.stackView.setConstraint(from: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
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
    
    public func setAxis(_ axis: NSLayoutConstraint.Axis) {
        self.stackView.axis = axis
    }
    
    public func addArrangedSubview(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    public func removeArrangedSubview(_ view: UIView) {
        self.stackView.removeArrangedSubview(view)
    }
    
    public func insertArrangedSubview(_ view: UIView, at index: Int) {
        self.stackView.insertArrangedSubview(view, at: index)
    }
}

extension SBUSelectableStackView {
    /**
     Adds arranged subviews to the stack view.
     */
    @discardableResult
    func setStack(_ views: [UIView]) -> Self {
        views.forEach { self.addArrangedSubview($0) }
        return self
    }
    
    /**
     Sets `axis`as  `.vertical` and adds arranged subviews to the stack view.
     */
    @discardableResult
    func setVStack(_ views: [UIView]) -> Self {
        self.stackView.axis = .vertical
        return self.setStack(views)
    }
    
    /**
     Sets `axis`as  `.horizontal` and adds arranged subviews to the stack view.
     */
    @discardableResult
    func setHStack(_ views: [UIView]) -> Self {
        self.stackView.axis = .horizontal
        return self.setStack(views)
    }
}
