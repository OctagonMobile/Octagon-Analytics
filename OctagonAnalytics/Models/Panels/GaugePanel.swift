//
//  GaugePanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/19/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class GaugePanel: Panel {
        
    var gaugeValue: CGFloat =   0.0
    
    override func parseBuckets(_ aggregationsDict: [String : Any]) {
        guard let visState = visState,
            let id = visState.metricAggregationsArray.first?.id else { return }
        
        
        guard let contentDict = aggregationsDict[id] as? [String: Any] else { return }

        gaugeValue = contentDict["value"] as? CGFloat ?? 0.0        
    }
}
