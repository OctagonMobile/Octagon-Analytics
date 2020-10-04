//
//  MapDetails.swift
//  OctagonAnalytics
//
//  Created by Rameez on 1/2/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class MapDetails: ChartContent {
    var location: CLLocation?
    
    var type: String        = ""

    init(data: [String: Any]) {
        super.init()
        if let keyValue = data[BucketConstant.key] {
            key = "\(keyValue)"
        }
        docCount = data[BucketConstant.docCount] as? Double ?? 0.0
        bucketValue = data[BucketConstant.bucketValue]  as? Double ?? 0.0
        type = data[BucketConstant.type] as? String ?? ""
        
        if let dict = data["3"] as? [String: Any],
            let locationDict = dict[MapDetailsConstant.location] as? [String: Any] {
            let lat = locationDict[MapDetailsConstant.lat] as? Double ?? 0.0
            let longitude = locationDict[MapDetailsConstant.long] as? Double ?? 0.0
            location = CLLocation(latitude: lat, longitude: longitude)
        }
    }
    
}
