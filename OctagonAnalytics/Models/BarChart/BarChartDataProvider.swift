//
//  BarChartDataProvider.swift
//  OctagonAnalytics
//
//  Created by Rameez on 9/9/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import Charts

protocol BarChartDataProvider {
    var initialXValue: Double { get }
    var groupSpace: Double { get }
    var barSpace: Double { get }
    
    func panelForChart() -> Panel?
    func generateChartData(_ chartContentList: [ChartContent]) -> ChartData?
}

extension BarChartDataProvider {
    
    var initialXValue: Double { return 0 }
    
    var groupSpace: Double { return 0.18 }
    var barSpace: Double { return 0.03 }
    
    func generateChartData(_ chartContentList: [ChartContent]) -> ChartData? {
        
        guard let panel = panelForChart() else { return nil }
        //        let mode = panel.visState?.seriesMode ?? .stacked
        let largest = chartContentList.max { $0.items.count < $1.items.count }?.items ?? []
        let isGrouped = (panel.visState?.seriesMode == .normal) && largest.count > 1
        
        if !isGrouped {
            var barChartDataEntry: [ChartDataEntry] = []
            
            var colorsList: [UIColor]   =   []
            
            var colorIndex = 0
            for (index, itm) in chartContentList.enumerated() {
                
                let yValues = itm.items.compactMap { (buck) -> Double in
                    colorIndex += 1
                    if colorIndex >= CurrentTheme.allChartColors.count {
                        colorIndex = 0
                    }
                    colorsList.append(CurrentTheme.allChartColors[colorIndex])
                    return buck.displayValue
                }
                colorIndex = 0
                
                let entry = BarChartDataEntry(x: Double(index), yValues: yValues, data: itm as AnyObject)
                barChartDataEntry.append(entry)
            }
            
            let dataSet = BarChartDataSet(entries: barChartDataEntry, label: "")
            dataSet.colors = colorsList
            
            dataSet.drawValuesEnabled = false
            return BarChartData(dataSet: dataSet)
        } else {
            
            let largest = chartContentList.max { $0.items.count < $1.items.count }?.items ?? []
            
            let barWidth = ((1.00 - groupSpace) / Double(largest.count)) - barSpace
            
            var colorIndex = 0
            let colors = CurrentTheme.allChartColors
            var dataSetList: [BarChartDataSet] = []
            for i in 0..<largest.count {
                
                let buckets = chartContentList.enumerated().compactMap { (index, chartContent) -> (Bucket?, Int) in
                    let list = chartContent.items
                    guard i < list.count else { return (nil, index) }
                    return (chartContent.items[i], index)
                }
                
                let yVals = buckets.compactMap { (arg0) -> BarChartDataEntry? in
                    
                    let (bucket, index) = arg0
                    let yVal = bucket?.displayValue ?? 0.0
                    return BarChartDataEntry(x: Double(index), y: yVal, data: bucket)
                }
                
                let set = BarChartDataSet(entries: yVals)
                colorIndex = colorIndex < colors.count ? colorIndex : 0
                set.setColor(colors[colorIndex])
                set.drawValuesEnabled = false
                colorIndex += 1
                
                dataSetList.append(set)
            }
            
            let data = BarChartData(dataSets: dataSetList)
            data.setValueFont(.systemFont(ofSize: 10, weight: .light))
            data.setValueFormatter(LargeValueFormatter())
            
            // specify the width each bar should have
            data.barWidth = barWidth
            
            return data
        }
    }
}

//MARK: Line Chart Data Provider
protocol LineChartDataProvider: BarChartDataProvider {
    var isAreaGraph: Bool { get }
}

extension LineChartDataProvider {
    
    var isAreaGraph: Bool { return false }
    
    func generateChartData(_ chartContentList: [ChartContent]) -> ChartData? {
        
        let largest = chartContentList.max { $0.items.count < $1.items.count }?.items ?? []
        
        var colorIndex = 0
        let colors = CurrentTheme.allChartColors
        var dataSetList: [LineChartDataSet] = []
        for i in 0..<largest.count {
            
            let buckets = chartContentList.enumerated().compactMap { (index, chartContent) -> (Bucket?, Int) in
                let list = chartContent.items
                guard i < list.count else { return (nil, index) }
                return (chartContent.items[i], index)
            }
            
            let yVals = buckets.compactMap { (arg0) -> BarChartDataEntry? in
                
                let (bucket, index) = arg0
                let yVal = bucket?.displayValue ?? 0.0
                return BarChartDataEntry(x: Double(index), y: yVal, data: bucket)
            }
            
            let set = LineChartDataSet(entries: yVals)
            colorIndex = colorIndex < colors.count ? colorIndex : 0
            
            set.circleRadius    =   3.0
            set.lineWidth       =   1.0
            set.setColor(colors[colorIndex])
            set.setCircleColor(colors[colorIndex])
            set.drawValuesEnabled = false
            if isAreaGraph {
                set.drawFilledEnabled = true
                set.fillColor = colors[colorIndex]
            }
            colorIndex += 1
            
            dataSetList.append(set)
        }
        
        let data = LineChartData(dataSets: dataSetList)
        data.setValueFont(.systemFont(ofSize: 10, weight: .light))
        data.setValueFormatter(LargeValueFormatter())
        
        return data
    }
}

//MARK: Chart Value Formatters
class LargeValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
    
    /// Suffix to be appended after the values.
    ///
    /// **default**: suffix: ["", "k", "m", "b", "t"]
    public var suffix = ["", "k", "m", "b", "t"]
    
    /// An appendix text to be added at the end of the formatted value.
    public var appendix: String?
    
    public init(appendix: String? = nil) {
        self.appendix = appendix
    }
    
    fileprivate func format(value: Double) -> String {
        var sig = value
        var length = 0
        let maxLength = suffix.count - 1
        
        while sig >= 1000.0 && length < maxLength {
            sig /= 1000.0
            length += 1
        }
        
        var r = String(format: "%2.f", sig) + suffix[length]
        
        if let appendix = appendix {
            r += appendix
        }
        
        return r
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return format(value: value)
    }
    
    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String {
        return format(value: value)
    }
}

class BarChartFormatter: NSObject, IAxisValueFormatter {
    
    var valueList: [ChartContent]  =   []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0 && index < valueList.count else {
            return ""
        }
        
        return valueList[index].displayValue
    }
}
