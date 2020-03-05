//
//  VisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/7/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class VisState: Mappable {

    enum AxisPosition: String {
        case left   =   "left"
        case right  =   "right"
        case top    =   "top"
        case bottom =   "bottom"
    }
    
    /**
     Type of the panel (eg.: Pie, TagCloud, Donut etc).
     */
    var type            = PanelType.unKnown

    /**
     Panel Title.
     */
    var title           = ""
    
    /**
     Array of aggregations. (Metrics & Buckets)
     */
    var aggregationsArray: [Aggregation] = []

    /**
     Position of X-Axis
     */
    var xAxisPosition: AxisPosition  =   .bottom
    
    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        title           <- map["title"]
        type            <- (map["type"],EnumTransform<PanelType>())
        
        if let params = map.JSON["params"] as? [String: Any],
            let categoryAxes = (params["categoryAxes"] as? [[String: Any]])?.first,
            let axisPositionString =  categoryAxes["position"] as? String {
            xAxisPosition = AxisPosition(rawValue: axisPositionString) ?? .bottom
        }

        // Mapping Aggregation
        if let aggregationJson = (map.JSON["aggs"] as? [[String: Any]]) {
            aggregationsArray = Mapper<Aggregation>().mapArray(JSONArray: aggregationJson)
        }

    }
}
