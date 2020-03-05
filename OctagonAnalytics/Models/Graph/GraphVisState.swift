//
//  GraphVisState.swift
//  KibanaGo
//
//  Created by Rameez on 11/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class GraphVisState: VisState {

    var query: String               =   ""
    var nodeImageBaseUrl: String    =   ""
    var nodeImageProperty: String   =   ""

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        query               <-  map["params.query"]
        nodeImageBaseUrl    <-  map["params.node_image_base_url"]
        nodeImageProperty   <-  map["params.node_image_property"]
    }
}
