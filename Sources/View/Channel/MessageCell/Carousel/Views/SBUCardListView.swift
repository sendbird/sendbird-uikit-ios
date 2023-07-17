//
//  SBUCardListView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/13.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SBUCardListView: SBUView {
    public struct Metric {
        public static var maxWidth = 258.0
    }
    
    // MARK: - Properties
    /// The stack view that contains the list of ``SBUCardView``
    /// - Since: 3.7.0
    public var stackView: UIStackView = SBUStackView(
        axis: .vertical,
        alignment: .fill,
        spacing: 8
    )
    
    /// The view to provide top spacing to the ``stackView``
    /// - Since: 3.7.0
    public var topSpacer: UIView = {
        let spacer = UIView()
        spacer.sbu_constraint(height: 8)
        return spacer
    }()
    
    /// (Read-only) The array of ``SBUCardViewParams`` object returned by ``params``
    /// - Since: 3.7.0
    public var items: [SBUCardViewParams] {
        self.params?.items ?? []
    }
    
    /// (Read-only) The ID of the message object returned by ``params``
    /// - Since: 3.7.0
    public var messageId: Int64? {
        self.params?.messageId
    }
    
    /// The data structure for ``SBUCardListViewParams``. Please use ``configure(with:)`` to update ``params``
    /// - Since: 3.7.0
    public private(set) var params: SBUCardListViewParams?
    
    // MARK: - Sendbird UIKit Life Cycle
    
    public override func setupViews() {
        super.setupViews()
        
        let itemViews = self.createCardViews(items: self.items)
        self.stackView.setVStack(itemViews)
        self.stackView.insertArrangedSubview(self.topSpacer, at: 0)
        self.addSubview(stackView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.sbu_constraint_lessThan(width: Metric.maxWidth)
        
        self.stackView
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        self.stackView.backgroundColor = .clear
    }
    
    /// Updates UI with ``SBUCardListViewParams`` object.
    /// - Parameter configuration: ``SBUCardListViewParams`` object.
    /// - Note: This method updates ``params`` and calls ``setupViews()``, ``setupLayouts()`` and ``setupStyles()``
    /// - Since: 3.7.0
    public func configure(with configuration: SBUCardListViewParams) {
        self.params = configuration
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        
        self.layoutIfNeeded()
    }
    
    /// Creates ``SBUCardView`` instances with ``SBUCardViewParams``.
    /// - Parameter items: The array of ``SBUCardViewParams``.
    /// - Returns: The array of ``SBUCardView`` instances.
    /// - Since: 3.7.0
    public func createCardViews(items: [SBUCardViewParams]) -> [SBUCardView] {
        let itemViews = items.compactMap { item in
            let view = SBUCardView()
            view.configure(with: item)
            return view
        }
        return itemViews
    }
}
