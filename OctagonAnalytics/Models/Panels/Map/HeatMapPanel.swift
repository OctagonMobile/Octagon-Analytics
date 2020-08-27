//
//  HeatMapPanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 1/2/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import OctagonAnalyticsService

class HeatMapPanel: Panel, WMSLayerProtocol {

    /**
     Map Details.
     */
    var mapDetail: [MapDetails] = []
    
    //MARK:
    override func dataParams() -> [String : Any]? {
        var params =  super.dataParams()

        if let precision = bucketAggregation?.params?.precision {
            params?["precision"] = NSNumber(value: precision)
        }
        return params
    }
    
    /**
     Parse the data into Map Detail object.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Map Details Object
     */
    override func parseData(_ result: Any?) -> [Any] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let aggregationsDict = responseJson.first?["aggregations"] as? [String: Any],
            let filterAggDict = aggregationsDict["filter_agg"] as? [String: Any],
            let bucketsContent = filterAggDict[AggregationId.bucket.rawValue] as? [String: Any],
            let bucketsArray = bucketsContent["buckets"] as? [[String: Any]] else {
                mapDetail.removeAll()
                return []
        }
        
        mapDetail = Mapper<MapDetails>().mapArray(JSONArray: bucketsArray)
        return mapDetail
    }
    
    func updatePrecisionFor(_ zoom: Double) {
        
        var precision: Int
        switch zoom {
        case 0...1.3:
            precision = 1
        case 1.3...5.2:
            precision = 2
        case 5.2...7.8:
            precision = 3
        case 7.8...11.7:
            precision = 4
        case 11.7...14.3:
            precision = 5
        case 14.3...16.9:
            precision = 6
        case 16.9...20.0:
            precision = 7

        default:
            precision = bucketAggregation?.params?.precision ?? 5
            
        }
        
        bucketAggregation?.params?.precision = precision
    }
    
    func zoomForPrecision(_ precision: Int) -> Int {
        
        var zoom: Int
        print(precision)
        switch precision {
        case 1:
            zoom = 3
        case 2...3:
            zoom = 5
        case 4:
            zoom = 7
        case 5:
            zoom = 8
        case 6...8:
            zoom = 10
            
        default:
            zoom = 4
            
        }
        return zoom
    }
    
    override func requestParams() -> VizDataParamsBase? {
        guard let indexPatternId = visState?.indexPatternId else { return nil }
        let reqParameters = MapVizParams(indexPatternId)
        reqParameters.panelType = visState?.type ?? .unKnown
        reqParameters.timeFrom = dashboardItem?.fromTime
        reqParameters.timeTo = dashboardItem?.toTime
        reqParameters.searchQueryPanel = searchQuery
        reqParameters.searchQueryDashboard = dashboardItem?.searchQuery ?? ""

        if let filtersList = dataParams()?[FilterConstants.filters] as? [[String: Any]] {
            reqParameters.filters = filtersList
        }
        
        // In case of date histogram send the interval
        if bucketType == .dateHistogram, let interval = mappedIntervalValue {
            reqParameters.interval = "\(interval)"
        }

        reqParameters.aggregationsArray = visState?.serviceAggregationsList ?? []
        return reqParameters
    }
}


//MARK: WMS protocol
protocol WMSLayerProtocol {}

extension WMSLayerProtocol {
    
    func loadLayersWith(mapUrl: String?, _ completion: CompletionBlock?)  {
        let params: [String : Any] = ["request": "GetCapabilities", "Service":  "WMS"]
        let mapUrl = mapUrl ?? Configuration.shared.environment.mapBaseUrl

        DataManager.shared.loadXMLData(baseUrl: mapUrl, parameters: params, completion: { (result, error) in
            guard let res = result as? [AnyHashable: Any?], let finalResult = res["result"] else {
                completion?(nil, error)
                return
            }
            completion?(finalResult, error)
        })
    }
}
