//
//  MarkDownVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 7/31/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class MarkDownVisState: VisState {

    var markdownText: String    =   ""
    var fontSize: CGFloat       =   12.0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        markdownText    <-  map["params.markdown"]
        fontSize        <-  map["params.fontSize"]
    }
}
