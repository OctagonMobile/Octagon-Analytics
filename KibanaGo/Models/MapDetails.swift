//
//  MapDetails.swift
//  KibanaGo
//
//  Created by Rameez on 1/2/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class MapDetails: ChartItem {

    var location: CLLocation?
    
    var type: String        = ""
    
    //MARK: Functions

    override func mapping(map: Map) {
        super.mapping(map: map)

        type                    <- map["type"]

        if let locationDict = map.JSON["location"] as? [String: Any] {
            let lat = locationDict["lat"] as? Double ?? 0.0
            let longitude = locationDict["lon"] as? Double ?? 0.0
            
            location = CLLocation(latitude: lat, longitude: longitude)
        }
    }

}
