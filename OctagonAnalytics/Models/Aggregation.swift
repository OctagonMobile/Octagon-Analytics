//
//  Aggregation.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/31/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

extension Collection where Element == Double {
    func apply(aggregate: AggregateFunction) -> Double {
        switch aggregate {
        case .average:
            return reduce(0, +) / Double(count)
        case .max:
            return self.max() ?? 0.0
        case .min:
            return self.min() ?? 0.0
        case .sum:
            return reduce(0, +)
        case .unknown:
            return 0.0
        }
    }
}

class Aggregation {

    var id: String                      = ""
    var schema: String                  = ""
    var field: String                   = ""

    var metricType: MetricType          = .unKnown
    var bucketType: BucketType          = .unKnown
    
    var params: AggregationParams?
    
    //MARK: Functions
    init(_ responseModel: AggregationService) {
        self.id     =   responseModel.id
        self.schema =   responseModel.schema
        self.field  =   responseModel.field
        self.metricType =   responseModel.metricType
        self.bucketType =   responseModel.bucketType
        
        if let paramsService = responseModel.params {
            self.params =   AggregationParams(paramsService)
        }
    }
}

class AggregationParams {
    
    var precision: Int      = 5
    var interval: AggregationParamsService.IntervalType          = .unKnown
    var customInterval: String          = ""
    var intervalInt: Int                = 0
    var aggregate: AggregateFunction    = .unknown

    init(_ responseModel: AggregationParamsService) {
        self.precision      =   responseModel.precision
        self.interval       =   responseModel.interval
        self.customInterval =   responseModel.customInterval
        self.intervalInt    =   responseModel.intervalInt
        self.aggregate      =   responseModel.aggregate
        
    }
}
