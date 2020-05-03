//
//  Panel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import SwiftDate

// MARK: PanelType
enum PanelType: String {
    case unKnown    =   "unKnown"
    case pieChart   =   "pie"
    case histogram  =   "histogram"
    case tagCloud   =   "tagcloud"
    case t4pTagcloud   =   "t4p-tagcloud"
    case table      =   "table"
    case search     =   "search"
    case metric     =   "metric"
    case tile       =   "t4p-tile"
    case heatMap    =   "tile_map"
    case mapTracking    =   "t4p-map"
    case vectorMap      =   "vectormap"
    case regionMap      =   "region_map"
    case faceTile       =   "t4p-face"
    case neo4jGraph     =   "t4p-neo4j-graph-graph"
    case html           =   "html"
    case line           =   "line"
    case horizontalBar  =   "horizontal_bar"
    case markdown       =   "markdown"
    case area           =   "area"
    case gauge          =   "gauge"
    case goal           =   "goal"
}

// MARK: Panel
class Panel: Mappable {

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
     Index (Note : Currently note used).
     */
    var index: String                   = ""
    
    /**
     List of chart items.
     */

    var chartContentList: [ChartContent] = []
    
    var parsedAggResult: AggResult?
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
    
    /**
     Metric Aggregation.
     */
    var metricAggregation: Aggregation? {
        return visState?.aggregationsArray.filter( {$0.id == AggregationId.metric.rawValue }).first
    }

    // The followig headers used only for Tables (Need better appraoch to handle it)
    var tableHeaderLeft: String? = ""
    
    var tableHeaderRight: String? = ""
    
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
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        panelIndex  <- map["panelIndex"]
        row         <- map["row"]
        column      <- map["col"]
        width       <- map["size_x"]
        height      <- map["size_y"]
        index       <- map["searchSourceJSON.index"]
        searchQuery <- map["searchQueryPanel"]

