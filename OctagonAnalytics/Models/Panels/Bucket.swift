//
//  Bucket.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 5/18/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

class Bucket {
    
    var key                     =   ""
    
    var docCount                =   0.0
    
    var bucketValue             =   0.0
    
    var metricValue             =   0.0

    var bucketType: BucketType  =   .unKnown
    var subAggsResult: AggResult?
        
    var displayValue: Double {
        let aggregationsCount = (visState?.otherAggregationsArray.count ?? 0)
        let metricType = visState?.metricAggregationsArray.first?.metricType ?? MetricType.unKnown
        let shouldShowBucketValue = (metricType == .sum || metricType == .max || metricType == .average || metricType == .median)

        //The condition (aggregation count == 1) is added because if there are more than 1 subbuckets present for the visualization then we should be showing the docCount/metricValue based on metricType or else we should show docCount/bucketValue based on metricType
        if aggregationsCount == 1 || metricType == .median {
            return shouldShowBucketValue ? bucketValue : docCount
        } else {
            return (metricType == .count || metricType == .topHit ) ? docCount : metricValue
        }
    }
    
    var parentBkt: Bucket? {
        return parentBucket
    }
    
    private var parentBucket: Bucket?
    private var visState: VisState?
    
    //MARK: Functions
    init(_ dictionary: [String: Any], visState: VisState, index: Int, parentBucket: Bucket?, bucketType: BucketType) {
        
        docCount            =   dictionary[BucketConstant.docCount] as? Double ?? 0.0
        let metricType = visState.metricAggregationsArray.first?.metricType ?? MetricType.unKnown

        if metricType == .median {
            if let firstMetricId = visState.metricAggregationsArray.first?.id,
                let dict = dictionary[firstMetricId] as? [String: Any],
                
                let values = dict [BucketConstant.values] as? [[String: Any]],
                let valueDict = values.first  {
                bucketValue         =   valueDict[BucketConstant.value] as? Double ?? 0.0
            }
        } else {
            bucketValue         =   dictionary[BucketConstant.bucketValue] as? Double ?? 0.0
        }
        
        self.bucketType = bucketType
        self.visState = visState
        self.parentBucket = parentBucket
        
        switch bucketType {
            case .dateHistogram:
                if let dateKey = dictionary[BucketConstant.key] {
                    key = "\(dateKey)"
                }
            default:
                key = bucketValueAsString(dictionary)
        }
        
        
        if let firstMetricId = visState.metricAggregationsArray.first?.id,
            let dict = dictionary[firstMetricId] as? [String: Any] {
            metricValue         =   dict[BucketConstant.value] as? Double ?? 0.0
        }

        guard index < visState.otherAggregationsArray.count else {
            return
        }
        
        let id = visState.otherAggregationsArray[index].id
        guard let dict = dictionary[id] as? [String: Any] else { return }
        subAggsResult          =   AggResult(dict, visState: visState, idx: index, parentBucket: self)
    }
    
    func getRelatedfilters(_ selectedDateComponant: DateComponents?) -> [FilterProtocol] {

        var filtersList: [FilterProtocol] = []
        var outerBucket: Bucket? = self
        let othersAggs = visState?.otherAggregationsArray ?? []
        for otherAggs in othersAggs.reversed() {
            let val = outerBucket?.key ?? ""
            guard let bucket = outerBucket else { continue }
            var filter: FilterProtocol
            switch bucket.bucketType {
            case .dateHistogram:
                let interval = otherAggs.params?.interval ?? AggregationParams.IntervalType.unKnown
                let customInterval = otherAggs.params?.customInterval ?? ""
                filter = DateHistogramFilter(fieldName: otherAggs.field, fieldValue: val, type: otherAggs.bucketType, interval: interval, customInterval: customInterval, selectedComponants: selectedDateComponant)
            default:
                filter = SimpleFilter(fieldName: otherAggs.field, fieldValue: val, type: otherAggs.bucketType)
            }

            filtersList.append(filter)

            outerBucket = outerBucket?.parentBucket
        }
        return filtersList
    }
    
    func bucketValueAsString(_ dict: [String: Any]) -> String {
        
        guard let val = dict[BucketConstant.key] else {
            return ""
        }
        let keyAsString = dict[BucketConstant.keyAsString] as? String
        
        if let number = val as? NSNumber {
            if number.isNumberFractional {
                return String(format: "%0.2f", number.floatValue)
            } else if keyAsString == BoolAsString.false_ || keyAsString == BoolAsString.true_ {
                return keyAsString!
            } else {
                return number.stringValue
            }
        } else {
            return val as? String ?? ""
        }
    }
    
    static func ==(lhs: Bucket, rhs: Bucket) -> Bool {
        return lhs.key == rhs.key && lhs.docCount == rhs.docCount && lhs.bucketValue == rhs.bucketValue
    }

}

class RangeBucket: Bucket {
    var from: Double    =   0.0
    var to: Double      =   0.0
    
    override init(_ dictionary: [String : Any], visState: VisState, index: Int, parentBucket: Bucket?, bucketType: BucketType = .unKnown) {
        super.init(dictionary, visState: visState, index: index, parentBucket: parentBucket, bucketType: bucketType)
        
        from        =   dictionary[BucketConstant.from] as? Double ?? 0.0
        to          =   dictionary[BucketConstant.to] as? Double ?? 0.0
    }
    var stringValue: String {
        return "\(from) to \(to)"
    }
    
    static func ==(lhs: RangeBucket, rhs: RangeBucket) -> Bool {
        return lhs.key == rhs.key && lhs.to == rhs.to && lhs.from == rhs.from
    }

}

extension Bucket: BucketAggType {
    var bucketKey: String {
        return key
    }
    
    var aggType: BucketType {
        return bucketType
    }
    
    var parent: BucketAggType? {
        return parentBkt
    }
    
}
