//
//  Controls.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/27/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

class ControlsWidgetBase {
    var control: Control
    init(_ control: Control) {
        self.control = control
    }
}

class RangeControlsWidget: ControlsWidgetBase {
    var minValue: Float?
    var maxValue: Float?

    var selectedMinValue: Float?
    var selectedMaxValue: Float?
    
    init(_ control: Control, min: Float? = nil, max: Float? = nil) {
        super.init(control)
        self.minValue = min
        self.maxValue = max
    }
}

class ListControlsWidget: ControlsWidgetBase {
    
    var list: [ChartContent]  =   []
    
    var selectedList: [ChartContent]   =   []
    
    init(_ control: Control, list: [ChartContent]) {
        super.init(control)
        self.list = list
    }
}
