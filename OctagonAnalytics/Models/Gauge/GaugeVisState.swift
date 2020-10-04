//
//  GaugeVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/9/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import OctagonAnalyticsService

class GaugeVisState: VisState {
    
    var gaugeType: GaugeVisStateService.GaugeType    =   .gauge
    var gauge: Gauge?
    
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let gaugeVisState = responseModel as? GaugeVisStateService else { return }
        gaugeType   =   gaugeVisState.gaugeType
        
        if let gaugeService = gaugeVisState.gauge {
            gauge       =   Gauge(gaugeService)
        }
    }
}

class Gauge {
    
    var ranges: [GaugeRange] =   []
    
    var subType: GaugeService.GaugeSubType  =   .arc
    
    //MARK: Functions
    init(_ responseModel: GaugeService) {
        self.subType    =   responseModel.subType
        self.ranges     =   responseModel.ranges.compactMap({ GaugeRange($0) })
    }
}

class GaugeRange {
    
    var from: CGFloat   =   0.0
    var to: CGFloat     =   0.0

    init(_ responseModel: GaugeRangeService) {
        self.from   =   responseModel.from
        self.to     =   responseModel.to
    }
}
