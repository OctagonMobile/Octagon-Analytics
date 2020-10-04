//
//  FaceTilePanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/24/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class FaceTilePanel: Panel {
    
    var filterName: String?
    
    /**
     List of face tiles.
     */
    var faceTileList: [FaceTile] = []
    
    override init(_ responseModel: PanelService) {
        super.init(responseModel)
        
        guard let faceTilePanelService = responseModel as? FaceTilePanelService else { return }
        self.filterName = faceTilePanelService.filterName
    }
    
    override func requestParams() -> VizDataParamsBase? {
        guard let faceTileVisState = (visState as? FaceTileVisState),
            let indexPatternId = visState?.indexPatternId else { return nil }
        let reqParameters = FaceTileVizDataParams(indexPatternId)
        reqParameters.panelType = visState?.type ?? .unKnown
        reqParameters.timeFrom = dashboardItem?.fromTime
        reqParameters.timeTo = dashboardItem?.toTime
        reqParameters.searchQueryPanel = searchQuery
        reqParameters.searchQueryDashboard = dashboardItem?.searchQuery ?? ""

        if let filtersList = dataParams()?[FilterConstants.filters] as? [[String: Any]] {
            reqParameters.filters = filtersList
        }
        
        reqParameters.aggregationsArray = visState?.serviceAggregationsList ?? []
        
        reqParameters.box = faceTileVisState.box
        reqParameters.faceUrl = faceTileVisState.faceUrl ?? ""
        reqParameters.file = faceTileVisState.file ?? ""
        return reqParameters
    }
    /**
     Parse the data into Tiles object.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Tiles Object
     */
    override func parseData(_ result: Any?) -> [Any] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let hitsDict = responseJson.first?["hits"] as? [String: Any],
            let metricsArray = hitsDict["hits"] as? [[String: Any]] else {
                faceTileList.removeAll()
                return []
        }

        faceTileList.removeAll()

        // Parse the response to create list of face tile object
        var parsedArray: [[String: Any]] = []
        for item in metricsArray {
            guard let faceUrls = item["faces"] as? [String] else { continue }
            for faceUrlString in faceUrls {
                var dict: [String: Any] = [:]
                dict["fileName"] = item["fileName"] as? String
                dict["faceUrl"] = faceUrlString
                parsedArray.append(dict)
            }
        }
        faceTileList = parsedArray.compactMap({ FaceTile($0) })
        return faceTileList
    }
    
}
