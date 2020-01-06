//
//  LineChartViewController.swift
//  KibanaGo
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts

class LineChartViewController: ChartBaseViewController {

    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var legendLabel: UILabel!
    @IBOutlet weak var legendHolder: UIView!

    var lineChartView: LineChartView? {
        return (chart as? LineChartView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if CurrentTheme == .dark {
            // For dark theme use the different color for bars
            defaultColors.insert(UIColor.ChartColorsDarkSet1.sixth, at: 0)
        }
    }
    
    override func setupChart() {
        super.setupChart()
        lineChartView?.delegate = self
    }

    override func setupLegend() {
        super.setupLegend()
        
        let theme = CurrentTheme
        legendView.style(.roundCorner(5.0, 0.0))
        legendLabel.style(theme.bodyTextStyle(theme.disabledStateBackgroundColor))
        
        chart?.extraBottomOffset = 3
        let xAxis = lineChartView?.xAxis
        xAxis?.wordWrapEnabled = false
        xAxis?.labelPosition = .bottom;
        xAxis?.labelFont = UIFont.systemFont(ofSize: 10.0)
        xAxis?.drawGridLinesEnabled = false
        xAxis?.labelRotationAngle = 300
        xAxis?.granularityEnabled = true
        xAxis?.labelTextColor = theme.disabledStateBackgroundColor
        
        // Update X-Axis Value
        let formatter = BarChartFormatter()
        formatter.bucketType = panel?.bucketType ?? .unKnown
        formatter.valueList = panel?.buckets ?? [] //.flatMap( {$0.key} ) ?? []
        xAxis?.valueFormatter = formatter
        
        let leftAxis = lineChartView?.leftAxis
        leftAxis?.labelFont = UIFont.systemFont(ofSize: 10.0)
        leftAxis?.labelCount = 4
        leftAxis?.labelPosition = .outsideChart
        leftAxis?.spaceTop = 0.15
        leftAxis?.axisMinimum = 0.0; // this replaces startAtZero = YES
        leftAxis?.gridColor = theme.separatorColor
        leftAxis?.labelTextColor = theme.disabledStateBackgroundColor
        let rightAxis = lineChartView?.rightAxis
        rightAxis?.enabled = false
        
    }
    override func updatePanelContent() {
        super.updatePanelContent()
        
        guard let panel = panel else { return }
        
        let formatter = lineChartView?.xAxis.valueFormatter as? BarChartFormatter
        formatter?.valueList = panel.buckets

        let buckets = panel.buckets

        let lineChartDataEntry: [ChartDataEntry] = buckets.enumerated().map( {
            let metricTypeValue = panel.metricAggregation?.metricType
            let shouldShowBucketValue = (metricTypeValue == .sum || metricTypeValue == .max || metricTypeValue == .average)
            let value = shouldShowBucketValue ? Double($1.bucketValue.magnitude)  : Double($1.docCount.magnitude)
            return ChartDataEntry(x: Double($0), y: value, data: $1)
            
        } )
        
        let legendText = panel.metricAggregation?.metricType.rawValue
        let dataSet = LineChartDataSet(entries: lineChartDataEntry, label: legendText)
        dataSet.colors = [defaultColors.first ?? UIColor.gray]
        dataSet.drawValuesEnabled = false
        dataSet.circleColors    =   [defaultColors.first ?? UIColor.white]
        dataSet.circleRadius    =   2.0
        dataSet.lineWidth       =   1.0
        
        dataSet.drawFilledEnabled = panel.visState?.type == PanelType.area

        chart?.data = LineChartData(dataSet: dataSet)
        
        legendView.backgroundColor = defaultColors.first ?? UIColor.white
        legendLabel.text = legendText
        
        chart?.animate(yAxisDuration: 1.5)

    }
    
    override func flipPanel(_ mode: PanelMode) {
        super.flipPanel(mode)
        
        let shouldHide = (panel?.buckets.count ?? 0) <= 0
        legendHolder.isHidden = shouldHide || (mode == .listing)
    }
}

extension LineChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLog("Chart Value Selected")
        guard let chartItem = entry.data as? ChartItem, let fieldName = panel?.bucketAggregation?.field, let type = panel?.bucketType else { return }
        let metricType = panel?.metricAggregation?.metricType ?? .unKnown
        let selectedFilter = Filter(fieldName: fieldName, fieldValue: chartItem, type: type, metricType: metricType)
        if !Session.shared.containsFilter(selectedFilter) {
            selectFieldAction?(self, selectedFilter, nil)
        }
    }
    
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        DLog("Chart Selection cleared")
        lineChartView?.highlightValues(nil)
        deselectFieldAction?(self)
    }
}
