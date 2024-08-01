//
//  SBUFeedNotificationChannelModule.CategoryFilter.swift
//  SendbirdUIKit
//
//  Created by Jed Gyeong on 8/21/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// swiftlint:disable type_name
protocol SBUFeedNotificationChannelModuleCategoryFilterDelegate: SBUCommonDelegate {
    func feedNotificationChannelModule(
        _ categoryFilterComponent: SBUFeedNotificationChannelModule.CategoryFilter,
        didSelectCategory: NotificationCategory
    )
}

protocol SBUFeedNotificationChannelModuleCategoryFilterDataSource: AnyObject {
    func categoriesForFeedNotificationChannelModule(
        _ categoryFilterComponent: SBUFeedNotificationChannelModule.CategoryFilter
    ) -> [NotificationCategory]?
}
// swiftlint:enable type_name

extension SBUFeedNotificationChannelModule {
    @objcMembers
    public class CategoryFilter: UIView {
        struct Constants {
            static let categoryInteritemSpacing: CGFloat = 8
            static let categoryCellLeftRightMargin: CGFloat = 24
            static let categoryCellHeight: CGFloat = 30
            static let cateogryEdgeInsetsTop: CGFloat = 8
            static let cateogryEdgeInsetsBottom: CGFloat = 8
            static let cateogryEdgeInsetsLeft: CGFloat = 16
            static let cateogryEdgeInsetsRight: CGFloat = 16
        }
        
        // MARK: - UI Properties
        lazy var collectionView: UICollectionView = {
            let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            
            view.isScrollEnabled = true
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.contentInset = UIEdgeInsets(
                top: Constants.cateogryEdgeInsetsTop,
                left: Constants.cateogryEdgeInsetsLeft,
                bottom: Constants.cateogryEdgeInsetsBottom,
                right: Constants.cateogryEdgeInsetsRight
            )
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if view.currentLayoutDirection.isRTL {
                view.transform = .init(scaleX: -1, y: 1)
            }
            return view
        }()
        
        /// Specifies the theme object that’s used as the theme of the list component. The theme must inherit the ``SBUNotificationTheme.CategoryFilter`` class.
        var theme: SBUNotificationTheme.CategoryFilter {
            switch SBUTheme.colorScheme {
            case .light: return .light
            case .dark: return .dark
            }
        }
        
        // MARK: - Logic properties
        /// The object that acts as the delegate of the list component. The delegate must adopt the ``SBUFeedNotificationChannelModuleCategoryFilterDelegate``.
        weak var delegate: SBUFeedNotificationChannelModuleCategoryFilterDelegate?
        
        /// The object that acts as the base data source of the list component. The base data source must adopt the ``SBUFeedNotificationChannelModuleCategoryFilterDataSource``.
        weak var dataSource: SBUFeedNotificationChannelModuleCategoryFilterDataSource?
        
        /// The category filter
        var categories: [NotificationCategory]? {
            self.dataSource?.categoriesForFeedNotificationChannelModule(self)
        }
        
        var selectedIndex: Int = 0

        // MARK: - UI Properties (Private)
        private let flowLayout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            
            return layout
        }()

        /// Configures component with parameters.
        /// - Parameters:
        ///    - delegate: ``SBUFeedNotificationChannelModuleListDelegate`` type event delegate.
        ///    - dataSource: The data source that is type of ``SBUFeedNotificationChannelModuleListDataSource``
        func configure(
            delegate: SBUFeedNotificationChannelModuleCategoryFilterDelegate,
            dataSource: SBUFeedNotificationChannelModuleCategoryFilterDataSource
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        func setupViews() {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            
            self.collectionView.register(
                SBUCategoryFilterCell.self,
                forCellWithReuseIdentifier: SBUCategoryFilterCell.sbu_className
            )
            
            self.addSubview(self.collectionView)
        }
        
        /// Sets layouts of the views in the list component.
        func setupLayouts() {
            self.collectionView.sbu_constraint(
                equalTo: self,
                left: 0,
                right: 0,
                top: 0
            )
            self.collectionView.sbu_constraint_equalTo(
                bottomAnchor: self.safeAreaLayoutGuide.bottomAnchor, bottom: 0
            )
        }
        
        /// Sets styles of the views in the list component. If set theme parameter as `nil`, it uses the stored value.
        func setupStyles() {
            self.backgroundColor = self.theme.backgroundColor
            self.collectionView.backgroundColor = self.theme.backgroundColor
        }
        
        func updateStyles() {
            self.setupStyles()
        }

        public func reloadCollectionView() {
            if Thread.isMainThread {
                self.collectionView.reloadData()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension SBUFeedNotificationChannelModule.CategoryFilter: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUCategoryFilterCell.sbu_className,
            for: indexPath
        ) as? SBUCategoryFilterCell else { return UICollectionViewCell() }
        
        guard let categories = self.categories else { return UICollectionViewCell() }
        
        cell.label.text = categories[indexPath.row].name
        cell.updateSelectionStatus(isSelected: indexPath.row == self.selectedIndex)
        
        if cell.currentLayoutDirection.isRTL {
            cell.contentView.transform = .init(scaleX: -1, y: 1)
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension SBUFeedNotificationChannelModule.CategoryFilter: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categories = self.categories else { return }
        
        self.selectedIndex = indexPath.row
        
        self.delegate?.feedNotificationChannelModule(self, didSelectCategory: categories[indexPath.row])
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension SBUFeedNotificationChannelModule.CategoryFilter: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SBUFeedNotificationChannelModule.CategoryFilter.Constants.categoryInteritemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let category = self.categories?[indexPath.row] else { return CGSize.zero }

        let size = UILabel.textSize(
            font: SBUFontSet.notificationsFont(
                size: self.theme.textSize,
                weight: self.theme.fontWeight.value
            ),
            text: category.name,
            numberOfLines: 1
        )
        
        return CGSize(
            width: size.width + SBUFeedNotificationChannelModule.CategoryFilter.Constants.categoryCellLeftRightMargin,
            height: SBUFeedNotificationChannelModule.CategoryFilter.Constants.categoryCellHeight
        )
    }
}
