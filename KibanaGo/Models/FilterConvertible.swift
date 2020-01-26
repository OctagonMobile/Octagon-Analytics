//
//  FilterConvertible.swift
//  KibanaGo
//
//  Created by Kishore Kumar on 1/22/20.
//  Copyright © 2020 MyCompany. All rights reserved.
//

import Foundation

protocol BucketAggType {
    var bucketKey: String { get }
    var aggType: BucketType { get }
    var parent: BucketAggType? { get }
}

protocol FilterProviderType {
   
    func makeDateFilter(dateComponents: DateComponents?,
                        aggregation: Aggregation,
                        key: String) -> DateHistogramFilter
  
    func makeFilters(_ bucket: BucketAggType,
                     dateComponents: DateComponents?,
                     aggs: [Aggregation]) -> [FilterProtocol]
   
    func makeFilter(_ bucket: BucketAggType,
                    dateComponents: DateComponents?,
                    agg: Aggregation) -> FilterProtocol
}

class FilterProvider: FilterProviderType {
    
    static let shared: FilterProviderType = FilterProvider()
    //Make Date Filter
    func makeDateFilter(dateComponents: DateComponents?,
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
    func makeFilters(_ bucket: BucketAggType,
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
    func makeFilter(_ bucket: BucketAggType, dateComponents: DateComponents?, agg: Aggregation) -> FilterProtocol {
        var filter: FilterProtocol
        
        switch agg.bucketType {
        case .dateHistogram:
            filter = makeDateFilter(dateComponents: dateComponents, aggregation: agg, key: bucket.bucketKey)
        default:
            filter = SimpleFilter(fieldName: agg.field, fieldValue: bucket.bucketKey, type: agg.bucketType)
        }
        return filter
    }
}

