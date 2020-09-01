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
        } else {
            gaugeValue         =   contentDict["value"] as? CGFloat ?? 0.0
        }
    }
}
