//
//  Aggregation.swift
//  KibanaGo
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
    case topHit         =   "top_hit"
    case max            =   "max"
    case average        =   "avg"
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
    case metric         = "1"
    case bucket         = "2"
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
        
        switch id {
        case AggregationId.metric.rawValue:
            metricType          <- (map["type"],EnumTransform<MetricType>())
        case AggregationId.bucket.rawValue:
            field               <- map["params.field"]
            bucketType          <- (map["type"],EnumTransform<BucketType>())
            params              <- map["params"]
        default:
            break
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

    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        precision           <- map["precision"]
        interval            <- (map["interval"],EnumTransform<IntervalType>())
        customInterval      <- map["customInterval"]
    }
    
}
