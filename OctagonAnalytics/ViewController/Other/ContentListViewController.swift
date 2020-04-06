//
//  ContentListViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import SwiftDataTables

class ContentListViewController: PanelBaseViewController {

    @IBOutlet weak var baseContentView: UIView!
    
    lazy var dataTable = makeDataTable()

    var dataSource: [Bucket] = []
        
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

//Data Table Integration
extension ContentListViewController {
    //Data Table Setup Methods
    private func setupTableConstraints() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: baseContentView.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: baseContentView.leadingAnchor, constant: 5),
            dataTable.bottomAnchor.constraint(equalTo: baseContentView.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: baseContentView.trailingAnchor, constant: -5),
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
        configuration.selectedHeaderBackgroundColor = CurrentTheme.standardColor
        configuration.selectedHeaderTextColor = UIColor.white
        configuration.cellTextColor = CurrentTheme.bodyTextStyle().color
        configuration.headerTextColor = CurrentTheme.headLineTextStyle().color
        configuration.cellSeparatorColor = CurrentTheme.separatorColor
        configuration.cellFont = CurrentTheme.bodyTextStyle().font
        configuration.headerFont = CurrentTheme.headLineTextStyle().font
        configuration.shouldContentWidthScaleToFillFrame = true
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
        let data = dataTable.data(for: indexPath)
       
        if case DataTableValueType.string( _, let bucket) = data,
            let bucketObj = bucket as? Bucket {
            
            var dateComponant: DateComponents?
            if let selectedDates =  panel?.currentSelectedDates,
                let fromDate = selectedDates.0, let toDate = selectedDates.1 {
                dateComponant = fromDate.getDateComponents(toDate)
            }
            
            let filters = bucketObj.getRelatedfilters(dateComponant)
            multiFilterAction?(self, filters)
        }
    }
}

extension ContentListViewController {
    //Subbucket to Table data conversion
    func rowData(_ bucket: Bucket) -> [DataTableValueType] {
        var currentBucket: Bucket? = bucket
        var rowData: [DataTableValueType] = []
        while currentBucket != nil {
            var key = currentBucket?.key ?? ""
            if let rangeBucket = currentBucket as? RangeBucket {
                key = rangeBucket.stringValue
            } else if currentBucket?.bucketType == BucketType.dateHistogram {
                let milliSeconds = Int(currentBucket?.key ?? "") ?? 0
                let date = Date(milliseconds: milliSeconds)
                key = date.toFormat("YYYY-MM-dd")
            }
            
            if rowData.isEmpty {
                rowData.append(DataTableValueType.string(key, bucket))
                rowData.append(DataTableValueType.string("\(currentBucket?.displayValue ?? 0)", bucket))
            } else {
                rowData.insert(DataTableValueType.string(key, bucket), at: 0)
            }
            currentBucket = currentBucket?.parentBkt
        }
        return rowData
    }
}

