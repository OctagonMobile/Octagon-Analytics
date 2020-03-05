//
//  PieChartViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts
import LanguageManager_iOS

class PieChartViewController: ChartBaseViewController {

    var pieChartView: PieChartView? {
        return (chart as? PieChartView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        legendEnableButton?.isSelected = true
        pieChartView?.scrollableLegend.isEnabled = true

    }
    
    override func setupChart() {
        super.setupChart()
        pieChartView?.delegate = self

        pieChartView?.transparentCircleRadiusPercent = 0.0
        pieChartView?.holeColor = nil
        pieChartView?.drawEntryLabelsEnabled = false
        pieChartView?.rotationEnabled = false
        
        let isDonut = (panel?.visState as? PieChartVisState)?.isDonut ?? false
        pieChartView?.drawHoleEnabled = isDonut
        if isDonut {
            pieChartView?.holeRadiusPercent = 0.8
        }

    }

    override func updatePanelContent() {
        super.updatePanelContent()
        
        guard let panel = panel else { return }
        
        
        var legendsList: [ScrollableLegendEntry] = []
        var colorIndex = 0
        let pieChartDataEntry: [ChartDataEntry] = panel.buckets.compactMap { (item) -> ChartDataEntry? in
            
            // Values
            let metricTypeValue = panel.metricAggregation?.metricType
            let shouldShowBucketValue = (metricTypeValue == .sum || metricTypeValue == .max || metricTypeValue == .average)
            let value = shouldShowBucketValue ? Double(item.bucketValue.magnitude)  : Double(item.docCount.magnitude)

            let dataEntry = PieChartDataEntry(value: value, label: item.key)
            dataEntry.data = item
            
            // Legend Setup
            if colorIndex >= defaultColors.count { colorIndex = 0 }
            let color = defaultColors[colorIndex]
            colorIndex += 1

            let legend = ScrollableLegendEntry(dataEntry: dataEntry, title: item.key, color: color, titleColor: CurrentTheme.disabledStateBackgroundColor)
            legendsList.append(legend)
            return dataEntry
        }
        
        let dataSet = PieChartDataSet(entries: pieChartDataEntry, label: "")
        dataSet.sliceSpace = 2.0
        dataSet.selectionShift = 8.0
        dataSet.colors = defaultColors
        dataSet.drawValuesEnabled = false
        pieChartView?.data = PieChartData(dataSet: dataSet)
        
        let direction: ScrollableLegend.ChartShiftDirection = LanguageManager.shared.isRightToLeft ? .right : .left
        pieChartView?.scrollableLegend.setWidthPercentage(0.3, direction: direction)
        pieChartView?.animate(xAxisDuration: 1.5, easingOption: .easeOutBack)
        
        
        pieChartView?.scrollableLegendRenderer.legendSelectionAction = { [weak self] (sender, legendEntry, index) in
            self?.pieChartView?.highlightValue(x: Double(index), dataSetIndex: 0, callDelegate: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.pieChartView?.scrollableLegend.updateLegends(legendsList)
        })

    }
}

extension PieChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLog("Chart Value Selected")
        
        guard let chartItem = entry.data as? ChartItem,
            let agg = panel?.bucketAggregation else { return }
      
        var dateComponant: DateComponents?
        if let selectedDates =  panel?.currentSelectedDates,
            let fromDate = selectedDates.0, let toDate = selectedDates.1 {
            dateComponant = fromDate.getDateComponents(toDate)
        }
        let filter = FilterProvider.shared.createFilter(chartItem, dateComponents: dateComponant, agg: agg)
        
        showInfoFieldActionBlock?(self, [filter], nil)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        DLog("Chart Selection cleared")
        chartView.highlightValues(nil)
        deselectFieldAction?(self)
    }
}

