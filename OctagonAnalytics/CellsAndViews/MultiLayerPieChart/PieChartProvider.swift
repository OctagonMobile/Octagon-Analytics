//
//  PieChart.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 5/28/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

protocol PiecharProvider {
    init(configuration: PieChartConfiguration)
    var pieChartVC: UIViewController { get }
    var onSelect: ((PieChartNode) -> Void)? { get set }
    var onDeselect: (() -> Void)? { get set }
    func updateChart(nodes: [PieChartNode])
}

struct PieChartNode {
    var name: String
    var children: [PieChartNode]
    var value: Double?
    var showName: Bool
    var image: UIImage?
    var backgroundColor: UIColor?
    var associatedObject: Any?
}

struct PieChartConfiguration {
    var nodes: [PieChartNode]
    var marginBetweenArcs: CGFloat
    var expandedArcThickness: CGFloat
    var collapsedArcThickness: CGFloat
    var maxExpandedArcCount: UInt
    var innerRadius: CGFloat
    var startingAngle: Double
    var strokeColor: UIColor
}

extension PieChartConfiguration {
    var totalValue: Double {
        return nodes.reduce(0
            , { (result, node) -> Double in
                return result + (node.value ?? 0)
        })
    }
}
