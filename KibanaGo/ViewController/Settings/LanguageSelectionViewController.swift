//
//  LanguageSelectionViewController.swift
//  KibanaGo
//
//  Created by Rameez on 9/29/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import LanguageManager_iOS

class LanguageSelectionViewController: BaseViewController {

    @IBOutlet var languagesTable: UITableView?
    var dataSource: [Language]    =   [Language(code: "en", desc: "English", iconName: "uk"),
                                       Language(code: "ar", desc: "العربية", iconName: "uae")]
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title   =   "Language".localiz()
        languagesTable?.dataSource = self
        languagesTable?.delegate = self
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        return []
    }
}

extension LanguageSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.langCellId) as? LanguageTableViewCell else {
            return UITableViewCell()
        }
        
        cell.updateUI(dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard LanguageManager.shared.currentLanguage.rawValue != dataSource[indexPath.row].code else { return }
        
        NavigationManager.shared.resetAppLanguage(dataSource[indexPath.row].code)        
    }
    
}

extension LanguageSelectionViewController {
    struct CellIdentifiers {
        static let langCellId   =   "LanguageCell"
    }
}

struct Language {
    var code: String    =   ""
    var desc: String    =   ""
    var iconName: String    =   ""
}
