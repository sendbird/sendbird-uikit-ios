//
//  SBUMesageFormChipView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 7/3/24.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.27.0
protocol SBUMesageFormChipViewDelegate: AnyObject {
    func messageFormChipView(_ chip: SBUMesageFormChipView, didSelect value: String)
}

/// Chip view A view that displays items
/// - Since: 3.27.0
public class SBUMesageFormChipView: SBUView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// The theme for ``SBUMessageFormItemView`` that is type of ``SBUMessageCellTheme``.
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// chip items
    public var chips: [String] = []
    
    var status: SBUMessageFormItemView.StatusType = .unknown
    
    weak var delegate: SBUMesageFormChipViewDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = .zero
        
        let collectionView = SBUWrappingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(
            SBUMesageFormChipCell.self,
            forCellWithReuseIdentifier: SBUMesageFormChipCell.sbu_className
        )
        
        return collectionView
    }()
    
    func update(chips: [String], status: SBUMessageFormItemView.StatusType) {
        self.status = status
        self.chips = chips
        self.collectionView.reloadData()
    }
    
    public override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.collectionView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.collectionView.sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.chips.count 
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUMesageFormChipCell.sbu_className,
            for: indexPath
        ) as? SBUMesageFormChipCell else {
            return UICollectionViewCell()
        }
        let value = self.chips[indexPath.row]
        let state = SBUMesageFormChipCell.ChipState(status: self.status, value: value)
        cell.configure(value: value, state: state)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.status.isEditable == true else { return }
        self.delegate?.messageFormChipView(self, didSelect: self.chips[indexPath.row])
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let value = self.chips[indexPath.row]
        let size = (value as NSString).size(withAttributes: [NSAttributedString.Key.font: theme.formChipTextFont])
        let state = SBUMesageFormChipCell.ChipState(status: self.status, value: value)
        let maxWidth = collectionView.bounds.width
        let iconViewWidth: CGFloat = state.isSubmitted ? 20 + 3 : 0
        let width = min(size.width + 24 + iconViewWidth, maxWidth)
        return CGSize(width: width.rounded(.up), height: 32)
    }
}

/// - Since: 3.27.0
class SBUMesageFormChipCell: SBUCollectionViewCell {
    /// The theme for ``SBUMessageFormItemView`` that is type of ``SBUMessageCellTheme``.
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    /// The `UILabel` displaying form field title.`
    var titleView = UILabel()
    /// The `UIImageView` for displaying input completion icons.
    var inputIconView = UIImageView()
    /// A horizontal stack view to configure layouts of `title` and `icon`.
    var stackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 3)
    
    var state: ChipState = .submitted(true) {
        didSet { updateAppearance() }
    }
    
    func configure(value: String, state: ChipState) {
        self.titleView.text = value
        self.state = state
        
        self.updateAppearance()
    }
    
    override func setupViews() {
        self.stackView.setHStack([self.titleView, self.inputIconView])
        self.contentView.addSubview(self.stackView)
    }
    
    override func setupLayouts() {
        self.stackView
            .sbu_constraint(height: 32, priority: .defaultLow)
            .sbu_constraint(equalTo: self.contentView, left: 12, top: 0)
            .sbu_constraint(equalTo: self.contentView, right: 12, bottom: 0)
        
        self.inputIconView
            .sbu_constraint(width: 20, height: 20)
    }
    
    override func setupStyles() {
        self.titleView.textAlignment = .center
        self.titleView.numberOfLines = 1
        self.titleView.font = theme.formChipTextFont
        self.titleView.lineBreakMode = .byTruncatingTail
        
        self.layer.cornerRadius = 16
        
        self.inputIconView.image = SBUIconSet.iconDone.sbu_with(tintColor: theme.formInputIconColor)
        self.updateAppearance()
    }
    
    private func updateAppearance() {
        switch state {
        case .selected(false):
            self.layer.borderWidth = 1
            self.layer.borderColor = theme.formChipBorderNormalColor.cgColor
            self.backgroundColor = theme.formChipBackgroundNormalColor
            self.titleView.textColor = theme.formChipTitleNormalColor
            self.inputIconView.isHidden = true
        case .selected(true):
            self.layer.borderWidth = 1
            self.layer.borderColor = theme.formChipBorderSelectColor.cgColor
            self.backgroundColor = theme.formChipBackgroundSelectColor
            self.titleView.textColor = theme.formChipTitleSelectColor
            self.inputIconView.isHidden = true
        case .submitted(false):
            self.layer.borderWidth = 1
            self.layer.borderColor = theme.formChipBorderDisableColor.cgColor
            self.backgroundColor = theme.formChipBackgroundDisableColor
            self.titleView.textColor = theme.formChipTitleDisableColor
            self.inputIconView.isHidden = true
        case .submitted(true):
            self.layer.borderWidth = 1
            self.layer.borderColor = theme.formChipBorderSubmittedColor.cgColor
            self.backgroundColor = theme.formChipBackgroundSubmittedColor
            self.titleView.textColor = theme.formChipTitleSubmittedColor
            self.inputIconView.isHidden = false
        }
    }
}

extension SBUMesageFormChipCell {
    /// - Since: 3.27.0
    enum ChipState {
        case selected(Bool)
        case submitted(Bool)
        
        var isSubmitted: Bool {
            switch self {
            case .submitted(true): return true
            default: return false
            }
        }
    }
}
 
extension SBUMesageFormChipCell.ChipState {
    init(status: SBUMessageFormItemView.StatusType, value: String) {
        switch status {
        case .done(let values): self = .submitted(values.contains(value))
        case .editing(let values): self = .selected((values ?? []).contains(value))
        case .optional: self = .submitted(false)
        case .unknown: self = .submitted(false)
        }
    }
}
