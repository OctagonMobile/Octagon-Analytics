//
//  Panel.swift
//  KibanaGo
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
    case faceTile       =   "t4p-face"
    case neo4jGraph     =   "t4p-neo4j-graph-graph"
    case html           =   "html"
    case line           =   "line"
    case horizontalBar  =   "horizontal_bar"
    case markdown       =   "markdown"
    case area           =   "area"
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
    var buckets: [ChartItem]            = []

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
        buckets.removeAll()
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
            
            var params: [String: Any]? = [:]
            
            if let filter = appliedFilter as? Filter {
                params = ["filterType": filter.type.rawValue,
                          "filterField": filter.fieldName]
                if let rangeItem = (filter.fieldValue as? RangeChartItem) {
                    params?["filterRangeFrom"] = rangeItem.from
                    params?["filterRangeTo"] = rangeItem.to
                } else if let termsItem = (filter.fieldValue as? TermsChartItem) {
                    params?["filterValue"] = termsItem.key
                } else if filter.type == .histogram {
                    //For Histogram use Range
                    let fVal = Int(filter.fieldValue.key) ?? 0
                    let interval = filter.interval ?? 0
                    params = ["filterType": "range",
                              "filterField": filter.fieldName,
                              "filterRangeFrom": "\(filter.fieldValue.key)",
                              "filterRangeTo": "\(fVal + interval)"]
                } else {
                    params?["filterValue"] = filter.fieldValue.key
                }
            }
            
            if let filter = appliedFilter as? ImageFilter {
                params = ["filterType": "terms",
                          "filterField": filter.fieldName,
                          "filterValue": filter.fieldValue]
            }
            
            if let filter = appliedFilter as? LocationFilter {
                params = ["filterType": filter.type.rawValue,
                          "filterField": filter.fieldName,
                          "filterValue": ["top_left": ["lat": filter.coordinateRectangle.topLeft.latitude, "lon": filter.coordinateRectangle.topLeft.longitude],
                    "top_right": ["lat": filter.coordinateRectangle.topRight.latitude, "lon": filter.coordinateRectangle.topRight.longitude],
                    "bottom_left": ["lat": filter.coordinateRectangle.bottomLeft.latitude, "lon": filter.coordinateRectangle.bottomLeft.longitude],
                    "bottom_right": ["lat": filter.coordinateRectangle.bottomRight.latitude, "lon": filter.coordinateRectangle.bottomRight.longitude]]
                ]
            }
            
            if let filter = appliedFilter as? MapFilter {
                params = ["filterType": "terms",
                          "filterField": filter.fieldName,
                          "filterValue": filter.fieldValue]
            }
            
            if let filter = appliedFilter as? SimpleFilter {
                params?["filterType"] = filter.bucketType.rawValue
                params?["filterField"] = filter.fieldName
                switch filter.bucketType {
                case .range:
                    let ranges: [String] = filter.fieldValue.components(separatedBy: "-")
                    params?["filterRangeFrom"] = ranges.first ?? ""
                    params?["filterRangeTo"] = ranges.last ?? ""
                default:
                    params?["filterValue"] = filter.fieldValue
                }
            }

            
            params?["isFilterInverted"] = appliedFilter.isInverted

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
            let aggregationsDict = responseJson.first?["aggregations"] as? [String: Any],
            let bucketsContent = aggregationsDict[AggregationId.bucket.rawValue] as? [String: Any] else {
                buckets.removeAll()
                return []
        }
        
        var bucketsArray: [[String: Any]] = []
        if bucketType == .range {
            bucketsArray.removeAll()
            let content = bucketsContent["buckets"] as? [String: [String: Any]] ?? [:]
            for (key, var item) in content {
                item["key"] = key
                bucketsArray.append(item)
            }
        } else {
            bucketsArray = bucketsContent["buckets"] as? [[String: Any]] ?? []
        }
        
        
        // Parse the response based on the bucket type
        switch bucketType {
        case .histogram:
            buckets = Mapper<ChartItem>().mapArray(JSONArray: bucketsArray)
        case .range:
            buckets = Mapper<RangeChartItem>().mapArray(JSONArray: bucketsArray)
            buckets.sort(by: { ($0 as! RangeChartItem).from < ($1 as! RangeChartItem).from })
        case .terms:
            buckets = Mapper<TermsChartItem>().mapArray(JSONArray: bucketsArray)
            if let termsBucket = buckets as? [TermsChartItem] {
               buckets = termsBucket.map { bucket -> TermsChartItem in
                    bucket.key = bucket.keyAsString
                    return bucket
                }
            }
            
        case .dateHistogram:
            buckets = Mapper<DateHistogramChartItem>().mapArray(JSONArray: bucketsArray)
        default:
            break
        }
        
        buckets = filterInvalidDataIfExist(buckets)
        
        // Parse table headers for Tables
        if visState?.type == .table , let headersArray = responseJson.first?["tableHeaders"] as? [[String: Any]] {
            let idDictionary = headersArray.filter(( {($0["id"] as? String) == "2"} )).first
            tableHeaderLeft = idDictionary?["label"] as? String ?? ""
            let namdeDictionary = headersArray.filter(( {($0["id"] as? String) == "1"} )).first
            tableHeaderRight = namdeDictionary?["label"] as? String ?? ""
        }
        
        return buckets
    }
    
    /**
     Filter invalid chart data.
     
     - parameter chartItems: Array of Chart data to be filtered.
     - returns : Array of filtered Chart data
     */
    private func filterInvalidDataIfExist(_ chartItems:[ChartItem]) -> [ChartItem] {
        return chartItems.filter( {
            if bucketType == .terms || bucketType == .dateHistogram  {
                let termsDate = ($0 as? TermsChartItem)?.termsDateString ?? ""
                return termsDate.isEmpty ? !$0.key.isEmpty : !termsDate.isEmpty
            } else {
                return !$0.key.isEmpty
            }
        } )
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
