//
//  CanvasLoader.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/4/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import Foundation
import OctagonAnalyticsService

class CanvasLoader {
    
    var total: Int  =   0
    var canvasList: [Canvas] = []
    
    //MARK: Functions
    func loadCanvasList(_ completion: CompletionBlock?) {
        
        ServiceProvider.shared.loadCanvasList(1, pageSize: Constant.perPage) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.canvasList.removeAll()
                completion?(nil, error.asNSError)
            case .success(let data):
                if let list = data as? CanvasListResponse {
                    self?.total = list.total
                    self?.canvasList = list.canvasList.compactMap({ Canvas($0) })
                }
                completion?(self?.canvasList, nil)
            }
        }
    }
}

extension CanvasLoader {
    
    struct Constant {
        //Temp.: PageSize is 1000 because backend need to handle the pagination logic
        static let perPage = 1000
    }
}
