//
//  Metric.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/28/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class Metric {
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
                if filteredMetric?.first?.field.isEmpty == false {
                    computed += " " + (filteredMetric?.first?.field ?? "")
                }
            return computed
        }
        
        computed += "-" + metric.metricType.displayValue
        
        if metric.field.isEmpty == false {
            computed += " " + metric.field
        }
        
        return computed
    }
    
    //MARK: Functions
    init(_ responseModel: MetricService) {
        self.id     =   responseModel.id
        self.type   =   responseModel.type
        self.labelStr   =   responseModel.label
        self.labelInt   =   Int(responseModel.label)
        self.value      =   responseModel.value
    }
    
    init(_ dict: [String: Any]) {
        self.id         =   dict["id"] as? String ?? ""
        self.type       =   dict["type"] as? String ?? ""
        self.labelStr   =   dict["label"] as? String ?? ""
        if let label = self.labelStr {
            self.labelInt   =   Int(label)
        }
        
        if let val = dict["value"] as? Double {
            self.value      =   NSNumber(value: val)
        }
    }
}
