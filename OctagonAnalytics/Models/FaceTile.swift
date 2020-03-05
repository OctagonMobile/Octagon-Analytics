//
//  FaceTile.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/24/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class FaceTile: Mappable {

    var fileName: String    =   ""
    
    var faceUrl: String       =   ""

    var thumbnailImage: UIImage?
    
    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        fileName                <- map["fileName"]
        faceUrl                 <- map["faceUrl"]
    }
}
