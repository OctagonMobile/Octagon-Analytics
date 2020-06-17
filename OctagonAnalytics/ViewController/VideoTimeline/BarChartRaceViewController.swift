//
//  BarChartRaceViewController.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/15/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts

enum DiffFunction {
    case increment
    case decrement
    case none
}

class BarChartRaceViewController: UIViewController {
   
    @IBOutlet weak var chartBaseView: UIView!
    @IBOutlet weak var chartView: HorizontalBarChartView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var sortedYValues: [[Double]] = []
    private var sortedData: [VideoContent] = []
   
    private var maxYValue: Double = 0.0
    var barData: [VideoContent] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChartView()
        let result = sort(barData)
        sortedData = result.0
        sortedYValues = result.1
        updateChart()
        
    }
    
    private func setupChartView() {
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        
        chartView.delegate = self
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.maxVisibleCount = 60
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = true
        xAxis.labelRotationAngle = 360
        xAxis.spaceMax = 0.15
        xAxis.spaceMin = 0.15
        xAxis.axisMinimum = -0.5;
                
        let l = chartView.legend
        l.enabled = false
        
        chartView.fitBars = true
    }
    
    func updateChart() {
        
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.enabled = false
        leftAxis.axisMaximum = maxYValue + (maxYValue/10)
        
        let rightAxis = chartView.rightAxis
        rightAxis.axisMinimum = 0
        rightAxis.enabled = true
        rightAxis.axisMaximum = maxYValue + (maxYValue/10)
        
        let formatter = BarChartRaceFormatter()
        formatter.valueList =  sortedData[0].entries
        chartView.xAxis.valueFormatter = formatter

        drawData(sortedYValues[0], currentIndex: 0)
        
    }
    
    func setDate(_ date: Date?) {
        guard let date = date else {
            dateLabel.text = "Date:"
            return
        }
        dateLabel.text = "Date: \(date.stringValue)"
    }
    
    private func sort(_ data: [VideoContent]) -> ([VideoContent], [[Double]]) {
        var vals: [[Double]] = []
        let sorted = data.sorted { (content1, content2) -> Bool in
            if let date1 = content1.date, let date2 = content2.date {
                return date1.compare(date2) == .orderedAscending
            } else {
                return false
            }
        }
        for content in sorted {
            let sortedYVals: [Double] = content.entries.map {
                let val = Double($0.value)
                if maxYValue < val {
                    maxYValue = val
                }
                return val
            }.sorted()
            vals.append(sortedYVals)
        }
        return (sorted, vals)
    }
    
    deinit {
        sortedData.removeAll()
        barData.removeAll()
    
    }
}

extension BarChartRaceViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}

class BarChartRaceFormatter: NSObject, IAxisValueFormatter {
    
    var valueList: [VideoEntry]  =   []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0 && index < valueList.count else {
            return ""
        }
        
        return valueList[index].title
    }
}


extension BarChartRaceViewController {
    
    private func drawData(_ vals: [Double],
                          currentIndex: Int) {
        
                setDate(sortedData[currentIndex].date)
        
        var i = 0
        let yVals = vals.map { (yVal) -> BarChartDataEntry in
            
            let entry = BarChartDataEntry(x: Double(i), y: yVal)
            i += 1
            return entry
            
        }
        let targetDatSet = BarChartDataSet(entries: yVals)
        targetDatSet.colors = ChartColorTemplates.material()
        targetDatSet.drawValuesEnabled = true
        
        let data = BarChartData(dataSet: targetDatSet)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 12)!)
        data.barWidth = 0.7
        chartView.updatedData = data
        chartView.animate(yAxisDuration: 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if currentIndex < (self.sortedYValues.count - 1) {
                self.drawData(self.sortedYValues[currentIndex + 1], currentIndex: currentIndex + 1)
            }
        }
    }
}
