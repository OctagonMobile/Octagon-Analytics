//
//  AggResult.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 5/18/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

class AggResult {
    
    var buckets: [Bucket]           =   []
    
    //MARK: Functions
    init(_ dictionary: [String: Any], visState: VisState, idx: Int, parentBucket: Bucket?) {
        
        var bucketList: [[String: Any]] = []

        let currentAggs = visState.otherAggregationsArray[idx]
        if currentAggs.bucketType == .range {
            guard let bucketDictionary = dictionary[AggregationConstant.buckets] as? [String: [String: Any]] else { return }
            for (key, var dict) in bucketDictionary {
                dict[BucketConstant.key] = key
                bucketList.append(dict)
            }
        } else {
            bucketList = dictionary[AggregationConstant.buckets] as? [[String: Any]] ?? []
        }
        
        let index = idx + 1
        for bucketData in bucketList {
            var bucket: Bucket
            switch currentAggs.bucketType {
            case .range:
                bucket = RangeBucket(bucketData, visState: visState, index: index, parentBucket: parentBucket)
                bucket.bucketType = currentAggs.bucketType
            default:
                bucket = Bucket(bucketData, visState: visState, index: index, parentBucket: parentBucket, bucketType: currentAggs.bucketType)
            }
            if bucket.isValid {
                buckets.append(bucket)
            }
        }
        
        if currentAggs.bucketType == .range {
            buckets.sort(by: { ($0 as! RangeBucket).from < ($1 as! RangeBucket).from })
        }

    }
}
