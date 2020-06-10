//
//  Aggregation.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/31/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

enum MetricType: String {
    case unKnown        =   "unKnown"
    case count          =   "count"
    case sum            =   "sum"
    case uniqueCount    =   "unique_count"
    case topHit         =   "top_hits"
    case max            =   "max"
    case min            =   "min"
    case average        =   "avg"
    case median         =   "median"
    
    var displayValue: String {
        switch self {
        case .count:
            return "Count"
        case .sum:
            return "Sum of"
        case .topHit:
            return "Last"
        case .max:
            return "Max"
        case .min:
            return "Min"
        case .average:
            return "Average"
        case .median:
            return "50th Percentile of"
        case .uniqueCount:
            return "Unique Count of"
        case .unKnown:
            return ""
        }
    }
}

enum BucketType: String {
    case unKnown            =   "unKnown"
    case dateHistogram      =   "date_histogram"
    case histogram          =   "histogram"
    case range              =   "range"
    case dateRange          =   "date_range"
    case ipv4Range          =   "ipv4_range"
    case terms              =   "terms"
    case filters            =   "filters"
    case significantTerms   =   "significant_terms"
    case geohashGrid        =   "geohash_grid"

}

enum AggregationId: String {
    case unKnown        = "0"
    case bucket         = "2"
}

enum AggregateFunction: String {
    case average
    case max
    case min
    case sum
    case unknown
}


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

class Aggregation : Mappable {

    var id: String                      = ""
    var schema: String                  = ""
    var field: String                   = ""

    var metricType: MetricType          = .unKnown
    var bucketType: BucketType          = .unKnown
    
    var params: AggregationParams?
    
    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        
        id                  <- map["id"]
        schema              <- map["schema"]
        
        field               <- map["params.field"]
        params              <- map["params"]
        
        switch schema {
        case "metric":
            metricType          <- (map["type"],EnumTransform<MetricType>())
        default:
            bucketType          <- (map["type"],EnumTransform<BucketType>())
        }
    }
    
}

/// This class Need to be updated (parse more fields based on type)
class AggregationParams: Mappable {

    enum IntervalType: String {
        case unKnown        =   "unKnown"
        case auto           =   "auto"
        case millisecond    =   "ms"
        case second         =   "s"
        case minute         =   "m"
        case hourly         =   "h"
        case daily          =   "d"
        case weekly         =   "w"
        case monthly        =   "M"
        case yearly         =   "y"
        case custom         =   "custom"

        static var customTypes: [IntervalType] {
            return [.millisecond, .second, .minute, .hourly,
                    .daily, .weekly, .monthly, .yearly]
        }
    }
    
    var precision: Int      = 5
    var interval: IntervalType          = IntervalType.unKnown
    var customInterval: String          = ""
    var intervalInt: Int                = 0
    var aggregate: AggregateFunction    = .unknown
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        precision           <- map["precision"]
        interval            <- (map["interval"],EnumTransform<IntervalType>())
        customInterval      <- map["customInterval"]
        intervalInt         <- map["interval"]
        aggregate           <- (map["aggregate"], EnumTransform<AggregateFunction>())
    }
    
}
