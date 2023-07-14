//
//  SBUCoverImageView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 04/03/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SBUCoverImageView: UIView {

    // MARK: - UI properties (Public)
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    
    // MARK: - UI properties (Private)
    var spacing: CGFloat = 0 {
        didSet {
            for subView in self.subviews {
                if let stack = subView as? UIStackView {
                    for subStack in stack.arrangedSubviews {
                        (subStack as? UIStackView)?.spacing = spacing
                    }
                }
                (subView as? UIStackView)?.spacing = spacing
            }
        }
    }
    
    private var iconSize: CGSize {
        let frameWidth = self.frame.size.width
        let marginsBetweenIconAndView: CGFloat = 8 * 2
        
        if frameWidth > SBUIconSetType.Metric.defaultIconSizeVeryLarge.width + marginsBetweenIconAndView {
            return SBUIconSetType.Metric.defaultIconSizeVeryLarge
        } else if frameWidth > SBUIconSetType.Metric.defaultIconSizeLarge.width + marginsBetweenIconAndView {
            return SBUIconSetType.Metric.defaultIconSizeLarge
        } else if frameWidth > SBUIconSetType.Metric.defaultIconSize.width + marginsBetweenIconAndView {
            return SBUIconSetType.Metric.defaultIconSize
        } else if frameWidth > SBUIconSetType.Metric.defaultIconSizeMedium.width + marginsBetweenIconAndView {
            return SBUIconSetType.Metric.defaultIconSizeMedium
        } else {
            return SBUIconSetType.Metric.defaultIconSizeSmall
        }
    }
    
    // MARK: - Life cycle
    
    public init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Setter
    
    /// This function sets the image using the cover image URL.
    /// - Parameter coverURL: Cover image url string
    public func setImage(withCoverURL coverURL: String) {
        self.setImage(with: coverURL)
    }
    
    /// This function sets the image using the cover image URL.
    /// - Parameters:
    ///     - CoverURL: Cover image url string
    ///     - makeCircle: A default value is `true`. If it's `true`, the image has rounded corners
    public func setImage(with coverURL: String, makeCircle: Bool = true) {
        let imageView = UIImageView(
            frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        )
        imageView.backgroundColor = self.theme.userPlaceholderBackgroundColor
        imageView.contentMode = coverURL.count > 0 ? .scaleAspectFill : .center

        imageView.loadImage(
            urlString: coverURL,
            placeholder: SBUIconSetType.iconUser.image(
                with: self.theme.userPlaceholderTintColor,
                to: self.iconSize
            ),
            subPath: SBUCacheManager.PathType.userProfile
        )
        
        self.addSubview(imageView)

        let subviews = self.subviews
        for subView in subviews {
            if subView != imageView {
                subView.removeFromSuperview()
            }
        }
        
        if makeCircle {
            self.makeCircularWithSpacing(spacing: 0)
        }
    }
    
    /// This function sets the broadcast icon
    public func setBroadcastIcon() {
        self.setIconImage(
            type: .iconBroadcast,
            tintColor: self.theme.broadcastIconTintColor,
            backgroundColor: theme.broadcastIconBackgroundColor
        )
    }
    
    /// This function sets the placeholder image with iconSet type.
    /// - Parameter type: IconSet type
    /// - Parameter iconSize: Icon size
    /// - Since: 3.2.0
    public func setPlaceholder(type: SBUIconSetType, iconSize: CGSize? = nil) {
        self.setIconImage(
            type: type,
            tintColor: self.theme.placeholderTintColor,
            backgroundColor: theme.placeholderBackgroundColor,
            iconSize: iconSize
        )
    }
    
    /// This function sets and image using image objects, background color, and circle option.
    /// - Parameters:
    ///   - image: Image object
    ///   - backgroundColor: background color
    ///   - makeCircle: If this value set to `true`, image will be circle.
    ///   - contentMode: The `ContentMode` value of `UIImageView`. The default value is `.center`
    public func setImage(
        withImage image: UIImage,
        backgroundColor: UIColor? = nil,
        makeCircle: Bool = false,
        contentMode: ContentMode = .center
    ) {
        let imageView = self.createImageView(
            withImage: image,
            backgroundColor: backgroundColor,
            makeCircle: makeCircle,
            contentMode: contentMode
        )
        self.addSubview(imageView)
        
        let subviews = self.subviews
        for subView in subviews {
            if subView != imageView {
                subView.removeFromSuperview()
            }
        }
        
        self.makeCircularWithSpacing(spacing: 0)
    }
    
    // MARK: - Internal
    func setIconImage(type: SBUIconSetType,
                              tintColor: UIColor?,
                              backgroundColor: UIColor? = nil,
                              iconSize: CGSize? = nil) {
        let iconSize = iconSize ?? self.iconSize
        let imageView = self.createImageView(
            withImage: type.image(with: tintColor, to: iconSize),
            backgroundColor: backgroundColor,
            makeCircle: true,
            contentMode: .center
        )
        self.addSubview(imageView)
        
        let subviews = self.subviews
        for subView in subviews {
            if subView != imageView {
                subView.removeFromSuperview()
            }
        }
        
        self.makeCircularWithSpacing(spacing: 0)
    }

    private func createImageView(withImage image: UIImage,
                                 backgroundColor: UIColor? = nil,
                                 makeCircle: Bool = false,
                                 contentMode: ContentMode) -> UIImageView {
        let imageView = UIImageView(
            frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        )
        imageView.image = image
        imageView.backgroundColor = backgroundColor
        imageView.contentMode = contentMode

        if makeCircle {
            imageView.layer.cornerRadius = self.frame.width / 2
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.clear.cgColor
            imageView.clipsToBounds = true
        }
        
        return imageView
    }
    
    /// This function sets the image using user objects.
    ///
    /// The image is created using up to four user objects.
    /// - Parameter users: `SBUUser` object array
    public func setImage(withUsers users: [User]) {
        let filteredUsers = users.filter { $0.userId != SBUGlobals.currentUser?.userId }
        let index = (filteredUsers.count > 3) ? 4 : filteredUsers.count
        let newUsers = Array(filteredUsers[0..<index])
        
        let stackView = self.setupImageStack(users: newUsers)

        self.addSubview(stackView)
        
        let subviews = self.subviews
        for subView in subviews {
            if subView != stackView {
                subView.removeFromSuperview()
            }
        }
        
        self.makeCircularWithSpacing(spacing: 0)
    }
    
    private func setupImageStack(users: [User]) -> UIStackView {
        let mainStackView = UIStackView(
            frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        )
        mainStackView.axis = .horizontal
        mainStackView.spacing = spacing
        mainStackView.distribution = .fillEqually
        
        if users.isEmpty {
            let imageView = UIImageView(frame: self.frame)
            imageView.image = SBUIconSetType.iconUser.image(
                with: theme.userPlaceholderTintColor,
                to: self.iconSize
            )
            imageView.backgroundColor = theme.userPlaceholderBackgroundColor
            imageView.contentMode = .center
            imageView.clipsToBounds = true
            
            mainStackView.addArrangedSubview(imageView)

        } else {
            let filteredUsers = users.filter { $0.userId != SBUGlobals.currentUser?.userId }
            for user in filteredUsers {
                let imageView = UIImageView(frame: self.frame)
                imageView.sbu_setProfileImageView(
                    for: user,
                    defaultImage: SBUIconSetType.iconUser.image(
                        with: theme.userPlaceholderTintColor,
                        to: self.iconSize
                    )
                )
                let profileURL = user.profileURL ?? ""
                imageView.backgroundColor = theme.userPlaceholderBackgroundColor
                imageView.contentMode = profileURL.count > 0 ? .scaleAspectFill : .center
                imageView.clipsToBounds = true

                let stackView = UIStackView(frame: self.bounds)
                stackView.addArrangedSubview(imageView)
                stackView.axis = .vertical
                stackView.distribution = .fillEqually
                stackView.spacing = spacing
                
                if mainStackView.arrangedSubviews.count < 2 {
                    mainStackView.addArrangedSubview(stackView)
                } else {
                    for subView in mainStackView.arrangedSubviews {
                        if (subView as? UIStackView)?.arrangedSubviews.count == 1 {
                            (subView as? UIStackView)?.addArrangedSubview(imageView)
                        }
                    }
                }
            }
        }

        return mainStackView
    }
    
    func makeCircularWithSpacing(spacing: CGFloat) {
        self.layer.cornerRadius = self.frame.height/2
        self.spacing = spacing
    }
    
}

extension UIImageView {
    public func sbu_setProfileImageView(for user: User, defaultImage: UIImage) {
        guard URL(string: ImageUtil.transformUserProfileImage(user: user)) != nil else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.image = defaultImage
            }
            return
        }
        
        self.loadImage(
            urlString: ImageUtil.transformUserProfileImage(user: user),
            placeholder: defaultImage,
            subPath: SBUCacheManager.PathType.userProfile
        )        
    }
}

class ImageUtil {
    static func transformUserProfileImage(user: User) -> String {
        guard let profileURL = user.profileURL else { return "" }

        if profileURL.hasPrefix("https://sendbird.com/main/img/profiles") {
            return ""
        } else {
            return profileURL
        }
    }
}
