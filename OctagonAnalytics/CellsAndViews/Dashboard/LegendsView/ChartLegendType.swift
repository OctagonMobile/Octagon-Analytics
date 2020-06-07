//
//  ChartLegendType.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/4/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

enum LegendIconShape {
    case circle(radius: CGFloat)
    case rect(width: CGFloat, height: CGFloat)
}

protocol ChartLegendType {
    var shape: LegendIconShape { get }
    var text: String { get }
    var color: UIColor { get }
    var textColor: UIColor? { get }
    var font: UIFont? { get }
}
