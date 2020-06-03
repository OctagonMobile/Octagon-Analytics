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
    private var colorIndex = 0

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

extension AggResult {
    func asPieChartData() -> [PieChartNode] {
        let convertedNodes = bucketsToNodes(buckets: buckets)
        return adjustNodeValuesBasedOnParent(nodes: convertedNodes, totalValue: nil)
    }
    
    func bucketsToNodes(buckets: [Bucket]) -> [PieChartNode] {
        let defaultColors = CurrentTheme.chartColors1 +
        CurrentTheme.chartColors2 +
        CurrentTheme.chartColors3
        
        var nodes:[PieChartNode] = []

        for bucket in buckets {
            //Get Color For Node
            if colorIndex >= defaultColors.count { colorIndex = 0 }
            let color = defaultColors[colorIndex]
            colorIndex += 1
            
            var children:[PieChartNode] = []
            if let childBuckets = bucket.subAggsResult?.buckets {
                children = bucketsToNodes(buckets: childBuckets)
            }
            let node = PieChartNode(name: bucket.key, children: children, value: bucket.displayValue, showName: false, image: nil, backgroundColor: color, associatedObject: bucket)
            nodes.append(node)
        }
        return nodes
    }
    
    func adjustNodeValuesBasedOnParent(nodes: [PieChartNode], totalValue: Double?) -> [PieChartNode] {
        var adjustedNodes: [PieChartNode] = []
        
        let nodesTotal = nodes.reduce(0.0) { (result, node) -> Double in
            return result + (node.value ?? 0.0)
        }
        
        let parentTotal: Double = (totalValue == nil) ? nodesTotal : totalValue!
        for node in nodes {
            var nodeToAdjust = node
            nodeToAdjust.value = (node.value ?? 0.0) * parentTotal / nodesTotal
            let children = adjustNodeValuesBasedOnParent(nodes: nodeToAdjust.children,
                                            totalValue: nodeToAdjust.value)
            nodeToAdjust.children = children
            adjustedNodes.append(nodeToAdjust)
        }
        
        return adjustedNodes
    }
}
