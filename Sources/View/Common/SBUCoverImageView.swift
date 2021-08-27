//
//  SBUCoverImageView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 04/03/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

public class SBUCoverImageView: UIView {

    // MARK: - UI properties (Public)
    public var theme: SBUComponentTheme = SBUTheme.componentTheme

    
    // MARK: - UI properties (Private)
    var spacing: CGFloat = 0 {
        didSet {
            for subView in self.subviews{
                if let stack = subView as? UIStackView{
                    for subStack in stack.arrangedSubviews{
                        (subStack as? UIStackView)?.spacing = spacing
                    }
                }
                (subView as? UIStackView)?.spacing = spacing
            }
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
    /// - Parameter coverUrl: Cover image url string
    public func setImage(withCoverUrl coverUrl: String){
        self.setImage(with: coverUrl)
    }
    
    /// This function sets the image using the cover image URL.
    /// - Parameters:
    ///     - CoverURL: Cover image url string
    ///     - makeCircle: A default value is `true`. If it's `true`, the image has rounded corners
    public func setImage(with coverURL: String, makeCircle: Bool = true) {
        self.theme = SBUTheme.componentTheme
        
        let imageView = UIImageView(
            frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        )
        imageView.loadImage(
            urlString: coverURL,
            placeholder: SBUIconSetType.iconUser.image(
                with: self.theme.userPlaceholderTintColor,
                to: iconSize()
            )
        )
        imageView.backgroundColor = theme.userPlaceholderBackgroundColor
        imageView.contentMode = .scaleAspectFill
        
        let subviews = self.subviews
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.addSubview(imageView)
            
            for subView in subviews{
                subView.removeFromSuperview()
            }
        }
        
        if makeCircle {
            makeCircularWithSpacing(spacing: 0)
        }
    }
    
    /// This function sets placeholder image with icon size.
    /// - Parameter iconSize: icon size
    public func setPlaceholderImage(iconSize: CGSize) {
        self.theme = SBUTheme.componentTheme
        self.setIconImage(type: .iconUser,
                          tintColor: theme.userPlaceholderTintColor,
                          backgroundColor: theme.userPlaceholderBackgroundColor)
    }
    
    /// This function sets the broadcast icon
    public func setBroadcastIcon() {
        self.theme = SBUTheme.componentTheme
        self.setIconImage(type: .iconBroadcast,
                          tintColor: self.theme.broadcastIconTintColor,
                          backgroundColor: theme.broadcastIconBackgroundColor)
    }
    
    /// This function sets and image using image objects, background color, and circle option.
    /// - Parameters:
    ///   - image: Image object
    ///   - backgroundColor: background color
    ///   - makeCircle: If this value set to `true`, image will be circle.
    public func setImage(withImage image: UIImage,
                         backgroundColor: UIColor? = nil,
                         makeCircle: Bool = false) {
        let imageView = createImageView(withImage: image,
                                        backgroundColor: backgroundColor,
                                        makeCircle: makeCircle,
                                        contentMode: .scaleAspectFill)
        let subviews = self.subviews

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.addSubview(imageView)

            for subView in subviews {
                subView.removeFromSuperview()
            }
        }

        makeCircularWithSpacing(spacing: 0)
    }
    
    private func setIconImage(type: SBUIconSetType,
                      tintColor: UIColor?,
                      backgroundColor: UIColor? = nil) {
        let imageView = createImageView(withImage: type.image(with: tintColor, to: iconSize()),
                                        backgroundColor: backgroundColor,
                                        makeCircle: true,
                                        contentMode: .center)
        let subviews = self.subviews
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.addSubview(imageView)
            
            for subView in subviews {
                subView.removeFromSuperview()
            }
        }

        makeCircularWithSpacing(spacing: 0)
    }
    
    private func iconSize() -> CGSize {
        let frameWidth = self.frame.size.width
        let marginsBetweenIconAndView: CGFloat = 8 * 2
        
        if frameWidth > SBUIconSetType.Metric.defaultIconSizeLarge.width + marginsBetweenIconAndView {
            return SBUIconSetType.Metric.defaultIconSizeLarge
        } else if frameWidth > SBUIconSetType.Metric.defaultIconSizeMedium.width + marginsBetweenIconAndView {
            return SBUIconSetType.Metric.defaultIconSizeMedium
        } else {
            return SBUIconSetType.Metric.defaultIconSizeSmall
        }
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
    public func setImage(withUsers users: [SBDUser]) {
        let filteredUsers = users.filter { $0.userId != SBUGlobals.CurrentUser?.userId }
        let index = (filteredUsers.count > 3) ? 4 : filteredUsers.count
        let newUsers = Array(filteredUsers[0..<index])
        
        let stackView = self.setupImageStack(users: newUsers)
        
        let subviews = self.subviews
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.addSubview(stackView)

            for subView in subviews {
                subView.removeFromSuperview()
            }
        }

        makeCircularWithSpacing(spacing: 0)
    }
    
    private func setupImageStack(users: [SBDUser]) -> UIStackView {
        self.theme = SBUTheme.componentTheme
        
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
                to: iconSize()
            )
            imageView.backgroundColor = theme.userPlaceholderBackgroundColor
            imageView.contentMode = .center
            imageView.clipsToBounds = true
            
            mainStackView.addArrangedSubview(imageView)

        } else {
            let filteredUsers = users.filter { $0.userId != SBUGlobals.CurrentUser?.userId }
            for user in filteredUsers {
                let imageView = UIImageView(frame: self.frame)
                imageView.sbu_setProfileImageView(
                    for: user,
                    defaultImage: SBUIconSetType.iconUser.image(
                        with: theme.userPlaceholderTintColor,
                        to: iconSize()
                    )
                )
                imageView.backgroundColor = theme.userPlaceholderBackgroundColor
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true

                let stackView = UIStackView(frame: self.bounds)
                stackView.addArrangedSubview(imageView)
                stackView.axis = .vertical
                stackView.distribution = .fillEqually
                stackView.spacing = spacing
                
                if mainStackView.arrangedSubviews.count < 2 {
                    mainStackView.addArrangedSubview(stackView)
                }
                else {
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
    
    func makeCircularWithSpacing(spacing: CGFloat){
        self.layer.cornerRadius = self.frame.height/2
        self.spacing = spacing
    }
    
}

extension UIImageView {
    public func sbu_setProfileImageView(for user: SBDUser, defaultImage: UIImage) {
        guard let _ = URL(string: ImageUtil.transformUserProfileImage(user: user)) else {
            self.image = defaultImage
            return
        }
        
        self.loadImage(
            urlString: ImageUtil.transformUserProfileImage(user: user),
            placeholder: defaultImage
        )        
    }
}

class ImageUtil {
    static func transformUserProfileImage(user: SBDUser) -> String {
        guard let profileUrl = user.profileUrl else { return "" }

        if profileUrl.hasPrefix("https://sendbird.com/main/img/profiles") {
            return ""
        } else {
            return profileUrl
        }
    }
}
