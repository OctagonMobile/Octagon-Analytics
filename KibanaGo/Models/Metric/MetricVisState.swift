//
//  MetricVisState.swift
//  KibanaGo
//
//  Created by Rameez on 3/14/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit
import ObjectMapper

class MetricVisState: VisState {

    var fontSize: CGFloat?            = 10.0
    
    //MARK: Functions
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        fontSize        <- map["params.metric.style.fontSize"]
    }

}
