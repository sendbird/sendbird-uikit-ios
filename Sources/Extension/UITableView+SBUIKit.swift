//
//  UITableView+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/04/09.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UITableView {
    func sbu_reloadCell(_ cell: UITableViewCell?) {
        guard let cell = cell, let indexPath = self.indexPath(for: cell) else { return }
        guard let visibleIndexPaths = self.indexPathsForVisibleRows else { return }
        guard visibleIndexPaths.contains(indexPath) else { return }
        
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            self.reloadRows(at: [indexPath], with: .none)
            self.layoutIfNeeded()
        }
    }
}
