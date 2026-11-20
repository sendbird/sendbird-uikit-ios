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
    
    /// 기본 세로형 뷰가 그리는 옵션 수의 상한.
    static let maxOptionCount = 20

    open override func setupViews() {
        super.setupViews()

        // 옵션마다 버튼 뷰를 main에서 한꺼번에 만들고 레이아웃 시간이 개수보다 빠르게 늘어
        // (iOS 26.4 시뮬레이터에서 300개 2.4초) 앞의 20개만 그린다. 나머지는 안내 없이 그리지 않는다.
        // `options`는 그대로 두어, 직접 만든 추천 답장 뷰는 모든 옵션을 읽는다.
        let optionViews = self.createSuggestedReplyOptionViews(options: Array(self.options.prefix(Self.maxOptionCount)))
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
