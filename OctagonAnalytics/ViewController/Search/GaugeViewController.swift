//
//  GaugeViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/9/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import SmartGauge

class GaugeViewController: PanelBaseViewController {
    
    //MARK: Outlets
    @IBOutlet weak var gaugeView: SmartGauge!

    //MARK: Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initialGaugeSetup()
    }
    
    private func initialGaugeSetup() {
        gaugeView.valueTextColor = CurrentTheme.titleColor
        gaugeView.coveredTickValueColor = CurrentTheme.titleColor
    }
    
    override func setupPanel() {
        super.setupPanel()
        
        guard let visState = panel?.visState as? GaugeVisState else { return }
        
        if visState.gaugeType == .gauge {
            let colors = CurrentTheme.allChartColors
            
            var colorIndex = 0
            let ranges: [SGRanges] = visState.gauge?.ranges.enumerated().compactMap { (index, element) in
                let title = "\(element.from) - \(element.to)"
                if index >= colors.count {
                    colorIndex = 0
                }
                return SGRanges(title, fromValue: element.from, toValue: element.to, color: colors[colorIndex])
            } ?? []
            
            gaugeView.rangesList = ranges
            if let lastRange = ranges.last {
                gaugeView.gaugeMaxValue = lastRange.toValue
            }

        } else {
            // Handle for gaol
        }
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        hideNoItemsAvailable()
        let gaugeVal = (panel as? GaugePanel)?.gaugeValue ?? 0.0
        gaugeView.gaugeValue = gaugeVal
        
        if gaugeVal > gaugeView.rangesList.last?.toValue ?? 0.0 {
            gaugeView.gaugeMaxValue = gaugeVal
        }
    }
}
