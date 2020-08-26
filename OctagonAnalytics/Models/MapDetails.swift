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
        if let keyValue = map.JSON[BucketConstant.key] {
            key   = "\(keyValue)"
        }
        docCount            <- map[BucketConstant.docCount]
        bucketValue         <- map[BucketConstant.bucketValue]
        
        type <- map[BucketConstant.type]
        
        if let dict = map.JSON["3"] as? [String: Any],
            let locationDict = dict[MapDetailsConstant.location] as? [String: Any] {
            let lat = locationDict[MapDetailsConstant.lat] as? Double ?? 0.0
            let longitude = locationDict[MapDetailsConstant.long] as? Double ?? 0.0
            
            location = CLLocation(latitude: lat, longitude: longitude)
        }
        
    }

}
