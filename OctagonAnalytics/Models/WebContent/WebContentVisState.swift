//
//  WebContentVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/27/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class WebContentVisState: VisState {

    var htmlString: String      = ""
    
    //MARK: Functions
    override func mapping(map: Map) {
        super.mapping(map: map)
        htmlString          <- map["params.html"]
    }
}
