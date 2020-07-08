//
//  VideoContentLoader.swift
//  OctagonAnalytics
//
//  Created by Rameez on 09/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import ObjectMapper
import Alamofire
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
        let params: [String : Any] = ["type": "index-pattern",
                                      "per_page": Constant.pageSize]
        DataManager.shared.loadData(UrlComponents.savedObjects, parameters: params) { [weak self] (result, error) in
            guard error == nil else {
                self?.indexPattersList.removeAll()
                completion?(self?.indexPattersList, error)
                return
            }
            
            if let res = result as? [AnyHashable: Any?], let finalResult = res["result"] {
                self?.indexPattersList = self?.parseIndexPattersList(finalResult) ?? []
            }
            
            completion?(self?.indexPattersList, error)
        }
    }
    
    private func parseIndexPattersList(_ result: Any?) -> [IndexPattern] {
        guard let dict = result as? [String: Any?],
            let savedObjectsList = dict["saved_objects"] as? [[String: Any]] else {
            return []
        }
        
        let list = savedObjectsList.compactMap({ IndexPattern(JSON: $0) }).sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending})
        return list
    }
        
    func loadVideoData(_ completion: CompletionBlock?) {
        guard let indexPattern = configContent.indexPattern else { return }
        let queryParams: [String : String] =
            ["method": "POST",
             "path": "\(indexPattern.title)/_search"]

        DataManager.shared.loadData(UrlComponents.videoData, queryParametres: queryParams, parameters: generatedQuery()) { [weak self] (result, error) in
            guard error == nil else {
                completion?(nil, error)
                return
            }

            if let res = result as? [AnyHashable: Any?], let finalResult = res["result"] as? [AnyHashable: Any?],
                let hitsDictionary = finalResult["aggregations"] as? [AnyHashable: Any?],
                let hitsResult = hitsDictionary["dateHistogramName"] as? [String: Any],
                let buckets = hitsResult["buckets"] as? [[String: Any]] {

                self?.videoContentList = Mapper<VideoContent>().mapArray(JSONArray: buckets)
                
                completion?(self?.videoContentList, nil)
            }
        }
    }
    
    private func generatedQuery() -> [String: Any] {
        
        guard let fromDate = configContent.fromDate,
            let toDate = configContent.toDate,
            let timeFieldName = configContent.timeField?.name,
            let fieldName = configContent.field?.name,
            let spanType = configContent.spanType,
            let valueToDisplayFieldName = configContent.valueToDisplay?.name else { return [:] }
        
        let fromDateStr = queryDateFormatter.string(from: fromDate)
        let toDateStr = queryDateFormatter.string(from: toDate)

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
    var videoType: VideoType                 =   .barChartRace
    var indexPattern: IndexPattern?
    var timeField: IPField?
    var field: IPField?
    var valueToDisplay: IPField?
    var topMaxNumber: Int               =   5
    var spanType: SpanType?
    var fromDate: Date?
    var toDate: Date?
}
