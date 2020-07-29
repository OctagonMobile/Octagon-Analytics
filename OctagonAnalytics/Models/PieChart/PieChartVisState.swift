//
//  PieChartVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/7/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class PieChartVisState: VisState {

    var isDonut: Bool   = false
    
    //MARK: Functions
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let pieVisService = responseModel as? PieChartVisStateService else { return }
        self.isDonut    =   pieVisService.isDonut
    }

}
