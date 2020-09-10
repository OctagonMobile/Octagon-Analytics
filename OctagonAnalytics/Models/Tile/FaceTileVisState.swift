//
//  FaceTileVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/09/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation
import OctagonAnalyticsService

class FaceTileVisState: VisState {
    
    var box: String         = ""
    var faceUrl: String?
    var file: String?

    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let faceTileVisService = responseModel as? FaceTileVisStateService else { return }
        
        self.box        =   faceTileVisService.box
        self.faceUrl    =   faceTileVisService.faceUrl
        self.file       =   faceTileVisService.file
    }
}
