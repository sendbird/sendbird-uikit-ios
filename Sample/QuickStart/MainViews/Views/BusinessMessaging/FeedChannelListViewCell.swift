//
//  FeedChannelListViewCell.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/30/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit

class FeedChannelListViewCell: UITableViewCell {
    @IBOutlet weak var channelKeyLabel: UILabel!
    @IBOutlet weak var channelURLLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
