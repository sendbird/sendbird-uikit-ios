//
//  SBUSuggestedMentionList.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/04/05.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

public protocol SBUSuggestedMentionListDelegate: AnyObject {
    func suggestedUserList(_ list: SBUSuggestedMentionList, didSelectUser user: SBUUser)
}

open class SBUSuggestedMentionList: SBUView, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Views
    public lazy var tableView = UITableView()
    
    public var userCell: UITableViewCell?
    public var limitGuideCell: UITableViewCell?
    
    public var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Models
    public private(set) var filteredUsers: [SBUUser] = []
    public var isLimitGuideEnabled: Bool = false
    
    // MARK: - Delegate
    public weak var delegate: SBUSuggestedMentionListDelegate?
    
    public var theme: SBUChannelTheme = .init()
    public var showsUserId = true {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    
    public override init() {
        super.init()
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.autoresizingMask = .flexibleHeight
        self.backgroundColor = self.theme.backgroundColor
        
        // table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.addSubview(self.tableView)

        // table view cells
        if userCell == nil {
            self.register(userCell: SBUUserCell())
        }
        if limitGuideCell == nil {
            self.register(limitGuideCell: SBUMentionLimitGuideCell())
        }
        
        // top border
        let border = UIView()
        border.backgroundColor = theme.separatorColor
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 0.5)
        self.tableView.addSubview(border)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.tableView
            .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
    }

    // MARK: Mention
    
    // MARK: Table View
    
    public func register(userCell: UITableViewCell, nib: UINib? = nil) {
        self.userCell = userCell
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: userCell.sbu_className)
        } else {
            self.tableView.register(
                type(of: userCell),
                forCellReuseIdentifier: userCell.sbu_className
            )
        }
    }
    
    public func register(limitGuideCell: UITableViewCell, nib: UINib? = nil) {
        self.limitGuideCell = limitGuideCell
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: limitGuideCell.sbu_className)
        } else {
            self.tableView.register(
                type(of: limitGuideCell),
                forCellReuseIdentifier: limitGuideCell.sbu_className
            )
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLimitGuideEnabled ? 1 : filteredUsers.count
    }
    
    /// Override `configureCell(_:forRowAt:)` to customize cell configuration with user object for each index path.
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        if isLimitGuideEnabled {
            cell = tableView.dequeueReusableCell(
                withIdentifier: limitGuideCell?.sbu_className ?? SBUMentionLimitGuideCell.sbu_className
            )
            cell?.selectionStyle = .none
        } else {
            cell = tableView.dequeueReusableCell(
                withIdentifier: userCell?.sbu_className ?? SBUUserCell.sbu_className
            )
            // configure cell
            self.configureCell(cell, forRowAt: indexPath)
        }
        
        return cell ?? UITableViewCell()
    }
    
    /// Override `selectUser(_:)` to customize action when the user has been selected.
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLimitGuideEnabled { return }
        let user = self.filteredUsers[indexPath.row]
        self.selectUser(user)
    }
    
    open func configureCell(_ cell: UITableViewCell?, forRowAt indexPath: IndexPath) {
        let user = self.filteredUsers[indexPath.row]
        if let defaultCell = cell as? SBUUserCell {
            defaultCell.configure(
                type: .suggestedMention(showsUserId),
                user: user
            )
        }
    }
    
    /// Calls `suggestedMentionList(_:didSelectUser:)` delegate method.
    open func selectUser(_ user: SBUUser) {
        self.delegate?.suggestedUserList(self, didSelectUser: user)
    }
    
    /// If `isLimitGuideEnabled` is `false`, it set up `filteredUsers` as an *empty*, even if the `users` isn't an empty value.
    open func reloadData(with users: [SBUUser]) {
        self.filteredUsers = isLimitGuideEnabled ? [] : users
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}
