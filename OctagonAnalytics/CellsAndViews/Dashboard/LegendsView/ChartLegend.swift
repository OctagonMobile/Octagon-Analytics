//
//  ChartLegend.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/4/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

struct ChartLegend: ChartLegendType, Equatable {
    
    var shape: LegendIconShape
    
    var text: String
    
    var color: UIColor
    
    var textColor: UIColor?
    
    var font: UIFont?
    
    init(text: String,
         color: UIColor,
         textColor: UIColor = CurrentTheme.disabledStateBackgroundColor,
         font: UIFont? = CurrentTheme.caption1TextStyle().font,
         shape: LegendIconShape) {
        self.text = text
        self.color = color
        self.textColor = textColor
        self.shape = shape
    }
    
    static func == (lhs: ChartLegend, rhs: ChartLegend) -> Bool {
        return lhs.text == rhs.text && lhs.color.isEqual(rhs.color)
    }
}
