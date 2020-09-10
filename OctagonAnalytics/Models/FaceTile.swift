//
//  FaceTile.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/24/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class FaceTile {

    var fileName: String    =   ""
    
    var faceUrl: String       =   ""

    var thumbnailImage: UIImage?
    
    //MARK: Functions
    init(_ dict: [String: Any]) {
        fileName    = dict[FaceTileConstant.fileName] as? String ?? ""
        faceUrl     = dict[FaceTileConstant.faceUrl] as? String ?? ""

    }
}
