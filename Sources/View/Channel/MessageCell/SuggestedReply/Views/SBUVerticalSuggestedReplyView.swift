//
//  SBUVerticalSuggestedReplyView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/04/22.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This is a vertical suggested reply view for displaying a list of `options`.
/// - Since: 3.11.0
open class SBUVerticalSuggestedReplyView: SBUSuggestedReplyView {
    // MARK: - Properties
    /// ``SBUStackView`` instance. The default value is a vertical stack view that contains ``topSpacer`` and the array of ``SBUSuggestedReplyOptionView``s
    public var stackView: UIStackView = SBUStackView(
        axis: .vertical,
        alignment: .trailing,
        spacing: 8
    )

    /// The view to provide top spacing to the ``stackView``
    public var topSpacer: UIView = {
        let view = UIView()
        view.sbu_constraint(height: 12)
        return view
    }()

    // MARK: - Sendbird UIKit Life Cycle
    
    open override func setupViews() {
        super.setupViews()

        let optionViews = self.createSuggestedReplyOptionViews(options: self.options)
        self.stackView.setVStack(optionViews)
        self.optionViews = optionViews
        
        self.stackView.insertArrangedSubview(self.topSpacer, at: 0)
        self.addSubview(stackView)
    }

    open override func setupLayouts() {
        super.setupLayouts()

        self.stackView
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
}
