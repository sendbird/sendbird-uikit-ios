//
//  MessageTranslationMessageCell.swift
//  QuickStart
//
//  Created by Celine Moon on 11/23/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class MessageTranslationMessageCell: UITableViewCell {
    
    static let identifier = "MessageTranslationMessageCell"
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    lazy var messageLabel: UILabel = {
        let messageLabel: UILabel = UILabel()
        messageLabel.textColor = .black
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 17)
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with message: BaseMessage) {
//        if let sender = message.sender {
//            profileLabel.text = "\(sender.nickname)"
//            profileImageView.setProfileImageView(for: sender)
//        } else if message is AdminMessage {
//            profileLabel.text = "Admin"
//        }
        messageLabel.text = "\(message.message)"
//        "\(message.message)\(MessageSendingStatus(message).description) (\(Date.sbu_from(message.createdAt).sbu_toString(format: .hhmma)))"
    }
}
