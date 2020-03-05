//
//  SavedSearchPanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 12/28/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class SavedSearchPanel: Panel {

    /**
     Total Saved search count.
     */
    var totalSavedSearchCount: Int      = 0
    
    /**
     Columns List.
     */
    var columns: [String]               = []

    /**
     Saved search list.
     */
    var hits: [SavedSearch]             = []

    //MARK:
    
    /**
     Loads Saved search list.
     
     - parameter pageNumber: Page number of the page to be loaded.
     - parameter completion: Call back once the server returns the response.
     */
    func loadSavedSearch(_ pageNumber: Int, _ completion: CompletionBlock?) {
        
        let urlString = UrlComponents.savedSearchData
        
        var params = dataParams()
        params?["pageSize"] = Constant.pageSize
        params?["pageNum"] = pageNumber
        
        DataManager.shared.loadData(urlString, methodType: .post, encoding: JSONEncoding.default, parameters: params) { [weak self] (result, error) in
            
            guard error == nil else {
                self?.resetDataSource()
                completion?(nil, error)
                return
            }
            
            guard let res = result as? [AnyHashable: Any?], let finalResult = res["result"], let parsedData = self?.parseSavedSearch(finalResult) else {
                self?.resetDataSource()
                completion?(nil, error)
                return
            }
            completion?(parsedData, error)
        }
    }
    
    override func resetDataSource() {
        super.resetDataSource()
        hits.removeAll()
        columns.removeAll()
        totalSavedSearchCount = 0
    }

    /**
     Parse the data into SavedSearch object.
     
     - parameter result: Data to be parsed.
     - returns [SavedSearch] - Array of SavedSearch object
     */
    fileprivate func parseSavedSearch(_ result: Any?) -> [SavedSearch] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let hitsDict = responseJson.first?["hits"] as? [String: Any],
            let hitsArray = hitsDict["hits"] as? [[String: Any]] else {
                hits.removeAll()
                return []
        }
        
        columns                 = hitsDict["columns"] as? [String] ?? []
        totalSavedSearchCount   = hitsDict["total"] as? Int ?? 0
        hits                    = Mapper<SavedSearch>().mapArray(JSONArray: hitsArray)
        
        return hits
    }

}

extension SavedSearchPanel {
    struct UrlComponents {
        static let savedSearchData = "saved-search-data"
    }
    
    struct Constant {
        static let pageSize = 25
    }
}


