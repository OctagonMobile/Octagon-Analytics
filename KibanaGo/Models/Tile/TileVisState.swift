//
//  TileVisState.swift
//  KibanaGo
//
//  Created by Rameez on 3/12/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit
import ObjectMapper

class TileVisState: VisState {
    
    var imageHashField: String      = ""
    var maxDistance: Int            = 15
    var containerId: Int            = 1

    //MARK: Functions
    override func mapping(map: Map) {
        super.mapping(map: map)
        imageHashField      <- map["params.imageHashField"]
        maxDistance         <- map["params.maxDistance"]
        containerId         <- map["params.containerId"]
    }
    
}

