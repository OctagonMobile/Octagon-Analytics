//
//  TagCloudVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

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
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let tagCloudVisService = responseModel as? TagCloudVisStateService else { return }
        self.minFontSize    =   tagCloudVisService.minFontSize
        self.maxFontSize    =   tagCloudVisService.maxFontSize
    }
}
