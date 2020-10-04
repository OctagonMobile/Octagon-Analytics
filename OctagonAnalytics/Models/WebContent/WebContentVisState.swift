//
//  WebContentVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/27/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class WebContentVisState: VisState {

    var htmlString: String      = ""
    
    //MARK: Functions
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let webVisService = responseModel as? WebContentVisStateService else { return }
        self.htmlString =   webVisService.htmlString
    }
}
