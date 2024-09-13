//
//  SBUMessageTemplateCellLayout.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 8/23/24.
//

import UIKit

/// The `SBUViewLayoutConfigurable` protocol defines the layout cycle for a cell.
/// Classes that conform to this protocol are responsible for configuring the views, setting up layouts, updating layouts, and preparing for reuse.
protocol SBUViewLayoutConfigurable: AnyObject {
    /// The associated cell type. Classes conforming to this protocol must be tied to a specific cell type.
    associatedtype TargetCell: UIView

    /// The target cell instance that this layout is associated with.
    var target: TargetCell? { get set }

    /// Configures the views of the target cell. This is typically where initial view setup occurs.
    func configureViews()
    
    /// Sets up the initial layout constraints or frames for the views in the target cell.
    func configureLayouts()

    /// Prepares the cell for reuse by resetting any state or views before the cell is reused.
    func prepareForReuse()
}

class SBUMessageTemplateCellLayout: SBUViewLayoutConfigurable {
    // -> baseStackView
    // + ------------------- +
    // | topStackView        |
    // + ------------------- +
    // | contentStackView    |
    // + ------------------- +
    // | bottomStackView     |
    // + ------------------- +
    // | additionalView     |
    // + ------------------- +
    
    var baseStackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 4)
    var topStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 0)
    var contentStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 0)
    var bottomStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 0)
    var additionalView = SBUStackView(axis: .vertical, alignment: .center, spacing: 0)
    
    var isMessyViewHierarchy: Bool = false
    
    weak var target: SBUMessageTemplateCell?
    
    var constraints: [NSLayoutConstraint] = [] {
        didSet {
            oldValue.forEach { $0.isActive = false }
            constraints.forEach { $0.isActive = true }
        }
    }
    
    func configureViews() {
        guard let cell = self.target else { return }
        
        cell.messageContentView.addSubview(self.baseStackView)
        
        self.baseStackView.setVStack([
            // top
            self.topStackView.setHStack([
                UIView.spacing(width: 12),
                cell.profileView,
                UIView.spacing(width: 24),
                cell.userNameView,
            ]),
            
            // contents
            self.contentStackView.setHStack([
                cell.messageTemplateLayer.templateContainerView
            ]),
            
            // bottom
            self.bottomStackView.setHStack([
                UIView.spacing(width: 50),
                cell.stateView
            ]),
            
            self.additionalView
        ])
    }
    
    func configureLayouts() {
        guard let cell = self.target else { return }
        
        self.baseStackView.sbu_constraint(
            equalTo: cell.contentView,
            leading: 0,
            trailing: 0,
            priority: UILayoutPriority(1000)
        )
        
        self.baseStackView.sbu_constraint(
            equalTo: cell.messageContentView,
            top: 0,
            bottom: 0,
            priority: UILayoutPriority(1000)
        )
        
        self.topStackView.isHidden = self.topStackViewHidden()
        self.bottomStackView.isHidden = self.topStackViewHidden()
        
        // layout for optional feature views
        
        if cell.messageTemplateLayer.messageTemplateRenderer.isLoaded {
            self.additionalView.setVStack([
                cell.suggestedReplyView
            ])
            
            cell.suggestedReplyView?.sbu_constraint(
                equalTo: self.additionalView,
                left: 12,
                right: 12
            )
        } else {
            self.additionalView.setVStack([])
        }
    
    }
    
    func prepareForReuse() {
        guard isMessyViewHierarchy == true else { return }
        
        self.configureViews()
        self.configureLayouts()
    }
    
    func topStackViewHidden() -> Bool {
        guard let cell = self.target else { return false }
        return cell.profileView.alpha == 0.0 && cell.userNameView.alpha == 0.0
    }
    
    func bottomStackViewHidden() -> Bool {
        guard let cell = self.target else { return false }
        return cell.stateView.alpha == 0.0
    }
}
