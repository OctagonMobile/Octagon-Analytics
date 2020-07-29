//
//  MetricVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 3/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class MetricVisState: VisState {

    var fontSize: CGFloat?            = 10.0
    
    //MARK: Functions
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let metricVisService = responseModel as? MetricVisStateService else { return }
        self.fontSize   =   metricVisService.fontSize
    }

}
