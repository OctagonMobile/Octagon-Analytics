//
//  SavedSearch.swift
//  KibanaGo
//
//  Created by Rameez on 11/13/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class SavedSearch: Mappable {

    var keys: [String]          = []

    var data: [String: Any?]    = [:]

    var columnsWidth: [CGFloat] = []

    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        data                = map.JSON
    }
}
