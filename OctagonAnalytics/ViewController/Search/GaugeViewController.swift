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
        //Set size of the legend to zero for Goal Viz (Note: for Gauge viz legends are disabled)
        gaugeView.legendSize = CGSize.zero
    }
    
    override func setupPanel() {
        super.setupPanel()
                
        guard let visState = panel?.visState as? GaugeVisState else { return }
        
        let isGaugeView = visState.gaugeType == .gauge
        gaugeView.gaugeType = isGaugeView ? .gauge : .goal
        gaugeView.enableLegends = !isGaugeView
        
        let colors = CurrentTheme.gaugeRangeColors
        var colorIndex = 0
        
        var rangesList = visState.gauge?.ranges ?? []
        if !isGaugeView && rangesList.count > 0 {
            rangesList = Array(rangesList.prefix(1))
        }
        
        let ranges: [SGRanges] = rangesList.enumerated().compactMap { (index, element) in
            
            let fromValue = floor(element.from) == element.from ? "\(Int(element.from))" : "\(element.from)"
            let toValue = floor(element.to) == element.to ? "\(Int(element.to))" : "\(element.to)"

            let title = isGaugeView ? "\(fromValue) - \(toValue)" : "Goal: \(toValue)"
            if index >= colors.count {
                colorIndex = 0
            }
            let color = colors[colorIndex]
            colorIndex += 1
            return SGRanges(title, fromValue: element.from, toValue: element.to, color: color)
        }
        
        gaugeView.rangesList = ranges
        if let lastRange = ranges.last {
            gaugeView.gaugeMaxValue = lastRange.toValue
        }

    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        hideNoItemsAvailable()
        let gaugeVal = (panel as? GaugePanel)?.gaugeValue ?? 0.0
        gaugeView.gaugeValue = gaugeVal
        
        if let color = gaugeView.rangesList.filter({ gaugeVal >= $0.fromValue && gaugeVal <= $0.toValue }).first?.color {
            gaugeView.trackBackgroundColor = color.withAlphaComponent(0.1)
        }
            
        if gaugeVal > gaugeView.rangesList.last?.toValue ?? 0.0 {
            gaugeView.gaugeMaxValue = gaugeVal
        }
    }
}
