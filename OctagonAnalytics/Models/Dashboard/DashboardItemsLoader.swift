
//
//  DashboardItemsLoader.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class DashboardItemsLoader: NSObject {
    
    /**
     Collection of dashboard items.
     */
    var dashBoardItems: [DashboardItem]         = []
    
    /**
     Page number.
     */
    var pageNumber: Int                         = 1

    //MARK: Functions
    /**
     Loads dashboard items from server.
     
     - parameter completion: Call back once the server returns the response.
     
     */
    func loadDashBoardItems(_ completion: CompletionBlock?) {
        
        ServiceProvider.shared.loadDashboards(pageNumber, pageSize: Constant.pageSize) { [weak self] (result) in
            
            switch result {
            case .failure(let error):
                self?.dashBoardItems.removeAll()
                completion?(self?.dashBoardItems, error.asNSError)
            case .success(let data):
                if let res = data as? DashboardListResponse {
                    self?.dashBoardItems = res.dashboards.compactMap({ DashboardItem($0) }).sorted(by:  {$0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending} )
                }
                completion?(self?.dashBoardItems, nil)
            }
        }
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
