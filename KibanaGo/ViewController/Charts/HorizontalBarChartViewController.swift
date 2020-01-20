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

    //MARK:
    override func setupLegend() {
        super.setupLegend()
        
        let leftAxis = horizontalBarChartView?.leftAxis
        leftAxis?.enabled = false

        let rightAxis = horizontalBarChartView?.rightAxis
        rightAxis?.enabled = true
        
        let xAxis = horizontalBarChartView?.xAxis
        xAxis?.labelRotationAngle = 360
    }
    
    override func reOrderChartContent() {
        panel?.chartContentList.reverse()
        if isGroupedBarChart {
            panel?.chartContentList.forEach({ $0.items.reverse() })
        }
    }
}
