//
//  SwiftDataTableAdapter.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 4/19/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation
import SwiftDataTables

class SwiftDataTableAdapter: DataTableType {
   
    var delegate: DataTableDelegate
    var dataTable: UIView {
        return table
    }
    private var table: SwiftDataTable!

    
    required init(_ config: DataTableConfig, delegate: DataTableDelegate) {
        self.delegate = delegate
        self.table = makeDataTable(config)
    }
    
    func data(for indexPath: IndexPath) -> DataTableValue {
        return table.data(for: indexPath).toOADataTableValueType
    }
    
    func reload() {
        table.reload()
    }
    
    private func makeDataTable(_ config: DataTableConfig) -> SwiftDataTable {
        let dataTable = SwiftDataTable(dataSource: self, options: dataTableConfiguration(config))
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTable.delegate = self
        dataTable.backgroundColor = config.rowBackgroundColor
        return dataTable
    }
    
    private func dataTableConfiguration(_ config: DataTableConfig) -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.shouldShowFooter = false
        configuration.shouldShowSearchSection = false
        configuration.highlightedAlternatingRowColors = [ config.rowBackgroundColor ]
        configuration.unhighlightedAlternatingRowColors = [ config.rowBackgroundColor ]
        configuration.headerBackgroundColor = config.headerBackgroundColor
        configuration.selectedHeaderBackgroundColor = config.selectedHeaderBackgroundColor
        configuration.selectedHeaderTextColor = config.selectedHeaderTextColor
        configuration.cellTextColor = config.rowTextColor
        configuration.headerTextColor = config.headerTextColor
        configuration.cellSeparatorColor = config.separatorColor
        configuration.cellFont = config.rowFont
        configuration.headerFont = config.headerFont
        configuration.shouldContentWidthScaleToFillFrame = true
        configuration.sortArrowTintColor = config.sortArrowColor
        configuration.enableSort = config.enableSorting
        return configuration
    }
    
}

extension SwiftDataTableAdapter: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return delegate.headerTitleForColumnInDataTable(dataTable: self, atIndex: columnIndex)
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return delegate.numberOfColumnsInDataTable(dataTable: self)
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return delegate.numberOfRowsInDataTable(dataTable: self)
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return delegate.dataForRowInDataTable(dataTable: self, atIndex: index).toSwiftDataTableValueArray
    }
}


extension SwiftDataTableAdapter: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
        delegate.didSelectItemInDataTable(dataTable: self, indexPath: indexPath)
    }
}

extension Collection where Self == [DataTableValue] {
    var toSwiftDataTableValueArray: [DataTableValueType] {
        return map {
            return $0.toSwiftDataTableValueType
        }
    }
}

extension DataTableValue {
    var toSwiftDataTableValueType: DataTableValueType {
        switch self {
        case .double(let val):
            return DataTableValueType.double(val)
        case .float(let val):
            return DataTableValueType.float(val)
        case .int(let val):
            return DataTableValueType.int(val)
        case .string(let str, let obj):
            return DataTableValueType.string(str, obj)
        }
    }
}

extension DataTableValueType {
    var toOADataTableValueType: DataTableValue {
        switch self {
        case .double(let val):
            return DataTableValue.double(val)
        case .float(let val):
            return DataTableValue.float(val)
        case .int(let val):
            return DataTableValue.int(val)
        case .string(let str, let obj):
            return DataTableValue.string(str, obj)
        }
    }
}
