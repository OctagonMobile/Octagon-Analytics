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
            let aggregationsDict = responseJson.first?["aggregations"] as? [String: Any],
            let maxAggDict = aggregationsDict["maxAgg"] as? [String: Any], let maxAgg = maxAggDict["value"] as? Int,
            let minAggDict = aggregationsDict["minAgg"] as? [String: Any], let minAgg = minAggDict["value"] as? Int else {
                return []
        }
        
        self.maxAgg = maxAgg
        self.minAgg = minAgg

        return [["min": self.minAgg, "max":self.maxAgg]]
    }

}
