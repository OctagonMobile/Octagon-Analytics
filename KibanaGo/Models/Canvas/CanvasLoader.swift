//
//  CanvasLoader.swift
//  KibanaGo
//
//  Created by Rameez on 11/4/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import Foundation

class CanvasLoader {
    
    var total: Int  =   0
    var canvasList: [Canvas] = []
    
    //MARK: Functions
    func loadCanvasList(_ completion: CompletionBlock?) {
        let params: [String : Any] = ["type": "canvas-workpad", "per_page": Constant.perPage]
        
        let componant = UrlComponents.canvasList + "?fields=name&fields=pages.id"
        DataManager.shared.loadData(componant, parameters: params) { [weak self] (result, error) in

            guard error == nil else {
                self?.canvasList.removeAll()
                completion?(nil, error)
                return
            }
            
            if let res = result as? [AnyHashable: Any?], let finalResult = res["result"] {
                self?.canvasList = self?.parseDashboardItems(finalResult) ?? []
            }
            
            completion?(self?.canvasList, nil)
        }
    }
    
    private func parseDashboardItems(_ result: Any?) -> [Canvas] {
        guard let dict = result as? [String: Any],
        let itemsArray = dict["saved_objects"] as? [[String: Any]] else { return [] }
        
        self.total  = dict["total"] as? Int ?? 0
        let canvasArray = itemsArray.compactMap { Canvas(JSON: $0) }.sorted(by:  {$0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending} )
        return canvasArray
    }

}

extension CanvasLoader {
    struct UrlComponents {
        static let canvasList = "saved_objects/_find"
    }
    
    struct Constant {
        //Temp.: PageSize is 1000 because backend need to handle the pagination logic
        static let perPage = 1000
    }
}
