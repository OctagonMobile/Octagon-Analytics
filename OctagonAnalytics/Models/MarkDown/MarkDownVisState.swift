//
//  MarkDownVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 7/31/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class MarkDownVisState: VisState {

    var markdownText: String    =   ""
    var fontSize: CGFloat       =   12.0
    
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let markDownVisService = responseModel as? MarkDownVisStateService else { return }
        self.markdownText   =   markDownVisService.markdownText
        self.fontSize       =   markDownVisService.fontSize
    }
}
