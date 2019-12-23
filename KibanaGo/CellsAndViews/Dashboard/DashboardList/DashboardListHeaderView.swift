//
//  DashboardListHeaderView.swift
//  KibanaGo
//
//  Created by Rameez on 3/4/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit

class DashboardListHeaderView: UICollectionReusableView {
    
    typealias SearchClickedBlock = (_ searchText: String?,_ sender: Any?) -> Void
    typealias SearchCancelBlock = (_ sender: Any?) -> Void

    var searchClicked: SearchClickedBlock?
    var searchCancel: SearchCancelBlock?

    @IBOutlet var searchBar: UISearchBar!
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureSearchBar()
    }
    
    private func configureSearchBar() {
        searchBar.placeholder = "Search...".localiz()
        searchBar.style(.roundCorner(5.0, 1.0, CurrentTheme.cellBackgroundColor))
        searchBar.tintColor = CurrentTheme.enabledStateBackgroundColor
        searchBar.delegate = self
        searchBar.barTintColor = CurrentTheme.cellBackgroundColor
        searchBar.showsCancelButton = false
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.style(CurrentTheme.subHeadTextStyle())
        textFieldInsideSearchBar?.backgroundColor = CurrentTheme.cellBackgroundColor
        style(.shadow())
    }

}

extension DashboardListHeaderView: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchCancel?(self)
    }
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchClicked?(searchBar.text, self)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchCancel?(self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchClicked?(searchBar.text, self)
    }
}
