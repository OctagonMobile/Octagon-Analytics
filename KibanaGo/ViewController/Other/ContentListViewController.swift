//
//  ContentListViewController.swift
//  KibanaGo
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

enum Sort: String {
    case left       = "left"
    case right      = "right"
    case unknown    = "unknown"
}

enum SortType: String {
    case asc        = "Asc"
    case desc       = "Desc"
    case unknown    = "unknown"
}

struct SortTable {
    var sort: Sort = .unknown
    var type: SortType = .unknown
    
    static var defaultSort: SortTable {
        return SortTable(sort: .unknown, type: .unknown)
    }
}

class ContentListViewController: PanelBaseViewController {

    @IBOutlet weak var contentListTableView: UITableView!
    
    var dataSource: [ChartItem] {
        return panel?.buckets ?? []
    }

    private var currentSort: SortTable = SortTable(sort: .right, type: .asc)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentListTableView.register(UINib(nibName: NibName.listTableViewCell, bundle: Bundle.main), forCellReuseIdentifier: CellIdentifiers.listTableViewCell)
        contentListTableView.register(UINib(nibName: NibName.listTableHeaderView, bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: CellIdentifiers.listTableHeaderView)
        
        contentListTableView.tableFooterView = UIView()
        contentListTableView.estimatedRowHeight = 40.0
        contentListTableView.rowHeight = UITableView.automaticDimension
        contentListTableView.separatorColor = CurrentTheme.separatorColor
        contentListTableView.backgroundColor = CurrentTheme.cellBackgroundColor
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        sortContent()
    }
    
    fileprivate func sortContent() {

        currentSort.type = (currentSort.type == .asc) ? .desc : .asc

        if currentSort.sort == .left {
            // Sort left
            if let rangeItems = dataSource as? [RangeChartItem] {
                panel?.buckets = rangeItems.sorted(by: { [weak self] (first, second) -> Bool in
                    return self?.currentSort.type == .asc ? (first.from > second.from) : (first.from < second.from)
                })
            } else {
                panel?.buckets = dataSource.sorted(by: { [weak self] (first, second) -> Bool in
                    return self?.currentSort.type == .asc ? (first.key.lowercased() > second.key.lowercased()) : (first.key.lowercased() < second.key.lowercased())
                })
            }
            
        } else {
            // Sort Right
            panel?.buckets = dataSource.sorted(by: { [weak self] (first, second) -> Bool in
                return self?.currentSort.type == .asc ? (first.docCount > second.docCount) : (first.docCount < second.docCount)
            })
        }
        
        contentListTableView.reloadData()
    }
}

extension ContentListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.listTableViewCell, for: indexPath) as? ListTableViewCell
        cell?.setupCell(dataSource[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellIdentifiers.listTableHeaderView) as? ListTableHeaderView
        headerView?.setupHeader(panel?.tableHeaderLeft, panel?.tableHeaderRight, currentSort)
        headerView?.leftAction = { [weak self] sender in
            
            self?.currentSort.sort = .left
            self?.sortContent()
        }
        
        headerView?.rightAction = { [weak self] sender in
            
            self?.currentSort.sort = .right
            self?.sortContent()
        }

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let agg = panel?.bucketAggregation, let fieldValue = panel?.buckets[indexPath.row] {
            
            var dateComponant: DateComponents?
            if let selectedDates =  panel?.currentSelectedDates,
                let fromDate = selectedDates.0, let toDate = selectedDates.1 {
                dateComponant = fromDate.getDateComponents(toDate)
            }
            let filter = FilterProvider.shared.makeFilter(fieldValue, dateComponents: dateComponant, agg: agg)            
            if !Session.shared.containsFilter(filter) {
                filterAction?(self, filter)
            }
        }

    }
}
extension ContentListViewController {
    struct CellIdentifiers {
        static let listTableViewCell = "ListTableViewCell"
    }
    
    struct NibName {
        static let listTableViewCell = "ListTableViewCell"
    }

}
