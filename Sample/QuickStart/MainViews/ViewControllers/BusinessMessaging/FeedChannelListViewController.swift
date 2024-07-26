//
//  FeedChannelListViewController.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/26/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

final class FeedChannelListViewController: UIViewController {
    var feedChannels: [(String, String)] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        self.tableView.register(UINib(nibName: "FeedChannelListViewCell", bundle: nil), forCellReuseIdentifier: "FeedChannelListViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let feedChannelsDict = SendbirdChat.getAppInfo()?.notificationInfo?.feedChannels  {
            for (key, url) in feedChannelsDict {
                self.feedChannels.append((key, url))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        #if INSPECTION
        AppDelegate.bringInspectionViewToFront()
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension FeedChannelListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channelURL = self.feedChannels[indexPath.row].1
        
        let vc = NotificationChannelViewController(
            channelURL: channelURL,
            displaysLocalCachedListFirst: true
        )
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedChannelListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedChannels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedChannelListViewCell", for: indexPath) as! FeedChannelListViewCell
        
        let channelKey = self.feedChannels[indexPath.row].0
        let channelURL = self.feedChannels[indexPath.row].1
        
        cell.channelKeyLabel.text = channelKey
        cell.channelURLLabel.text = channelURL
        
        return cell
    }
}
