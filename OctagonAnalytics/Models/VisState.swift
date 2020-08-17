//
//  VisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/7/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class VisState {

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

    var metricAggregationsArray: [Aggregation] = []
    var segmentSchemeAggregation: Aggregation?
    var otherAggregationsArray: [Aggregation] = []

    /**
     Position of X-Axis
     */
    var xAxisPosition: VisStateService.AxisPosition  =   .bottom
    
    var seriesMode: VisStateService.SeriesMode  =   .stacked
    
    var indexPatternId: String?
    
    // The following is used to load the data for Visualization
    var serviceAggregationsList: [AggregationService] = []
    
    //MARK: Functions
//    required init?(map: Map) {
//        // Empty Method
//    }
    
//    func mapping(map: Map) {
//        title           <- map["title"]
//        type            <- (map["type"],EnumTransform<PanelType>())
//        seriesMode      <- (map["params.seriesParams.mode"],EnumTransform<SeriesMode>())
//
//        if let params = map.JSON["params"] as? [String: Any] {
//            if let categoryAxes = (params["categoryAxes"] as? [[String: Any]])?.first,
//                let axisPositionString =  categoryAxes["position"] as? String {
//                xAxisPosition = AxisPosition(rawValue: axisPositionString) ?? .bottom
//            }
//
//            if let seriesParams = (params["seriesParams"] as? [[String: Any]])?.first,
//                let mode =  seriesParams["mode"] as? String {
//                seriesMode = SeriesMode(rawValue: mode) ?? .stacked
//            }
//        }
//
//        // Mapping Aggregation
//        if let aggregationJson = (map.JSON["aggs"] as? [[String: Any]]) {
//            aggregationsArray = Mapper<Aggregation>().mapArray(JSONArray: aggregationJson)
//        }
//
//        metricAggregationsArray = aggregationsArray.filter({ $0.schema == "metric"})
//        otherAggregationsArray = aggregationsArray.filter({ $0.schema != "metric"})
//        segmentSchemeAggregation = otherAggregationsArray.filter({ $0.schema == "segment"}).first
//    }
    
    init(_ responseModel: VisStateService) {
        self.title  =   responseModel.title
        self.type   =   responseModel.type
        self.indexPatternId =   responseModel.indexPatternId
        self.aggregationsArray = responseModel.aggregationsArray.compactMap({ Aggregation($0) })
        self.metricAggregationsArray = aggregationsArray.filter({ $0.schema == "metric" })
        self.otherAggregationsArray = aggregationsArray.filter({ $0.schema != "metric" })
        self.segmentSchemeAggregation = aggregationsArray.filter({ $0.schema == "segment" }).first
        self.xAxisPosition  =   responseModel.xAxisPosition
        self.seriesMode     =   responseModel.seriesMode
        
        serviceAggregationsList = responseModel.aggregationsArray
    }
}
