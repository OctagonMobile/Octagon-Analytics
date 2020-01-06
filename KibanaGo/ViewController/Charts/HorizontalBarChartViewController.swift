//
//  HorizontalBarChartViewController.swift
//  KibanaGo
//
//  Created by Rameez on 2/28/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts

class HorizontalBarChartViewController: BarChartViewController {

    var horizontalBarChartView: HorizontalBarChartView? {
        return (chart as? HorizontalBarChartView)
    }

    override var buckets: [ChartItem] {
        //Note: Array is reversed to draw the horizontal bars from top to bottom
        return panel?.buckets.reversed() ?? []
    }
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func setupLegend() {
        super.setupLegend()
        
        let leftAxis = horizontalBarChartView?.leftAxis
        leftAxis?.enabled = false

        let rightAxis = horizontalBarChartView?.rightAxis
        rightAxis?.enabled = true
        
        let xAxis = horizontalBarChartView?.xAxis
        xAxis?.labelRotationAngle = 360
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        
        horizontalBarChartView?.xAxis.labelCount = totalChartEntries

    }
}
