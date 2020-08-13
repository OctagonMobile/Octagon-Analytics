//
//  Panel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService
import Alamofire
import SwiftDate

// MARK: Panel
class Panel {

    /**
     Panel Id.
     */
    fileprivate var id                              = ""
    
    /**
     Panel Index.
     */
    fileprivate var panelIndex                           = 0
    
    /**
     Row number of Panel.
     */
    var row                             = 0
    
    /**
     Column number of Panel.
     */
    var column                          = 0
    
    /**
     Width of Panel.
     */
    var width                           = 0
    
    /**
     Height of Panel.
     */
    var height                          = 0
    
    /**
     Visualization State. (Contains Title, Type & other Info)
     */
    var visState: VisState?
    
    /**
     Dashboard Item to which the panel belongs to
     */
    var dashboardItem: DashboardItem?
    
    /**
     Search query string.
     */
    var searchQuery                     = ""
    
    /**
     List of chart items.
     */

    var chartContentList: [ChartContent] = []
    
    /**
     Parsed Agg Result, Used only for Pie Chart - Multilayer
     */
    var parsedAgg: AggResult?
    
    /**
     Bucket Type of the panel.
     */
    var bucketType: BucketType {
        return visState?.aggregationsArray.filter( {$0.id == AggregationId.bucket.rawValue }).first?.bucketType ?? .unKnown
    }
    
    /**
     Bucket Aggregation.
     */
    var bucketAggregation: Aggregation? {
        return visState?.aggregationsArray.filter( {$0.id == AggregationId.bucket.rawValue }).first
    }
        
    //Sub Buckets Support, All Headers are put into an array
    var tableHeaders: [String] = []

    /**
     Currently selected dates (From & To), which are shown on top of the dashboard.
     */
    var currentSelectedDates: (Date?, Date?)? {
        guard let fromTime = dashboardItem?.fromTime, let totime = dashboardItem?.toTime else { return nil }
        var from = dashboardItem?.fromTime.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        var to = dashboardItem?.toTime.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        if from == nil, to == nil, dashboardItem?.datePickerMode == DatePickerMode.quickPicker {
            let mappedValue = DatePickerMapper.shared.mappedPickerValueWith(fromTime, toDate: totime)
            from = mappedValue.1?.selectedDate().fromDate
            to = mappedValue.1?.selectedDate().toDate
        }
        return (from, to)
    }
    
    // Counter used to parse data only
    fileprivate var counter: Int = 0
    
    //MARK: Functions    
    init(_ responseModel: PanelService) {
        self.id     =   responseModel.id ?? ""
        self.panelIndex =   Int(responseModel.panelIndex) ?? 0
        self.row        =   responseModel.row
        self.column     =   responseModel.column
        self.width      =   responseModel.width
        self.height     =   responseModel.height
        self.searchQuery    =   responseModel.searchQuery
        
        guard let responseVisState = responseModel.visState else { return }
        switch responseModel.visState?.type {
        case .pieChart:
            visState    =   PieChartVisState(responseVisState)
        
        case .tagCloud, .t4pTagcloud:
            visState = TagCloudVisState(responseVisState)
            
        case .tile:
            visState = TileVisState(responseVisState)
            
        case .metric:
            visState = MetricVisState(responseVisState)
            
        case .heatMap, .mapTracking:
            visState = MapVisState(responseVisState)
            
        case .neo4jGraph:
            visState = GraphVisState(responseVisState)
            
        case .html:
            visState = WebContentVisState(responseVisState)
            
        case .markdown:
            visState = MarkDownVisState(responseVisState)
            
        case .gauge, .goal:
            visState = GaugeVisState(responseVisState)
            
        case .inputControls:
            visState = InputControlsVisState(responseVisState)

        default:
            visState    =   VisState(responseVisState)
        }
    }
    
