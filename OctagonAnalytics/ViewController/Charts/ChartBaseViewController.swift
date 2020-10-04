//
//  ChartBaseViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/16/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts
import OctagonAnalyticsService

class ChartBaseViewController: PanelBaseViewController {

    @IBOutlet weak var chart: ChartViewBase? 
    @IBOutlet weak var legendEnableButton: UIButton?
    @IBOutlet weak var legendButtonWidthConstraint: NSLayoutConstraint?

    var legendOnIconName: String {
        return CurrentTheme.isDarkTheme ? "LegendOn-Dark" : "LegendOn"
    }
    
    var legendOffIconName: String {
        return CurrentTheme.isDarkTheme ? "LegendOff-Dark" : "LegendOff"
    }

    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupPanel() {
        super.setupPanel()
        setupLegend()
        setupChart()
        
    }
    
    override func setupHeader() {
        super.setupHeader()
        
        legendEnableButton?.setTitle("", for: .normal)
        legendEnableButton?.setImage(UIImage(named: legendOffIconName), for: .normal)
        legendEnableButton?.setImage(UIImage(named: legendOnIconName), for: .selected)
    }
    
    func setupLegend() {
        
        // Disable default legend
        chart?.legend.enabled = false

        let legend = chart?.scrollableLegend
        legend?.isEnabled = legendEnableButton?.isSelected ?? false
        legend?.isScrollEnabled = false
    }

    func setupChart() {
        // Override in subclass to setup the chart
        super.setupPanel()
        chart?.chartDescription?.enabled = false
        chart?.noDataText = ""
        
        // Default Colors
        defaultColors.append(contentsOf: CurrentTheme.chartColors1)
        defaultColors.append(contentsOf: CurrentTheme.chartColors2)
        defaultColors.append(contentsOf: CurrentTheme.chartColors3)
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        if panel?.bucketType == BucketType.histogram {
            //For Histogram, Filter not supported from chart view
            chart?.isUserInteractionEnabled = false
        }
        chart?.data = nil
    }

    override func flipPanel(_ mode: PanelMode) {
        super.flipPanel(mode)
        let shouldHide = (panel?.chartContentList.count ?? 0) <= 0
        legendEnableButton?.isHidden = shouldHide || (panelMode == .listing)
    }
    
    //MARK: Button Actions
    @IBAction func legendButtonAction(_ sender: UIButton) {
        legendEnableButton?.isSelected = !(legendEnableButton?.isSelected ?? false)
        chart?.scrollableLegend.isEnabled = (legendEnableButton?.isSelected ?? true)
        updatePanelContent()
    }

}
