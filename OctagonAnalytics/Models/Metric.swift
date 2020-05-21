//
//  Metric.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/28/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class Metric: Mappable {

    var type: String    = ""
    var value: NSNumber  = NSNumber(value: 0)
    var label: String   = ""
    
    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        type            <- map[MetricConstant.type]
        label           <- map[MetricConstant.label]
        value           <- map[MetricConstant.value]
    }

}