        // Manual mapping based on visualization type
        if let visStateJson = (map.JSON["visState"] as? [String: Any]) {
            
            guard let type = visStateJson["type"] as? String,
                let panelType = PanelType(rawValue: type) else {
                visState <- map["visState"]
                return
            }
            
            switch panelType {
            case .pieChart:
                visState = Mapper<PieChartVisState>().map(JSONObject: visStateJson)
                
            case .tagCloud, .t4pTagcloud:
                visState = Mapper<TagCloudVisState>().map(JSONObject: visStateJson)

            case .tile:
                visState = Mapper<TileVisState>().map(JSONObject: visStateJson)

            case .metric:
                visState = Mapper<MetricVisState>().map(JSONObject: visStateJson)

            case .heatMap, .mapTracking:
                visState = Mapper<MapVisState>().map(JSONObject: visStateJson)

            case .neo4jGraph:
                visState = Mapper<GraphVisState>().map(JSONObject: visStateJson)

            case .html:
                visState = Mapper<WebContentVisState>().map(JSONObject: visStateJson)

            case .markdown:
                visState = Mapper<MarkDownVisState>().map(JSONObject: visStateJson)
            
            case .gauge, .goal:
                visState = Mapper<GaugeVisState>().map(JSONObject: visStateJson)
                
            default:
                visState <- map["visState"]
            }
        }
    }
    
    /**
     Loads chart data list.
     
     - parameter completion: Call back once the server returns the response.
     */
    func loadChartData(_ completion: CompletionBlock?) {
        // Load ChartData using id

        let urlString = UrlComponents.visualizationData

        let params: [String: Any]? = dataParams()
        
        DataManager.shared.loadData(urlString, methodType: .post, encoding: JSONEncoding.default, parameters: params) { [weak self] (result, error) in
            
            
            guard error == nil else {
                self?.resetDataSource()
                completion?(nil, error)
                return
            }
            
            guard let res = result as? [AnyHashable: Any?], let finalResult = res["result"], let parsedData = self?.parseData(finalResult) else {
                self?.resetDataSource()
                completion?(nil, error)
                return
            }
            completion?(parsedData, error)
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
        filtersDict["id"] = id
        
        var filtersArray:[[String: Any]?]  = []
        
        for appliedFilter in Session.shared.appliedFilters {
            var params: [String: Any] = appliedFilter.dataParams
            params["isFilterInverted"] = appliedFilter.isInverted
            filtersArray.append(params)
        }
                
        if filtersArray.count > 0 {
            filtersDict["filters"] = filtersArray
        }

        filtersDict["timeFrom"] = dashboardItem?.fromTime
        filtersDict["timeTo"] = dashboardItem?.toTime

        filtersDict["searchQueryPanel"] = searchQuery
        filtersDict["searchQueryDashboard"] = dashboardItem?.searchQuery
        
        // In case of date histogram send the interval
        if bucketType == .dateHistogram, let interval = mappedIntervalValue {
            filtersDict["interval"] = "\(interval)"
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
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let aggregationsDict = responseJson.first?["aggregations"] as? [String: Any] else {
                return []
        }
        
        parseBuckets(aggregationsDict)
        
        
        // Parse table headers for Tables
        if visState?.type == .table , let headersArray = responseJson.first?["tableHeaders"] as? [[String: Any]] {
            let idDictionary = headersArray.filter(( {($0["id"] as? String) == "2"} )).first
            tableHeaderLeft = idDictionary?["label"] as? String ?? ""
            let namdeDictionary = headersArray.filter(( {($0["id"] as? String) == "1"} )).first
            tableHeaderRight = namdeDictionary?["label"] as? String ?? ""
            
            //Sub Buckets Support
            var headers = [String]()
            for headerDict in headersArray {
                if let header = headerDict["label"] as? String {
                    headers.append(header)
                }
            }
            if headers.count > 1 {
                let metric = headers.remove(at: 0)
                headers.append(metric)
            }
            tableHeaders = headers
        }
        
        return [chartContentList]
    }
    
    
    func parseBuckets(_ aggregationsDict: [String: Any])  {
        
        guard let visState = visState,
            let id = visState.otherAggregationsArray.first?.id else { return }

        
        guard let contentDict = aggregationsDict[id] as? [String: Any] else { return }
        let parsedData = AggResult(contentDict, visState: visState, idx: 0, parentBucket: nil)
        self.parsedAggResult = parsedData
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
            return value + AggregationParams.IntervalType.yearly.rawValue
        }
        
        if let year = year, let month = month,
            year == 1 || month > 1 {
            return value + AggregationParams.IntervalType.monthly.rawValue
        }
        
        if let month = month,
            month <= 6 && month >= 1 {
            return value + AggregationParams.IntervalType.weekly.rawValue
        }
        
        if let week = week,
            week <= 5 && week >= 1 {
            return value + AggregationParams.IntervalType.daily.rawValue
        }
        
        if let days = days,
            days <= 7 && days >= 1 {
            value = "12"
            return value + AggregationParams.IntervalType.hourly.rawValue
        }
        
        if let hour = hour,
            hour <= 24 && hour > 1 {
            return value + AggregationParams.IntervalType.hourly.rawValue
        }
        
        if let hour = hour, let minutes = minutes,
            hour == 1 || (hour < 1 && minutes >= 10) {
            value = "5"
            return value + AggregationParams.IntervalType.minute.rawValue
        }
        
        if let minutes = minutes,
            minutes <= 10 && minutes > 0 {
            value = "10"
            return value + AggregationParams.IntervalType.second.rawValue
        }

        var millisecondsToAdd = 200
        if let seconds = seconds, seconds <= 0 {
            millisecondsToAdd   =   10
        }

        return "\(millisecondsToAdd)" + AggregationParams.IntervalType.millisecond.rawValue
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

class AggResult {
    
    var buckets: [Bucket]           =   []
    
//    private var internalIndex: Int  =   0
    //MARK: Functions
    init(_ dictionary: [String: Any], visState: VisState, idx: Int, parentBucket: Bucket?) {
        
        var bucketList: [[String: Any]] = []

        let currentAggs = visState.otherAggregationsArray[idx]
        if currentAggs.bucketType == .range {
            guard let bucketDictionary = dictionary["buckets"] as? [String: [String: Any]] else { return }
            for (key, var dict) in bucketDictionary {
                dict["key"] = key
                bucketList.append(dict)
            }
        } else {
            bucketList = dictionary["buckets"] as? [[String: Any]] ?? []
        }
        
        let index = idx + 1
        for bucketData in bucketList {
            var bucket: Bucket
            switch currentAggs.bucketType {
            case .range:
                bucket = RangeBucket(bucketData, visState: visState, index: index, parentBucket: parentBucket)
                bucket.bucketType = currentAggs.bucketType
            default:
                bucket = Bucket(bucketData, visState: visState, index: index, parentBucket: parentBucket, bucketType: currentAggs.bucketType)
            }
            buckets.append(bucket)
        }
        
        if currentAggs.bucketType == .range {
            buckets.sort(by: { ($0 as! RangeBucket).from < ($1 as! RangeBucket).from })
        }

    }
}

class Bucket {
    
    var key                     =   ""
    
    var docCount                =   0.0
    
    var bucketValue             =   0.0
    
    var metricValue             =   0.0

    var bucketType: BucketType  =   .unKnown
    var subAggsResult: AggResult?
        
    var displayValue: Double {
        let aggregationsCount = (visState?.otherAggregationsArray.count ?? 0)
        let metricType = visState?.metricAggregationsArray.first?.metricType ?? MetricType.unKnown
        let shouldShowBucketValue = (metricType == .sum || metricType == .max || metricType == .average)

        if aggregationsCount == 1 {
            return shouldShowBucketValue ? bucketValue : docCount
        } else {
            return metricType == .count ? docCount : metricValue
        }
    }
    
    var parentBkt: Bucket? {
        return parentBucket
    }
    
    private var parentBucket: Bucket?
    private var visState: VisState?
    
    //MARK: Functions
    init(_ dictionary: [String: Any], visState: VisState, index: Int, parentBucket: Bucket?, bucketType: BucketType) {
        
        docCount            =   dictionary["doc_count"] as? Double ?? 0.0
        bucketValue         =   dictionary["bucketValue"] as? Double ?? 0.0
        self.bucketType = bucketType
        self.visState = visState
        self.parentBucket = parentBucket
        
        switch bucketType {
            case .dateHistogram:
                if let dateKey = dictionary["key"] {
                    key = "\(dateKey)"
                }
            default:
                key = bucketValueAsString(dictionary)
        }
        
        
        if let firstMetricId = visState.metricAggregationsArray.first?.id,
            let dict = dictionary[firstMetricId] as? [String: Any] {
            metricValue         =   dict["value"] as? Double ?? 0.0
        }

        guard index < visState.otherAggregationsArray.count else {
            return
        }
        
        let id = visState.otherAggregationsArray[index].id
        guard let dict = dictionary[id] as? [String: Any] else { return }
        subAggsResult          =   AggResult(dict, visState: visState, idx: index, parentBucket: self)
    }
    
    func getRelatedfilters(_ selectedDateComponant: DateComponents?) -> [FilterProtocol] {

        var filtersList: [FilterProtocol] = []
        var outerBucket: Bucket? = self
        let othersAggs = visState?.otherAggregationsArray ?? []
        for otherAggs in othersAggs.reversed() {
            let val = outerBucket?.key ?? ""
            guard let bucket = outerBucket else { continue }
            var filter: FilterProtocol
            switch bucket.bucketType {
            case .dateHistogram:
                let interval = otherAggs.params?.interval ?? AggregationParams.IntervalType.unKnown
                let customInterval = otherAggs.params?.customInterval ?? ""
                filter = DateHistogramFilter(fieldName: otherAggs.field, fieldValue: val, type: otherAggs.bucketType, interval: interval, customInterval: customInterval, selectedComponants: selectedDateComponant)
            default:
                filter = SimpleFilter(fieldName: otherAggs.field, fieldValue: val, type: otherAggs.bucketType)
            }

            filtersList.append(filter)

            outerBucket = outerBucket?.parentBucket
        }
        return filtersList
    }
    
    func bucketValueAsString(_ dict: [String: Any]) -> String {
        
        guard let val = dict["key"] else {
            return ""
        }
        let keyAsString = dict["key_as_string"] as? String
        
        if let number = val as? NSNumber {
            if number.isNumberFractional {
                return String(format: "%0.2f", number.floatValue)
            } else if keyAsString == "false" || keyAsString == "true" {
                return keyAsString!
            } else {
                return number.stringValue
            }
        } else {
            return val as? String ?? ""
        }
    }
    
    static func ==(lhs: Bucket, rhs: Bucket) -> Bool {
        return lhs.key == rhs.key && lhs.docCount == rhs.docCount && lhs.bucketValue == rhs.bucketValue
    }

}

class RangeBucket: Bucket {
    var from: Double    =   0.0
    var to: Double      =   0.0
    
    override init(_ dictionary: [String : Any], visState: VisState, index: Int, parentBucket: Bucket?, bucketType: BucketType = .unKnown) {
        super.init(dictionary, visState: visState, index: index, parentBucket: parentBucket, bucketType: bucketType)
        
        from        =   dictionary["from"] as? Double ?? 0.0
        to          =   dictionary["to"] as? Double ?? 0.0
    }
    var stringValue: String {
        return "\(from) to \(to)"
    }
    
    static func ==(lhs: RangeBucket, rhs: RangeBucket) -> Bool {
        return lhs.key == rhs.key && lhs.to == rhs.to && lhs.from == rhs.from
    }

}

extension Bucket: BucketAggType {
    var bucketKey: String {
        return key
    }
    
    var aggType: BucketType {
        return bucketType
    }
    
    var parent: BucketAggType? {
        return parentBkt
    }
    
    
}

class ChartContent {
    var key: String             =   ""
    var bucketType: BucketType  =   .unKnown
    var docCount                =   0.0
    var bucketValue             =   0.0
    var items: [Bucket]      =   []
    
    var displayValue: String {
        if bucketType == .dateHistogram {
            guard let keyValue = Int(key) else { return key }
            let date = Date(milliseconds: keyValue)
            return date.toFormat("YYYY-MM-dd HH:mm:ss")
        }
        return key
    }
}

extension ChartContent: BucketAggType {
    var bucketKey: String {
        return key
    }
    
    var aggType: BucketType {
        return bucketType
    }
    
    var parent: BucketAggType? {
        return nil
    }
    
    
}


extension NSNumber {
    var isNumberFractional: Bool {
        let str = self.stringValue
        return (str.split(separator: ".").count > 1)
    }
}

extension Double {
    var isInteger: Bool {
        return floor(self) == self
    }
}

extension String {
    var isBool: Bool {
        return self == "false" || self == "true"
    }
}
