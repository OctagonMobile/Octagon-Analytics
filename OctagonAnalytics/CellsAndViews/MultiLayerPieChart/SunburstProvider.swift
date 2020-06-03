//
//  SunburstProvider.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 5/31/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation
import SunburstDiagram
import SwiftUI
import Combine

class SunburstProvider: PiecharProvider {
    //Public APis
    var onSelect: ((PieChartNode) -> Void)?
    var onDeselect: (() -> Void)?
    
    var pieChartVC: UIViewController {
        return hostingViewController
    }
    var configuration: PieChartConfiguration
    private var cancellable: AnyCancellable?
    
    //Private properties
    private var sunburstView: SunburstView
    private var hostingViewController: UIHostingController<SunburstView>
    private var sunburstConfiguration: SunburstConfiguration
    
    required init(configuration: PieChartConfiguration) {
        self.configuration = configuration
        self.sunburstConfiguration = configuration.asSunburstConfiguration
        self.sunburstView = SunburstView(configuration: sunburstConfiguration)
        self.hostingViewController = UIHostingController(rootView: sunburstView)
        cancellable = sunburstConfiguration.$selectedNode.sink(receiveValue: { (node) in
            if let selectedNode = node {
                self.onSelect?(selectedNode.asPieChartNode)
            } else {
                self.onDeselect?()
            }
        })
    }
    
    func updateChart(nodes: [PieChartNode]) {
        configuration.nodes = nodes
        sunburstConfiguration.nodes = nodes.map {$0.asSunburstNode}
        sunburstConfiguration.calculationMode = .parentDependent(totalValue: configuration.totalValue)
    }
    
    
}

extension PieChartNode {
    var asSunburstNode: Node {
        let node =  Node(name: name,
                    showName:
                    showName,
                    image: nil,
                    value: value,
                    backgroundColor: backgroundColor,
                    children: children.map { $0.asSunburstNode },
                    associatedObject: associatedObject)
        return node
    }
}

extension PieChartConfiguration {
    var asSunburstConfiguration: SunburstConfiguration {
        let sunburstConfig = SunburstConfiguration(nodes: nodes.map {$0.asSunburstNode},
                                     calculationMode: .parentDependent(totalValue: totalValue),
                                     nodesSort: .none)
        sunburstConfig.innerRadius = innerRadius
        sunburstConfig.expandedArcThickness = expandedArcThickness
        sunburstConfig.collapsedArcThickness = collapsedArcThickness
        sunburstConfig.startingAngle = startingAngle
        sunburstConfig.maximumExpandedRingsShownCount = maxExpandedArcCount
        sunburstConfig.strokeColor = Color(strokeColor)
        sunburstConfig.shouldFocusNode = false
        return sunburstConfig
    }
}

extension Node {
    var asPieChartNode: PieChartNode {
        return PieChartNode(name: name,
                            children: children.map { $0.asPieChartNode },
                            value: value,
                            showName: showName,
                            image: nil,
                            backgroundColor: backgroundColor,
                            associatedObject: associatedObject)
    }
}
