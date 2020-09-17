//
//  GaugePanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/19/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class GaugePanel: Panel {
        
    var gaugeValue: CGFloat =   0.0
    
    override func parseData(_ result: Any?) -> [Any] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let metricAggs = visState?.metricAggregationsArray.first else {
            return []
        }
                
        if metricAggs.metricType == .count {
            gaugeValue = (responseJson.first?["hits"] as? [String: Any])?["total"] as? CGFloat ?? 0.0
        } else {
            guard let aggregationsDict = responseJson.first?[PanelConstant.aggregations] as? [String: Any] else { return chartContentList }
            parseBuckets(aggregationsDict)
        }
        
        return chartContentList

    }
    
    override func parseBuckets(_ aggregationsDict: [String : Any]) {
        guard let visState = visState,
            let id = visState.metricAggregationsArray.first?.id else { return }
                
        guard let contentDict = aggregationsDict[id] as? [String: Any] else { return }

        let metricType = visState.metricAggregationsArray.first?.metricType ?? MetricType.unKnown

        if metricType == .median {
            if let values = contentDict ["values"] as? [[String: Any]],
                let valueDict = values.first  {
                gaugeValue         =   valueDict["value"] as? CGFloat ?? 0.0
            }
        } else if metricType == .topHit {
            gaugeValue = CGFloat(parseTopHitValue(dict: contentDict))
        } else {
            gaugeValue         =   contentDict["value"] as? CGFloat ?? 0.0
        }
    }
}

extension GaugePanel {
    func parseTopHitValue(dict: [String: Any]) -> Double {
        guard let metricAgg = visState?.metricAggregationsArray.first else {
            return 0.0
        }
        var values: [Double] = []
        if let hitsDict = dict[BucketConstant.hits] as? [String : Any],
            let hitsArray = hitsDict[BucketConstant.hits] as? [[String: Any]] {
            for hit in hitsArray {
                if let source = hit[BucketConstant.source] as? [String: Any],
                    let value = source[metricAgg.field] as? Double {
                    values.append(value)
                }
            }
        }
        
        if let aggregate = metricAgg.params?.aggregate {
            let value = values.apply(aggregate: aggregate)
            return  Double(round(100*value)/100)
        }
        
        return 0
    }
    
}
