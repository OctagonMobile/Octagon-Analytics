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

enum DiffFunction {
    case increment
    case decrement
    case none
}

class BarChartRaceViewController: UIViewController {
   
    @IBOutlet weak var chartBaseView: UIView!
    @IBOutlet weak var chartView: HorizontalBarChartView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var inProgress: Bool = false
    private var sortedYValues: [[Double]] = []
    private var sortedData: [VideoContent] = []
   
    private var maxYValue: Double = 0.0
    private var timer: Timer?
    private var diffFunctions: [DiffFunction] = []
    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()
    
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
        xAxis.granularity = 1
        xAxis.labelRotationAngle = 360
        xAxis.spaceMax = 0.15
        xAxis.spaceMin = 0.15
        xAxis.axisMinimum = -0.5;
                
        let l = chartView.legend
        l.enabled = false
        
        chartView.fitBars = true
    }
    
    func updateChart() {
        if let labelCount = sortedData.first?.entries.count {
            chartView.xAxis.labelCount = labelCount
        }
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
                        
            Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if phase > 1.0 {
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
        let targetData = BarChartData(dataSet: targetDatSet)
        
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            let pointsPerTime = calculatePointsPerTime(targetData)
            var previousSet = set
            Timer.scheduledTimer(withTimeInterval: 0.00000001, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                var shouldInvalidate = true
                for index in 0..<previousSet.entries.count {
                    let previousVal = previousSet.entries[index].y
                    let targetVal = vals[index]
                    if previousVal != targetVal {
                        shouldInvalidate = false
                        break
                    }
                }
                if shouldInvalidate {
                    timer.invalidate()
                    if currentIndex < (self.sortedYValues.count - 1) {
                        let nextIndex = currentIndex + 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.applyDiffFunction(targetDatSet, nextIndex: nextIndex)
                            self.drawData(self.sortedYValues[nextIndex],
                                          currentIndex: nextIndex)
                        }
                    }
                    return
                }
                
                let newDataSet = BarChartDataSet()
                for index in 0..<previousSet.entries.count {
                    let prevY = previousSet.entries[index].y
                    let diffFn = self.diffFunctions[index]
                    let targetVal = vals[index]
                    var newY = prevY
                    let diffPoints = pointsPerTime[index]

                    switch diffFn {
                    case .increment:
                        newY += diffPoints
                        if newY > targetVal {
                            newY = targetVal
                            self.diffFunctions[index] = .none
                        }
                    case .decrement:
                        newY -= diffPoints
                        if newY < targetVal {
                            newY = targetVal
                            self.diffFunctions[index] = .none
                        }
                    default:
                        newY = targetVal
                    }
                    
                    newDataSet.append(BarChartDataEntry(x: Double(index), y: newY))
                }
                newDataSet.colors = previousSet.colors
                let newData = BarChartData(dataSet: newDataSet)
                newData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 12)!)
                newData.barWidth = 0.7
                
                self.chartView.data = newData
                self.chartView.notifyDataSetChanged()
                previousSet = newDataSet
            }
            
        } else {
            targetDatSet.colors = ChartColorTemplates.material()
            targetDatSet.drawValuesEnabled = true
            
            let data = BarChartData(dataSet: targetDatSet)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 12)!)
            data.barWidth = 0.7
            chartView.data = data
           
            if currentIndex < (sortedYValues.count - 1) {
                let nextIndex = currentIndex + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.applyDiffFunction(targetDatSet, nextIndex: nextIndex)
                    self.drawData(self.sortedYValues[nextIndex],
                                  currentIndex: nextIndex)
                }
            }
        }
        
        
    }
    
    private func applyDiffFunction(_ currentDataSet: BarChartDataSet,  nextIndex: Int) {
        diffFunctions = emptyDiffFns
        let vals = sortedYValues[nextIndex]
        for index in 0..<currentDataSet.entries.count {
            let targetVal = vals[index]
            let currentVal = currentDataSet.entries[index].y
            if currentVal < targetVal {
                diffFunctions[index] = .increment
            } else if currentVal > targetVal {
                diffFunctions[index] = .decrement
            }
        }
    }
    
    private func calculatePointsPerTime(_ newData: BarChartData) -> [Double] {
        guard let currentData = chartView.data as? BarChartData,
            let oldSet = currentData.dataSets.first as? BarChartDataSet,
        let newSet = newData.dataSets.first as? BarChartDataSet else {
            return []
        }
       
        var currentRects = emptyRects
        var newRects = emptyRects
        calculateRects(data: currentData, rects: &currentRects)
        calculateRects(data: newData, rects: &newRects)
        var diffRects = [CGRect]()
        for index in 0 ..< newRects.count {
            var rect = currentRects[index]
            let width = abs(rect.size.width - newRects[index].size.width)
            rect.size.width = width
            diffRects.append(rect)
        }
        
        var pointsPerTime = [Double]()
        for index in 0 ..< diffRects.count {
            let currA = oldSet.entries[index].y
            let currB = newSet.entries[index].y
            let newValue = abs(currB - currA)
            let pointsPerPixel = newValue / Double(diffRects[index].width)
            pointsPerTime.append(pointsPerPixel)
        }
        return pointsPerTime
    }
    
    private var emptyRects: [CGRect] {
       return sortedYValues[0].map { _ in
            return CGRect()
        }
    }
    
    private var emptyDiffFns: [DiffFunction] {
       return sortedYValues[0].map { _ in
            return .none
        }
    }
    
    private func calculateRects(data: BarChartData, rects: inout [CGRect]) {
        guard let set = data.dataSets.first as? BarChartDataSet else {
            return
        }
        prepareBuffer(data: data, dataSet: set, rects: &rects)
        chartView.getTransformer(forAxis: .left).rectValuesToPixel(&rects)
    }
    
    private func prepareBuffer(data: BarChartData,
                               dataSet: IBarChartDataSet,
                               rects: inout [CGRect])
    {
        let barData = data
        
        let barWidthHalf = barData.barWidth / 2.0
        let isInverted = chartView.leftAxis.isInverted
        var bufferIndex = 0
        
        var barRect = CGRect()
        var x: Double
        var y: Double
        
        for i in stride(from: 0, to: dataSet.entryCount, by: 1)
        {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            
            
            x = e.x
            y = e.y
            
            
            let bottom = CGFloat(x - barWidthHalf)
            let top = CGFloat(x + barWidthHalf)
            let right = isInverted
                ? (y <= 0.0 ? CGFloat(y) : 0)
                : (y >= 0.0 ? CGFloat(y) : 0)
            let left = isInverted
                ? (y >= 0.0 ? CGFloat(y) : 0)
                : (y <= 0.0 ? CGFloat(y) : 0)
            
            barRect.origin.x = left
            barRect.size.width = right - left
            barRect.origin.y = top
            barRect.size.height = bottom - top
            
            rects[bufferIndex] = barRect
            bufferIndex += 1
            
        }
    }
}

private class Buffer
{
    var rects = [CGRect]()
}