    /**
     Loads chart data list.
     
     - parameter completion: Call back once the server returns the response.
     */
    func loadChartData(_ completion: CompletionBlock?) {
        // Load ChartData using id

        guard let indexPatternId = visState?.indexPatternId else { return }
        let reqParameters = VizDataParams(indexPatternId)
        reqParameters.panelType = visState?.type ?? .unKnown
        reqParameters.timeFrom = dashboardItem?.fromTime
        reqParameters.timeTo = dashboardItem?.toTime
        
        if let filtersList = dataParams()?[FilterConstants.filters] as? [[String: Any]] {
            reqParameters.filters = filtersList
        }
        
        reqParameters.aggregationsArray = visState?.serviceAggregationsList ?? []
        
        ServiceProvider.shared.loadVisualizationData(reqParameters) { [weak self] (result, error) in
            
            guard error == nil else {
                self?.resetDataSource()
                completion?(nil, error?.asNSError)
                return
            }
            
            guard let res = result as? [AnyHashable: Any?], let finalResult = res["responses"], let parsedData = self?.parseData(finalResult) else {
                self?.resetDataSource()
                completion?(nil, error?.asNSError)
                return
            }
            completion?(parsedData, error?.asNSError)
        }
    }
    
    /**
     Clear data here in case of error
     */
    internal func resetDataSource() {
//        buckets.removeAll()
    }
    
    /**
     Parameters for the request to load data.
     
     - returns:  Parameters dictionary
     */
    internal func dataParams() -> [String: Any]? {
        var filtersDict: [String: Any] = [:]
        filtersDict[FilterConstants.id] = id
        
        var filtersArray:[[String: Any]?]  = []
        
        for appliedFilter in Session.shared.appliedFilters {
            filtersArray.append(appliedFilter.dataParams)
        }
                
        if filtersArray.count > 0 {
            filtersDict[FilterConstants.filters] = filtersArray
        }

        filtersDict[FilterConstants.timeFrom] = dashboardItem?.fromTime
        filtersDict[FilterConstants.timeTo] = dashboardItem?.toTime

        filtersDict[PanelConstant.searchQuery] = searchQuery
        filtersDict[PanelConstant.searchQueryDashboard] = dashboardItem?.searchQuery
        
        // In case of date histogram send the interval
        if bucketType == .dateHistogram, let interval = mappedIntervalValue {
            filtersDict[FilterConstants.interval] = "\(interval)"
        }

        return filtersDict
    }
    
    //MARK: Private Methods
    /**
     Parse the data into Model object.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Buckets/ Chart Items object
     */
    internal func parseData(_ result: Any?) -> [Any] {
        // Parse here and update/create chart item
//        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let aggregationsDict = responseJson.first?[PanelConstant.aggregations] as? [String: Any] else {
                return []
        }
        
        parseBuckets(aggregationsDict)
        
        
        // Parse table headers for Tables
        if visState?.type == .table , let headersArray = responseJson.first?[PanelConstant.tableHeaders] as? [[String: Any]] {
            //Sub Buckets Support
            var headers = [String]()
            for headerDict in headersArray {
                if let header = headerDict[PanelConstant.label] as? String {
                    headers.append(header)
                }
            }
            if headers.count > 1 {
                let metric = headers.remove(at: 0)
                headers.append(metric)
            }
            tableHeaders = headers
        }
        
        return chartContentList
    }
    
    
    func parseBuckets(_ aggregationsDict: [String: Any])  {
        
        guard let visState = visState,
            let id = visState.otherAggregationsArray.first?.id else { return }

        
        guard let contentDict = aggregationsDict[id] as? [String: Any] else { return }
        let parsedData = AggResult(contentDict, visState: visState, idx: 0, parentBucket: nil)
        parsedAgg = parsedData
        chartContentList = parsedDataForChart(parsedData)
    }
    
}

extension Panel {
    //MARK: Date Histogram Filtering methods
    private var mappedIntervalValue: String? {
        guard let interval = bucketAggregation?.params?.interval else { return nil }
        switch interval {
        case .unKnown:  return nil
        case .custom:   return bucketAggregation?.params?.customInterval
        case .auto:     return intervalForAuto()
        default:        return "1\(interval.rawValue)"
        }
    }
    
