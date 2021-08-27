//
//  CustomBaseViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/01.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class CustomBaseViewController: UITableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalSetCustomManager.setDefault()
        SBUTheme.set(theme: .light)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Custom Samples"
        self.createBackButton()        
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return CustomSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return CustomSection(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return CustomSection.customItems(section: section).count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CustomListCell")
        let title: String = CustomSection.customItems(section: indexPath.section)[indexPath.row]
        let description: String = CustomSection.customItemDescriptions(
            section: indexPath.section
            )[indexPath.row]
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = description
        cell.detailTextLabel?.textColor = .lightGray

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }
        let section = CustomSection(rawValue: indexPath.section)
        let row = indexPath.row
        
        GlobalSetCustomManager.setDefault()
        
        switch section {
        case .Default:
            startDefault()
        case .Global:
            GlobalSetCustomManager.startSample(
                naviVC: navigationController,
                type: GlobalCustomType(rawValue: row)
            )
        case .ChannelList:
            ChannelListCustomManager.shared.startSample(
                naviVC: navigationController,
                type: ChannelListCustomType(rawValue: row)
            )
        case .Channel:
            ChannelCustomManager.shared.startSample(
                naviVC: navigationController,
                type: ChannelCustomType(rawValue: row)
            )
        case .ChannelSettings:
            ChannelSettingsCustomManager.shared.startSample(
                naviVC: navigationController,
                type: ChannelSettingsCustomType(rawValue: row)
            )
        case .CreateChannel:
            CreateChannelCustomManager.shared.startSample(
                naviVC: navigationController,
                type: CreateChannelCustomType(rawValue: row)
            )
        case .InviteUser:
            InviteUserCustomManager.shared.startSample(
                naviVC: navigationController,
                type: InviteUserCustomType(rawValue: row)
            )
        case .MemberList:
            MemberListCustomManager.shared.startSample(
                naviVC: navigationController,
                type: MemberListCustomType(rawValue: row)
            )
        default:
            break
        }
    }
    
    func startDefault() {
        SBUTheme.set(theme: .light)
        let channelListVC = SBUChannelListViewController()
        self.navigationController?.pushViewController(channelListVC, animated: true)
    }
}


// MARK: - Navigation
extension CustomBaseViewController {
    func createBackButton() {
        let backButton = UIBarButtonItem( image: nil,
                                          style: .plain,
                                          target: self,
                                          action: #selector(onClickBack) )
        backButton.image = SBUIconSet.iconBack.resize(with: CGSize(width: 24, height: 24))
        backButton.tintColor = SBUColorSet.primary300
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
