//
//  BarChartViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts

class BarChartViewController: ChartBaseViewController {

    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var legendLabel: UILabel!
    @IBOutlet weak var legendHolder: UIView!
    
    var barChartView: BarChartView? {
        return (chart as? BarChartView)
    }
    
    internal var buckets: [ChartItem] {
        return panel?.buckets ?? []
    }
    
    internal var totalChartEntries: Int     =   0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listTableView?.delegate = self
        
        if CurrentTheme == .dark {
            // For dark theme use the different color for bars
            defaultColors.insert(UIColor.ChartColorsDarkSet1.sixth, at: 0)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setupLegend() {
        super.setupLegend()
        
        let theme = CurrentTheme
        legendView.style(.roundCorner(5.0, 0.0))
        legendLabel.style(theme.bodyTextStyle(theme.disabledStateBackgroundColor))
        
        chart?.extraBottomOffset = 3
        let xAxis = barChartView?.xAxis
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
        
        let leftAxis = barChartView?.leftAxis
        leftAxis?.labelFont = UIFont.systemFont(ofSize: 10.0)
        leftAxis?.labelCount = 4
        leftAxis?.labelPosition = .outsideChart
        leftAxis?.spaceTop = 0.15
        leftAxis?.axisMinimum = 0.0; // this replaces startAtZero = YES
        leftAxis?.gridColor = theme.separatorColor
        leftAxis?.labelTextColor = theme.disabledStateBackgroundColor
        let rightAxis = barChartView?.rightAxis
        rightAxis?.enabled = false
        
    }
    

    override func setupChart() {
        super.setupChart()
        barChartView?.delegate = self
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()

        guard let panel = panel else { return }
        
        // Update X-Axis Value
        let formatter = barChartView?.xAxis.valueFormatter as? BarChartFormatter
        formatter?.valueList = buckets

        let barChartDataEntry: [ChartDataEntry] = buckets.enumerated().map( {
            let metricTypeValue = panel.metricAggregation?.metricType
            let shouldShowBucketValue = (metricTypeValue == .sum || metricTypeValue == .max || metricTypeValue == .average)
              let value = shouldShowBucketValue ? Double($1.bucketValue.magnitude)  : Double($1.docCount.magnitude)
            return BarChartDataEntry(x: Double($0), y: value, data: $1)
        } )
        
        totalChartEntries = barChartDataEntry.count
        
        let legendText = panel.metricAggregation?.metricType.rawValue
        let dataSet = BarChartDataSet(entries: barChartDataEntry, label: legendText)
        dataSet.colors = [defaultColors.first ?? UIColor.gray]
        dataSet.drawValuesEnabled = false
        chart?.data = BarChartData(dataSet: dataSet)
        
        legendView.backgroundColor = defaultColors.first ?? UIColor.white
        legendLabel.text = legendText
        
        chart?.animate(yAxisDuration: 1.5)
    }

    override func flipPanel(_ mode: PanelMode) {
        super.flipPanel(mode)
        
        let shouldHide = (panel?.buckets.count ?? 0) <= 0
        legendHolder.isHidden = shouldHide || (mode == .listing)
    }

    
    internal func applyFiltersWith(_ bucket: ChartItem, applyImmedietly: Bool = false) {
      
        guard let agg = panel?.bucketAggregation else { return }

        var dateComponant: DateComponents?
        if let selectedDates =  panel?.currentSelectedDates,
            let fromDate = selectedDates.0, let toDate = selectedDates.1 {
            dateComponant = fromDate.getDateComponents(toDate)
        }

//        let filtersToBeApplied: [FilterProtocol] = bucket.getRelatedfilters(dateComponant)
        let filter: FilterProtocol = FilterProvider.shared.createFilter(bucket, dateComponents: dateComponant, agg: agg)

        if applyImmedietly {
            filterAction?(self, filter)
        } else {
            showInfoFieldActionBlock?(self, [filter], nil)
        }
    }
}

extension BarChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLog("Chart Value Selected")
        guard let chartItem = entry.data as? ChartItem else { return }
        applyFiltersWith(chartItem)
    }

    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        DLog("Chart Selection cleared")
        barChartView?.highlightValues(nil)
        deselectFieldAction?(self)
    }
}

extension BarChartViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let chartItem = panel?.buckets[indexPath.row] else { return }
        applyFiltersWith(chartItem, applyImmedietly: true)
    }
}

class BarChartFormatter: NSObject, IAxisValueFormatter {
    
    var valueList: [ChartItem]  =   []
    var bucketType: BucketType  =   .unKnown
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0 && index < valueList.count else {
            return "NA"
        }
        
        let selectedItem = valueList[index]
        if bucketType == .terms {
            let termsDate = (selectedItem as? TermsChartItem)?.termsDateString ?? ""
            return termsDate.isEmpty ? selectedItem.key : termsDate
        } else if bucketType == .dateHistogram {
            let termsDate = (selectedItem as? DateHistogramChartItem)?.termsDateString ?? ""
            return termsDate.isEmpty ? selectedItem.key : termsDate
        } else if let keyValue = Double(valueList[index].key) {
            return String(format: "%.3f", keyValue)
        }
        return valueList[index].key
    }
}

