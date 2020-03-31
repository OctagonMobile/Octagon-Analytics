//
//  ContentListViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import SwiftDataTables

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

    @IBOutlet weak var baseContentView: UIView!
    
    lazy var dataTable = makeDataTable()

    var dataSource: [Bucket] = []
    
    private var currentSort: SortTable = SortTable(sort: .right, type: .asc)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseContentView.addSubview(dataTable)
        setupTableConstraints()
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        updateDataSource()
    }
    
    private func updateDataSource() {
        if let parentBuckets = panel?.chartContentList {
            var buckets = [Bucket]()
            for parent in parentBuckets {
                buckets.append(contentsOf: parent.items)
            }
            dataSource = buckets
        }
        dataTable.reload()

    }
    
}

extension ContentListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let agg = panel?.bucketAggregation, let fieldValue = panel?.buckets[indexPath.row] {
            
            var dateComponant: DateComponents?
            if let selectedDates =  panel?.currentSelectedDates,
                let fromDate = selectedDates.0, let toDate = selectedDates.1 {
                dateComponant = fromDate.getDateComponents(toDate)
            }
            let filter = FilterProvider.shared.createFilter(fieldValue, dateComponents: dateComponant, agg: agg)            
            if !Session.shared.containsFilter(filter) {
                filterAction?(self, filter)
            }
        }

    }
}

//Data Table Integration
extension ContentListViewController {
    //Data Table Setup Methods
    private func setupTableConstraints() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: baseContentView.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: baseContentView.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: baseContentView.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: baseContentView.trailingAnchor),
        ])
    }
    
    private func makeDataTable() -> SwiftDataTable {
        let dataTable = SwiftDataTable(dataSource: self, options: dataTableConfiguration())
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTable.delegate = self
        dataTable.backgroundColor = CurrentTheme.cellBackgroundColor
        return dataTable
    }
    
    private func dataTableConfiguration() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.shouldShowFooter = false
        configuration.shouldShowSearchSection = false
        configuration.highlightedAlternatingRowColors = [ CurrentTheme.cellBackgroundColor ]
        configuration.unhighlightedAlternatingRowColors = [ CurrentTheme.cellBackgroundColor ]
        configuration.headerBackgroundColor = CurrentTheme.cellBackgroundColor
        configuration.cellTextColor = CurrentTheme.bodyTextStyle().color
        configuration.headerTextColor = CurrentTheme.headLineTextStyle().color
        configuration.cellSeparatorColor = CurrentTheme.separatorColor
        configuration.cellFont = CurrentTheme.bodyTextStyle().font
        configuration.headerFont = CurrentTheme.headLineTextStyle().font
        return configuration
    }
}

extension ContentListViewController: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return panel?.tableHeaders[columnIndex] ?? ""
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return panel?.tableHeaders.count ?? 0
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return rowData(dataSource[index])
    }
}

extension ContentListViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
    }
}

extension ContentListViewController {
    //Subbucket to Table data conversion
    func rowData(_ bucket: Bucket) -> [DataTableValueType] {
        var currentBucket: Bucket? = bucket
        var rowData: [String] = []
        while currentBucket != nil {
            var key = currentBucket?.key ?? ""
            if let rangeBucket = currentBucket as? RangeBucket {
                key = rangeBucket.stringValue
            }
            
            if rowData.isEmpty {
                rowData.append(key)
                rowData.append("\(currentBucket?.displayValue ?? 0)")
            } else {
                rowData.insert(key, at: 0)
            }
            currentBucket = currentBucket?.parent
        }
        return rowData.map( DataTableValueType.string )
    }
}

