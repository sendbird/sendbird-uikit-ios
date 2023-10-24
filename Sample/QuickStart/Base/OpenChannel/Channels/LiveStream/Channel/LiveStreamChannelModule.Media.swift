//
//  LiveStreamChannelModule.List.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2022/09/08.
//  Copyright © 2022 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol LiveStreamChannelModuleMediaDelegate: SBUOpenChannelModuleMediaDelegate {
    func liveStreamChannelModule(
        _ mediaComponent: LiveStreamChannelModule.Media,
        didTapCloseButton button: UIButton
    )
}

protocol LiveStreamChannelModuleMediaDataSource: AnyObject {
    func liveStreamChannelModule(
        _ mediaComponent: LiveStreamChannelModule.Media,
        channelForMediaView mediaView: UIView
    ) -> OpenChannel?
}

class LiveStreamChannelModule {
    class Media: SBUOpenChannelModule.Media {
        
        static let activeIndicatorSize: CGFloat = 10
        static let liveInfoHeight: CGFloat = 16
        static let closeButtonSize: CGFloat = 24
        
        lazy var closeButton: UIButton = {
            let button = UIButton()
            button.addTarget(
                self,
                action: #selector(onTapCloseButton),
                for: .touchUpInside
            )
            button.setImage(
                SBUIconSetType.iconClose
                    .image(to: SBUIconSetType.Metric.defaultIconSize)
                    .sbu_with(tintColor: SBUColorSet.ondark01),
                for: .normal
            )
            return button
        }()
        
        let contentStackView = SBUStackView(
            axis: .vertical,
            alignment: .fill,
            spacing: 0
        )
        let topStackView = SBUStackView(
            axis: .horizontal,
            alignment: .fill,
            spacing: 0
        )
        let bottomStackView = SBUStackView(
            axis: .horizontal,
            alignment: .center,
            spacing: 8
        )
        let liveInfoHStack = SBUStackView(
            axis: .horizontal,
            spacing: 4
        )
        lazy var translucentView: UIView = {
            let view = UIView()
            view.backgroundColor = SBUColorSet.onlight03
            return view
        }()
        lazy var liveLabel: UILabel = {
            let label = UILabel()
            label.font = SBUFontSet.body2
            label.textColor = SBUColorSet.ondark01
            return label
        }()
        let participantCountLabel: UILabel = {
            let label = UILabel()
            label.font = SBUFontSet.body3
            label.textColor = SBUColorSet.ondark01
            return label
        }()
        let activeIndicator = UIView()
        lazy var redDotIcon: UIView = {
            let icon = UIView()
            icon.layer.cornerRadius = Self.activeIndicatorSize / 2
            icon.clipsToBounds = true
            icon.backgroundColor = .red
            return icon
        }()
        
        weak var dataSource: LiveStreamChannelModuleMediaDataSource?
        
        var channel: OpenChannel? {
            self.dataSource?
                .liveStreamChannelModule(self, channelForMediaView: self.mediaView)
        }
        
        func configure(
            delegate: LiveStreamChannelModuleMediaDelegate,
            dataSource: LiveStreamChannelModuleMediaDataSource,
            theme: SBUChannelTheme
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles(theme: theme)
            
            self.backgroundColor = .black
            self.mediaView.backgroundColor = .clear
            
            guard let channel = channel else { return }

            if let mediaView = self.mediaView as? UIImageView, let liveStreamData = channel.liveStreamData {
                mediaView.updateImage(urlString: liveStreamData.liveChannelURL)
            }
            
            self.liveLabel.text = "LIVE"
            
            switch channel.participantCount {
            case 0: self.participantCountLabel.text = "0 participant"
            case 1...: self.participantCountLabel.text = SBUStringSet.Open_Channel_Participants_Count(channel.participantCount)
            default: self.participantCountLabel.text = ""
            }
            self.liveInfoHStack.setHStack([
                self.activeIndicator,
                self.liveLabel,
                self.participantCountLabel
            ])
        }
        
        /// - IMPORTANT: Do nothing here. Please refer to ``configure(delegate:dataSource:theme:)``.
        /// Override to do nothing when it's called from `SBUOpenChannelViewController loadView()`
        override func configure(delegate: SBUOpenChannelModuleMediaDelegate, theme: SBUChannelTheme) {
            // DO NOTHING
        }
        
        override func setupViews() {
            self.mediaView = UIImageView()
            self.mediaView.contentMode = .scaleAspectFill
            self.mediaView.clipsToBounds = true
            
            self.activeIndicator.clipsToBounds = true
            
            self.translucentView.isHidden = true
            
            // Calls super method
            super.setupViews()
            
            // Set up view hierarchy
            self.mediaView.addSubview(
                self.translucentView
            )
            self.translucentView.addSubview(
                self.contentStackView.setVStack([
                    self.topStackView.setHStack([
                        closeButton,
                        UIView()
                    ]),
                    UIView(),
                    self.bottomStackView.setHStack([
                        self.liveInfoHStack
                    ])
                ])
            )
            self.activeIndicator.addSubview(redDotIcon)
            self.liveInfoHStack.setCustomSpacing(8, after: liveLabel)
        }
        
        override func setupLayouts() {
            super.setupLayouts()
            
            self.translucentView
                .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
            
            self.contentStackView
                .sbu_constraint_equalTo(
                    leadingAnchor: self.translucentView.layoutMarginsGuide.leadingAnchor, leading: 0,
                    trailingAnchor: self.translucentView.trailingAnchor, trailing: 30,
                    topAnchor: self.translucentView.layoutMarginsGuide.topAnchor, top: 0,
                    bottomAnchor: self.translucentView.layoutMarginsGuide.bottomAnchor, bottom: 0
                )
            
            self.closeButton
                .sbu_constraint(width: Self.closeButtonSize, height: Self.closeButtonSize)
            
            self.liveInfoHStack
                .sbu_constraint(height: Self.liveInfoHeight)
            
            self.liveLabel
                .sbu_constraint(width: 32)
            
            self.activeIndicator
                .sbu_constraint(width: Self.activeIndicatorSize)
            
            self.redDotIcon
                .sbu_constraint(width: Self.activeIndicatorSize, height: Self.activeIndicatorSize)
                .sbu_constraint_equalTo(
                    centerXAnchor: self.activeIndicator.centerXAnchor, centerX: 0,
                    centerYAnchor: self.activeIndicator.centerYAnchor, centerY: 0
                )
        }
        
        func hideLiveInfo() {
            self.translucentView.isHidden.toggle()
        }
        
        // MARK: - Actions
        @objc func onTapCloseButton() {
            (self.delegate as? LiveStreamChannelModuleMediaDelegate)?
                .liveStreamChannelModule(self, didTapCloseButton: self.closeButton)
        }
    }
}
