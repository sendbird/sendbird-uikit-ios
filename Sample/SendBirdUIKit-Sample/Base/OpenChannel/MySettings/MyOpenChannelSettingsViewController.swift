//
//  MyOpenChannelSettingsViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/11/15.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class MyOpenChannelSettingsViewController: MySettingsViewController {

    open override func changeDarkThemeSwitch(isOn: Bool) {
        SBUTheme.set(theme: isOn ? .dark : .light)
        
        guard let tabbarController = self.tabBarController as? MainOpenChannelTabbarController else { return }
        tabbarController.updateTheme(isDarkMode: isOn)
        self.userInfoView.setupStyles()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MySettingsCell.sbu_className
            ) as? MySettingsCell else { fatalError() }
        
        cell.selectionStyle = .none
        let isDarkMode = (self.tabBarController as? MainOpenChannelTabbarController)?.isDarkMode ?? false
        
        let rowValue = indexPath.row
        switch rowValue {
            case 0:
                cell.configure(type: .darkTheme, isDarkMode: isDarkMode)
                cell.switchAction = { [weak self] isOn in
                    self?.changeDarkThemeSwitch(isOn: isOn)
            }
            case 1: cell.configure(type: .signOut, isDarkMode: isDarkMode)
            default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 1: self.signOutAction()
            default: break
        }
    }
}
