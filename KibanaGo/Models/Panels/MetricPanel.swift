//
//  MetricPanel.swift
//  KibanaGo
//
//  Created by Rameez on 11/28/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class MetricPanel: Panel {

    /**
     List of Metric.
     */
    var metricsList: [Metric] = []
    
    //MARK: Functions
    override func mapping(map: Map) {
        super.mapping(map: map)
        metricsList = Mapper<Metric>().mapArray(JSONObject: map.JSON) ?? []
    }
    
    
    override func resetDataSource() {
        super.resetDataSource()
        metricsList.removeAll()
    }
    
    /**
     Parse the data into Metrics List.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Metric Object
     */
    override func parseData(_ result: Any?) -> [Any] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let aggregationsDict = responseJson.first?["aggregations"] as? [String: Any],
            let metricsArray = aggregationsDict["metrics"] as? [[String: Any]] else {
                metricsList.removeAll()
                return []
        }
        
        metricsList = Mapper<Metric>().mapArray(JSONArray: metricsArray)
        return metricsList
    }
}
