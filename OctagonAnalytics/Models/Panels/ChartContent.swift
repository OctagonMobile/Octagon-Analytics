//
//  ChartContent.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 5/18/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

class ChartContent {
    var key: String             =   ""
    var bucketType: BucketType  =   .unKnown
    var docCount                =   0.0
    var bucketValue             =   0.0
    var items: [Bucket]      =   []
    
    var displayValue: String {
        if bucketType == .dateHistogram {
            guard let keyValue = Int(key) else { return key }
            let date = Date(milliseconds: keyValue)
            return date.toFormat("YYYY-MM-dd HH:mm:ss")
        }
        return key
    }
}

extension ChartContent: BucketAggType {
    var bucketKey: String {
        return key
    }
    
    var aggType: BucketType {
        return bucketType
    }
    
    var parent: BucketAggType? {
        return nil
    }
    
}
