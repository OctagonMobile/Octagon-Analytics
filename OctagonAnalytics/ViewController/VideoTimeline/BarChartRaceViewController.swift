//
//  BarChartRaceViewController.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/15/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts
import MBProgressHUD

class BarChartRaceViewController: UIViewController {
   
    @IBOutlet weak var chartBaseView: UIView!
    @IBOutlet weak var chartView: HorizontalBarChartView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var inProgress: Bool = false
    private var sortedYValues: [[Double]] = []
    private var sortedData: [VideoContent] = []
    private var maxYValue: Double = 0.0
    private var timer: Timer?
    var barData: [VideoContent] = [] 

    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()
    
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
        leftAxis.axisMaximum = maxYValue + 1.0
        
        let rightAxis = chartView.rightAxis
        rightAxis.axisMinimum = 0
        rightAxis.enabled = false
        rightAxis.axisMaximum = maxYValue + 1.0
        
        let formatter = BarChartRaceFormatter()
        formatter.valueList =  sortedData[0].entries
        chartView.xAxis.valueFormatter = formatter
        
        timer?.invalidate()
        timer = nil
        var yValIndex = 1
        runDataInAnimation(sortedYValues[0])
        setDate(sortedData[0].date)
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if yValIndex >= self.sortedYValues.count {
                timer.invalidate()
                return
            }

            DispatchQueue.main.async {
                self.setDate(self.sortedData[yValIndex].date)
                self.runDataInAnimation(self.sortedYValues[yValIndex])
                yValIndex += 1
            }
        }
        timer?.fire()
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
    
    private func runDataInAnimation(_ vals: [Double]) {
        if self.inProgress {
            return
        }
        
        var i = 0
        let yVals = vals.map { (yVal) -> BarChartDataEntry in
            
            let entry = BarChartDataEntry(x: Double(i), y: yVal)
            i += 1
            return entry
            
        }

        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            self.inProgress = true
            let oldDataSet = set
            // new entries is yVals
            let newDataSet = BarChartDataSet(entries: yVals)
            
            var phase: Double = 0.0
                        
            Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if phase > 1.0 {
                    print("done invalidating timer")
                    self.inProgress = false
                    timer.invalidate()
                    return
                }
                let combinedDataSet = self.chartView.partialResults(setA: oldDataSet,
                                                                       setB: newDataSet,
                                                                       phase: phase)
                combinedDataSet.colors = ChartColorTemplates.material()
                
                let newData = BarChartData(dataSet: combinedDataSet)
                newData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 12)!)
                newData.barWidth = 0.7
                
                self.chartView.data = newData
                self.chartView.notifyDataSetChanged()
                
                phase += 0.01
            }
            
        } else {
            set1 = BarChartDataSet(entries: yVals, label: "")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 12)!)
            data.barWidth = 0.7
            chartView.data = data
        }
    }
    
    deinit {
        timer?.invalidate()
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


extension BarChartView {
    public func partialResults(setA: BarChartDataSet, setB: BarChartDataSet, phase: Double) -> BarChartDataSet {
        let newSet = BarChartDataSet()
        
        for index in 0..<setA.entries.count {
            let currA = setA.entries[index].y
            let currB = setB.entries[index].y
            
            let newValue = (currB - currA) * phase + currA
            newSet.append(BarChartDataEntry(x: Double(index), y: newValue))
        }
        
        return newSet
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
