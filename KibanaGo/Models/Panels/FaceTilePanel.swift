//
//  FaceTilePanel.swift
//  KibanaGo
//
//  Created by Rameez on 10/24/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class FaceTilePanel: Panel {
    
    var filterName: String?
    
    /**
     List of face tiles.
     */
    var faceTileList: [FaceTile] = []
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        filterName      <-  map["visState.params.file"]
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
        faceTileList = Mapper<FaceTile>().mapArray(JSONArray: parsedArray)
        return faceTileList
    }
    
}
