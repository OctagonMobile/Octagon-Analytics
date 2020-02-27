//
//  Controls.swift
//  KibanaGo
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
    var selectedMinValue: Float?
    var selectedMaxValue: Float?
    
    init(_ control: Control, min: Float? = nil, max: Float? = nil) {
        super.init(control)
        self.selectedMinValue = min
        self.selectedMaxValue = max
    }
}

class ListCControlsWidget: ControlsWidgetBase {
    
    var list: [String]  =   []
    
    init(_ control: Control, list: [String]) {
        super.init(control)
        self.list = list
    }
}
