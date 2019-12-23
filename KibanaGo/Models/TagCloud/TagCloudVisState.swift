//
//  TagCloudVisState.swift
//  KibanaGo
//
//  Created by Rameez on 11/23/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit
import ObjectMapper

class TagCloudVisState: VisState {

    /**
     Minimum Font Size.
     */
    var minFontSize: NSInteger    = 14
    
    /**
     Maximum Font Size.
     */
    var maxFontSize: NSInteger    = 60

    //MARK: Functions
    override func mapping(map: Map) {
        super.mapping(map: map)
        minFontSize     <- map["params.minFontSize"]
        maxFontSize     <- map["params.maxFontSize"]
    }
    

}
