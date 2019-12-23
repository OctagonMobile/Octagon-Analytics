//
//  SettingsViewController.swift
//  KibanaGo
//
//  Created by Rameez on 2/19/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit
import LanguageManager_iOS

struct SettingsItem {
    var identifier: String
    var name: String
    var iconName: String?
    var secondaryName: String?

    init(dict: [String: Any]) {
        self.identifier = dict["identifier"] as? String ?? ""
        self.name       = dict["name"] as? String ?? ""
        self.iconName   = dict["iconName"] as? String
        self.secondaryName       = dict["secondaryName"] as? String
    }
}

class SettingsViewController: BaseViewController {

    var dataSource: [SettingsItem]      =   []
    
    override var backButtonIconName: String {
        return isIPhone ?  (LanguageManager.shared.isRightToLeft ? "backFlip" : "back") : "close"
    }
    
    @IBOutlet var settingsTable: UITableView!
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title   =   "Settings".localiz()
        settingsTable.dataSource    =   self
        settingsTable.delegate      =   self
        loadSettingsMenuItems()
        
        if !isIPhone {
            navigationController?.preferredContentSize = CGSize(width: 400, height: 500)
        }
        
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        return []
    }
    
    override func leftBarButtonAction(_ sender: UIBarButtonItem) {
        if isIPhone {
            super.leftBarButtonAction(sender)
        } else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    private func loadSettingsMenuItems() {
        
        guard let url = Bundle.main.url(forResource: "Settings", withExtension: "plist"),
            let menuItems = NSArray(contentsOf: url) as? [[String: Any]] else { return }
        
        for item in menuItems {
            let dropDownItem = SettingsItem(dict: item)
            dataSource.append(dropDownItem)
        }
    }
    
    private func showAuthenticationScreen() {
        guard let authScreen = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.authScreenId) as? AuthenticationViewController else { return }
        authScreen.touchIdConfigurationBlock = { [weak self] (sender, isSuccess) in
            
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let biomenticString = TouchIdHelper.shared.biomenticString
                    self?.showAlert("Congratulations!!!".localiz(),  String(format: "BiometricSuccessConfig".localiz(), biomenticString))
                })
            }
            self?.settingsTable.reloadData()
        }
        
        navigationController?.pushViewController(authScreen, animated: true)
    }
    
    private func disableTouchIdConfiguration() {
        let biomenticString = TouchIdHelper.shared.biomenticString
        let title = String(format: "DisableBiometricTitle".localiz(), biomenticString)
        let message = String(format: "BiometricDisableAlert".localiz(), biomenticString)
        showOkCancelAlert(title, message, okTitle: YES, okActionBlock: {
            Session.shared.removeUser()
        }, cancelTitle: Cancel) {
            self.settingsTable.reloadData()
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let settingsItem = dataSource[indexPath.row]
        let cellId = settingsItem.identifier == Identifiers.touchId ? CellIdentifier.touchIdTableViewCell : CellIdentifier.settingsTableViewCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SettingsTableViewCell else { return UITableViewCell() }
        
        cell.setup(settingsItem)
        
        if settingsItem.identifier == Identifiers.touchId {
            (cell as? TouchIdTableViewCell)?.isTouchIdEnabled = Session.shared.isTouchIdUserAvailable()
            (cell as? TouchIdTableViewCell)?.switchAction = { [weak self] (sender, setting) in
                
                let isEnabled = (sender as? UISwitch)?.isOn ?? false
                if isEnabled {
                    // Show authentication screen
                    self?.showAuthenticationScreen()
                } else {
                    // Disable Touch ID
                    self?.disableTouchIdConfiguration()
                }
            }
        } else if settingsItem.identifier == Identifiers.language {
            cell.valueLabel?.text = LanguageManager.shared.currentLanguage == .en ? "English" : "العربية"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SettingsTableViewCell else { return }
        cell.updateUI()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let settingsItem = dataSource[indexPath.row]
        
        if settingsItem.identifier == Identifiers.language {
            let languageList = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.languageSelectionCtr)
            navigationController?.pushViewController(languageList, animated: true)
        }
    }
}

extension SettingsViewController {
    struct CellIdentifier {
        static let settingsTableViewCell    =   "SettingsTableViewCell"
        static let touchIdTableViewCell     =   "TouchIdTableViewCell"
    }
    
    struct Identifiers {
        static let touchId      =   "TouchID"
        static let language     =   "Language"
    }
    
    struct ViewControllerIdentifiers {
        static let authScreenId         =   "AuthenticationViewController"
        static let languageSelectionCtr =   "LanguageSelectionViewController"
    }
}
