//
//  ChartItem.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class ChartItem: Mappable {

    var key                     = ""
    
    var docCount                =   0.0

    var bucketValue                =   0.0

    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        
        if let keyValue = map.JSON["key"] {
            key   = "\(keyValue)"
        }
        docCount            <- map["doc_count"]
        bucketValue            <- map["bucketValue"]
    }
    
    static func ==(lhs: ChartItem, rhs: ChartItem) -> Bool {
        return lhs.key == rhs.key && lhs.docCount == rhs.docCount && lhs.bucketValue == rhs.bucketValue
    }

}

extension ChartItem: BucketAggType {
    var bucketKey: String {
        return key
    }
    
    var aggType: BucketType {
        return .unKnown
    }
    
    var parent: BucketAggType? {
        return nil
    }
}
