//
//  VideoContentLoader.swift
//  OctagonAnalytics
//
//  Created by Rameez on 09/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import OctagonAnalyticsService
import SwiftDate

class VideoContentLoader {
    
    var configContent: VideoConfigContent       =   VideoConfigContent()
    
    var indexPattersList: [IndexPattern]        =   []
    
    var videoContentList: [VideoContent]        =   []
    
    private var queryDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZ"
        return formatter
    }
    
    //MARK: Functions
    func loadIndexPatters(_ completion: CompletionBlock?) {
        
        ServiceProvider.shared.loadIndexPatterns(1, pageSize: Constant.pageSize) { [weak self] (result, error) in
            guard error == nil else {
                self?.indexPattersList.removeAll()
                completion?(self?.indexPattersList, error?.asNSError)
                return
            }
            
            if let res = result as? IndexPatternsListResponse{
                self?.indexPattersList = res.indexPatterns.compactMap({ IndexPattern($0) }).sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending})
            }
            
            completion?(self?.indexPattersList, error?.asNSError)
        }
    }
            
    func loadVideoData(_ completion: CompletionBlock?) {
        guard let indexPattern = configContent.indexPattern else { return }

        ServiceProvider.shared.loadVideoContent(indexPattern.title, query: generatedQuery()) { [weak self] (result, error) in
            guard error == nil else {
                completion?(nil, error?.asNSError)
                return
            }
            
            if let res = result as? VideoContentListResponse {
                self?.videoContentList = res.buckets.compactMap({ VideoContent($0) })
            }
            completion?(self?.videoContentList, nil)
        }
    }
    
    private func generatedQuery() -> [String: Any] {
        
        guard let timeFieldName = configContent.timeField?.name,
            let fieldName = configContent.field?.name,
            let spanType = configContent.spanType,
            let valueToDisplayFieldName = configContent.valueToDisplay?.name else { return [:] }
        
        let fromDateStr = queryDateFormatter.string(from: configContent.fromDate)
        let toDateStr = queryDateFormatter.string(from: configContent.toDate)

        let query = [ "range":
            ["\(timeFieldName)": [ "gte": fromDateStr,"lte": toDateStr]]]

        
        let datHistogram = ["field":"\(timeFieldName)", "interval": "1\(spanType.code)"]
        
        let maxAggs = ["sum": ["field": valueToDisplayFieldName]]
        let sortAggs = ["bucket_sort": ["sort": [["max_field": ["order": "desc"]]], "size": configContent.topMaxNumber]]
        
        let innerMostAggs = ["max_field": maxAggs, "count_bucket_sort": sortAggs]
        let middleLevelAggs: [String : Any] = ["terms": ["field": fieldName, "size": 500], "aggs": innerMostAggs]
        let topMostAggs: [String : Any] = ["date_histogram": datHistogram, "aggs": ["aggs_Fields": middleLevelAggs]]
        
        return ["query": query, "size": 0, "aggs": ["dateHistogramName" : topMostAggs]]
    }
}

extension VideoContentLoader {
    struct UrlComponents {
        static let savedObjects = "saved_objects/_find"
        static let videoData    = "console/proxy"
    }
    
    struct Constant {
        static let pageSize = 10000
    }
}

///Used to store all the selected data from forms
class VideoConfigContent {
    var videoType: VideoType            =   .barChartRace
    var indexPattern: IndexPattern?
    var timeField: IPField?
    var field: IPField?
    var valueToDisplay: IPField?
    var topMaxNumber: Int               =   10
    var spanType: SpanType?
    var fromDate: Date                  =   Date().dateAtStartOf(.day)
    var toDate: Date                    =   Date().dateAtEndOf(.day)
}


public enum SpanType: String {
    case seconds    =   "Second"
    case minutes    =   "Minute"
    case hours      =   "Hour"
    case days       =   "Day"
    case weeks      =   "Week"
    case months     =   "Month"
    case years      =   "Year"

    var code: String {
        switch self {
        case .seconds:  return "s"
        case .minutes:  return "m"
        case .hours:    return "h"
        case .days:     return "d"
        case .weeks:    return "w"
        case .months:   return "M"
        case .years:    return "y"
        }
    }
    static var all: [SpanType]    =   [.seconds, .minutes, .hours, .days, .weeks, .months, .years]
    
    static func spanTypeListFor(_ fromDate: Date, toDate: Date) -> [SpanType] {
        let dateUnits = toDate.timeIntervalSince(fromDate).toUnits([.year, .month, .weekOfMonth, .day, .hour, .minute, .second])
        
        guard let year = dateUnits[.year], let month = dateUnits[.month],
            let week = dateUnits[.weekOfMonth], let day = dateUnits[.day] else { return all }
        
        if year >= 2 {
            return [years, .months,.weeks, .days, .hours, .minutes,.seconds]
        } else if year == 1 || month >= 2 {
            return [.months,.weeks, .days, .hours, .minutes,.seconds]
        } else if month == 1 || week >= 2 {
            return [.weeks, .days, .hours, .minutes,.seconds]
        } else if week == 1 || day >= 2 {
            return [.days, .hours, .minutes,.seconds]
        } else {
            return [.hours, .minutes,.seconds]
        }
    }
}
