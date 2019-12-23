//
//  WebContentVisState.swift
//  KibanaGo
//
//  Created by Rameez on 2/27/19.
//  Copyright © 2019 MyCompany. All rights reserved.
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
