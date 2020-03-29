//
//  TableVizDataProvider.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 3/22/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

protocol TableVizUIData {
    var key: String { get }
    var value: String { get }
    var childBucket: TableVizUIData? { get }
    var bucket: Bucket? { get }
}

struct TableVizUIBucket: TableVizUIData {
    let key: String
    let value: String
    var childBucket: TableVizUIData?
    var bucket: Bucket?
}

class TableVizDataProvider {
 
    class func getTableVizUIData(chartContents: [ChartContent]) -> [TableVizUIBucket] {
        
        var tableDataList = [TableVizUIBucket]()
       
        for chartContent in chartContents {
            
            for bucket in chartContent.items {
                tableDataList.append(contentsOf: split(bucket: bucket))
            }
        }
        
        return tableDataList
    }
    
    class func split(bucket: Bucket) -> [TableVizUIBucket] {
        var splitted = [TableVizUIBucket]()
        
        if let immediateChildren = bucket.subAggsResult?.buckets {
            if let _ = immediateChildren.first?.subAggsResult?.buckets {
                for childBucket in immediateChildren {
                    let childSplitted = split(bucket: childBucket)
                    for child in childSplitted {
                        let parent = TableVizUIBucket(key: bucket.key,
                                                      value: "\(bucket.displayValue)",
                            childBucket: child,
                            bucket: bucket)
                        
                        splitted.append(parent)
                    }
                    
                }
            } else {
                for childBucket in immediateChildren {
                    let child = TableVizUIBucket(key: childBucket.key,
                                                 value: "\(childBucket.displayValue)",
                        childBucket: nil,
                        bucket: childBucket)
                    
                    let parent = TableVizUIBucket(key: bucket.key,
                                                  value: "\(bucket.displayValue)",
                        childBucket: child,
                        bucket: bucket)
                    splitted.append(parent)
                }
            }
        } else {
            let parent = TableVizUIBucket(key: bucket.key,
                                          value: "\(bucket.displayValue)",
                childBucket: nil,
                bucket: bucket)
            splitted = [parent]
        }
        
        return splitted
    }
}
