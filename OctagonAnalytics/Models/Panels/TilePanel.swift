//
//  TilePanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class TilePanel: Panel {
    
    /**
     List of tiles.
     */
    var tileList: [Tile] = []
    
    //MARK: Functions
    override func requestParams() -> VizDataParamsBase? {
        guard let tileVisState = (visState as? TileVisState),
            let indexPatternId = visState?.indexPatternId else { return nil }
        
        let reqParameters = TilesVizDataParams(indexPatternId, tileViewType: tileVisState.specifytype)
        reqParameters.panelType = visState?.type ?? .unKnown
        reqParameters.timeFrom = dashboardItem?.fromTime
        reqParameters.timeTo = dashboardItem?.toTime
        reqParameters.searchQueryPanel = searchQuery
        reqParameters.searchQueryDashboard = dashboardItem?.searchQuery ?? ""

        if let filtersList = dataParams()?[FilterConstants.filters] as? [[String: Any]] {
            reqParameters.filters = filtersList
        }

        reqParameters.aggregationsArray = visState?.serviceAggregationsList ?? []
        
        reqParameters.specifyType   = tileVisState.specifytype
        reqParameters.urlThumbnail  = tileVisState.urlThumbnail
        reqParameters.imlServer     = tileVisState.imlServer
        
        reqParameters.thumbnailFilePath = tileVisState.thumbnailFilePath != nil ? tileVisState.thumbnailFilePath! : tileVisState.images
        reqParameters.imageFilePath     = tileVisState.imageFilePath ?? ""
        reqParameters.imageHashField    =   tileVisState.imageHashField

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
            let tilesArray = hitsDict["hits"] as? [[String: Any]] else {
                tileList.removeAll()
                return []
        }
        
        tileList = tilesArray.compactMap({ Tile($0) })
        return tileList
    }

}
