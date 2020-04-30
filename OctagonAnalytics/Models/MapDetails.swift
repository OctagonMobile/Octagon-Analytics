//
//  MapDetails.swift
//  OctagonAnalytics
//
//  Created by Rameez on 1/2/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class MapDetails: ChartContent, Mappable {
   
    required init?(map: Map) {
        
    }

    var location: CLLocation?
    
    var type: String        = ""
    
    //MARK: Functions

    func mapping(map: Map) {
        if let keyValue = map.JSON["key"] {
            key   = "\(keyValue)"
        }
        docCount            <- map["doc_count"]
        bucketValue         <- map["bucketValue"]
        
        type <- map["type"]
        
        if let locationDict = map.JSON["location"] as? [String: Any] {
            let lat = locationDict["lat"] as? Double ?? 0.0
            let longitude = locationDict["lon"] as? Double ?? 0.0
            
            location = CLLocation(latitude: lat, longitude: longitude)
        }
        
    }

}
