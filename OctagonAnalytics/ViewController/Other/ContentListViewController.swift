//
//  ContentListViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class ContentListViewController: PanelBaseViewController {
    
    @IBOutlet weak var baseContentView: UIView!
    
    lazy var clDataTableAdapter: DataTableType = SwiftDataTableAdapter(getCLDataTableConfig(),
                                                                       delegate: self)
    
    lazy var clDataTable = clDataTableAdapter.dataTable
    
    var clDataSource: [Bucket] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseContentView.addSubview(clDataTable)
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
            clDataSource = buckets
        }
        clDataTableAdapter.reload()
    }
    
    override func numberOfColumnsInDataTable(dataTable: DataTableType) -> Int {
        return panel?.tableHeaders.count ?? 0
    }
    
    override func numberOfRowsInDataTable(dataTable: DataTableType) -> Int {
        return clDataSource.count
    }
    
    override func didSelectItemInDataTable(dataTable: DataTableType,  indexPath: IndexPath) {
        let data = clDataTableAdapter.data(for: indexPath)
        
        if case DataTableValue.string( _, let bucket) = data,
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
    
    override func dataForRowInDataTable(dataTable: DataTableType, atIndex index: Int) -> [DataTableValue] {
        return rowData(clDataSource[index])
    }
    
    override func headerTitleForColumnInDataTable(dataTable: DataTableType, atIndex index: Int) -> String {
        return panel?.tableHeaders[index] ?? ""
    }
    
}

extension ContentListViewController {
    
    
}

extension ContentListViewController {
    func getCLDataTableConfig() -> DataTableConfig {
        return DataTableConfig(headerTextColor: CurrentTheme.headLineTextStyle().color,
                               headerBackgroundColor: CurrentTheme.cellBackgroundColor,
                               headerFont: CurrentTheme.headLineTextStyle().font,
                               selectedHeaderBackgroundColor: CurrentTheme.standardColor,
                               selectedHeaderTextColor: CurrentTheme.secondaryTitleColor,
                               rowTextColor: CurrentTheme.bodyTextStyle().color,
                               rowBackgroundColor: CurrentTheme.cellBackgroundColor,
                               rowFont: CurrentTheme.bodyTextStyle().font,
                               separatorColor: CurrentTheme.separatorColor,
                               sortArrowColor: CurrentTheme.secondaryTitleColor,
                               enableSorting: true)
    }
    
    private func setupTableConstraints() {
        NSLayoutConstraint.activate([
            clDataTable.topAnchor.constraint(equalTo: baseContentView.layoutMarginsGuide.topAnchor),
            clDataTable.leadingAnchor.constraint(equalTo: baseContentView.leadingAnchor, constant: 5),
            clDataTable.bottomAnchor.constraint(equalTo: baseContentView.layoutMarginsGuide.bottomAnchor),
            clDataTable.trailingAnchor.constraint(equalTo: baseContentView.trailingAnchor, constant: -5),
        ])
    }
}



