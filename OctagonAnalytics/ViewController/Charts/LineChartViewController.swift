//
//  LineChartViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts

class LineChartViewController: BarChartViewController, LineChartDataProvider {

    var lineChartView: LineChartView? {
        return (chart as? LineChartView)
    }
    
    var isAreaGraph: Bool {
        panel?.visState?.type == PanelType.area
    }
    
    override internal var xAxis: Charts.XAxis? {
        return lineChartView?.xAxis
    }
    
    override internal var leftAxis: Charts.YAxis? {
        return lineChartView?.leftAxis
    }

    //MARK: Functions
    override func setupChart() {
        super.setupChart()
        lineChartView?.delegate = self
    }

    override func setupLegend() {
        super.setupLegend()
        lineChartView?.rightAxis.enabled = false
    }
    
    internal override func refreshChartContent() {
        
        guard let data = generateChartData(chartContentList) else { return }
        // Update X-Axis Value
        let formatter = xAxis?.valueFormatter as? BarChartFormatter
        formatter?.valueList = chartContentList
        
        chart?.data = data
        chart?.animate(yAxisDuration: 1.5)
    }
}

extension LineChartViewController {
    override func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

        guard let bucket = entry.data as? Bucket else { return }
        lineChartView?.highlightValues(nil)
        applyFiltersWith(bucket)
    }


    override func chartValueNothingSelected(_ chartView: ChartViewBase) {

        lineChartView?.highlightValues(nil)
        deselectFieldAction?(self)
    }
}
