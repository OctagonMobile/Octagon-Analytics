//
//  SavedSearchCollectionViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 11/13/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

typealias SavedSearchCellSelectionBlock = (_ sender: SavedSearchTableViewCell, _ selectedSavedSearch: SavedSearch) -> Void
typealias SavedSearchCellLongPressBlock = (_ sender: SavedSearchTableViewCell, _ filter: Filter) -> Void
typealias DidScrollToBoundary = (_ scrollView: UIScrollView) -> Void

class SavedSearchCollectionViewCell: UICollectionViewCell {

    var dataSource: [SavedSearch] = [] {
        didSet {
            searchListTableView.reloadData()
        }
    }
    
    var cellSelectionBlock: SavedSearchCellSelectionBlock?
    var cellLongPressBlock: SavedSearchCellLongPressBlock?
    var didScrollToBoundary: DidScrollToBoundary?

    fileprivate var headerHeight: CGFloat {
        return dataSource.count > 0 ? 70.0 : 0
    }
    
    fileprivate var cellHeight: CGFloat {
        let calculatedHeight = (self.frame.height - headerHeight) / CGFloat(SavedSearchPanel.Constant.pageSize)
        return (calculatedHeight < 37.0) ? 37.0 : calculatedHeight
    }

    @IBOutlet weak var searchListTableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchListTableView.register(UINib(nibName: NibName.savedSearchTableViewCell, bundle: Bundle.main), forCellReuseIdentifier: CellIdentifiers.savedSearchTableViewCell)
        searchListTableView.register(UINib(nibName: NibName.savedSearchHeaderView, bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: CellIdentifiers.savedSearchHeaderView)
        searchListTableView.backgroundColor = CurrentTheme.cellBackgroundColor
        searchListTableView.dataSource = self
        searchListTableView.delegate = self
    }

}

extension SavedSearchCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.savedSearchTableViewCell, for: indexPath) as? SavedSearchTableViewCell
        cell?.contentView.backgroundColor = (indexPath.row % 2 == 0) ? CurrentTheme.cellBackgroundColorPair.first : CurrentTheme.cellBackgroundColorPair.last
        
        let searchObj = dataSource[indexPath.row]
        cell?.selectedSavedSearch = searchObj
        cell?.cellLongPressBlock = cellLongPressBlock
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? SavedSearchTableViewCell ?? SavedSearchTableViewCell()
        cellSelectionBlock?(cell, dataSource[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellIdentifiers.savedSearchHeaderView) as? SavedSearchHeaderView
        headerView?.selectedSavedSearch = dataSource.first
        return headerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let didScrollToTop = scrollView.contentOffset.y <= 0.0
        let didScrollToBottom = (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height)
        if didScrollToTop || didScrollToBottom {
            didScrollToBoundary?(scrollView)
        }
    }

}

extension SavedSearchCollectionViewCell {
    struct CellIdentifiers {
        static let savedSearchTableViewCell = "SavedSearchTableViewCell"
        static let savedSearchHeaderView    = "SavedSearchHeaderView"
    }
    
    struct NibName {
        static let savedSearchTableViewCell = "SavedSearchTableViewCell"
        static let savedSearchHeaderView    = "SavedSearchHeaderView"
    }
    
}
