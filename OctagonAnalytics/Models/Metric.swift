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
    var id: String = ""
    var type: String    = ""
    var value: NSNumber  = NSNumber(value: 0)
    private var labelStr: String?
    private var labelInt: Int?
    var label: String {
        if let str = labelStr, !str.isEmpty {
            return str
        } else if let int = labelInt, int > 0 {
            return String(int)
        } else {
            return ""
        }
    }
    weak var panel: MetricPanel?
    
    var computedLabel: String {
        var computed = label
        let filteredMetric = panel?.visState?.metricAggregationsArray.filter { $0.id == id }

        guard let metric = filteredMetric?.first,
            panel?.visState?.otherAggregationsArray.isEmpty == false else {
            return computed
        }
        
        computed += "-" + metric.metricType.displayValue
        
        if metric.field.isEmpty == false {
            computed += " " + metric.field
        }
        
        return computed
    }
    
    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        id              <- map[MetricConstant.id]
        type            <- map[MetricConstant.type]
        labelStr        <- map[MetricConstant.label]
        labelInt        <- map[MetricConstant.label]
        value           <- map[MetricConstant.value]
    }

}
