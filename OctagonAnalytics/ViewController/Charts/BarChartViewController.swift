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
    
    internal var totalChartEntries: Int     =   0
    
    var chartContentList: [ChartContent] {
        return panel?.chartContentList ?? []
    }
    
    var bucketsList: [Bucket] = []

    var isGroupedBarChart: Bool {
        let largest = chartContentList.max { $0.items.count < $1.items.count }?.items ?? []
        let isGrouped = (panel?.visState?.seriesMode == .normal) && largest.count > 1
        return isGrouped
    }

    internal var xAxis: Charts.XAxis? {
        return barChartView?.xAxis
    }
    
    internal var leftAxis: Charts.YAxis? {
        return barChartView?.leftAxis
    }

    
    //MARK: Functions
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

        xAxis?.wordWrapEnabled = false
        xAxis?.labelPosition = .bottom;
        xAxis?.labelFont = UIFont.systemFont(ofSize: 10.0)
        xAxis?.drawGridLinesEnabled = false
        xAxis?.labelRotationAngle = 300
        xAxis?.granularityEnabled = true
        xAxis?.labelTextColor = theme.disabledStateBackgroundColor

        // Update X-Axis Value
        let formatter = BarChartFormatter()
        formatter.valueList =  chartContentList
        xAxis?.valueFormatter = formatter
        
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
        
        bucketsList = chartContentList.reduce([]) { (res, item) -> [Bucket] in
            return res + item.items
        }
        listTableView?.reloadData()
        legendLabel.text = panel?.visState?.metricAggregationsArray.first?.metricType.rawValue.capitalized

        xAxis?.centerAxisLabelsEnabled = isGroupedBarChart
        xAxis?.resetCustomAxisMax()
        xAxis?.resetCustomAxisMin()

        refreshChartContent()
    }
    
    internal func refreshChartContent() {
        
        // Re-order chart content if required.(Required for horizontal bar chart to look same as in web)
        reOrderChartContent()
        
        guard let data = generateChartData(chartContentList) as? BarChartData else { return }
        if isGroupedBarChart {
            xAxis?.axisMinimum = initialXValue
            let groupCount = chartContentList.count
            let axisMaxVal = initialXValue + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount)
            xAxis?.axisMaximum = axisMaxVal
            data.groupBars(fromX: initialXValue, groupSpace: groupSpace, barSpace: barSpace)
        }

        // Update X-Axis Value
        let formatter = xAxis?.valueFormatter as? BarChartFormatter
        formatter?.valueList = chartContentList

        chart?.data = data
        chart?.animate(yAxisDuration: 1.5)
    }
    
    internal func reOrderChartContent() {
        // Do nothing
    }
    
    override func flipPanel(_ mode: PanelMode) {
        super.flipPanel(mode)
        
        let shouldHide = (panel?.buckets.count ?? 0) <= 0
        legendHolder.isHidden = shouldHide || (mode == .listing)
    }

    
    
     internal func applyFiltersWith(_ bucket: Bucket, applyImmedietly: Bool = false) {
           
           var dateComponant: DateComponents?
           if let selectedDates =  panel?.currentSelectedDates,
               let fromDate = selectedDates.0, let toDate = selectedDates.1 {
               dateComponant = fromDate.getDateComponents(toDate)
           }

           let filtersToBeApplied: [FilterProtocol] = bucket.getRelatedfilters(dateComponant)

           if applyImmedietly {
               multiFilterAction?(self, filtersToBeApplied)
           } else {
               showInfoFieldActionBlock?(self, filtersToBeApplied, nil)
           }
       }
}

extension BarChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

        var bucket: Bucket
        if isGroupedBarChart {
            guard let buck = entry.data as? Bucket else { return }
            bucket = buck
        } else {
            guard let chartContent = entry.data as? ChartContent,
                highlight.stackIndex < chartContent.items.count else { return }
            
            var itemIndex = highlight.stackIndex
            if itemIndex == -1 {
                itemIndex = 0
            }
            bucket = chartContent.items[itemIndex]
        }

        barChartView?.highlightValues(nil)
        applyFiltersWith(bucket)
    }

    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        DLog("Chart Selection cleared")
        barChartView?.highlightValues(nil)
        deselectFieldAction?(self)
    }
}

extension BarChartViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bucketsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.bucketListCellId) as? BucketListTableViewCell
        cell?.backgroundColor = .clear

        let bucket = bucketsList[indexPath.row]
        var dateComponant: DateComponents?
        if let selectedDates =  panel?.currentSelectedDates,
            let fromDate = selectedDates.0, let toDate = selectedDates.1 {
            dateComponant = fromDate.getDateComponents(toDate)
        }
        
        let filters = bucket.getRelatedfilters(dateComponant).reversed()
        
        let result = filters.reduce("") { (res, filter) -> String in
            var val = ""
            if let fil = (filter as? SimpleFilter) {
                val = fil.fieldValue
            } else if let fil = (filter as? DateHistogramFilter) {
                guard let value = Int(fil.fieldValue) else { return fil.fieldValue }
                let date = Date(milliseconds: value)
                val = date.toFormat("YYYY-MM-dd HH:mm:ss")
            }
            
            return res.isEmpty ? val : (res + " - " + val)
        }
        let title = result
        let value = bucket.displayValue.format(f: "0.2")
        cell?.updateCellContentLatest(title, value: value)
        return cell ?? UITableViewCell()

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bucket = bucketsList[indexPath.row]
        
        var dateComponant: DateComponents?
        if let selectedDates =  panel?.currentSelectedDates,
            let fromDate = selectedDates.0, let toDate = selectedDates.1 {
            dateComponant = fromDate.getDateComponents(toDate)
        }
        
        guard let filter = bucket.getRelatedfilters(dateComponant).first else { return }
        multiFilterAction?(self, [filter])

    }
}

extension BarChartViewController: BarChartDataProvider {
    func panelForChart() -> Panel? {
        return panel
    }
}