    private func intervalForAuto() -> String? {
        
        guard let selectedDates = currentSelectedDates,
        let fromDate = selectedDates.0, let toDate = selectedDates.1  else { return nil }

        let dateComponant = fromDate.getDateComponents(toDate)
        
        // Rules for 'Auto' Date calculation
        let year = dateComponant?.year
        let month = dateComponant?.month
        let week = dateComponant?.weekOfMonth
        let days = dateComponant?.day
        let hour = dateComponant?.hour
        let minutes = dateComponant?.minute
        let seconds = dateComponant?.second
        
        var value = "1"
        if let year = year, year > 1 {
            return value + AggregationParamsService.IntervalType.yearly.rawValue
        }
        
        if let year = year, let month = month,
            year == 1 || month > 1 {
            return value + AggregationParamsService.IntervalType.monthly.rawValue
        }
        
        if let month = month,
            month <= 6 && month >= 1 {
            return value + AggregationParamsService.IntervalType.weekly.rawValue
        }
        
        if let week = week,
            week <= 5 && week >= 1 {
            return value + AggregationParamsService.IntervalType.daily.rawValue
        }
        
        if let days = days,
            days <= 7 && days >= 1 {
            value = "12"
            return value + AggregationParamsService.IntervalType.hourly.rawValue
        }
        
        if let hour = hour,
            hour <= 24 && hour > 1 {
            return value + AggregationParamsService.IntervalType.hourly.rawValue
        }
        
        if let hour = hour, let minutes = minutes,
            hour == 1 || (hour < 1 && minutes >= 10) {
            value = "5"
            return value + AggregationParamsService.IntervalType.minute.rawValue
        }
        
        if let minutes = minutes,
            minutes <= 10 && minutes > 0 {
            value = "10"
            return value + AggregationParamsService.IntervalType.second.rawValue
        }

        var millisecondsToAdd = 200
        if let seconds = seconds, seconds <= 0 {
            millisecondsToAdd   =   10
        }

        return "\(millisecondsToAdd)" + AggregationParamsService.IntervalType.millisecond.rawValue
    }
}

extension Panel {
    struct UrlComponents {
        static let visualizationData = "visualization-data"
    }
}



//MARK: Under development

extension Panel {
    // Logic to parse the kibana response
    internal func parsedDataForChart(_ aggs: AggResult) -> [ChartContent] {
        
        let aggregationsCount = (visState?.otherAggregationsArray.count ?? 0)
        let segmentAggs = visState?.segmentSchemeAggregation
        var dataList: [ChartContent] = []
        
        for bucket1 in aggs.buckets {
            
            let data = ChartContent()
            data.key = bucket1.key
            data.bucketType = segmentAggs?.bucketType ?? .unKnown
            data.bucketValue = bucket1.bucketValue
            data.docCount = bucket1.docCount
            data.metricValue = bucket1.metricValue
            data.metricType = visState?.metricAggregationsArray.first?.metricType ?? .unKnown
            
            var items: [Bucket] = []
            
            switch aggregationsCount {
            case 1:
                items = [bucket1]
                break
            case 2:
                items = bucket1.subAggsResult?.buckets.sorted(by: { $0.key < $1.key }) ?? []
                break
            default:
                counter = aggregationsCount - 1
                let list = loopThroughAllBuckets(bucket1, maxLoop: counter)
                items = list
                break
            }
            
            data.items = items
            dataList.append(data)
            
        }
        
        return dataList
    }
    
    private func loopThroughAllBuckets(_ bucket: Bucket, maxLoop: Int) -> [Bucket] {
        
        guard let aggResult = bucket.subAggsResult else { return [] }
        var bucketList = aggResult.buckets
        bucketList.sort(by: { $0.key < $1.key })
        var finalResult: [Bucket] = []
        
        for (index,b1) in bucketList.enumerated() {
            
            guard counter == 2 else {
                counter -= 1
                let list = loopThroughAllBuckets(b1, maxLoop: maxLoop)
                finalResult.append(contentsOf: list)
                continue
            }
            
            let lastBucketsList = b1.subAggsResult?.buckets.sorted(by: { $0.key < $1.key }) ?? []
            
            finalResult.append(contentsOf: lastBucketsList)
            
            if index == bucketList.count - 1 {
                counter = maxLoop
            }
        }
        
        return finalResult
    }

}
