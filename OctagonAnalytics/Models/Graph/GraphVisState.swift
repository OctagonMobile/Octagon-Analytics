//
//  GraphVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class GraphVisState: VisState {

    var query: String               =   ""
    var nodeImageBaseUrl: String    =   ""
    var nodeImageProperty: String   =   ""

    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let graphServiceVisState = responseModel as? GraphVisStateService else { return }
        self.query      =   graphServiceVisState.query
        self.nodeImageBaseUrl   =   graphServiceVisState.nodeImageBaseUrl
        self.nodeImageProperty  =   graphServiceVisState.nodeImageProperty
    }
//    override func mapping(map: Map) {
//        super.mapping(map: map)
//
//        query               <-  map["params.query"]
//        nodeImageBaseUrl    <-  map["params.node_image_base_url"]
//        nodeImageProperty   <-  map["params.node_image_property"]
//    }
}
