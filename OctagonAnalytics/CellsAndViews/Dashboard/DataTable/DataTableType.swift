//
//  DataTableType.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 4/19/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

public enum DataTableValue {
    //MARK: - Properties
    case string(String, Any? = nil)
    case int(Int, Any? = nil)
    case float(Float, Any? = nil)
    case double(Double, Any? = nil)
}

struct DataTableConfig {
    let headerTextColor: UIColor
    let headerBackgroundColor: UIColor
    let headerFont: UIFont
    let selectedHeaderBackgroundColor: UIColor
    let selectedHeaderTextColor: UIColor
    let rowTextColor: UIColor
    let rowBackgroundColor: UIColor
    let rowFont: UIFont
    let separatorColor: UIColor
    let sortArrowColor: UIColor
    let enableSorting: Bool
}

protocol DataTableDelegate: class {
    func dataForRowInDataTable(dataTable: DataTableType, atIndex index: Int) -> [DataTableValue]
    func headerTitleForColumnInDataTable(dataTable: DataTableType, atIndex index: Int) -> String
    func numberOfColumnsInDataTable(dataTable: DataTableType) -> Int
    func numberOfRowsInDataTable(dataTable: DataTableType) -> Int
    func didSelectItemInDataTable(dataTable: DataTableType, indexPath: IndexPath)
}

protocol DataTableType: class {
    var delegate: DataTableDelegate { get set }
    var dataTable: UIView { get }
    
    init(_ config: DataTableConfig, delegate: DataTableDelegate)
    func data(for indexPath: IndexPath) -> DataTableValue
    func reload()
}
