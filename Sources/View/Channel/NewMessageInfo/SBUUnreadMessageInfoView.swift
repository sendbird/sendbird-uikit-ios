//
//  SBUUnreadMessageInfoView.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 6/19/25.
//

import UIKit

/// The view that shows the number of unread messages in a group channel.
/// - Since: [NEXT_VERSION]
public class SBUUnreadMessageInfoView: SBUView {
    public lazy var baseStackView: SBUStackView = {
        let view = SBUStackView(axis: .horizontal, spacing: 4)
        view.clipsToBounds = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: -2, left: 0, bottom: -2, right: 0)
        return view
    }()
    
    public lazy var unreadMessageCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = theme.unreadMessageFont
        label.textColor = theme.unreadMessageLabelTintColor
        return label
    }()
    
    public lazy var markAsReadButton: UIButton = {
        let button = UIButton()
        button.setImage(
            SBUIconSetType.iconClose.image(
                with: theme.unreadMessageButtonTintColor,
                to: SBUIconSetType.Metric.defaultIconSizeSmall
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(onClickMarkAsReadButton), for: .touchUpInside)
        return button
    }()
    
    public typealias SBUUnreadMessageInfoViewHandler = () -> Void
    
    public var actionHandler: SBUUnreadMessageInfoViewHandler?
    
    public var totalUnreadCount: UInt = 0
    
    // MARK: - Properties (Private)
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    // MARK: - Initializers
    required public override init() {
        super.init()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc
    public func onClickMarkAsReadButton() {
        self.actionHandler?()
    }
    
    public override func setupViews() {
        super.setupViews()
        
        self.baseStackView.setHStack([
            self.unreadMessageCountLabel,
            self.markAsReadButton
        ])
        
        self.addSubview(self.baseStackView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.baseStackView.sbu_constraint(equalTo: self, leading: 16, trailing: -16, top: 12, bottom: 12)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = theme.unreadMessageBackground
        self.layer.cornerRadius = 20
        self.clipsToBounds = false
        
        // Add multiple shadow layers
        self.setupShadowLayers()
    }
    
    private func setupShadowLayers() {
        let shadowConfigs: [(radius: CGFloat, offset: CGSize, color: UIColor)] = [
            (radius: 3, offset: CGSize(width: 0, height: 0), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)),
            (radius: 1, offset: CGSize(width: 0, height: 2), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)),
            (radius: 5, offset: CGSize(width: 0, height: 1), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.04))
        ]
        
        self.applyMultipleShadows(
            cornerRadius: 20,
            backgroundColor: theme.unreadMessageBackground,
            shadowConfigs: shadowConfigs
        )
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update shadow layers when bounds change
        if !self.bounds.isEmpty {
            setupShadowLayers()
        }
    }
    
    /// Updates the unread message count.
    public func updateCount(
        addCount: UInt = 0,
        replaceCount: UInt = 0
    ) {
        SBULog.info("addCount=\(addCount) replaceCount=\(replaceCount)")
        
        if addCount > 0 {
            self.totalUnreadCount += addCount
        } else {
            self.totalUnreadCount = replaceCount
        }
        unreadMessageCountLabel.text = SBUStringSet.Channel_Unread_Message(self.totalUnreadCount)
    }
}

extension SBUUnreadMessageInfoView {
    static func createDefault(_ viewType: SBUUnreadMessageInfoView.Type) -> SBUUnreadMessageInfoView {
        return viewType.init()
    }
}
