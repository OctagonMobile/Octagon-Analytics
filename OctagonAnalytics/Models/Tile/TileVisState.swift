//
//  TileVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 3/12/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class TileVisState: VisState {
    
    var imageHashField: String      = ""
    var maxDistance: Int            = 15
    var containerId: Int            = 1

    //MARK: Functions
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let tileVisService = responseModel as? TileVisStateService else { return }
        self.imageHashField =   tileVisService.imageHashField
        self.maxDistance    =   tileVisService.maxDistance
        self.containerId    =   tileVisService.containerId
    }    
}

