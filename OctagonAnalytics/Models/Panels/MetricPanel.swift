//
//  MetricPanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/28/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService
import Alamofire

class MetricPanel: Panel {

    /**
     List of Metric.
     */
    var metricsList: [Metric] = []
    
    //MARK: Functions
    override init(_ responseModel: PanelService) {
        super.init(responseModel)
        
        guard let panelService = responseModel as? MetricPanelService else { return }
        self.metricsList    =   panelService.metricsList.compactMap({ Metric($0) })
        
        metricsList = metricsList.map {
            $0.panel = self
            return $0
        }
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

        metricsList = metricsArray.compactMap({ Metric($0) })
        metricsList = metricsList.map {
            $0.panel = self
            return $0
        }
        return metricsList
    }
}
