//
//  PieChartVisState.swift
//  KibanaGo
//
//  Created by Rameez on 11/7/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class PieChartVisState: VisState {

    var isDonut: Bool   = false
    
    //MARK: Functions
    override func mapping(map: Map) {
        super.mapping(map: map)
        isDonut     <- map["params.isDonut"]
    }

}
