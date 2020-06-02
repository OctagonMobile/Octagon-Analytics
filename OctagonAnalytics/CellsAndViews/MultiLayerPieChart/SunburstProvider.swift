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

class SunburstProvider: PiecharProvider {
    //Public APis
    var onSelect: ((PieChartNode) -> Void)?
    var pieChartVC: UIViewController {
        return hostingViewController
    }
    var configuration: PieChartConfiguration
    
    //Private properties
    private var sunburstView: SunburstView
    private var hostingViewController: UIHostingController<SunburstView>
    private var sunburstConfiguration: SunburstConfiguration
    
    required init(configuration: PieChartConfiguration) {
        self.configuration = configuration
        self.sunburstConfiguration = configuration.asSunburstConfiguration
        self.sunburstView = SunburstView(configuration: sunburstConfiguration)
        self.hostingViewController = UIHostingController(rootView: sunburstView)
    }
    
    func updateChart(nodes: [PieChartNode]) {
        configuration.nodes = nodes
        sunburstConfiguration.nodes = nodes.map {$0.asSunburstNode}
        sunburstConfiguration.calculationMode = .parentDependent(totalValue: configuration.totalValue)
    }
    
}

extension PieChartNode {
    var asSunburstNode: Node {
        return Node(name: name,
                    showName:
                    showName,
                    image: nil,
                    value: value,
                    backgroundColor: backgroundColor,
                    children: children.map { $0.asSunburstNode })
    }
}

extension PieChartConfiguration {
    var asSunburstConfiguration: SunburstConfiguration {
        return SunburstConfiguration(nodes: nodes.map {$0.asSunburstNode},
                                     calculationMode: .parentDependent(totalValue: totalValue),
                                     nodesSort: .none)
    }
}
