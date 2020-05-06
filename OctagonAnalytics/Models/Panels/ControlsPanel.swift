//
//  ControlsPanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 3/1/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import ObjectMapper

class ControlsPanel: Panel {
    
    var maxAgg: Int?
    
    var minAgg: Int?

    /**
     Parse the data into Metrics List.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Metric Object
     */
    override func parseData(_ result: Any?) -> [Any] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let aggregationsDict = responseJson.first?["aggregations"] as? [String: Any] else {
                return []
        }
        
        let type = (visState as? InputControlsVisState)?.controls.first?.type
        
        if type == Control.ControlType.range {
            let maxAggDict = aggregationsDict["maxAgg"] as? [String: Any]
            self.maxAgg = maxAggDict?["value"] as? Int
            let minAggDict = aggregationsDict["minAgg"] as? [String: Any]
            self.minAgg = minAggDict?["value"] as? Int
            return [["min": self.minAgg, "max":self.maxAgg]]
        } else {
            guard let termsAggs = aggregationsDict["termsAgg"] as? [String: Any],
                let bucketsList = termsAggs["buckets"] as? [[String: Any]] else { return [] }
            
            chartContentList = bucketsList.compactMap { (dict) -> ChartContent? in
                let content = ChartContent()
                content.key         = dict["key"] as? String ?? ""
                content.docCount    = dict["doc_count"] as? Double ?? 0.0
                return content
            }
            return chartContentList
        }
    }
}
