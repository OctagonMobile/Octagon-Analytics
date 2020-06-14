//
//  VideoContent.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//
import ObjectMapper

class VideoContent {
    
    var configContent: VideoConfigContent?
    
    var date: Date?
    var entries: [VideoEntry]   =   []
    
    //MARK: Functions
    
    func updateContent(_ dict: [String: Any]) {
        guard let source = dict["_source"] as? [String: Any] else { return }

        if let timeFieldName = configContent?.timeField?.name,
            let dateString = source[timeFieldName] as? String {
            date = dateString.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        }

        var list: [[String: Any]] = []
        for field in configContent?.selectedFieldList ?? [] {
            let val = source[field.name] as? CGFloat ?? 0.0
            list.append(["title":field.name, "value": val])
        }

        entries = Mapper<VideoEntry>().mapArray(JSONArray: list)
    }
}

class VideoEntry: Mappable {
    
    var title: String       =   ""
    var value: CGFloat      =   0.0

    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title       <-  map["title"]
        value       <-  map["value"]
    }
}
