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
        guard let cell = cell else { return }

        Thread.executeOnMain { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            // 행 번호와 개수는 main으로 넘어온 뒤 이 블록 안에서 읽는다.
            guard let indexPath = self.indexPath(for: cell) else { return }
            guard let visibleIndexPaths = self.indexPathsForVisibleRows else { return }
            guard visibleIndexPaths.contains(indexPath) else { return }
            // 데이터 행 수가 table view가 아는 행 수와 다르면 reloadRows가 예외를 내므로 건너뛴다.
            guard self.dataSource?.tableView(self, numberOfRowsInSection: indexPath.section)
                    == self.numberOfRows(inSection: indexPath.section) else { return }

            self.reloadRows(at: [indexPath], with: .none)
            self.layoutIfNeeded()
        }
    }
}
