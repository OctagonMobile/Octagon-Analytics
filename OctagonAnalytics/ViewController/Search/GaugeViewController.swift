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
    @IBOutlet weak var legendEnableButton: UIButton?

    var legendOnIconName: String {
        return CurrentTheme.isDarkTheme ? "LegendOn-Dark" : "LegendOn"
    }
    
    var legendOffIconName: String {
        return CurrentTheme.isDarkTheme ? "LegendOff-Dark" : "LegendOff"
    }

    //MARK: Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initialGaugeSetup()
    }
    
    private func initialGaugeSetup() {
        
        gaugeView.valueTextColor = CurrentTheme.titleColor
        gaugeView.coveredTickValueColor = CurrentTheme.titleColor
        gaugeView.gaugeViewPercentage = 0.7
        gaugeView.legendMargin = 10
        gaugeView.legendSpacing = 5
        gaugeView.legendSize = CGSize(width: 25, height: 20)
        if let font = CTFontCreateUIFontForLanguage(.system, 17.0, nil) {
            gaugeView.legendFont = font
        }
    }
    
    override func setupHeader() {
        super.setupHeader()
        legendEnableButton?.isSelected = true
        legendEnableButton?.setTitle("", for: .normal)
        legendEnableButton?.setImage(UIImage(named: legendOffIconName), for: .normal)
        legendEnableButton?.setImage(UIImage(named: legendOnIconName), for: .selected)
    }
    
    override func setupPanel() {
        super.setupPanel()
        
        gaugeView.enableLegends = legendEnableButton?.isSelected ?? false
        
        guard let visState = panel?.visState as? GaugeVisState else { return }
        
        if visState.gaugeType == .gauge {
            let colors = CurrentTheme.gaugeRangeColors
            
            var colorIndex = 0
            let ranges: [SGRanges] = visState.gauge?.ranges.enumerated().compactMap { (index, element) in
                
                let fromValue = floor(element.from) == element.from ? "\(Int(element.from))" : "\(element.from)"
                let toValue = floor(element.to) == element.to ? "\(Int(element.to))" : "\(element.to)"

                let title = "\(fromValue) - \(toValue)"
                if index >= colors.count {
                    colorIndex = 0
                }
                let color = colors[colorIndex]
                colorIndex += 1
                return SGRanges(title, fromValue: element.from, toValue: element.to, color: color)
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
        
        if let color = gaugeView.rangesList.filter({ gaugeVal >= $0.fromValue && gaugeVal <= $0.toValue }).first?.color {
            gaugeView.trackBackgroundColor = color.withAlphaComponent(0.1)
        }
            
        if gaugeVal > gaugeView.rangesList.last?.toValue ?? 0.0 {
            gaugeView.gaugeMaxValue = gaugeVal
        }
    }
    
    //MARK: Button Actions
    @IBAction func legendButtonAction(_ sender: UIButton) {
        legendEnableButton?.isSelected = !(legendEnableButton?.isSelected ?? false)
        gaugeView.enableLegends = (legendEnableButton?.isSelected ?? true)
        updatePanelContent()
    }
}
