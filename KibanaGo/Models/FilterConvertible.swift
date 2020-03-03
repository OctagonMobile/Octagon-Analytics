//
//  FilterConvertible.swift
//  KibanaGo
//
//  Created by Kishore Kumar on 1/22/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

protocol BucketAggType {
    var bucketKey: String { get }
    var aggType: BucketType { get }
    var parent: BucketAggType? { get }
}

protocol FilterProviderType {
  
    func createFilters(_ bucket: BucketAggType,
                     dateComponents: DateComponents?,
                     aggs: [Aggregation]) -> [FilterProtocol]
   
    func createFilter(_ bucket: BucketAggType,
                    dateComponents: DateComponents?,
                    agg: Aggregation) -> FilterProtocol
}

class FilterProvider: FilterProviderType {
    
    static let shared: FilterProviderType = FilterProvider()
    //Make Date Filter
    private func makeDateFilter(dateComponents: DateComponents?,
                        aggregation: Aggregation,
                        key: String) -> DateHistogramFilter {
        let interval = aggregation.params?.interval ?? AggregationParams.IntervalType.unKnown
        let customInterval = aggregation.params?.customInterval ?? ""
        return DateHistogramFilter(fieldName: aggregation.field,
                                   fieldValue: key,
                                   type: aggregation.bucketType,
                                   interval: interval,
                                   customInterval: customInterval,
                                   selectedComponants: dateComponents)
    }
    
    
    //Make Filters to bucket with sub buckets
    func createFilters(_ bucket: BucketAggType,
                     dateComponents: DateComponents?,
                     aggs: [Aggregation]) -> [FilterProtocol] {
        
        
        var currentBucket: BucketAggType? = bucket
        var filtersList: [FilterProtocol] = []
        
        for agg in aggs {
            let val = bucket.bucketKey
            var filter: FilterProtocol
            
            switch bucket.aggType {
            case .dateHistogram:
                filter = makeDateFilter(dateComponents: dateComponents,
                                        aggregation: agg,
                                        key: val)
            case .histogram:
                let interval = agg.params?.intervalInt
                filter = SimpleFilter(fieldName: agg.field, fieldValue: bucket.bucketKey, type: agg.bucketType, interval: interval)
            default:
                filter = SimpleFilter(fieldName: agg.field,
                                      fieldValue: val,
                                      type: agg.bucketType)
            }
            
            filtersList.append(filter)
            currentBucket = currentBucket?.parent
        }
        
        return filtersList
    }
    
    //Make Filter without Sub bucket, just for the current bucket.
    //Will be deprecated soon
    func createFilter(_ bucket: BucketAggType, dateComponents: DateComponents?, agg: Aggregation) -> FilterProtocol {
        var filter: FilterProtocol
        
        switch agg.bucketType {
        case .dateHistogram:
            filter = makeDateFilter(dateComponents: dateComponents, aggregation: agg, key: bucket.bucketKey)
        case .histogram:
            let interval = agg.params?.intervalInt
            filter = SimpleFilter(fieldName: agg.field, fieldValue: bucket.bucketKey, type: agg.bucketType, interval: interval)
        default:
            filter = SimpleFilter(fieldName: agg.field, fieldValue: bucket.bucketKey, type: agg.bucketType)
        }
        return filter
    }
}

