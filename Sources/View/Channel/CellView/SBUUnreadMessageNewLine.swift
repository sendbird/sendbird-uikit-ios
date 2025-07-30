//
//  SBUUnreadMessageNewLine.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 5/13/25.
//

import UIKit

/// The view that shows the new line for first unread message of the channel.
/// - Since: 3.32.0
public class SBUUnreadMessageNewLine: SBUView {
    private let label: UILabel = {
        let label = UILabel()
        label.text = SBUStringSet.Channel_Unread_Message_Newline
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // prevent the label from stretching
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let leftLine: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.setContentHuggingPriority(.defaultLow, for: .horizontal)
        line.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return line
    }()
    
    private let rightLine: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .systemGray3
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.setContentHuggingPriority(.defaultLow, for: .horizontal)
        line.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return line
    }()
    
    private lazy var stackView: SBUStackView = {
        let stackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties (Private)
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    public override init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func setupViews() {
        super.setupViews()
        
        self.stackView.setHStack([
            self.leftLine,
            self.label,
            self.rightLine
        ])
        self.addSubview(self.stackView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.leftLine.widthAnchor.constraint(equalTo: self.rightLine.widthAnchor).isActive = true
        
        self.stackView.sbu_constraint(
            equalTo: self,
            left: 7.5,
            right: 7.5,
            top: 0,
            bottom: 0
        )
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        label.font = theme.newLineLabelFont
        label.textColor = theme.newLineLabelTintColor
        
        leftLine.backgroundColor = theme.newLineTintColor
        rightLine.backgroundColor = theme.newLineTintColor
    }
}
