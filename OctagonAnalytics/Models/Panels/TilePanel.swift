//
//  TilePanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class TilePanel: Panel {
    
    /**
     List of tiles.
     */
    var tileList: [Tile] = []
    
    /**
     Parse the data into Tiles object.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Tiles Object
     */
    override func parseData(_ result: Any?) -> [Any] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let hitsDict = responseJson.first?["hits"] as? [String: Any],
            let metricsArray = hitsDict["hits"] as? [[String: Any]] else {
                tileList.removeAll()
                return []
        }
        
        tileList = Mapper<Tile>().mapArray(JSONArray: metricsArray)
        return tileList
    }

}
