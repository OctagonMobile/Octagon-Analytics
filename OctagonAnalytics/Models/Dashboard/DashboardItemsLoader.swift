
//
//  DashboardItemsLoader.swift
//  KibanaGo
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class DashboardItemsLoader: NSObject {
    
    /**
     Collection of dashboard items.
     */
    var dashBoardItems: [DashboardItem]         = []
    
    /**
     Page number.
     */
    var pageNumber: Int                         = 0

    //MARK: Functions
    /**
     Loads dashboard items from server.
     
     - parameter completion: Call back once the server returns the response.
     
     */
    func loadDashBoardItems(_ completion: CompletionBlock?) {
        
        let params: [String : Any] = ["pageNum": pageNumber ,"pageSize": Constant.pageSize]
        DataManager.shared.loadData(UrlComponents.dashBoardList, parameters: params) { [weak self] (result, error) in

            guard error == nil else {
                self?.dashBoardItems.removeAll()
                completion?(self?.dashBoardItems, error)
                return
            }
            
            if let res = result as? [AnyHashable: Any?], let finalResult = res["result"] {
                self?.dashBoardItems = self?.parseDashboardItems(finalResult) ?? []
            }
            
            completion?(self?.dashBoardItems, error)
        }
    }
    
    /**
     Used to parse the server response (Dashboard items).
     
     - parameter result: result to be parsed.
     - returns : Parsed array of DashboardItem
     */
    private func parseDashboardItems(_ result: Any?) -> [DashboardItem] {
        guard let itemsArray = result as? [[String: Any]] else { return [] }
        
        let dashboardList = itemsArray.compactMap { DashboardItem(JSON: $0) }.sorted(by:  {$0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending} )
        return dashboardList
    }
}

extension DashboardItemsLoader {
    struct UrlComponents {
        static let dashBoardList = "dashboard/list"
    }
    
    struct Constant {
        //Temp.: PageSize is 1000 because backend need to handle the pagination logic
        static let pageSize = 1000
    }
}
